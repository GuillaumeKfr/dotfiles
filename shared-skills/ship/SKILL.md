---
name: ship
description: >
  Ship current changes: create a branch if on main, make small atomic commits,
  push, create or update a PR, then hand off to /autofix-pr to fix CI
  failures and review comments. Use when the user says "ship", "ship it", "send a PR",
  "push and create PR", or wants to land their current work.
---

# Ship

## Prerequisites

- `gh` CLI authenticated and available in PATH
- Git repo with uncommitted or staged changes (or recent unpushed commits)

## Step 1: Ensure a feature branch

Check the current branch with `git branch --show-current`.

If on `main` or `master`, ask the user for a branch name (or propose one derived from the work), then `git checkout -b <branch-name>`. Otherwise continue on the current branch.

## Step 2: Pre-flight checks

Detect configured linters, formatters, and test runners from repo config files (e.g., `.pre-commit-config.yaml`, `pyproject.toml`, `package.json`, `Makefile`, `Cargo.toml`, `go.mod`). Run every applicable check.

Fix every failure found — apply code changes, re-run to confirm, and repeat until all checks pass cleanly. Only then proceed.

## Step 3: Create small atomic commits

Analyze all pending changes (`git status --short`, `git diff`, `git diff --cached`).

Produce the smallest meaningful commits, each focused on one logical change. Group related changes by feature/module and type (feature, fix, refactor, config, docs, tests).

For each logical group:

1. Stage only the relevant files (`git add <files>`). Use `git add -p` if a file contains changes belonging to multiple groups.
2. Commit with a conventional-commit message following the repo style:

```bash
git commit -m "$(cat <<'EOF'
type(scope): concise description

Optional body with context on why, not what.
EOF
)"
```

Repeat until all changes are committed.

## Step 4: Push

```bash
git push -u origin HEAD
```

If rejected due to diverged history, `git pull --rebase origin <branch>` first, then push again.

## Step 5: Create or update the PR

Check for an existing PR: `gh pr view --json number,title,url 2>/dev/null`.

### No PR exists

Analyze commits on the branch (`git log --oneline main..HEAD`, `git diff main..HEAD --stat`). Draft a title and body:

```markdown
## Summary
<bullet points summarizing the changes>

## Test plan
<how to verify the changes>
```

Show the user the title and body for approval, then `gh pr create`.

### PR already exists

The push already updated the code. Regenerate the **Summary** section from all commits on the branch, preserving any other sections the user added. Show the updated description for approval, then apply with `gh pr edit --body`.

## Step 6: Hand off to /autofix-pr

Print the PR URL and tell the user to run `/autofix-pr` to have Claude watch the PR and fix CI failures and review comments. `/autofix-pr` is a built-in command and cannot be invoked from a skill. Stop here.

## Safety Rules

- **Never push to main/master** directly.
- **Never commit secrets or .env files** — warn the user if detected.
- **Always show the commit plan** (which files go into which commit) and get user approval before the Step 3 commits.
- **Always show the PR title/body** before creating the PR and get user approval.
