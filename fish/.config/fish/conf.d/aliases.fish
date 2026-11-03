for line in (string match -r '^alias .*' < ~/.config/shell/aliases.sh)
    set -l m (string match -r '^alias ([^=]+)="(.*)"\s*(# noabbr)?$' -- $line); or continue
    if test -n "$m[4]"
        alias $m[2] $m[3]
    else
        abbr --add $m[2] -- $m[3]
    end
end

if test -n "$WSL_DISTRO_NAME"
    function clip
        cat $argv | clip.exe
    end
end

if command -q eza
    alias ls="eza --group-directories-first --icons --git"

    alias ll="ls --long"
    alias la="ll --all"
    alias tree="ll --tree"
end

if command -q bat
    alias cat="bat --style=plain"
end

function mkdir -d "Create a directory and set CWD"
    command mkdir -pv $argv
    if test $status = 0
        switch $argv[(count $argv)]
            case '-*'

            case '*'
                cd $argv[(count $argv)]
                return
        end
    end
end

if command -q npx
    alias ccusage="npx ccusage@latest"
end
