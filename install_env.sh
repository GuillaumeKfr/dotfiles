#! /bin/bash

# Env
DOTFILES_DIR="$HOME"/dotfiles
ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
ZSH_PLUGINS_DIR="${ZSH_CUSTOM_DIR}/plugins"
ZSH_THEMES_DIR="${ZSH_CUSTOM_DIR}/themes"

CLIP_DEPS=(
    build-essential 
    libcairo2-dev 
    libdbus-glib-1-dev 
    libfuse2 
    libgirepository1.0-dev 
    libsystemd-dev 
    pkg-config 
    python3-pip
    ripgrep 
    stow
    unzip 
)

CLI_TOOLS=(
    exa
    jq
    shellcheck
    tmux
    unzip
    zsh
)

PIP_DEPS=(
    pip-review
)

PIP_TOOLS=(
    black
    sqlfluff
)

STOW_DIRS=(
    nvim
    zsh
)

echo "== SYS == Upgrade packages"
sudo apt update && apt upgrade -y

echo "== CLI == Installing dependencies"
sudo apt install -y "${CLIP_DEPS[@]}"

echo "== CLI == Installing tools"
sudo apt install -y "${CLI_TOOLS[@]}"

echo "== PIP == Installing dependencies"
pip install --upgrade "${PIP_DEPS[@]}"

echo "== PIP == Upgrade packages"
pip-review --auto

echo "== PIP == Installing tools"
pip install --upgrade "${PIP_TOOLS[@]}"

echo "== CFG == Stow configuration files"
pushd "${DOTFILES_DIR}" || exit
for dir in "${STOW_DIRS[@]}"; do
    echo "stow $dir"
    stow -D "${dir}"
    stow "${dir}"
done
popd || exit

echo "== ZSH == Install OMZ"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

echo "== ZSH == Install plugins"
mkdir -p "${ZSH_PLUGINS_DIR}"

git clone "https://github.com/zsh-users/zsh-autosuggestions.git" "${ZSH_PLUGINS_DIR}"/zsh-autosuggestions
git clone "https://github.com/zsh-users/zsh-syntax-highlighting.git" "${ZSH_PLUGINS_DIR}"/zsh-syntax-highlighting
git clone "https://github.com/agkozak/zsh-z" "${ZSH_PLUGINS_DIR}"/zsh-z
git clone --depth=1 "https://github.com/romkatv/powerlevel10k.git" "${ZSH_THEMES_DIR}"/powerlevel10k

echo "== Change shell"
chsh -s "$(which zsh)"

echo "== VIM == Install NeoVim"
curl -LO https://github.com/neovim/neovim/releases/download/stable/nvim.appimage
chmod u+x nvim.appimage
sudo mv nvim.appimage /usr/local/bin/nvim


