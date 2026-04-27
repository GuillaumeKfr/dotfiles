#!/bin/bash

#/ Install and configure the development environment.
#/
#/ Usage: install_env.sh [command]
#/
#/ Commands:
#/   all           Run full installation (default)
#/   system        OS-specific package setup + Homebrew install
#/   brew          Install packages from Brewfile
#/   stow          Symlink configuration files
#/   post-install  Run post-install setup (bat cache, worktrunk)
#/   shell         Configure default shell (requires sudo)
#/   help          Show this help message

set -euo pipefail

SCRIPT_DIR="$(dirname -- "${BASH_SOURCE[0]}")"

source "${SCRIPT_DIR}/_libs/logging.sh"
source "${SCRIPT_DIR}/_libs/config.sh"
source "${SCRIPT_DIR}/_libs/steps.sh"

# --- OS detection ---

detect_os() {
    case "$(uname -s)" in
        Darwin) echo "macos" ;;
        Linux)
            if [[ "$(command -v apt)" ]]; then
                echo "debian"
            elif [[ "$(command -v dnf)" ]]; then
                echo "fedora"
            else
                echo "unknown"
            fi
            ;;
        *) echo "unknown" ;;
    esac
}

OS="$(detect_os)"

ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
ZSH_PLUGINS_DIR="${ZSH_CUSTOM_DIR}/plugins"

CONF="${SCRIPT_DIR}/install.conf"

STOW_DIRS=()
while IFS= read -r line; do STOW_DIRS+=("$line"); done < <(config::read_section "$CONF" "stow")

APT_EXTRA_REPOS=()
while IFS= read -r line; do APT_EXTRA_REPOS+=("$line"); done < <(config::read_section "$CONF" "apt-repos")

APT_DEPS=()
while IFS= read -r line; do APT_DEPS+=("$line"); done < <(config::read_section "$CONF" "apt-deps")

APT_TO_REMOVE=()
while IFS= read -r line; do APT_TO_REMOVE+=("$line"); done < <(config::read_section "$CONF" "apt-remove")

cmd::debian_setup() {
    if steps::is_sudo; then
        steps::apt_setup "${APT_EXTRA_REPOS[@]}"
        steps::apt_deps "${APT_DEPS[@]}"
        steps::clean_preinstalled "${APT_TO_REMOVE[@]}"
    else
        logging::warn "[apt] Skipping setup (no sudo)"
    fi
}

cmd::fedora_setup() {
    logging::err "[dnf] Fedora setup not implemented yet"
    exit 1
}

cmd::system_setup() {
    case "$OS" in
        macos)
            logging::info "[system] macOS detected, skipping system package setup"
            ;;
        debian)
            cmd::debian_setup
            ;;
        fedora)
            cmd::fedora_setup
            ;;
        *)
            logging::warn "[system] Unknown OS, skipping system package setup"
            ;;
    esac

    steps::install_homebrew
}

cmd::brew() {
    if [[ ! "$(command -v brew)" ]]; then
        logging::err "[brew] Homebrew is not installed. Run './install_env.sh system' first."
        exit 1
    fi

    logging::info "[brew] Installing from Brewfile..."
    if ! brew bundle --file="${SCRIPT_DIR}/Brewfile"; then
        logging::err "[brew] brew bundle failed"
        exit 1
    fi
    logging::success "[brew] Installed all packages from Brewfile"
}

cmd::stow() {
    steps::setup_stow "${STOW_DIRS[@]}"
}

cmd::post_install() {
    steps::post_install
}

cmd::shell() {
    if steps::is_sudo; then
        steps::setup_shell
    else
        logging::warn "[install] Skipping shell setup (requires sudo for chsh/etc/shells)"
    fi
}

cmd::all() {
    cmd::system_setup
    cmd::brew
    cmd::stow
    cmd::post_install
    cmd::shell
    logging::success "Installation complete."
}

cmd::help() {
    grep '^#/' "${BASH_SOURCE[0]}" | sed 's/^#\/\($\| \)//' >&2
}

case "${1:-all}" in
    all)          cmd::all ;;
    system)       cmd::system_setup ;;
    brew)         cmd::brew ;;
    stow)         cmd::stow ;;
    post-install) cmd::post_install ;;
    shell)        cmd::shell ;;
    help|-h|--help) cmd::help ;;
    *)
        logging::err "Unknown command: $1"
        cmd::help
        exit 1
        ;;
esac
