if status is-interactive
    # Commands to run in interactive sessions can go here
end

set fish_greeting

function fish_greeting
    echo '
⠀⠀⠀⠀⣀⣀⣤⣤⣦⣶⢶⣶⣿⣿⣿⣿⣿⣿⣿⣷⣶⣶⡄
⠀⠀⠀⠀⣿⣿⣿⠿⣿⣿⣾⣿⣿⣿⣿⣿⣿⠟⠛⠛⢿⣿⡇
⠀⠀⠀⠀⣿⡟⠡⠂⠀⢹⣿⣿⣿⣿⣿⣿⡇⠘⠁⠀⠀⣿⡇⠀⢠⣄
⠀⠀⠀⠀⢸⣗⢴⣶⣷⣷⣿⣿⣿⣿⣿⣿⣷⣤⣤⣤⣴⣿⣗⣄⣼⣷⣶⡄
⠀⠀⠀⢀⣾⣿⡅⠐⣶⣦⣶⠀⢰⣶⣴⣦⣦⣶⠴⠀⢠⣿⣿⣿⣿⣼⣿⡇
⠀⠀⢀⣾⣿⣿⣷⣬⡛⠷⣿⣿⣿⣿⣿⣿⣿⠿⠿⣠⣿⣿⣿⣿⣿⠿⠛⠃
⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣶⣦⣭⣭⣥⣭⣵⣶⣿⣿⣿⣿⣟⠉
⠀⠀⠀⠙⠇⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟
⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣛⠛⠛⠛⠛⠛⢛⣿⣿⣿⣿⣿⡇
⠀⠀⠀⠀⠀⠿⣿⣿⣿⠿⠿⠀⠀⠀⠀⠀⠸⣿⣿⣿⣿⠿⠇'
end

fish_add_path ~/bin
fish_add_path ~/.local/bin

# WSL Config
if -f /etc/wsl.conf
    # Make / shared instead of private
    wsl.exe -u root -e mount --make-rshared /
end

# Linuxbrew
if -f /home/linuxbrew/.linuxbrew
    set HOMEBREW_PREFIX "/home/linuxbrew/.linuxbrew"
    eval ($HOMEBREW_PREFIX/bin/brew shellenv)
end

# direnv
direnv hook fish | source

# FZF
fzf --fish | source

# Starship
starship init fish | source

# uv
uv generate-shell-completion fish | source

# Zoxide
zoxide init fish | source

# Aliases
source $HOME/.config/fish/aliases.fish
source $HOME/.config/fish/docker.fish
source $HOME/.config/fish/git.fish

# Certificates
if test -f $HOME/ca-bundle.pem
    export PIP_CERT=$HOME/ca-bundle.pem
    export REQUESTS_CA_BUNDLE=$HOME/ca-bundle.pem
    export CURL_CA_BUNDLE=$HOME/ca-bundle.pem
    export SSL_CERT_FILE=$HOME/ca-bundle.pem
    export AWS_CA_BUNDLE=$HOME/ca-bundle.pem

    export NODE_EXTRA_CA_CERTS=$HOME/ca-bundle.pem
end
