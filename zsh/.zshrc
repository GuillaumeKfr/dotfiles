# Homebrew
if [[ -d /opt/homebrew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -d /home/linuxbrew/.linuxbrew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi
export PATH="${HOMEBREW_PREFIX}/opt/openssl/bin:$PATH"

autoload -Uz compinit && compinit

# Starship
eval "$(starship init zsh)"

# ####### #
# Aliases #
# ####### #

# General purpose
alias v="nvim ."
alias py="python3"
alias tf="terraform"
alias calc="bc -l"
alias mkdir="mkdir -pv"
alias rm="rm -i"
update() {
    if [[ $OSTYPE == linux* ]]; then
        sudo apt update && sudo apt upgrade -y && sudo apt autoremove
    fi
    brew update && brew upgrade && brew cleanup
}
alias ping="ping -c 5"

if [[ -v WSL_DISTRO_NAME ]]; then
    function clip() {
        cat $1 | clip.exe
    }
fi

docker_aliases() {
    alias dk="docker"
    alias dkl="docker logs"
    alias dklf="docker logs -f"
    alias dki="docker images"
    alias dkc="docker container"
    alias dkrm="docker rm"

    alias dke="docker exec"
    dksh() {
        docker exec -it $1 /bin/sh
    }

    alias dkps="docker ps --format '{{.ID}} ~ {{.Names}} ~ {{.Status}} ~ {{.Image}}'"
    alias dktop="docker stats --format 'table {{.Container}}\t{{.Name}}\t{{.CPUPerc}}\t{{.MemPerc}}\t{{.NetIO}}\t{{.BlockIO}}'"
    dkstats() {
        if [[ $# -eq 0 ]]; then
            docker stats --no-stream
        else
            docker stats --no-stream | grep $1
        fi
    }

    alias dkprune="docker system prune -af"
}
# Docker
if [[ -x "$(command -v docker)" ]]; then
    docker_aliases
fi

# Git
git_aliases() {
    alias g="git"

    alias ga="git add"
    alias gaa="git add --all"

    alias gc="git commit -v -m"
    alias gc!="git commit -v --amend"

    alias gaac="gaa && gc"

    alias gb="git branch --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(contents:subject) %(color:green)(%(committerdate:relative)) [%(authorname)]' --sort=-committerdate"
    alias gs="git status -sb"

    alias gst="git stash"
    alias gsta="git stash apply"
    alias gstp="git stash pop"

    alias gco="git checkout"

    alias gd="git diff"

    alias gl="git pull"

    alias glog="git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset'"

    alias gm="git merge"

    alias gp="git push"

    alias grb="git rebase"
    alias grba="git rebase --abort"
    alias grbc="git rebase --continue"
}
git_aliases

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi

# Ported from fish config
bindkey -v
[[ -f ~/.config/shell/exports.sh ]] && source ~/.config/shell/exports.sh
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
