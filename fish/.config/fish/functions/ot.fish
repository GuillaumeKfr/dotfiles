#/ Open a worktree for the given branch in a new herdr tab
#/ with nvim, claude, and a shell (nvim main pane, claude+shell on the side).
#/
#/ Usage: ot [-C <repo-path>] <branch>
#/   -C <path>   Treat <path> as the repository root (like git -C / wt -C).
#/               Defaults to `git rev-parse --show-toplevel` in the current cwd.
#/   -h/--help   Display this help.
function ot
    argparse h/help 'C=' -- $argv
    or return 2

    if set -q _flag_help
        # Print the leading `#/`-prefixed header from this file as usage.
        grep '^#/' (status filename) | string replace -r '^#/( |$)' ''
        return 0
    end

    if test (count $argv) -ne 1
        grep '^#/ Usage:' (status filename) | string replace -r '^#/ ' '' >&2
        return 2
    end
    set -l branch $argv[1]

    if test "$HERDR_ENV" != 1
        echo "ot: must be run inside a herdr session" >&2
        return 1
    end

    set -l repo_path
    if set -ql _flag_C
        set repo_path $_flag_C
    else
        set repo_path (git rev-parse --show-toplevel 2>/dev/null)
        or begin
            echo "ot: not inside a git repository (and no -C given)" >&2
            return 1
        end
    end

    if not test -d $repo_path
        echo "ot: repo path does not exist: $repo_path" >&2
        return 1
    end

    git -C $repo_path fetch --quiet 2>/dev/null

    # A tab we opened earlier for this branch lives in the current workspace already.
    set -l existing_tab (herdr tab list --workspace $HERDR_WORKSPACE_ID | jq -r --arg b $branch '.result.tabs[] | select(.label == $b) | .tab_id')
    if test -n "$existing_tab"
        herdr tab focus $existing_tab >/dev/null
        return 0
    end

    set -l result (herdr worktree open --cwd $repo_path --branch $branch --no-focus 2>/dev/null)
    if test $status -ne 0
        set -l create_args --cwd $repo_path --branch $branch --no-focus
        if not git -C $repo_path show-ref --verify --quiet refs/heads/$branch
            # Branch doesn't exist locally yet: track a same-named remote branch if there is one.
            set -l remote_ref (git -C $repo_path for-each-ref --format='%(refname)' "refs/remotes/*/$branch")
            if test -n "$remote_ref"
                set create_args $create_args --base $remote_ref
            else
                read -P "ot: branch '$branch' does not exist. Create it? [y/N] " -l answer
                if not string match -qi 'y' -- $answer
                    return 1
                end
            end
        end
        set result (herdr worktree create $create_args)
        or return $status
    end

    set -l root_pane (echo $result | jq -r '.result.root_pane.pane_id')
    set -l wt_path (echo $result | jq -r '.result.worktree.path')
    if test -z "$root_pane" -o "$root_pane" = null
        echo "ot: could not locate worktree pane for $branch" >&2
        return 1
    end

    set -l moved (herdr pane move $root_pane --new-tab --workspace $HERDR_WORKSPACE_ID --label $branch --focus)
    or return $status
    set -l nvim_pane (echo $moved | jq -r '.result.move_result.pane.pane_id')

    herdr pane run $nvim_pane nvim >/dev/null
    set -l claude_pane (herdr pane split $nvim_pane --direction right --ratio 0.5 --cwd $wt_path --no-focus | jq -r '.result.pane.pane_id')
    herdr agent start claude --kind claude --pane $claude_pane >/dev/null
    herdr pane split $claude_pane --direction down --cwd $wt_path --no-focus >/dev/null
end
