SHELL := /bin/bash
.ONESHELL:

REPO_ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

INIT := source _libs/logging.sh && source _libs/steps.sh

STOW_DIRS := aerospace bat btop containers cursor fish fzf gh-dash git kitty lazygit nvim starship tmux zsh

ifeq ($(shell uname -s),Linux)
ALL_LINUX := linux-setup
else
ALL_LINUX :=
endif

.PHONY: all brew stow custom shell ssh linux-setup help

all: $(ALL_LINUX) brew stow custom ssh shell
	cd "$(REPO_ROOT)" && set -euo pipefail && source _libs/logging.sh && logging::success "Installation complete."

brew:
	cd "$(REPO_ROOT)" && set -euo pipefail && $(INIT)
	logging::info "[brew] Installing from Brewfile..."
	if ! brew bundle --file=Brewfile; then
		logging::err "[brew] brew bundle failed"
		exit 1
	fi
	logging::success "[brew] Installed all packages from Brewfile"

stow:
	cd "$(REPO_ROOT)" && set -euo pipefail && source _libs/logging.sh
	logging::info "[stow] Stowing configuration folders..."
	for dir in $(STOW_DIRS); do
		logging::info "[stow] [$${dir}] Stowing ..."
		if ! stow -D "$${dir}" || ! stow "$${dir}"; then
			logging::err "[stow] [$${dir}] Stow failed"
			exit 1
		fi
		logging::success "[stow] [$${dir}] Stowed"
	done
	logging::success "[stow] Stowed all config folders"

custom:
	cd "$(REPO_ROOT)" && set -euo pipefail && $(INIT)
	steps::custom_setup

shell:
	cd "$(REPO_ROOT)" && set -euo pipefail && $(INIT)
	export ZSH_CUSTOM_DIR="$${ZSH_CUSTOM:-$$HOME/.oh-my-zsh/custom}"
	export ZSH_PLUGINS_DIR="$$ZSH_CUSTOM_DIR/plugins"
	if steps::is_sudo; then
		steps::setup_shell
	else
		logging::warn "[install] Skipping shell setup (requires sudo for chsh/etc/shells)"
	fi

ssh:
	cd "$(REPO_ROOT)" && set -euo pipefail && $(INIT)
	steps::ssh_config

linux-setup:
	cd "$(REPO_ROOT)" && set -euo pipefail && $(INIT)
	if steps::is_sudo; then
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
		steps::sys_setup "$${APT_EXTRA_REPOS[@]}"
		steps::deps "$${APT_DEPS[@]}"
		steps::clean_preinstalled "$${APT_TO_REMOVE[@]}"
	else
		logging::warn "[install] Skipping sys_setup, deps, and clean_preinstalled (no sudo)"
	fi

help:
	@echo "Dotfiles install targets (run from repo root):"
	@echo "  make / make all  Full install: linux-setup (Linux only), brew, stow, custom, ssh, shell (sudo only)"
	@echo "  make brew        Install Homebrew packages from Brewfile"
	@echo "  make stow        Symlink config packages under STOW_DIRS"
	@echo "  make custom      Bat cache + worktrunk shell integration"
	@echo "  make ssh         SSH config helper"
	@echo "  make shell       Interactive default shell setup (needs sudo)"
	@echo "  make linux-setup APT + Homebrew bootstrap on Linux (needs sudo)"
	@echo "  make help        Show this message"
