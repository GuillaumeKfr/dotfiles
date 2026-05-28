#/ Open a worktree for the given branch in a new tmux window
#/ with nvim, opencode, and a shell (main-vertical layout).
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

    if not set -q TMUX
        echo "ot: must be run inside a tmux session" >&2
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

    set -l create_flag
    if not git -C $repo_path show-ref --verify --quiet refs/heads/$branch
        and not git -C $repo_path for-each-ref --format='%(refname:lstrip=3)' refs/remotes \
            | string match -q -- $branch
        read -P "ot: branch '$branch' does not exist. Create it? [y/N] " -l answer
        if not string match -qi 'y' -- $answer
            return 1
        end
        set create_flag --create
    end

    wt -C $repo_path switch --no-cd $create_flag $branch
    or return $status

    set -l wt_path (
        git -C $repo_path worktree list --porcelain \
        | awk -v b=refs/heads/$branch '/^worktree / {p=$2} $1=="branch" && $2==b {print p; exit}'
    )
    if test -z "$wt_path"
        echo "ot: could not locate worktree for $branch" >&2
        return 1
    end

    tmux new-window -n $branch -c $wt_path nvim \; \
        split-window -c $wt_path opencode \; \
        split-window -c $wt_path \; \
        select-layout main-vertical \; \
        select-pane -t 0
end
