#!/bin/bash

set -euo pipefail

# Params:
#  - 1: List of APT repos
steps::sys_setup() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        logging::info "[sys] MACOS detected, skipping step"
        return 0
    fi

    local repos_list=("${@}")

    logging::info "[sys] Upgrading packages..."

    if sudo apt -qq update && sudo apt -qq upgrade -y; then
        logging::success "[sys] Upgrade complete"
    else
        logging::err "[sys] Error in apt"
        exit 1
    fi

    logging::info "[sys] Adding extra repos..."

    if [[ ${#repos_list[@]} = 0 ]]; then
        logging::warn "[sys] No extra repo to add"
        return 0
    fi

    if ! sudo apt-add-repository "${APT_EXTRA_REPOS[@]}"; then
        logging::err "[sys] Issue when adding repos"
        exit 1
    fi

    logging::success "[sys] Added extra repos"
}

# Params:
#   - 1: List of APT dependencies
steps::deps() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        logging::info "[sys] MACOS detected, skipping step"
        return 0
    fi

    local deps_list=("${@}")

    logging::info "[deps] Installing apt dependencies..."

    if ! sudo apt -qq install -y "${deps_list[@]}"; then
        logging::err "[deps] Install failed"
        exit 1
    fi

    logging::success "[deps] Installed apt dependencies"

    logging::info "[deps] Installing Homebrew..."

    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

    if [[ ! "$(command -v brew)" ]]; then
        logging::err "[deps] Install failed"
        exit 1
    fi

    logging::success "[deps] Installed Homebrew"
}

# Params:
#   -1: List of APT packages to remove
steps::clean_preinstalled() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        logging::info "[sys] MACOS detected, skipping step"
        return 0
    fi

    local packages=("${@}")

    logging::info "[clean] Removing packages..."

    for package in "${packages[@]}"; do
        logging::info "[clean] [${package}] Checking package..."

        if ! apt list --installed "${package}" | grep "installed"; then
            logging::info "[clean] [${package}] Not found. Skipping..."
            continue
        fi

        logging::info "[clean] [${package}] Removing ..."

        if ! sudo apt -qq remove -y "${package}"; then
            logging::err "[clean] [${package}] Remove failed"
            exit 1
        fi

        logging::success "[clean] [${package}] Removed"
    done

    logging::info "[clean] Remove unused packages"

    if ! sudo apt -qq autoremove -y; then
        logging::err "[clean] Remove failed"
        exit 1
    fi

    logging::success "[clean] Removed all packages"
}

# Params:
#   - 1: List of formulae
steps::brew_installs() {
    local to_install=("${@}")

    logging::info "[brew] Installing formulae..."

    for formula in "${to_install[@]}"; do
        logging::info "[brew] [${formula}] Checking formula..."

        if ! brew list "${formula}" &>/dev/null; then
            logging::info "[brew] [${formula}] Installing..."

            if ! brew install -q "${formula}"; then
                logging::err "[brew] [${formula}] Install failed"
                exit 1
            fi

            logging::success "[brew] [${formula}] Installed"
            continue
        fi

        if ! brew outdated "${formula}" &>/dev/null; then
            logging::info "[brew] [${formula}] Upgrading..."

            if ! brew upgrade -q "${formula}"; then
                logging::err "[brew] [${formula}] Upgrade failed"
                exit 1
            fi

            logging::success "[brew] [${formula}] Upgraded"
        fi

        logging::info "[brew] [${formula}] Nothing to do"
    done

    logging::success "[brew] Installed all formulae"
}

steps::custom_setup() {
    if ! command -v bat &>/dev/null; then
        logging::warn "[custom] bat not found, skipping cache rebuild"
        return 0
    fi

    logging::info "[custom] Rebuilding bat's cache"
    if ! bat cache --build; then
        logging::err "[custom] Rebuild failed"
        return 1
    fi
    logging::success "[custom] Rebuilt bat's cache"
    return 0
}

# Params:
#   - 1: List of folders to stow
steps::setup_stow() {
    local to_stow=("${@}")
    logging::info "[stow] Stowing configuration folders..."

    pushd "${SCRIPT_DIR}" || exit 1

    for dir in "${to_stow[@]}"; do
        logging::info "[stow] [${dir}] Stowing ..."

        if ! stow -D "${dir}" || ! stow "${dir}"; then
            logging::err "[stow] [${dir}] Stow failed"
            exit 1
        fi

        logging::success "[stow] [${dir}] Stowed"
    done

    popd || exit 1

    logging::success "[stow] Stowed all config folders"
}

steps::ssh_config() {
    logging::info "[ssh] Configuring SSH connectivity..."

    if [[ -d ~/.ssh ]]; then
        logging::warn "[ssh] Config already existing. Skipping section."
        return 0
    fi

    logging::info "[ssh] No existing SSH config found. Generating key."
    logging::info "[ssh] <To be implemented>"
}

__setup_zsh() {
    logging::info "[zsh] Setting up configuration..."

    if [[ ! "$(command -v zsh)" ]]; then
        logging::err "[zsh] ZSH is not installed or not found in PATH"
        exit 1
    fi

    logging::info "[zsh] Installing OMZ..."

    ZSH=~/.oh-my-zsh sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

    logging::success "[zsh] Installed OMZ"

    logging::info "[zsh] Installing plugins"

    mkdir -p "${ZSH_PLUGINS_DIR}"

    rm -rf "${ZSH_PLUGINS_DIR}"/zsh-autosuggestions
    rm -rf "${ZSH_PLUGINS_DIR}"/zsh-syntax-highlighting
    rm -rf "${ZSH_PLUGINS_DIR}"/zsh-z

    git clone --quiet "https://github.com/zsh-users/zsh-autosuggestions.git" "${ZSH_PLUGINS_DIR}"/zsh-autosuggestions
    git clone --quiet "https://github.com/zsh-users/zsh-syntax-highlighting.git" "${ZSH_PLUGINS_DIR}"/zsh-syntax-highlighting
    git clone --quiet "https://github.com/agkozak/zsh-z" "${ZSH_PLUGINS_DIR}"/zsh-z

    logging::success "[zsh] Installed plugins"

    logging::info "[zsh] Setting ZSH as default"

    if ! chsh -s "$(which zsh)"; then
        logging::err "[zsh] Failed to set ZSH as default"
        exit 1
    fi

    logging::success "[zsh] Set ZSH as default"
}

__setup_fish() {
    logging::info "[fish] Setting up configuration..."

    if [[ ! "$(command -v fish)" ]]; then
        logging::err "[fish] FISH is not installed or not found in PATH"
        exit 1
    fi

    logging::info "[fish] Setting fish as valid shell..."

    which fish | sudo tee -a /etc/shells >/dev/null

    logging::success "[fish] Set up as valid"

    logging::info "[fish] Setting FISH as default"

    if ! chsh -s "$(which fish)"; then
        logging::err "[fish] Failed to set FISH as default"
        exit 1
    fi

    logging::success "[fish] Set FISH as default"
}

steps::setup_shell() {
    local setup_cmd shell_opts

    shell_opts=(zsh fish)

    logging::info "[shell] Select a shell to setup:"

    select user_shell in "${shell_opts[@]}"; do
        if [[ 1 -le "$REPLY" ]] && [[ "$REPLY" -le "${#shell_opts}" ]]; then
            if [[ ! "$(command -v "${user_shell}")" ]]; then
                logging::err "[shell] ${user_shell} is not installed or not found in PATH"
            else
                setup_cmd="__setup_${user_shell}"
                $setup_cmd
                break
            fi
        else
            logging::warn "[shell] Wrong selection: Select any number from 1-${#shell_opts}"
        fi
    done
}
