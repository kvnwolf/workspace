function fish_title
    pwd | sed "s|/Users/$USER|~|" | sed "s|~/Developer/github.com/|github/|"
end
