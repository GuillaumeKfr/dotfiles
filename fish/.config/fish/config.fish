if status is-interactive
    # Commands to run in interactive sessions can go here
end

set fish_greeting

fish_add_path ~/.local/bin

# Homebrew
set -gx HOMEBREW_PREFIX "/home/linuxbrew/.linuxbrew";
set -gx HOMEBREW_CELLAR "/home/linuxbrew/.linuxbrew/Cellar";
set -gx HOMEBREW_REPOSITORY "/home/linuxbrew/.linuxbrew/Homebrew";
set -q PATH; or set PATH ''; set -gx PATH "/home/linuxbrew/.linuxbrew/bin" "/home/linuxbrew/.linuxbrew/sbin" $PATH;
set -q MANPATH; or set MANPATH ''; set -gx MANPATH "/home/linuxbrew/.linuxbrew/share/man" $MANPATH;
set -q INFOPATH; or set INFOPATH ''; set -gx INFOPATH "/home/linuxbrew/.linuxbrew/share/info" $INFOPATH;

# ASDF
source /home/linuxbrew/.linuxbrew/opt/asdf/libexec/asdf.fish

# Starship
starship init fish | source

# Zoxide
zoxide init fish | source

# Aliases
source $HOME/.config/fish/aliases.fish
source $HOME/.config/fish/docker.fish
source $HOME/.config/fish/git.fish
