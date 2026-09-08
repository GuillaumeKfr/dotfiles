#!/bin/sh
# Mirrors ~/.config/starship.toml:
#   ∴(jobs) user@host(ssh/root only) directory(blue) branch(dim) git-status(cyan) [venv] [model ctx%]
input=$(cat)

RESET=$(printf '\033[0m')
DIM=$(printf '\033[2m')
GRAY=$(printf '\033[90m')
BLUE=$(printf '\033[34m')
CYAN=$(printf '\033[36m')
GREEN=$(printf '\033[32m')
YELLOW=$(printf '\033[33m')
RED=$(printf '\033[31m')

# green below 70%, yellow below 90%, red at/above 90%
color_for_pct() {
  pct=$1
  color=$GREEN
  [ "$pct" -ge 70 ] && color=$YELLOW
  [ "$pct" -ge 90 ] && color=$RED
  echo "$color"
}

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
[ "$jobs_count" -gt 0 ] && jobspart=$(printf '%s∴%s ' "$GRAY" "$RESET")

# $username + $hostname — only shown on SSH or when root, matching Starship defaults
hostpart=""
if [ -n "$SSH_CONNECTION" ] || [ "$(id -u)" = "0" ]; then
  hostpart=$(printf '%s%s@%s%s ' "$GRAY" "$(whoami)" "$(hostname -s)" "$RESET")
fi

# $git_branch (bright-black) + $git_status (cyan): ahead/behind/stash
gitpart=""
if git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    gitpart=$(printf '%s%s%s' "$GRAY" "$branch" "$RESET")

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

    [ -n "$gitstatus" ] && gitpart=$(printf '%s %s%s%s' "$gitpart" "$CYAN" "$gitstatus" "$RESET")
  fi
fi

# $python virtualenv (bright-black)
venvpart=""
if [ -n "$VIRTUAL_ENV" ]; then
  venv=$(basename "$VIRTUAL_ENV")
  venvpart=$(printf '%s(%s)%s' "$GRAY" "$venv" "$RESET")
fi

# context window usage as a progress bar, colored by fullness
ctxpart=""
if [ -n "$used" ]; then
  pct=$(printf '%.0f' "$used")
  bar_width=20
  filled=$((pct * bar_width / 100))
  empty=$((bar_width - filled))
  ctx_color=$(color_for_pct "$pct")
  filledbar=""
  [ "$filled" -gt 0 ] && filledbar=$(printf "%${filled}s" | tr ' ' '▮')
  emptybar=""
  [ "$empty" -gt 0 ] && emptybar=$(printf "%${empty}s" | tr ' ' '▮')
  ctxpart=$(printf '%s%s%s%s%s %s%%' "$ctx_color" "$filledbar" "$DIM" "$emptybar" "$RESET" "$pct")
fi

# cost: session (uncolored) | today (colored by % of daily budget) | month (colored by % of monthly budget)
budget=500
sessionpart=""
[ -n "$session_cost" ] && sessionpart=$(printf '%s$%.2f%s' "$GRAY" "$session_cost" "$RESET")

# working days in the month, and how many have elapsed so far (today inclusive)
working_days=$(cal -h | cut -c 4-17 | tail -n +3 | wc -w | tr -d ' ')
worked_days=0
for d in $(seq -w 1 "$(date +%d)"); do
  dow=$(date -j -f '%Y-%m-%d' "$(date +%Y-%m)-$d" +%u)
  [ "$dow" -lt 6 ] && worked_days=$((worked_days + 1))
done

budget_part() {
  cost=$1; pct=$2
  color=$(color_for_pct "$pct")
  printf '%s$%.2f%s' "$color" "$cost" "$RESET"
}

daypart=""
day_cost=$(npx --yes ccusage@latest daily --json --last 1 2>/dev/null | jq -r '.totals.totalCost // empty')
if [ -n "$day_cost" ]; then
  dpct=$(awk -v c="$day_cost" -v b="$budget" -v d="$working_days" 'BEGIN { printf "%.0f", (c / (b / d)) * 100 }')
  daypart=$(budget_part "$day_cost" "$dpct")
fi

monthpart=""
month_cost=$(npx --yes ccusage@latest monthly --json --last 1 2>/dev/null | jq -r '.totals.totalCost // empty')
if [ -n "$month_cost" ]; then
  mpct=$(awk -v c="$month_cost" -v b="$budget" -v w="$worked_days" -v d="$working_days" 'BEGIN { printf "%.0f", (c / (b * w / d)) * 100 }')
  monthpart=$(budget_part "$month_cost" "$mpct")
fi

# assemble pipe-separated segments, skipping any that are empty
sep=$(printf ' %s|%s ' "$GRAY" "$RESET")
line="${jobspart}${hostpart}${BLUE}${dir}${RESET}"
for seg in "$gitpart" "$venvpart" "$model" "$ctxpart" "$sessionpart" "$daypart" "$monthpart"; do
  [ -n "$seg" ] && line="${line}${sep}${seg}"
done

printf '%b' "$line"
