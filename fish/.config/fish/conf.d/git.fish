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
