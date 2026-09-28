complete -c ot -f
complete -c ot -s h -l help -d 'Display help'
complete -c ot -s C -d 'Repository path' -xa '(__fish_complete_directories)'
complete -c ot -s x -d 'Prompt to send to the agent'
# `complete -C"git "` forces fish to autoload git's completions/git.fish,
# which is where __fish_git_branches is defined - it isn't loaded otherwise.
complete -c ot -n '__fish_is_first_arg' -xa '(complete -C"git " >/dev/null 2>&1; __fish_git_branches)'
