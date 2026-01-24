function cpwd -d "Copy current directory to clipboard"
    pwd | pbc && echo "Copied: "(pwd)
end