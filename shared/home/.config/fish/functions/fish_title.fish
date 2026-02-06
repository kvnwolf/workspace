function fish_title
    set -q argv[1]; and return
    string replace "$HOME/Developer/github.com/" "" (pwd) | string replace "$HOME" "~"
end
