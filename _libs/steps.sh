#! /bin/bash

# Params:
#  - 1: List of APT repos 
steps::sys_setup() {
    local repos_list=("${@}")

    logging::info "Upgrade packages"

    if sudo apt -qq update && sudo apt -qq upgrade -y; then
        logging::success "Upgrade complete"
    else
        logging::err "Error in apt"
        exit 1
    fi

    logging::info "Adding extra repos"

    if [[ ${#repos_list[@]} = 0 ]]; then
        logging::warn "No extra repo to add"
        return
    fi

    if ! sudo apt-add-repository "${APT_EXTRA_REPOS[@]}"; then
        logging::error "Issue when adding repos"
        exit 1
    fi

    logging::success "Repos added"
}

# Params:
#   - 1: List of APT dependencies
steps::deps() {
    local deps_list=("${@}")

    logging::info "Installing apt dependencies"

    if sudo apt -qq install -y "${deps_list[@]}"; then
        logging::success "Dependencies installed"
    else
        logging::err "Failed with install"
        exit 1
    fi

    logging::success "Dependencies installed"
    logging::info "Installing Homebrew"

    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

    if [[ ! "$(command -v brew)" ]]; then
        logging::err "Failed to install homebrew"
        exit 1
    fi

    logging::success "Homebrew installed"
}

# Params:
#   - 1: List of formulae
steps::brew_installs() {
    local to_install=("${@}")

    logging::info "Installing tools with homebrew"

    if ! brew install -q "${to_install[@]}"; then
        logging::err "Failed to install formulae"
        exit 1
    fi

    logging::success "Installation complete"
}

# Params:
#   - 1: List of packages
steps::pip_installs() {
    local to_install=("${@}")

    logging::info "Installing tools with pip"

    if ! pip install --quiet --upgrade "${to_install[@]}"; then
        logging::err "Failed to install packages"
        exit 1
    fi

    logging::success "Installation complete"

    logging::info "Upgrade pip packages"

    if ! ~/.local/bin/pip-review --auto --quiet; then
        logging::err "Failed to upgrade packages"
        return
    fi

    logging::success "Upgrade complete"
}

# Params:
#   - 1: List of folders to stow
steps::setup_stow() {
    local to_stow=("${@}")
    logging::info "Stowing configuration files"

    pushd "${SCRIPT_DIR}" || exit 1

    for dir in "${to_stow[@]}"; do
        logging::info "Stowing $dir"

        
        if ! stow -D "${dir}" || ! stow "${dir}" ; then
            logging::error "Failed to stow $dir"
            exit
        fi
    done

    popd || exit 1

    logging::success "Operation complete"
}

steps::ssh_config() {
    logging::info "Configure SSH connectivity"

    if [[ -d ~/.ssh ]]; then
        logging::warn "SSH config already existing. Skipping section."
    fi

    logging::info "No existing SSH config found. Generating key."
}

__setup_zsh() {
    logging::info "Setup ZSH configuration"

    if [[ ! "$(command -v zsh)" ]]; then
        logging::err "ZSH is not installed or not found in PATH"
        exit 1
    fi

    logging::info "Install OMZ"

    ZSH=~/.oh-my-zsh sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

    logging::info "Install plugins"

    mkdir -p "${ZSH_PLUGINS_DIR}"

    rm -rf "${ZSH_PLUGINS_DIR}"/zsh-autosuggestions
    rm -rf "${ZSH_PLUGINS_DIR}"/zsh-syntax-highlighting
    rm -rf "${ZSH_PLUGINS_DIR}"/zsh-z

    git clone --quiet "https://github.com/zsh-users/zsh-autosuggestions.git" "${ZSH_PLUGINS_DIR}"/zsh-autosuggestions
    git clone --quiet "https://github.com/zsh-users/zsh-syntax-highlighting.git" "${ZSH_PLUGINS_DIR}"/zsh-syntax-highlighting
    git clone --quiet "https://github.com/agkozak/zsh-z" "${ZSH_PLUGINS_DIR}"/zsh-z

    chsh -s "$(which zsh)"
}

__setup_fish() {
    logging::info "Setup FISH configuration"

    if [[ ! "$(command -v fish)" ]]; then
        logging::err "FISH is not installed or not found in PATH"
        exit 1
    fi

    logging::info "Set fish as valid shell"

    which fish | sudo tee -a /etc/shells > /dev/null

    chsh -s "$(which fish)"
}

steps::setup_shell() {
    local setup_cmd shell_opts

    shell_opts=(zsh fish)

    select user_shell in "${shell_opts[@]}"; do
        if [[ 1 -le "$REPLY" ]] && [[ "$REPLY" -le "${#shell_opts}" ]]; then
            if [[ ! "$(command -v "${user_shell}")" ]]; then
                logging::err "${user_shell} is not installed or not found in PATH"
            else
                setup_cmd="__setup_${user_shell}"
                $setup_cmd
                break
            fi
        else
            logging::warn "Wrong selection: Select any number from 1-$#"
        fi
    done
}
