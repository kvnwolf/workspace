function swarm -d "Attach to a Claude Code swarm tmux session"
    if test (count $argv) -eq 0
        echo "Usage: swarm <id>"
        return 1
    end
    tmux -L claude-swarm-$argv[1] a
end
