#!/bin/bash

set -euo pipefail

# Initialize color codes only if terminal supports colors
if [[ -t 1 ]] && command -v tput &>/dev/null; then
    set +e  # Temporarily disable exit on error for tput commands
    __fmt_reset=$(tput sgr0 2>/dev/null || echo '')
    __fmt_red=$(tput setaf 1 2>/dev/null || echo '')
    __fmt_green=$(tput setaf 2 2>/dev/null || echo '')
    __fmt_yellow=$(tput setaf 3 2>/dev/null || echo '')
    __fmt_blue=$(tput setaf 4 2>/dev/null || echo '')
    set -e  # Re-enable exit on error
else
    __fmt_reset=''
    __fmt_red=''
    __fmt_green=''
    __fmt_yellow=''
    __fmt_blue=''
fi

logging::warn() {
    printf "${__fmt_yellow}[!] $1${__fmt_reset}\n" >&2
}

logging::info() {
    printf "${__fmt_blue}[i] $1${__fmt_reset}\n"
}

logging::success() {
    printf "${__fmt_green}[✓] $1${__fmt_reset}\n"
}

logging::err() {
    printf "${__fmt_red}[⨯] $1${__fmt_reset}\n" >&2
}
