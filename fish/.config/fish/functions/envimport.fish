# Usage: envimport <file>
# Sources a POSIX shell file in bash and exports new/changed variables into fish.
# Idea from oh-my-fish/plugin-foreign-env.
function envimport
    bash -c 'source "$1" && env -0 >&31' _ $argv[1] 31>| while read -l -z kv
        set -l pair (string split -m 1 = $kv); or continue
        contains $pair[1] _ SHLVL PWD OLDPWD; and continue
        string match -rq '^[a-zA-Z0-9_]+$' $pair[1]; or continue
        if not set -qx $pair[1]; or test "$$pair[1]" != $pair[2]
            set -gx $pair
        end
    end
    return $pipestatus[1]
end
