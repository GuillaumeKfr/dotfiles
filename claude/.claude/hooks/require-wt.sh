#!/usr/bin/env bash
# Block worktree creation that bypasses wt.
input=$(cat)
tool=$(jq -r '.tool_name' <<<"$input")

case "$tool" in
  EnterWorktree) bad=1 ;;
  Agent) [[ $(jq -r '.tool_input.isolation // empty' <<<"$input") == worktree ]] && bad=1 ;;
  Bash) jq -r '.tool_input.command' <<<"$input" | grep -Eq 'git[[:space:]]+(-C[[:space:]]+[^[:space:]]+[[:space:]]+)?worktree[[:space:]]+add' && bad=1 ;;
esac

[[ -z ${bad:-} ]] && exit 0

echo "Use 'wt switch -c <branch>' to create worktrees, not raw git/EnterWorktree/isolation." >&2
exit 2
