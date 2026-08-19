# ccusage completions for fish
complete -c ccusage -f

set -l subcommands daily weekly monthly session blocks statusline claude
set -l subcommand_descriptions \
    "Usage grouped by day" \
    "Usage grouped by week" \
    "Usage grouped by month" \
    "Usage grouped by session" \
    "Usage grouped by billing block" \
    "Compact status line for Claude Code hooks" \
    "Claude Code usage commands"

for i in (seq (count $subcommands))
    complete -c ccusage -n "not __fish_seen_subcommand_from $subcommands" -a $subcommands[$i] -d $subcommand_descriptions[$i]
end

# short flag, long flag, description
set -l option_short j s u z '' '' ''
set -l option_long json since until timezone all sections by-agent
set -l option_descriptions \
    "Output in JSON format" \
    "Filter from date (YYYY-MM-DD)" \
    "Filter until date (inclusive)" \
    "Timezone for date grouping (IANA)" \
    "Accepted for compatibility" \
    "Emit multiple report sections" \
    "Include per-agent JSON breakdowns"

for i in (seq (count $option_long))
    if test -n "$option_short[$i]"
        complete -c ccusage -s $option_short[$i] -l $option_long[$i] -d $option_descriptions[$i]
    else
        complete -c ccusage -l $option_long[$i] -d $option_descriptions[$i]
    end
end
