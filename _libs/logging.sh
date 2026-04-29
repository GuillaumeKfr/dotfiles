#!/bin/bash

# Initialize color codes only if terminal supports colors
if [[ -t 1 ]] && command -v tput &>/dev/null; then
    __fmt_reset=$(tput sgr0 2>/dev/null || echo '')
    __fmt_red=$(tput setaf 1 2>/dev/null || echo '')
    __fmt_green=$(tput setaf 2 2>/dev/null || echo '')
    __fmt_yellow=$(tput setaf 3 2>/dev/null || echo '')
    __fmt_blue=$(tput setaf 4 2>/dev/null || echo '')
else
    __fmt_reset=''
    __fmt_red=''
    __fmt_green=''
    __fmt_yellow=''
    __fmt_blue=''
fi

logging::warn() {
    printf '%s[!] %s%s\n' "${__fmt_yellow}" "$1" "${__fmt_reset}" >&2
}

logging::info() {
    printf '%s[i] %s%s\n' "${__fmt_blue}" "$1" "${__fmt_reset}"
}

logging::success() {
    printf '%s[✓] %s%s\n' "${__fmt_green}" "$1" "${__fmt_reset}"
}

logging::err() {
    printf '%s[⨯] %s%s\n' "${__fmt_red}" "$1" "${__fmt_reset}" >&2
}
