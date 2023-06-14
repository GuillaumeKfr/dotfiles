#! /bin/bash

SCRIPT_DIR="$( dirname -- "${BASH_SOURCE[0]}" )"

source "${SCRIPT_DIR}/_libs/logging.sh"
source "${SCRIPT_DIR}/_libs/steps.sh"

# Env
DOTFILES_DIR="$HOME"/dotfiles
ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
ZSH_PLUGINS_DIR="${ZSH_CUSTOM_DIR}/plugins"
ZSH_THEMES_DIR="${ZSH_CUSTOM_DIR}/themes"

APT_EXTRA_REPOS=()

APT_DEPS=(
    build-essential 
    libcairo2-dev 
    libdbus-glib-1-dev 
    libgirepository1.0-dev 
    libsystemd-dev 
    pkg-config 
    python3-pip
    ripgrep 
    stow
)

BREW_INSTALLS=(
    asdf
    bat
    exa
    fish
    fzf
    git-delta
    jq
    neovim
    shellcheck
    starship
    tldr
    tmux
    unzip
    zoxide
    zsh
)

PIP_INSTALLS=(
    black
    pip-review
    sqlfluff
)

STOW_DIRS=(
    fish
    fzf
    git
    nvim
    starship
    tmux
    zsh
)

steps::sys_setup ${APT_EXTRA_REPOS[@]}

steps::deps ${APT_DEPS[@]}

logging::info "== CLI == Installing tools"
brew install -q "${BREW_INSTALLS[@]}"

logging::info "== PIP == Installing tools"
pip install --quiet --upgrade "${PIP_INSTALLS[@]}"

logging::info "== PIP == Upgrade packages"
~/.local/bin/pip-review --auto --quiet

logging::info "== CFG == Stow configuration files"
pushd "${DOTFILES_DIR}" || exit
for dir in "${STOW_DIRS[@]}"; do
    logging::info "stow $dir"
    stow -D "${dir}"
    stow "${dir}"
done
popd || exit

logging::info "== ZSH == Install OMZ"
ZSH=~/.oh-my-zsh sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

logging::info "== ZSH == Install plugins"
mkdir -p "${ZSH_PLUGINS_DIR}"

rm -rf "${ZSH_PLUGINS_DIR}"/zsh-autosuggestions
rm -rf "${ZSH_PLUGINS_DIR}"/zsh-syntax-highlighting
rm -rf "${ZSH_PLUGINS_DIR}"/zsh-z
git clone --quiet "https://github.com/zsh-users/zsh-autosuggestions.git" "${ZSH_PLUGINS_DIR}"/zsh-autosuggestions
git clone --quiet "https://github.com/zsh-users/zsh-syntax-highlighting.git" "${ZSH_PLUGINS_DIR}"/zsh-syntax-highlighting
git clone --quiet "https://github.com/agkozak/zsh-z" "${ZSH_PLUGINS_DIR}"/zsh-z

logging::info "== Fish == Set as valid shell"
which fish | sudo tee -a /etc/shells > /dev/null

logging::info "== SSH == Create private key"
if [[ ! -d ~/.ssh ]]; then
    logging::info "== No existing config found. Generating key."
else
    logging::warn "SSH config already existing. Skipping section."
fi

logging::info "== User == Change shell"
shell_opts=(zsh fish)
select user_shell in "${shell_opts[@]}"; do
    if chsh -s "$(which "${user_shell}")"; then
        break
    fi
done

logging::success "Installation complete."
