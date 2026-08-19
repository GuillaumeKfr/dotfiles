#!/bin/sh
# Mirrors ~/.config/starship.toml:
#   ∴(jobs) user@host(ssh/root only) directory(blue) branch(dim) git-status(cyan) [venv] [model ctx%]
input=$(cat)

cwd=$(echo "$input" | jq -r '.cwd')
model=$(echo "$input" | jq -r '.model.display_name')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

dir=$(echo "$cwd" | sed "s|^$HOME|~|")

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
    gitpart=$(printf ' \033[90m%s\033[0m' "$branch")

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
  venvpart=$(printf ' \033[90m(%s)\033[0m' "$venv")
fi

# model + context window % (statusline-only info)
ctx=""
if [ -n "$used" ]; then
  ctx=$(printf ' ctx:%.0f%%' "$used")
fi

# this month's cost, via ccusage, colored by % of $500 monthly budget
budget=500
costpart=""
cost=$(npx --yes ccusage@latest monthly --json --last 1 2>/dev/null | jq -r '.totals.totalCost // empty')
if [ -n "$cost" ]; then
  pct=$(awk -v c="$cost" -v b="$budget" 'BEGIN { printf "%.0f", (c / b) * 100 }')
  color=32
  [ "$pct" -ge 50 ] && color=33
  [ "$pct" -ge 80 ] && color=31
  costpart=$(printf ' \033[%sm$%.2f\033[0m' "$color" "$cost")
fi

printf '%s%s\033[34m%s\033[0m%s%s \033[90m[%s%s]\033[0m%s' \
  "$jobspart" "$hostpart" "$dir" "$gitpart" "$venvpart" "$model" "$ctx" "$costpart"
