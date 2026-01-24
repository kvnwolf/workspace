function reload -d "Reload fish shell"
    set -gx FISH_RELOADED 1
    fish
end
