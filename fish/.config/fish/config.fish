set -g fish_key_bindings fish_vi_key_bindings
set -gx XDG_CONFIG_HOME $HOME/.config
set -gx EDITOR nvim
set -gx VISUAL nvim

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
if test -f /etc/wsl.conf
    wsl.exe -u root -e mount --make-rshared /
end

# Homebrew
if test -d /opt/homebrew
    eval (/opt/homebrew/bin/brew shellenv)
else if test -d /home/linuxbrew/.linuxbrew
    eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)
end

# Interactive-only: tool initializations and env vars
if status is-interactive
    command -q direnv; and direnv hook fish | source
    command -q fzf; and fzf --fish | source
    command -q starship; and starship init fish | source
    command -q uv; and uv generate-shell-completion fish | source
    command -q zoxide; and zoxide init fish | source
end

# Certificates
if test -f $HOME/ca-bundle.pem
    set -gx PIP_CERT $HOME/ca-bundle.pem
    set -gx REQUESTS_CA_BUNDLE $HOME/ca-bundle.pem
    set -gx CURL_CA_BUNDLE $HOME/ca-bundle.pem
    set -gx SSL_CERT_FILE $HOME/ca-bundle.pem
    set -gx AWS_CA_BUNDLE $HOME/ca-bundle.pem
    set -gx NODE_EXTRA_CA_CERTS $HOME/ca-bundle.pem
end
