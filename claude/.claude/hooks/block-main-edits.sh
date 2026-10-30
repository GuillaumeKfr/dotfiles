#!/usr/bin/env bash
# Block file edits on main in ~/workspace; force work in a wt worktree instead.
input=$(cat)
file=$(jq -r '.tool_input.file_path // .tool_input.notebook_path // empty' <<<"$input")

[[ -z $file ]] && exit 0
[[ $file != "$HOME"/workspace/* ]] && exit 0

dir=$(dirname "$file")
while [[ ! -d $dir ]]; do dir=$(dirname "$dir"); done

branch=$(git -C "$dir" symbolic-ref --short -q HEAD 2>/dev/null) || exit 0
[[ $branch != main ]] && exit 0

echo "Refusing to edit on 'main'. Create a worktree with 'wt switch -c <branch>' and make the change there." >&2
exit 2
