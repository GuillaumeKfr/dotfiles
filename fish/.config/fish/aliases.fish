abbr --add v nvim .
abbr --add py python3
abbr --add tf terraform
abbr --add calc bc -l
alias rm="rm -I --preserve-root"
abbr --add update "sudo apt update && sudo apt upgrade"
abbr --add ping ping -c 5

if test -n WSL_DISTRO_NAME
    function clip
        cat $argv | clip.exe
    end
end

if command -q eza
    alias ls="eza --group-directories-first --icons --git"

    alias ll="ls --long"
    alias la="ll --all"
    alias tree="ll --tree"
end

if command -q bat
    alias cat=bat
end

function mkdir -d "Create a directory and set CWD"
    command mkdir -pv $argv
    if test $status = 0
        switch $argv[(count $argv)]
            case '-*'

            case '*'
                cd $argv[(count $argv)]
                return
        end
    end
end
