#/ Open a git worktree for the given branch in a new tmux window via workmux
#/ (nvim main pane, claude agent pane, shell pane) - or send it a prompt instead.
#/
#/ Usage: ot [-C <repo-path>] [-x <prompt>] <branch>
#/   -C <path>   Treat <path> as the repository root. Defaults to `git rev-parse --show-toplevel`.
#/   -x <prompt> Send <prompt> to the agent instead of opening the default layout.
#/   -h/--help   Display this help.
function ot
    argparse h/help 'C=' 'x=' -- $argv
    or return 2

    if set -q _flag_help
        grep '^#/' (status filename) | string replace -r '^#/( |$)' ''
        return 0
    end

    if test (count $argv) -ne 1
        grep '^#/ Usage:' (status filename) | string replace -r '^#/ ' '' >&2
        return 2
    end
    set -l branch $argv[1]

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

    pushd $repo_path
    if set -ql _flag_x
        workmux add $branch --open-if-exists -p "$_flag_x"
    else
        workmux add $branch --open-if-exists
    end
    set -l ret $status
    popd
    return $ret
end
