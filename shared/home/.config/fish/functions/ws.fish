function ws -d "Run Claude in workspace directory (non-interactive)"
    set -l cwd $PWD
    builtin cd $WORKSPACE_SETUP_DIR
    set -l append_prompt "After completing the task, provide a brief summary of changes made."
    set -l stream_filter 'select(.type == "assistant").message.content[]? | select(.type == "text").text // empty | gsub("\n"; "\r\n") | . + "\r\n\n"'
    claude --dangerously-skip-permissions --output-format stream-json --verbose --append-system-prompt "$append_prompt" -p $argv \
        | command grep --line-buffered '^{' \
        | jq --unbuffered -rj "$stream_filter"
    builtin cd $cwd
end
