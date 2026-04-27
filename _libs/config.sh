#!/bin/bash

set -euo pipefail

# Reads items from a section in an INI-style config file.
# Params:
#   $1 - config file path
#   $2 - section name (without brackets)
# Output: one item per line on stdout
config::read_section() {
    local file="$1" section="$2"
    local in_section=false
    while IFS= read -r line || [[ -n "$line" ]]; do
        line="${line%%#*}"
        line="$(echo "$line" | xargs)"
        [[ -z "$line" ]] && continue
        if [[ "$line" =~ ^\[(.+)\]$ ]]; then
            [[ "${BASH_REMATCH[1]}" == "$section" ]] && in_section=true || in_section=false
            continue
        fi
        if $in_section; then printf '%s\n' "$line"; fi
    done < "$file"
    return 0
}
