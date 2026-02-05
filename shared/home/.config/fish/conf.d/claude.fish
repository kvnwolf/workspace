function __claude_cmd
    set -l input $argv[1]
    set -l opts

    if string match -qr 'c' $input
        set -a opts --continue
    else if string match -qr 'r' $input
        set -a opts --resume
    end

    if string match -qr 'd' $input
        set -a opts --debug
    end

    echo claude $opts
end

abbr --add cl --regex '^cl[cr]?d?$' --function __claude_cmd