---
name: review-pr
description: >
  Review a GitHub pull request for bugs, security issues, improvements,
  documentation, and tests. Proposes each finding for user approval, then
  either posts it as a PR comment (remote mode) or applies the fix locally as
  an atomic commit (local mode). Use when the user asks to review a PR, audit
  PR changes, or check a pull request for issues.
---

# Review PR

## Tone and wording for feedback

These rules apply to every comment body and every commit message produced by this skill:

- **Describe the issue, not the author.** "This can NPE when X" — not "you forgot to handle X".
- **Be concrete and specific.** Point at the exact symptom or scenario; avoid "this seems off" or "consider refactoring".
- **Suggest, don't mandate.** Phrase fixes as proposals ("consider...", "could become...") unless it's a clear bug or security issue.
- **One thought per comment.** If a finding contains two unrelated points, split it.
- **No throat-clearing.** No "great PR overall, but...", no "I think maybe you might want to consider...".
- **Plain prose.** No headers, no bold labels, no titles inside comment bodies — the categorization is metadata, not the message.

## Prerequisites

- `gh` CLI authenticated and available in PATH
- Git repo with the PR branch checked out locally

## Step 0: Determine the mode

Two modes are supported:

- **remote** — approved findings are posted as inline PR comments. No local edits, no commits.
- **local** — approved findings are applied directly to the working tree. Each approved finding becomes its own atomic commit on the current branch.

There is **no default mode**. Determine the mode as follows:

- If the user's request explicitly specifies a mode (e.g. "review the PR remotely", "review locally", "apply fixes locally", "post comments"), use it.
- Otherwise, ask the user which mode to use before starting.

For **local** mode, also verify before starting:

```bash
git status --porcelain
git log -n 5 --pretty=format:'%s'
```

- If the working tree is dirty, stop and tell the user — local mode requires a clean tree so each review commit contains only the fix for one finding.
- The `git log` output is used to match the repo's existing commit message style for the commits this skill will create.

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

Analysis runs in three phases: gather findings via parallel agents, score each one for confidence, then keep only the high-confidence ones.

### Phase 3a: Gather findings (parallel agents)

Identify the relevant `CLAUDE.md` files: the repo root one (if present), and any `CLAUDE.md` in directories the PR modifies. Pass the list of paths (not contents) to the agents below.

**Right-size the analysis to the diff.** For tiny diffs (≲20 lines, single file, obviously trivial change like a typo or a one-line config tweak), skip the multi-agent fan-out and review inline — the cost of 5 subagents + scoring on a 5-line PR exceeds the value. Use the full multi-agent flow below for non-trivial diffs.

For the multi-agent flow, dispatch the following five agents in parallel using a single message with multiple `Agent` tool calls (use the `general-purpose` subagent type unless a more specific one fits). Each agent must return a JSON list of findings, where each finding has: `category`, `path`, `line` (or line range), `description`, `current_code` (if any), `suggested_fix`, and `reason` (e.g. "CLAUDE.md adherence", "logic bug", "git history").

- **Agent 1 — CLAUDE.md compliance**: read each CLAUDE.md, then check the diff for violations. CLAUDE.md is guidance for *writing* code, so not every instruction applies during review — judge accordingly.
- **Agent 2 — shallow bug scan**: read only the diff (no extra context) and flag obvious bugs: logic errors, off-by-one, null/undefined access, race conditions, missing error handling, security issues (injection, hardcoded secrets, insecure defaults, missing auth checks). Focus on real bugs; ignore nits.
- **Agent 3 — historical context**: run `git blame` and read recent history of the modified lines/files; flag bugs that are only obvious in light of prior changes (e.g. a recently added invariant the diff breaks).
- **Agent 4 — prior PR feedback**: find merged PRs that touched these files and read review comments on them, then flag guidance that also applies to the current diff. To find them: `git log --pretty=format:%H -n 20 -- <path>` for recent commits on each path, then `gh api repos/{owner}/{repo}/commits/<sha>/pulls --jq '.[].number'` to map each commit to its PR. Read comments via `gh api repos/{owner}/{repo}/pulls/<num>/comments`. (`gh pr list --search` does not support a `path:` qualifier — don't use it for this.)
- **Agent 5 — docs and tests quality**: review documentation and test changes specifically.
  - Documentation: flag content that is redundant with the code, speculative, verbose, stale, or missing a non-obvious *why*. Goal: minimal, useful, simple.
  - Tests: flag tests that test the framework, are over-specified, duplicate existing coverage, miss obvious edges tied to the change, mock where real calls are cheap, or have unclear arrange/act/assert.

### Phase 3b: Score each finding

For each finding returned in 3a, dispatch a Haiku agent (or score inline if dispatch overhead isn't worth it for a small set). Each agent receives the PR diff, the finding, and the CLAUDE.md path list, and returns a confidence score 0–100:

- **0** — false positive that doesn't survive light scrutiny, or a pre-existing issue.
- **25** — might be real, might not; couldn't verify. If stylistic, not explicitly called out by CLAUDE.md.
- **50** — verified real but minor; nit or rare in practice.
- **75** — verified, likely to bite in practice; the PR's approach is insufficient. Or: explicitly named in CLAUDE.md.
- **100** — certain; evidence directly confirms it.

For CLAUDE.md-flagged findings, the scorer must verify that the cited CLAUDE.md actually says what was claimed.

### Phase 3c: Filter

Discard findings that match any of these false-positive patterns:

- Pre-existing issues not introduced by this PR
- Pedantic nits a senior engineer wouldn't raise
- Anything a linter, typechecker, or compiler catches (imports, types, formatting) — assume CI runs
- Issues silenced in code on purpose (e.g. lint-ignore comments)
- Likely-intentional changes related to the broader change
- Findings on lines the user did not modify

Keep only findings with score **≥ 75**, **except**: keep all `DOCS` and `TESTS` findings with score ≥ 50, since those are core to this skill's purpose and the official rubric undervalues them.

Categorize each surviving finding:

| Category      | Meaning                                        |
|---------------|------------------------------------------------|
| `BUG`         | Definite or likely bug                         |
| `SECURITY`    | Security vulnerability / concern               |
| `IMPROVEMENT` | Enhancement suggestion                         |
| `DOCS`        | Documentation/comment issue                    |
| `TESTS`       | Test quality, coverage, or correctness issue   |

If no findings survive, present "No findings — checked for bugs, CLAUDE.md compliance, docs, and tests" and stop.

Otherwise present a **short summary only** — one line per finding with category, file, and description (with score in parentheses). Do NOT show code snippets or suggested fixes yet:

> Found 3 findings:
> 1. **BUG** (95) — `src/auth.py` — missing null check on user lookup
> 2. **SECURITY** (80) — `src/api.py` — SQL query built with string concatenation
> 3. **DOCS** (60) — `README.md` — restates what the code already shows

## Step 4: Present findings one by one

> **CRITICAL: Present exactly ONE finding per message. After showing the finding and asking for approval, STOP your response and WAIT for the user to reply. Do NOT present the next finding until the user has responded.**

For the **next pending** finding, show the user:

- **Category** (BUG / SECURITY / IMPROVEMENT / DOCS / TESTS)
- **File & line range** (or location, if proposing new code)
- **Current code** at that location, if any
- **What's wrong** and why it matters
- **Suggested fix** — concrete replacement, deletion, or new code as appropriate

Then ask, depending on mode:

- **remote**: **"Queue this for the PR review? (approve / revise / skip)"**
- **local**: **"Apply this fix locally as a commit? (approve / revise / skip)"**

Wait for the user's response before continuing.

When the user responds:

- **approve** — execute the action for the current mode (see below), mark the finding as completed, then present the next finding
- **revise** — user provides adjustments, re-present the revised finding and ask again
- **skip** — mark the finding as completed, then present the next finding

### Remote mode: queueing approved comments

Do **not** post comments one-by-one. Approved findings are queued and submitted as a single PR review at the end (Step 5).

For each approved finding, append an entry to the queue containing:

- `path` — file path
- `line` — line number on the new side of the diff (for a multi-line range, also set `start_line`)
- `body` — plain explanation; include a ` ```suggestion ` block when a direct replacement applies

Comment-body rules: see "Tone and wording for feedback" at the top of this skill. Example body:

    This can raise a NullPointerException when `user` is not found.

    ```suggestion
    user = get_user(id)
    if user is None:
        raise ValueError(f"User {id} not found")
    ```

For broader observations that don't map to a single code replacement, just write the explanation without a suggestion block.

### Local mode: applying an approved fix

Re-read the file before applying the fix — line numbers and surrounding context from the original diff may have drifted as earlier findings were committed.

Apply the suggested fix to the working tree using the Edit tool. Then create one atomic commit per approved finding:

```bash
git add <changed-files>
git commit -m "<message>"
```

Commit message rules:

- Match the repo's existing commit style (use the `git log` output captured in Step 0).
- One short subject line that names what was fixed, not the review process. Good: `fix: null check on user lookup`. Bad: `address review finding #1`.
- One finding = one commit. Do not batch multiple findings into a single commit, even if they touch the same file.
- Before committing, verify the working tree contains only the changes for this finding (`git status` / `git diff --staged`). If unrelated changes leaked in, stop and ask the user.

If the fix turns out to require changes you can't make safely (e.g. needs broader refactor, breaks tests you can't run, ambiguous intent), tell the user and treat it as **skip** rather than committing a partial fix.

## Step 5: Submit and summarize

### Remote mode: submit the queued review

If the queue is empty, skip submission.

Otherwise, submit all queued comments as a single PR review. `gh pr review` does not support inline comments, so use `gh api` (it auto-substitutes `{owner}` and `{repo}` from the current repo). Capture the response so the summary can link the review:

```bash
gh api -X POST "repos/{owner}/{repo}/pulls/<PR_NUMBER>/reviews" \
  --jq '.html_url' \
  --input - <<'JSON'
{
  "event": "COMMENT",
  "body": "",
  "comments": [
    {"path": "<file>", "line": <line>, "body": "<body>"},
    {"path": "<file>", "start_line": <start>, "line": <end>, "body": "<body>"}
  ]
}
JSON
```

The `html_url` returned is the link to use in the summary below.

### Then present a summary

- Findings by category (BUG / SECURITY / IMPROVEMENT / DOCS / TESTS)
- Number actioned vs. skipped
- **remote**: link to the submitted review
- **local**: list of commit SHAs created, plus a reminder that the user still needs to push

## Safety Rules

- **Never submit a review or commit a fix without explicit user approval for each finding.**
- **Remote mode**: never modify code or commit — this mode only submits a PR review.
- **Local mode**: never push, never amend existing commits, never rebase. Only create new commits on the current branch.
- If a finding overlaps with an existing PR comment, note the overlap and let the user decide.
