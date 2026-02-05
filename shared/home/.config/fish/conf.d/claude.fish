set -gx CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS 1

function __claude_cmd
    set -l flags (string replace 'cl' '' $argv[1])
    set -l opts

    if string match -qr 'c' $flags
        set -a opts --continue
    else if string match -qr 'r' $flags
        set -a opts --resume
    end

    if string match -qr 's' $flags
        set -a opts --dangerously-skip-permissions
    end

    if string match -qr 'd' $flags
        set -a opts --debug
    end

    echo claude $opts
end

abbr --add cl --regex '^cl[cr]?s?d?$' --function __claude_cmd
