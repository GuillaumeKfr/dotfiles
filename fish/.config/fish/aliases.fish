abbr --add v nvim .
abbr --add py python3
abbr --add tf terraform
abbr --add calc bc -l
alias rm="rm -I --preserve-root"
abbr --add update "sudo apt update && sudo apt upgrade"
abbr --add ping ping -c 5

if test -n WSL_DISTRO_NAME
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

function bind_bang
    switch (commandline -t)[-1]
        case "!"
            commandline -t -- $history[1]
            commandline -f repaint
        case "*"
            commandline -i !
    end
end

function bind_dollar
    switch (commandline -t)[-1]
        case "!"
            commandline -f backward-delete-char history-token-search-backward
        case "*"
            commandline -i '$'
    end
end

function fish_user_key_bindings
    bind ! bind_bang
    bind '$' bind_dollar
end
