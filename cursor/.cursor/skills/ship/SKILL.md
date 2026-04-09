---
name: ship
description: >
  Ship current changes: create a branch if on main, make small atomic commits,
  push, create or update a PR, and monitor CI checks — fixing failures
  automatically. Use when the user says "ship", "ship it", "send a PR",
  "push and create PR", or wants to land their current work.
---

# Ship

## Prerequisites

- `gh` CLI authenticated and available in PATH
- Git repo with uncommitted or staged changes (or recent unpushed commits)

## Step 1: Ensure a feature branch

```bash
git branch --show-current
```

If on `main` or `master`:

1. Ask the user for a branch name, or propose one derived from the changed files / nature of the work.
2. Create and switch:

```bash
git checkout -b <branch-name>
```

If already on a feature branch, continue on it.

## Step 2: Create small atomic commits

Analyze all pending changes (staged + unstaged + untracked):

```bash
git status --short
git diff
git diff --cached
```

**Goal**: produce the smallest meaningful commits, each focused on one logical change. Group related changes by:

- Feature / module / file purpose
- Type of change (new feature, fix, refactor, config, docs, tests)

For each logical group:

1. Stage only the relevant files:

```bash
git add <file1> <file2> ...
```

2. If a file contains changes belonging to multiple groups, use partial staging:

```bash
git add -p <file>
```

When using `git add -p`, you MUST handle the interactive prompts. For each hunk:
- Send `y` to stage, `n` to skip, `s` to split into smaller hunks
- Plan which hunks belong to each commit before starting

3. Commit with a conventional-commit message following the repo style (`type(scope): description`):

```bash
git commit -m "$(cat <<'EOF'
type(scope): concise description

Optional body with context on why, not what.
EOF
)"
```

Repeat until all changes are committed.

**Commit message conventions** (inferred from this repo):
- `feat(scope):` — new feature
- `fix(scope):` — bug fix
- `chore(scope):` — maintenance, dependencies
- `refactor(scope):` — code restructuring
- `docs(scope):` — documentation only

## Step 3: Push

```bash
git push -u origin HEAD
```

If the push is rejected (e.g., diverged history), pull with rebase first:

```bash
git pull --rebase origin <branch> && git push -u origin HEAD
```

## Step 4: Create or update the PR

Check if a PR already exists for this branch:

```bash
gh pr view --json number,title,url 2>/dev/null
```

### If no PR exists — create one

Analyze the full commit history on this branch:

```bash
git log --oneline main..HEAD
git diff main..HEAD --stat
```

Draft a PR title and body following this structure:

```markdown
## Summary
<bullet points summarizing the changes>

## Test plan
<how to verify the changes>
```

Show the user the title and body and ask for approval. Once approved, create the PR:

```bash
gh pr create --title "<title>" --body "$(cat <<'EOF'
<approved body>
EOF
)"
```

### If a PR exists — update its description

The push in step 3 already updated the PR code. Now ensure the description reflects the latest changes.

1. Fetch the current PR body and the full commit log:

```bash
gh pr view --json body --jq '.body'
git log --oneline main..HEAD
git diff main..HEAD --stat
```

2. Regenerate the **Summary** section based on all commits on the branch (not just the new ones). Keep any other sections the user may have added (e.g., Test plan, Notes).

3. Show the user the updated description and ask for approval, then apply:

```bash
gh pr edit --body "$(cat <<'EOF'
<updated body>
EOF
)"
```

## Step 5: Wait for CI checks

Watch check status until all checks complete or one fails:

```bash
gh pr checks --watch --fail-fast
```

### If checks pass

Print a success summary with the PR URL. Done.

### If checks fail

1. Identify the failing check(s):

```bash
gh pr checks --json name,state,link \
  --jq '.[] | select(.state != "SUCCESS" and .state != "SKIPPED")'
```

2. Fetch the failure logs. Try the check link first. If it's a GitHub Actions run:

```bash
gh run view <run-id> --log-failed
```

3. Analyze the failure and fix the issue in the code.

4. Commit the fix following the same atomic commit conventions from step 2.

5. Push and re-check:

```bash
git push
```

6. Go back to the polling loop. Repeat until checks pass or you've attempted **3 fix cycles** — after that, present the remaining failures to the user and stop.

## Safety Rules

- **Never push to main/master** directly.
- **Never commit secrets or .env files** — warn the user if detected.
- **Always show the commit plan** (which files go into which commit) and get user approval before committing.
- **Always show the PR title/body** before creating the PR and get user approval.
