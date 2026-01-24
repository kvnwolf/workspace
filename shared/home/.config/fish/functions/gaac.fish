function gaac -d "Git add all and commit"
    git add --all && git commit --verbose -m $argv[1]
end