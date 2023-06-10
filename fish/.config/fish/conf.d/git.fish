abbr --add g git

abbr --add ga git add
abbr --add gaa git add --all

abbr --add gc git commit -v -m
abbr --add gc! git commit -v --amend

abbr --add gaac "git add --all && git commit -v -m"

alias gb="git branch --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(contents:subject) %(color:green)(%(committerdate:relative)) [%(authorname)]' --sort=-committerdate"
abbr --add gs git status -sb

abbr --add gst git stash
abbr --add gsta git stash apply
abbr --add gstp git stash pop

abbr --add gco git checkout

abbr --add gd git diff

abbr --add gl git pull

alias glog="git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset'"

abbr --add gm git merge

abbr --add gp git push

abbr --add grb git rebase
abbr --add alias grba git rebase --abort
abbr --add grbc git rebase --continue
