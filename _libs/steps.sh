#! /bin/bash

# Params:
#  - 1: List of APT repos 
steps::sys_setup() {
    local repos_list="${@}"

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

    if sudo apt-add-repository "${APT_EXTRA_REPOS[@]}"; then
        logging::success "Repos added"
    else
        logging::error "Issue when adding repos"
        exit 1
    fi
}

# Params:
#   - 1: List of APT dependencies
steps::deps() {
    local deps_list="${@}"

    logging::info "Installing apt dependencies"

    if sudo apt -qq install -y "${deps_list[@]}"; then
        logging::success "Dependencies installed"
    else
        logging::err "Failed with install"
        exit 1
    fi

    logging::info "Installing Homebrew"

    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

    if [[ ! "$(command -v brew)" ]]; then
        logging::err "Failed to install homebrew"
        exit 1
    fi
}
