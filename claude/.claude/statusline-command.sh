#!/bin/sh
# Mirrors ~/.config/starship.toml:
#   ∴(jobs) user@host(ssh/root only) directory(blue) branch(dim) git-status(cyan) [venv] [model ctx%]
input=$(cat)

cwd=$(echo "$input" | jq -r '.cwd')
model=$(echo "$input" | jq -r '.model.display_name')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
repo=$(echo "$input" | jq -r '.workspace.repo.name // empty')
session_cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')

if [ -n "$repo" ]; then
  dir="$repo"
else
  dir=$(echo "$cwd" | sed "s|^$HOME|~|")
fi

# $jobs — symbol ∴ when background jobs exist (bright-black)
jobspart=""
jobs_count=$(jobs 2>/dev/null | wc -l | tr -d ' ')
[ "$jobs_count" -gt 0 ] && jobspart=$(printf '\033[90m∴\033[0m ')

# $username + $hostname — only shown on SSH or when root, matching Starship defaults
hostpart=""
if [ -n "$SSH_CONNECTION" ] || [ "$(id -u)" = "0" ]; then
  hostpart=$(printf '\033[90m%s@%s\033[0m ' "$(whoami)" "$(hostname -s)")
fi

# $git_branch (bright-black) + $git_status (cyan): ahead/behind/stash
gitpart=""
if git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    gitpart=$(printf '\033[90m%s\033[0m' "$branch")

    gitstatus=""
    upstream=$(git -C "$cwd" --no-optional-locks rev-parse --abbrev-ref '@{upstream}' 2>/dev/null)
    if [ -n "$upstream" ]; then
      counts=$(git -C "$cwd" --no-optional-locks rev-list --left-right --count "@{upstream}...HEAD" 2>/dev/null)
      behind=$(echo "$counts" | awk '{print $1}')
      ahead=$(echo "$counts" | awk '{print $2}')
      [ "$ahead" -gt 0 ] 2>/dev/null && gitstatus="${gitstatus}⇡${ahead}"
      [ "$behind" -gt 0 ] 2>/dev/null && gitstatus="${gitstatus}⇣${behind}"
    fi
    stash=$(git -C "$cwd" --no-optional-locks stash list 2>/dev/null | wc -l | tr -d ' ')
    [ "$stash" -gt 0 ] 2>/dev/null && gitstatus="${gitstatus}≡"

    [ -n "$gitstatus" ] && gitpart=$(printf '%s \033[36m%s\033[0m' "$gitpart" "$gitstatus")
  fi
fi

# $python virtualenv (bright-black)
venvpart=""
if [ -n "$VIRTUAL_ENV" ]; then
  venv=$(basename "$VIRTUAL_ENV")
  venvpart=$(printf '\033[90m(%s)\033[0m' "$venv")
fi

# context window usage as a progress bar, colored by fullness
ctxpart=""
if [ -n "$used" ]; then
  pct=$(printf '%.0f' "$used")
  bar_width=20
  filled=$((pct * bar_width / 100))
  empty=$((bar_width - filled))
  ctx_color=32
  [ "$pct" -ge 70 ] && ctx_color=33
  [ "$pct" -ge 90 ] && ctx_color=31
  filledbar=""
  [ "$filled" -gt 0 ] && filledbar=$(printf "%${filled}s" | tr ' ' '▮')
  emptybar=""
  [ "$empty" -gt 0 ] && emptybar=$(printf "%${empty}s" | tr ' ' '▮')
  ctxpart=$(printf '\033[%sm%s\033[2m%s\033[0m %s%%' "$ctx_color" "$filledbar" "$emptybar" "$pct")
fi

# cost: session (uncolored) | today (colored by % of daily budget) | month (colored by % of monthly budget)
budget=500
sessionpart=""
[ -n "$session_cost" ] && sessionpart=$(printf '\033[90m$%.2f\033[0m' "$session_cost")

# working days in the month, and how many have elapsed so far (today inclusive)
working_days=$(cal -h | cut -c 4-17 | tail -n +3 | wc -w | tr -d ' ')
worked_days=0
for d in $(seq -w 1 "$(date +%d)"); do
  dow=$(date -j -f '%Y-%m-%d' "$(date +%Y-%m)-$d" +%u)
  [ "$dow" -lt 6 ] && worked_days=$((worked_days + 1))
done

daypart=""
day_cost=$(npx --yes ccusage@latest daily --json --last 1 2>/dev/null | jq -r '.totals.totalCost // empty')
if [ -n "$day_cost" ]; then
  dpct=$(awk -v c="$day_cost" -v b="$budget" -v d="$working_days" 'BEGIN { printf "%.0f", (c / (b / d)) * 100 }')
  color=32
  [ "$dpct" -ge 50 ] && color=33
  [ "$dpct" -ge 80 ] && color=31
  daypart=$(printf '\033[%sm$%.2f\033[0m' "$color" "$day_cost")
fi

monthpart=""
month_cost=$(npx --yes ccusage@latest monthly --json --last 1 2>/dev/null | jq -r '.totals.totalCost // empty')
if [ -n "$month_cost" ]; then
  mpct=$(awk -v c="$month_cost" -v b="$budget" -v w="$worked_days" -v d="$working_days" 'BEGIN { printf "%.0f", (c / (b * w / d)) * 100 }')
  color=32
  [ "$mpct" -ge 50 ] && color=33
  [ "$mpct" -ge 80 ] && color=31
  monthpart=$(printf '\033[%sm$%.2f\033[0m' "$color" "$month_cost")
fi

# assemble pipe-separated segments, skipping any that are empty
sep=$(printf ' \033[90m|\033[0m ')
line="${jobspart}${hostpart}\033[34m${dir}\033[0m"
for seg in "$gitpart" "$venvpart" "$model" "$ctxpart" "$sessionpart" "$daypart" "$monthpart"; do
  [ -n "$seg" ] && line="${line}${sep}${seg}"
done

printf '%b' "$line"
