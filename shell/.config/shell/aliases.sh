# Shared aliases, loaded by zsh (source) and fish (conf.d/aliases.fish).
# Keep to one `alias name="value"` per line. fish turns them into abbrs,
# except lines ending in "# noabbr", which become fish aliases.

alias v="nvim ."
alias py="python3"
alias tf="terraform"
alias calc="bc -l"
alias top="btop" # noabbr
alias rm="rm -i" # noabbr
alias ping="ping -c 5"
alias wm="workmux"
alias cl="claude --ide"

alias g="git"
alias ga="git add"
alias gaa="git add --all"
alias gc="git commit -v -m"
alias gc!="git commit -v --amend"
alias gaac="git add --all && git commit -v -m"
alias gb="git branch --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(contents:subject) %(color:green)(%(committerdate:relative)) [%(authorname)]' --sort=-committerdate" # noabbr
alias gs="git status -sb"
alias gst="git stash"
alias gsta="git stash apply"
alias gstp="git stash pop"
alias gco="git checkout"
alias gd="git diff"
alias gl="git pull"
alias gf="git fetch --all --prune --tags"
alias glog="git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset'" # noabbr
alias gm="git merge"
alias gp="git push"
alias grb="git rebase"
alias grba="git rebase --abort"
alias grbc="git rebase --continue"

alias dk="docker"
alias dkl="docker logs"
alias dklf="docker logs -f"
alias dki="docker images"
alias dkc="docker container"
alias dkrm="docker rm"
alias dke="docker exec"
alias dkps="docker ps --format '{{.ID}} ~ {{.Names}} ~ {{.Status}} ~ {{.Image}}'" # noabbr
alias dktop="docker stats --format 'table {{.Container}}\t{{.Name}}\t{{.CPUPerc}}\t{{.MemPerc}}\t{{.NetIO}}\t{{.BlockIO}}'" # noabbr
alias dkprune="docker system prune -af"
