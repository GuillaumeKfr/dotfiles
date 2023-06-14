#! /bin/bash


reset_color=$(tput sgr 0)

logging::info() {
  printf "%s[i] %s%s\n" "$(tput setaf 4)" "$1" "$reset_color"
}

logging::success() {
    
  printf "%s[✓] %s%s\n" "$(tput setaf 2)" "$1" "$reset_color"
}

logging::err() {
  printf "%s[⨯] %s%s\n" "$(tput setaf 1)" "$1" "$reset_color"
}

logging::warn() {
  printf "%s[!] %s%s\n" "$(tput setaf 3)" "$1" "$reset_color"
}
