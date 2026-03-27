#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(dirname -- "${BASH_SOURCE[0]}")"

source "${SCRIPT_DIR}/_libs/logging.sh"
source "${SCRIPT_DIR}/_libs/steps.sh"

# Env
ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
ZSH_PLUGINS_DIR="${ZSH_CUSTOM_DIR}/plugins"

APT_EXTRA_REPOS=()

APT_DEPS=(
    build-essential
    ca-certificates
    curl
    libcairo2-dev
    libdbus-glib-1-dev
    libgirepository1.0-dev
    libsystemd-dev
    pkg-config
    python3-pip
    stow
    uidmap
)

APT_TO_REMOVE=(
    python3
    python3.10
    python3-minimal
    python3.10-minimal
)

BREW_INSTALLS=(
    bat
    black
    btop
    colima
    direnv
    docker
    eza
    fish
    fzf
    gh
    git-delta
    jq
    markdownlint-cli2
    neovim
    pre-commit
    python
    ripgrep
    shellcheck
    sqlfluff
    starship
    stow
    tlrc
    tmux
    unzip
    uv
    worktrunk
    yazi
    zoxide
    zsh
)

STOW_DIRS=(
    bat
    btop
    containers
    cursor
    fish
    fzf
    gh-dash
    git
    kitty
    nvim
    starship
    tmux
    zsh
)

if steps::is_sudo; then
    steps::sys_setup "${APT_EXTRA_REPOS[@]}"
    steps::deps "${APT_DEPS[@]}"
    steps::clean_preinstalled "${APT_TO_REMOVE[@]}"
else
    logging::warn "[install] Skipping sys_setup, deps, and clean_preinstalled (no sudo)"
fi

steps::brew_installs "${BREW_INSTALLS[@]}"

steps::setup_stow "${STOW_DIRS[@]}"

steps::custom_setup

steps::ssh_config

if steps::is_sudo; then
    steps::setup_shell
else
    logging::warn "[install] Skipping shell setup (requires sudo for chsh/etc/shells)"
fi

logging::success "Installation complete."
