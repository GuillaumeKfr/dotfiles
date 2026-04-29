# Usage: envsource <path/to/env>
# Loads KEY=VALUE pairs from a .env file into the current shell environment.
# Supports comments (#), empty lines, quoted values, and `export` prefix.

function envsource
    if not test -f "$argv[1]"
        echo "envsource: file not found: $argv[1]" >&2
        return 1
    end

    for line in (grep -v '^\s*#' "$argv[1]" | grep -v '^\s*$')
        # Strip optional 'export ' prefix
        set line (string replace -r '^\s*export\s+' '' "$line")

        set -l key (string split -m 1 '=' "$line")[1]
        set -l value (string split -m 1 '=' "$line")[2]

        # Strip surrounding quotes from value
        set value (string trim -c '"' "$value")
        set value (string trim -c "'" "$value")

        if test -n "$key"
            set -gx "$key" "$value"
            echo "Exported key $key"
        end
    end
end
