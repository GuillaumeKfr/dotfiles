---
name: review-all
description: >
  Run ponytail-review, simplify and code-review on the current branch's diff,
  merge their findings into one prioritized list (priority, impact, effort),
  then process items one-by-one with user approval, committing each approved
  fix atomically. Use when the user asks for a full, combined or all-in-one
  review of the branch.
---

# Review All

## Prerequisites

- Git repo; `gh` optional (used to find the PR base).
- Clean working tree. Each approved item becomes its own commit.

```bash
git status --porcelain
git log -n 5 --pretty=format:'%s'
```

If the tree is dirty, stop and tell the user. Use the `git log` output to match the repo's commit message style.

## Step 1: Resolve the diff

Base is the PR base if one exists, else `main`:

```bash
gh pr view --json baseRefName --jq .baseRefName
git diff <base>...HEAD
```

If the diff is empty, tell the user and stop.

## Step 2: Run the three reviews in parallel

In a single message, launch three subagents (Agent tool, general-purpose), one per skill: `ponytail:ponytail-review`, `simplify`, `code-review`. Each prompt must state the diff target (`git diff <base>...HEAD`) and require **report-only** mode:

- Do not edit files, stage, or commit. `simplify` normally applies fixes: tell it to return the fixes it would make instead.
- Do not pass `--fix` or `--comment` to `code-review`.
- Return findings only, one per line: `file:line | summary | suggested fix`.

After they return, check `git status --porcelain` is still clean. If not, report which skill edited files and stop.

## Step 3: Merge and rank

- Deduplicate findings on the same file and overlapping lines. Keep every source tag (e.g. `[code-review, simplify]`); agreement across skills raises confidence.
- Score each item:
  - **Priority**: P1 correctness/security bug, P2 meaningful cleanup/reuse/efficiency, P3 nit or over-engineering trim.
  - **Impact**: high / med / low (risk removed or maintenance win).
  - **Effort**: S / M / L (size of the change).
- Sort by priority, then impact (high first), then effort (small first).

Present a table: `# | prio | impact | effort | source | location | summary`. Ask whether any items should be dropped before starting.

## Step 4: Process each item

Track progress as a checklist. For each item, in order:

1. Show the item and the proposed change (before/after or a clear description). Re-read the file first: earlier commits may have shifted lines or made the item obsolete. If so, say so and move on.
2. Ask: **"Apply this fix? (approve / revise / skip)"**
   - **approve**: edit, then commit.
   - **revise**: ask what to change, re-propose.
   - **skip**: next item.
3. Commit only the files for this item:

```bash
git add <changed_files>
git commit -m "<type>(<scope>): <summary>"
```

Match the style from Step 0. Use `refactor` for cleanups, `fix` for bugs.

If an item overlaps with a later one, warn the user.

## Step 5: Summary

List items applied (with short SHAs), skipped, and obsolete. Remind the user to `git push` when ready.

## Safety Rules

- **Never push automatically.**
- **Never edit or commit without explicit approval for that item.**
- Stage only files related to the current item.
- Do not fix anything that is not in the approved list.
