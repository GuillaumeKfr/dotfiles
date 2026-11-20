# Run from an `ot` window once its PR is merged: removes worktree, local branch and tmux window.
function cleanup
    set -l branch (git branch --show-current); or return
    if contains $branch main master
        echo "cleanup: run it from a feature worktree" >&2
        return 1
    end

    set -l state (gh pr view $branch --json state -q .state 2>/dev/null)
    if test "$state" != MERGED
        echo "cleanup: PR for $branch is '$state', not MERGED" >&2
        return 1
    end

    # -f: squash merges look unmerged to git (PR state verified above)
    workmux remove -f
end
