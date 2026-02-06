function fork -d "Fork a GitHub repo and clone it to ~/Developer/github.com/<owner>/<repo>"
    if not set -q argv[1]
        echo "Usage: fork <owner/repo or GitHub URL>"
        return 1
    end

    set -l slug (string replace -r '^https?://github\.com/' '' $argv[1] | string replace -r '(\.git|/)$' '')

    if not string match -qr '^[^/]+/[^/]+$' $slug
        echo "fork: invalid format '$argv[1]' (expected owner/repo or GitHub URL)"
        return 1
    end

    set -l owner (string split '/' $slug)[1]
    set -l name (string split '/' $slug)[2]
    set -l parent "$HOME/Developer/github.com/$owner"

    if test -d "$parent/$name"
        echo "fork: directory already exists: $parent/$name"
        return 1
    end

    mkdir -p $parent

    set -l cwd $PWD
    builtin cd $parent

    gh repo fork $slug --clone
    or begin
        builtin cd $cwd
        return 1
    end

    builtin cd $name
    gh repo set-default $slug

    echo ""
    git remote -v
end
