if status is-interactive
    # Commands to run in interactive sessions can go here
end

set fish_greeting

fish_add_path ~/bin
fish_add_path ~/.local/bin

# Make / shared instead of private
wsl.exe -u root -e mount --make-rshared /

# Homebrew
set HOMEBREW_PREFIX "/home/linuxbrew/.linuxbrew"
eval ($HOMEBREW_PREFIX/bin/brew shellenv)

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
