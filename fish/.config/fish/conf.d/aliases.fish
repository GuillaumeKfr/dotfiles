abbr --add v nvim .
abbr --add py python3
abbr --add tf terraform
abbr --add calc bc -l
# abbr --add mkdir mkdir -pv
alias rm="rm -I --preserve-root"
abbr --add update "sudo apt update && sudo apt upgrade"
abbr --add ping ping -c 5

if test -n WSL_DISTRO_NAME
    function clip
        cat $argv | clip.exe
    end
end

if type -q exa
    alias ls="exa --group-directories-first --icons"
    alias ll="ls --long"
    alias la="ll --all"
    alias tree="ll --tree"
end

if type -q bat
    alias cat=bat
end

if type -q podman
    alias docker="podman"
end

if type -q zoxide
    alias z="zoxide"
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
