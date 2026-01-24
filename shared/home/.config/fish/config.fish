set fish_greeting

if set -q FISH_RELOADED
    set -e FISH_RELOADED
    clear
    echo "Config reloaded"
end
