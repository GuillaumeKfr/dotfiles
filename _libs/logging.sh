#!/bin/bash

__fmt_reset=$(tput sgr 0)

__fmt_red=$(tput setaf 1)
__fmt_green=$(tput setaf 2)
__fmt_yellow=$(tput setaf 3)
__fmt_blue=$(tput setaf 4)

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
