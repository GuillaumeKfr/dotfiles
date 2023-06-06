alias v="nvim ."
alias py="python3"
alias tf="terraform"
alias calc="bc -l"
alias mkdir="mkdir -pv"
alias rm="rm -I --preserve-root"
alias update="sudo apt update && sudo apt upgrade"
alias ping="ping -c 5"

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

if type -q batcat
    alias cat=batcat
end

if type -q podman
    alias docker="podman"
end

