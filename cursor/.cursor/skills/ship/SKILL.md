---
name: ship
description: >
  Ship current changes: create a branch if on main, make small atomic commits,
  push, create or update a PR, monitor CI checks — fixing failures
  automatically — then scan SonarCloud for code quality issues and fix those
  too. Use when the user says "ship", "ship it", "send a PR",
  "push and create PR", or wants to land their current work.
---

# Ship

## Prerequisites

- `gh` CLI authenticated and available in PATH
- Git repo with uncommitted or staged changes (or recent unpushed commits)
- SonarCloud MCP server configured (for Step 7)

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

## Step 2: Pre-flight checks

Before committing anything, run all applicable tests and checks to catch issues early.

1. Detect which tools are configured in the repo (look for config files, scripts, `package.json` scripts, `Makefile` targets, `pyproject.toml` sections, `.pre-commit-config.yaml`, etc.).

2. Run every applicable check. Common examples — adapt to what the repo actually uses:

| Tool / Config detected | Command to run |
| --- | --- |
| `pre-commit` config | `pre-commit run --all-files` |
| `dbt` project | `dbt build` (or `dbt test` if models are already built) |
| `sqlfluff` config | `sqlfluff lint .` |
| `pytest` / `pyproject.toml [tool.pytest]` | `pytest` |
| `npm test` / `vitest` / `jest` | `npm test` (or equivalent) |
| `eslint` config | `npx eslint .` |
| `Makefile` with `lint` / `check` targets | `make lint check` |
| `cargo` project | `cargo clippy && cargo test` |
| `go.mod` | `go vet ./... && go test ./...` |

3. Collect all failures and warnings.

4. **Fix every issue** found — apply code changes, re-run the failing check to confirm the fix, and repeat until all checks pass.

5. Only proceed to Step 3 once every check passes cleanly.

## Step 3: Create small atomic commits

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

## Step 4: Push

```bash
git push -u origin HEAD
```

If the push is rejected (e.g., diverged history), pull with rebase first:

```bash
git pull --rebase origin <branch> && git push -u origin HEAD
```

## Step 5: Create or update the PR

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

The push in step 4 already updated the PR code. Now ensure the description reflects the latest changes.

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

## Step 6: Wait for CI checks

Watch check status until all checks complete or one fails:

```bash
gh pr checks --watch --fail-fast
```

### If checks pass

Proceed to Step 7 (SonarCloud scan).

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

4. Commit the fix following the same atomic commit conventions from step 3.

5. Push and re-check:

```bash
git push
```

6. Go back to the polling loop. Repeat until checks pass or you've attempted **3 fix cycles** — after that, present the remaining failures to the user and stop.

## Step 7: SonarCloud code quality scan

After CI checks pass, scan the PR for code quality issues using the SonarCloud MCP.

### 7a. Resolve the project key

Find the SonarCloud project key using this lookup order:

1. `.sonarlint/connectedMode.json` — use the `projectKey` field
2. Root config files — look for `sonar.projectKey` in `sonar-project.properties`, `pom.xml`, `build.gradle`, `package.json`, or look for `sonarqube.org/project-key` in `catalog-info.yaml`

If no project key is found, skip Step 7 entirely and print a success summary with the PR URL.

### 7b. Query issues on the PR

Use the PR number from Step 5 and call `search_sonar_issues_in_projects` with:

- `pullRequestId`: the GitHub PR number (as a string)
- `issueStatuses`: `["OPEN"]`
- `projects`: `["<project-key>"]`

Filter out TODO/FIXME tracker rules client-side — skip any issue whose rule key ends with `:S1135` or is otherwise a TODO/FIXME tag tracker.

### 7c. If no issues — done

Print a success summary with the PR URL and a note that SonarCloud found no issues. Done.

### 7d. Fix each issue

For each remaining issue:

1. Call `show_rule` with the issue's rule key to understand what the rule expects.
2. Read the affected file and locate the problematic code using the issue's component (file path) and line/textRange information.
3. Apply the fix.

Once all issues in the batch are fixed:

1. Commit the fixes following the same atomic commit conventions from Step 3 (e.g., `fix(sonar): resolve null pointer dereference in parser`).
2. Push:

```bash
git push
```

### 7e. Loop

After pushing SonarCloud fixes:

1. Go back to **Step 6** — wait for CI checks to pass again (CI retries follow Step 6's own 3-cycle cap).
2. Once CI passes, re-run **Step 7b** to check for remaining SonarCloud issues.
3. Repeat until SonarCloud is clean or you've attempted **3 SonarCloud fix cycles**.
4. After 3 cycles, if issues still remain, present the remaining issues to the user and stop.

## Safety Rules

- **Never push to main/master** directly.
- **Never commit secrets or .env files** — warn the user if detected.
- **Always show the commit plan** (which files go into which commit) and get user approval before committing.
- **Always show the PR title/body** before creating the PR and get user approval.
