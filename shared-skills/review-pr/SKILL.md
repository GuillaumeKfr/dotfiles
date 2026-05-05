---
name: review-pr
description: >
  Review a GitHub pull request for bugs, security issues, and improvements.
  Proposes each finding for user approval before posting as a PR comment with
  code suggestions. Use when the user asks to review a PR, audit PR changes,
  or check a pull request for issues.
---

# Review PR

When formulating and posting review feedback, apply the `receiving-code-review` skill.

## Prerequisites

- `gh` CLI authenticated and available in PATH
- Git repo with the PR branch checked out locally

## Step 1: Identify the PR

Assume the PR is the one associated with the current branch:

```bash
gh pr view --json number,title,headRefName,baseRefName,url
```

If no PR exists for the current branch, tell the user and stop.

## Step 2: Fetch the diff and changed files

```bash
gh pr diff <PR_NUMBER>
```

Get the list of changed files:

```bash
gh pr view <PR_NUMBER> --json files --jq '.files[].path'
```

Read each changed file in full for context beyond the diff hunks.

## Step 3: Analyze the diff

Review each changed file systematically. Look for:

- **Bugs** — logic errors, off-by-one, null/undefined access, race conditions, missing error handling
- **Security** — injection, hardcoded secrets, insecure defaults, missing auth checks
- **Improvements** — performance, readability, naming, dead code, missing tests, better patterns

Categorize each finding:

| Category      | Meaning                          |
|---------------|----------------------------------|
| `BUG`         | Definite or likely bug           |
| `SECURITY`    | Security vulnerability / concern |
| `IMPROVEMENT` | Enhancement suggestion           |

Track all findings as a checklist.

After analysis, present a **short summary only** — list each finding with its category, file, and a one-line description. Do NOT show code snippets or suggested fixes yet. Example:

> Found 3 findings:
> 1. **BUG** — `src/auth.py` — missing null check on user lookup
> 2. **SECURITY** — `src/api.py` — SQL query built with string concatenation
> 3. **IMPROVEMENT** — `src/utils.py` — redundant loop can be replaced with list comprehension

## Step 4: Present findings one by one

> **CRITICAL: Present exactly ONE finding per message. After showing the finding and asking for approval, STOP your response and WAIT for the user to reply. Do NOT present the next finding until the user has responded.**

For the **next pending** finding, show the user:

- **Category** (BUG / SECURITY / IMPROVEMENT)
- **File & line range**
- **Current code** at that location
- **What's wrong** and why it matters
- **Suggested fix** (concrete replacement code)

Then ask: **"Post this as a PR comment? (approve / revise / skip)"**

Wait for the user's response before continuing.

When the user responds:

- **approve** — post the comment on the PR immediately (see below), mark the finding as completed, then present the next finding
- **revise** — user provides adjustments, re-present the revised finding and ask again
- **skip** — mark the finding as completed, then present the next finding

### Posting an approved comment

Get the head commit SHA (once, cache for subsequent postings):

```bash
gh pr view <PR_NUMBER> --json headRefOid --jq '.headRefOid'
```

Post a review comment on the specific file and line:

```bash
gh api repos/{owner}/{repo}/pulls/<PR_NUMBER>/comments \
  -f body="<comment_body>" \
  -f commit_id="<head_sha>" \
  -f path="<file>" \
  -F line=<line> \
  -f side="RIGHT"
```

Keep comment bodies plain and concise — no headers, no bold labels, no titles. Write a short explanation of the issue, then use a GitHub suggestion code fence (` ```suggestion `) when a direct replacement applies. This lets the author apply the fix with one click.

Example comment body:

    This can raise a NullPointerException when `user` is not found.

    ```suggestion
    user = get_user(id)
    if user is None:
        raise ValueError(f"User {id} not found")
    ```

For broader observations that don't map to a single code replacement, just write the explanation without a suggestion block.

## Step 5: Summary

After all findings are processed, present:

- Findings by category (BUG / SECURITY / IMPROVEMENT)
- Number posted vs. skipped
- Links to posted comments

## Safety Rules

- **Never post a comment without explicit user approval.**
- **Never modify code or commit** — this skill only posts review comments.
- **Never skip the approval step** — always wait for the user to confirm.
- If a finding overlaps with an existing PR comment, note the overlap and let the user decide.
