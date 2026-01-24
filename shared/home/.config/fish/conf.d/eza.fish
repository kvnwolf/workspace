function __eza_list
    set -l input $argv[1]
    set -l opts --icons --group-directories-first

    if string match -qr 't' $input
        set -a opts --tree
        if set -l num (string match -r '[0-9]+' $input)
            set -a opts --level=$num
        else
            set -a opts --level=1
        end
    end

    if string match -qr 'a' $input
        set -a opts --all
    end

    if string match -qr 'f' $input
        set -a opts --long --header
    else
        set -a opts --no-permissions --no-filesize --no-user --no-time --long
    end

    echo eza $opts
end

abbr --add l --regex '^l[taf]*[0-9]*$' --function __eza_list