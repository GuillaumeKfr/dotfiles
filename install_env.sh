#! /bin/sh

DOTFILES_DIR="$HOME"/dotfiles
ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
ZSH_PLUGINS_DIR="${ZSH_CUSTOM_DIR}/plugins"
ZSH_THEMES_DIR="${ZSH_CUSTOM_DIR}/themes"

# Install and enable zsh
sudo apt update
sudo apt upgrade
sudo apt install -y zsh
chsh -s "$(which zsh)"

# Link zsh config
ln -sf "$DOTFILES_DIR"/zsh/zshrc "$HOME"/.zshrc
ln -sf "$DOTFILES_DIR"/zsh/p10k.zsh "$HOME"/.p10k.zsh

# Install oh-my-zsh and plugins
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

git clone "https://github.com/zsh-users/zsh-autosuggestions.git" "${ZSH_PLUGINS_DIR}"/zsh-autosuggestions
git clone "https://github.com/zsh-users/zsh-syntax-highlighting.git" "${ZSH_PLUGINS_DIR}"/zsh-syntax-highlighting
git clone "https://github.com/agkozak/zsh-z" "${ZSH_PLUGINS_DIR}"/zsh-z
git clone --depth=1 "https://github.com/romkatv/powerlevel10k.git" "${ZSH_THEMES_DIR}"/powerlevel10k

# Link oh-my-zsh config
ln -sf "$DOTFILES_DIR"/oh-my-zsh/alias.zsh "${ZSH_CUSTOM_DIR}"/alias.zsh

# Install TMUX

sudo apt install -y tmux

git clone "https://github.com/tmux-plugins/tpm" "$HOME"/.tmux/plugins/tpm

# Link tmux config
ln -sf "$DOTFILES_DIR"/tmux/tmux.conf "$HOME"/.tmux.conf