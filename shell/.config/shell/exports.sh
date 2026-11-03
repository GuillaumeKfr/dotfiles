# Shared env vars, POSIX syntax. zsh sources it; fish imports it via `envimport`.
export XDG_CONFIG_HOME="$HOME/.config"
export EDITOR=nvim
export VISUAL=nvim
export CLAUDE_CODE_SUBAGENT_MODEL=haiku
export HOMEBREW_CASK_OPTS="--appdir=$HOME/Applications"

if [ -f "$HOME/ca-bundle.pem" ]; then
    for v in PIP_CERT REQUESTS_CA_BUNDLE CURL_CA_BUNDLE SSL_CERT_FILE AWS_CA_BUNDLE NODE_EXTRA_CA_CERTS; do
        export "$v=$HOME/ca-bundle.pem"
    done
fi

# Catppuccin Mocha
export FZF_DEFAULT_OPTS="\
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#cba6f7 \
--color=fg:#cdd6f4,header:#cdd6f4,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#cba6f7 \
--color=selected-bg:#45475a \
--color=border:#313244,label:#cdd6f4"
export BAT_THEME="Catppuccin Mocha"

# `|| true` keeps the file's exit status 0, which envimport needs
if [ -f /etc/wsl.conf ]; then
    wsl.exe -u root -e mount --make-rshared / || true
fi
