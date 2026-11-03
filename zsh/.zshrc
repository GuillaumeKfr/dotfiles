# Homebrew
if [[ -d /opt/homebrew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -d /home/linuxbrew/.linuxbrew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

autoload -Uz compinit && compinit

# Starship
eval "$(starship init zsh)"

# ####### #
# Aliases #
# ####### #

# General purpose
alias mkdir="mkdir -pv"
update() {
    if [[ $OSTYPE == linux* ]]; then
        sudo apt update && sudo apt upgrade -y && sudo apt autoremove
    fi
    brew update && brew upgrade && brew cleanup
}

if [[ -v WSL_DISTRO_NAME ]]; then
    function clip() {
        cat $1 | clip.exe
    }
fi

dksh() {
    docker exec -it $1 /bin/sh
}
dkstats() {
    if [[ $# -eq 0 ]]; then
        docker stats --no-stream
    else
        docker stats --no-stream | grep $1
    fi
}

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi

# Ported from fish config
bindkey -v
[[ -f ~/.config/shell/exports.sh ]] && source ~/.config/shell/exports.sh
[[ -f ~/.config/shell/aliases.sh ]] && source ~/.config/shell/aliases.sh
export PATH=$HOME/.local/bin:$PATH

if (( $+commands[eza] )); then
    alias ls="eza --group-directories-first --icons --git"
    alias ll="ls --long"
    alias la="ll --all"
    alias tree="ll --tree"
fi
(( $+commands[bat] )) && alias cat="bat --style=plain"

(( $+commands[direnv] )) && eval "$(direnv hook zsh)"
(( $+commands[fzf] )) && source <(fzf --zsh)
(( $+commands[uv] )) && eval "$(uv generate-shell-completion zsh)"
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"

# Plugins from brew; syntax-highlighting must be sourced last
for p in zsh-autosuggestions zsh-syntax-highlighting; do
    for d in /opt/homebrew /home/linuxbrew/.linuxbrew; do
        [[ -f $d/share/$p/$p.zsh ]] && { source $d/share/$p/$p.zsh; break; }
    done
done
