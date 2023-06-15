#! /bin/bash

# string formatters
if [[ -t 1 ]]; then
    tty_escape() { printf "\033[%sm" "$1"; }
else
    tty_escape() { :; }
fi

__tty_mkbold() { tty_escape "1;$1"; }

__tty_blue="$(__tty_mkbold 34)"
__tty_green="$(__tty_mkbold 32)"
__tty_red="$(__tty_mkbold 31)"
__tty_yellow="$(__tty_mkbold "1;33")"
__tty_bold="$(__tty_mkbold 39)"

__tty_reset="$(tty_escape 0)"

__chomp() {
    printf "%s" "${1/"$'\n'"/}"
}

logging::warn() {
    printf "${__tty_yellow}[!] %s${__tty_reset}\n" "$(__chomp "$1")" >&2
}

logging::info() {
    printf "${__tty_blue}[i] %s${__tty_reset}\n" "$(__chomp "$1")"
}

logging::success() {
    printf "${__tty_green}[✓] %s${__tty_reset}\n" "$(__chomp "$1")"
}

logging::err() {
    printf "${__tty_red}[⨯] %s${__tty_reset}\n" "$(__chomp "$1")" >&2
}
