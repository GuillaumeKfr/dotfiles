# Complete branch names and flags for `ot`
# Local branches as-is; remote branches with the remote prefix stripped
# (so completing a remote-only branch lets `wt switch` create a local tracking branch).
complete -c ot -f -a '(
    git for-each-ref --format="%(refname:short)" refs/heads 2>/dev/null;
    git for-each-ref --format="%(refname:lstrip=3)" refs/remotes 2>/dev/null \
        | string match -v HEAD
)'
complete -c ot -s C -r -d 'Repository path (like git -C)'
