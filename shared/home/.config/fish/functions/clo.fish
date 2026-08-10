function __clo_proxy_is_ready
    set -l response (command curl --silent --fail --max-time 1 http://127.0.0.1:18765/healthz 2>/dev/null)
    test "$response" = '{"ok":true}'
end

function __clo_proxy_port_is_occupied
    command nc -z -w 1 127.0.0.1 18765 >/dev/null 2>&1
end

function __clo_directory_is_owned --argument-names directory
    test -L "$directory"
    and return 1

    test -d "$directory"
    or return 1

    set -l directory_uid (command stat -f '%u' "$directory" 2>/dev/null)
    or set directory_uid (command stat -c '%u' "$directory" 2>/dev/null)
    or return 1

    test "$directory_uid" = (command id -u)
end

function __clo_directory_is_private --argument-names directory
    __clo_directory_is_owned "$directory"
    or return 1

    set -l directory_mode (command stat -f '%OLp' "$directory" 2>/dev/null)
    or set directory_mode (command stat -c '%a' "$directory" 2>/dev/null)
    or return 1

    test "$directory_mode" = 0700; or test "$directory_mode" = 700
    or return 1

    if test (command uname) = Darwin
        command ls -lde "$directory" 2>/dev/null | string match --quiet --regex '^[[:space:]]*[0-9]+:'
        and return 1
    end

    return 0
end

function __clo_protect_directory --argument-names directory
    __clo_directory_is_owned "$directory"
    or return 1

    if test (command uname) = Darwin
        command chmod -N "$directory"
        or return 1
    end

    command chmod 700 "$directory"
    and __clo_directory_is_private "$directory"
end

function __clo_file_is_owned_regular --argument-names file
    test -L "$file"
    and return 1

    test -f "$file"
    or return 1

    set -l file_uid (command stat -f '%u' "$file" 2>/dev/null)
    or set file_uid (command stat -c '%u' "$file" 2>/dev/null)
    or return 1

    test "$file_uid" = (command id -u)
end

function __clo_prepare_state_directory --argument-names state_dir sessions_dir
    if not command mkdir -p -m 700 "$state_dir"
        echo "clo: no se pudo crear el directorio de estado $state_dir" >&2
        return 1
    end

    if not __clo_directory_is_owned "$state_dir"
        echo "clo: el directorio de estado debe ser un directorio del usuario actual (no un symlink)" >&2
        return 1
    end

    if not __clo_protect_directory "$state_dir"
        echo "clo: no se pudieron proteger los permisos del directorio de estado" >&2
        return 1
    end

    if not command mkdir -m 700 "$sessions_dir"; and not __clo_directory_is_owned "$sessions_dir"
        echo "clo: no se pudo crear el directorio de sesiones privado" >&2
        return 1
    end

    if not __clo_directory_is_owned "$sessions_dir"
        echo "clo: el directorio de sesiones debe ser un directorio del usuario actual (no un symlink)" >&2
        return 1
    end

    if not __clo_protect_directory "$sessions_dir"
        echo "clo: no se pudieron proteger los permisos del directorio de sesiones" >&2
        return 1
    end
end

function __clo_proxy_pid_is_live --argument-names proxy_pid
    string match --quiet --regex '^[0-9]+$' -- "$proxy_pid"
    and kill -0 $proxy_pid 2>/dev/null
    or return 1

    set -l process_uid (command ps -p $proxy_pid -o uid= 2>/dev/null | string trim)
    test "$process_uid" = (command id -u)
    or return 1

    set -l command_line (command ps -p $proxy_pid -o command= 2>/dev/null)
    string match --quiet --regex '(^|[/[:space:]])claude-code-proxy([[:space:]]|$)' -- "$command_line"
end

function __clo_proxy_owns_listener --argument-names proxy_pid
    __clo_proxy_pid_is_live "$proxy_pid"
    and command lsof -nP -a -p "$proxy_pid" -iTCP@127.0.0.1:18765 -sTCP:LISTEN >/dev/null 2>&1
end

function __clo_session_pid_is_live --argument-names session_pid
    string match --quiet --regex '^[0-9]+$' -- "$session_pid"
    and kill -0 $session_pid 2>/dev/null
    or return 1

    set -l command_line (command ps -p $session_pid -o command= 2>/dev/null)
    string match --quiet --regex '(^|[/[:space:]])claude([/[:space:]]|$)|claude-code' -- "$command_line"
end

function __clo_acquire_lock --argument-names lock_dir
    set -l attempts 0

    while not command mkdir -m 700 "$lock_dir" 2>/dev/null
        if not __clo_directory_is_owned "$lock_dir"
            echo "clo: el lock de sesiones no es un directorio privado del usuario actual" >&2
            return 1
        end

        if not __clo_protect_directory "$lock_dir"
            echo "clo: no se pudieron proteger los permisos del lock de sesiones" >&2
            return 1
        end

        if test -f "$lock_dir/owner"
            set -l owner_pid (string trim <"$lock_dir/owner")
            if test "$owner_pid" = "$fish_pid"; or not kill -0 $owner_pid 2>/dev/null
                command rm -f "$lock_dir/owner"
                command rmdir "$lock_dir" 2>/dev/null
                and continue
            end
        else if test $attempts -ge 10
            command rmdir "$lock_dir" 2>/dev/null
            and continue
        end

        set attempts (math $attempts + 1)
        if test $attempts -ge 100
            echo "clo: no se pudo adquirir el lock de sesiones" >&2
            return 1
        end

        command sleep 0.05
    end

    if not __clo_directory_is_owned "$lock_dir"
        echo "clo: el lock de sesiones no es un directorio privado del usuario actual" >&2
        return 1
    end

    if not command chmod 700 "$lock_dir"
        echo "clo: no se pudieron proteger los permisos del lock de sesiones" >&2
        return 1
    end

    if not printf '%s\n' $fish_pid >"$lock_dir/owner"
        command rmdir "$lock_dir" 2>/dev/null
        echo "clo: no se pudo registrar el propietario del lock de sesiones" >&2
        return 1
    end
end

function __clo_release_lock --argument-names lock_dir
    command rm -f "$lock_dir/owner"
    command rmdir "$lock_dir" 2>/dev/null
end

function __clo_prune_sessions --argument-names sessions_dir
    for marker in "$sessions_dir"/*
        set -l session_pid (string trim <"$marker")
        if not __clo_session_pid_is_live "$session_pid"
            command rm -f "$marker"
        end
    end
end

function __clo_cleanup --argument-names state_dir marker proxy_pid
    set -l lock_dir "$state_dir/lock"
    set -l sessions_dir "$state_dir/sessions"
    set -l proxy_pid_file "$state_dir/proxy.pid"

    __clo_acquire_lock "$lock_dir"
    or return 1

    if not test -f "$marker"
        __clo_release_lock "$lock_dir"
        return 0
    end

    command rm -f "$marker"
    __clo_prune_sessions "$sessions_dir"

    set -l active_sessions (count "$sessions_dir"/*)
    set -l current_proxy_pid
    if test -f "$proxy_pid_file"
        set current_proxy_pid (string trim <"$proxy_pid_file")
    end

    if test $active_sessions -eq 0; and test "$current_proxy_pid" = "$proxy_pid"
        if __clo_proxy_pid_is_live "$proxy_pid"
            echo "clo: última sesión cerrada; apagando claude-code-proxy."
            command kill $proxy_pid 2>/dev/null

            for attempt in (seq 1 20)
                kill -0 $proxy_pid 2>/dev/null
                or break
                command sleep 0.1
            end
        end

        if kill -0 $proxy_pid 2>/dev/null
            echo "clo: el proxy no se detuvo; revisa el PID $proxy_pid" >&2
        else
            command rm -f "$proxy_pid_file"
        end
    end

    __clo_release_lock "$lock_dir"
end

function clo --description "Run Claude Code with OpenAI and manage its local proxy" --wraps claude
    if not command -q claude-code-proxy
        echo "clo: claude-code-proxy no está instalado" >&2
        return 127
    end

    if not command -q claude
        echo "clo: Claude Code no está instalado" >&2
        return 127
    end

    if not claude-code-proxy codex auth status >/dev/null 2>&1
        echo "clo: autentícate primero con 'claude-code-proxy codex auth login'" >&2
        return 1
    end

    set -l runtime_root
    if set -q XDG_RUNTIME_DIR
        set runtime_root $XDG_RUNTIME_DIR
    else if set -q TMPDIR
        set runtime_root $TMPDIR
    else
        set runtime_root "/tmp/clo-"(command id -u)
    end

    set -l state_dir "$runtime_root/claude-code-proxy-clo"
    set -l sessions_dir "$state_dir/sessions"
    set -l lock_dir "$state_dir/lock"
    set -l proxy_pid_file "$state_dir/proxy.pid"
    set -l daemon_log "$state_dir/daemon.log"

    set -l previous_umask (umask)
    umask 077

    __clo_prepare_state_directory "$state_dir" "$sessions_dir"
    or begin
        umask "$previous_umask"
        return 1
    end

    __clo_acquire_lock "$lock_dir"
    or begin
        umask "$previous_umask"
        return 1
    end

    __clo_prune_sessions "$sessions_dir"

    if test -L "$proxy_pid_file"
        echo "clo: el archivo PID del proxy no es un archivo regular privado" >&2
        __clo_release_lock "$lock_dir"
        umask "$previous_umask"
        return 1
    end

    if test -e "$proxy_pid_file"; and not test -f "$proxy_pid_file"
        echo "clo: el archivo PID del proxy no es un archivo regular privado" >&2
        __clo_release_lock "$lock_dir"
        umask "$previous_umask"
        return 1
    end

    set -l proxy_pid
    if test -f "$proxy_pid_file"
        if not command chmod 600 "$proxy_pid_file"
            echo "clo: no se pudieron proteger los permisos del archivo PID del proxy" >&2
            __clo_release_lock "$lock_dir"
            umask "$previous_umask"
            return 1
        end

        set proxy_pid (string trim <"$proxy_pid_file")
        if not __clo_proxy_pid_is_live "$proxy_pid"
            command rm -f "$proxy_pid_file"
            set -e proxy_pid
        end
    end

    if __clo_proxy_port_is_occupied
        if test -z "$proxy_pid"
            echo "clo: el listener en 127.0.0.1:18765 no está administrado por clo; abortando." >&2
            __clo_release_lock "$lock_dir"
            umask "$previous_umask"
            return 1
        end

        if not __clo_proxy_owns_listener "$proxy_pid"
            echo "clo: el listener en 127.0.0.1:18765 no corresponde al proxy administrado (PID $proxy_pid); abortando." >&2
            __clo_release_lock "$lock_dir"
            umask "$previous_umask"
            return 1
        end

        if not __clo_proxy_is_ready
            echo "clo: el proxy administrado (PID $proxy_pid) no responde correctamente" >&2
            __clo_release_lock "$lock_dir"
            umask "$previous_umask"
            return 1
        end
    else
        if test -n "$proxy_pid"
            echo "clo: el proxy administrado (PID $proxy_pid) no responde" >&2
            __clo_release_lock "$lock_dir"
            umask "$previous_umask"
            return 1
        end

        if test -L "$daemon_log"
            echo "clo: el registro del proxy debe ser un archivo regular del usuario actual (no un symlink)" >&2
            __clo_release_lock "$lock_dir"
            umask "$previous_umask"
            return 1
        end

        if test -e "$daemon_log"; and not __clo_file_is_owned_regular "$daemon_log"
            echo "clo: el registro del proxy debe ser un archivo regular del usuario actual (no un symlink)" >&2
            __clo_release_lock "$lock_dir"
            umask "$previous_umask"
            return 1
        end

        if not command touch "$daemon_log"
            echo "clo: no se pudo preparar el registro del proxy" >&2
            __clo_release_lock "$lock_dir"
            umask "$previous_umask"
            return 1
        end

        if not __clo_file_is_owned_regular "$daemon_log"; or not command chmod 600 "$daemon_log"
            echo "clo: no se pudo proteger el registro del proxy" >&2
            __clo_release_lock "$lock_dir"
            umask "$previous_umask"
            return 1
        end

        echo "clo: iniciando claude-code-proxy..."
        claude-code-proxy serve --no-monitor >"$daemon_log" 2>&1 &
        set proxy_pid $last_pid
        disown $proxy_pid
        if not printf '%s\n' $proxy_pid >"$proxy_pid_file"
            command kill $proxy_pid 2>/dev/null
            __clo_release_lock "$lock_dir"
            umask "$previous_umask"
            echo "clo: no se pudo guardar el PID del proxy" >&2
            return 1
        end

        set -l proxy_started 0
        for attempt in (seq 1 50)
            if __clo_proxy_is_ready; and __clo_proxy_owns_listener "$proxy_pid"
                set proxy_started 1
                break
            end

            kill -0 $proxy_pid 2>/dev/null
            or break
            command sleep 0.1
        end

        if test $proxy_started -eq 0
            command kill $proxy_pid 2>/dev/null
            command rm -f "$proxy_pid_file"
            __clo_release_lock "$lock_dir"
            umask "$previous_umask"
            echo "clo: no se pudo iniciar el proxy; revisa $daemon_log" >&2
            return 1
        end
    end

    set -lx ANTHROPIC_BASE_URL http://127.0.0.1:18765
    set -lx ANTHROPIC_AUTH_TOKEN unused
    set -lx ANTHROPIC_MODEL 'gpt-5.6-sol[1m]'
    set -lx ANTHROPIC_SMALL_FAST_MODEL 'gpt-5.6-luna[1m]'
    set -lx CLAUDE_CODE_AUTO_COMPACT_WINDOW 900000
    set -lx CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC 1
    set -lx CLAUDE_CODE_DISABLE_NONSTREAMING_FALLBACK 1

    command claude $argv &
    set -l claude_pid $last_pid
    set -l marker "$sessions_dir/$claude_pid"
    if not printf '%s\n' $claude_pid >"$marker"
        command kill $claude_pid 2>/dev/null
        __clo_release_lock "$lock_dir"
        umask "$previous_umask"
        echo "clo: no se pudo registrar la sesión de Claude" >&2
        return 1
    end
    __clo_release_lock "$lock_dir"
    umask "$previous_umask"

    set -l clo_state_dir $state_dir
    set -l clo_marker $marker
    set -l clo_proxy_pid $proxy_pid
    set -l clo_job_handler "__clo_job_exit_$claude_pid"
    set -l clo_shell_handler "__clo_shell_exit_$claude_pid"

    function $clo_job_handler --on-job-exit $claude_pid \
        --inherit-variable clo_state_dir \
        --inherit-variable clo_marker \
        --inherit-variable clo_proxy_pid \
        --inherit-variable clo_job_handler \
        --inherit-variable clo_shell_handler
        __clo_cleanup "$clo_state_dir" "$clo_marker" "$clo_proxy_pid"
        functions --erase $clo_job_handler $clo_shell_handler
    end

    function $clo_shell_handler --on-process-exit %self \
        --inherit-variable clo_state_dir \
        --inherit-variable clo_marker \
        --inherit-variable clo_proxy_pid
        __clo_cleanup "$clo_state_dir" "$clo_marker" "$clo_proxy_pid"
    end

    if status is-interactive
        fg $claude_pid 2>/dev/null
    else
        wait $claude_pid
    end
    set -l claude_status $status

    __clo_cleanup "$state_dir" "$marker" "$proxy_pid"
    functions --erase $clo_job_handler $clo_shell_handler

    return $claude_status
end
