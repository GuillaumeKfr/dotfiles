---
name: review-pr-comments
description: >
  Review comments on a GitHub pull request, analyze each for relevance,
  propose code fixes or explain why not relevant, and after user approval
  commit changes and reply to the comment on GitHub. Use when the user asks
  to review PR comments, handle PR feedback, or address review comments.
---

# Review PR Comments

## Prerequisites

- `gh` CLI authenticated and available in PATH
- Git repo with the PR branch checked out locally

## Step 1: Identify the PR

Ask the user for the PR number or URL if not provided. Then fetch PR metadata:

```bash
gh pr view <PR_NUMBER> --json number,title,headRefName,baseRefName,url
```

Confirm you are on the correct branch. If not, check it out:

```bash
git checkout <headRefName>
git pull origin <headRefName>
```

## Step 2: Fetch all review comments

```bash
gh api repos/{owner}/{repo}/pulls/<PR_NUMBER>/comments \
  --jq '.[] | {id, path, line, body, user: .user.login, in_reply_to_id, html_url}'
```

Also fetch issue-level (general) comments:

```bash
gh api repos/{owner}/{repo}/issues/<PR_NUMBER>/comments \
  --jq '.[] | {id, body, user: .user.login, html_url}'
```

Filter out comments authored by the current user. Group threaded comments by `in_reply_to_id` so you process each top-level thread once.

## Step 3: Process each comment

Use a TodoWrite checklist to track progress across comments. For **each** comment thread:

### 3a. Present the comment

Show the user:
- **Author** and link to the comment
- **File & line** (if it's a review comment)
- **Comment body** (full text)
- The **current code** at that location (read the file)

Then ask: **"Do you want to address this comment? (yes / skip)"**

If the user says **skip**, move to the next comment.

### 3b. Analyze relevance

Read the referenced file and surrounding context. Determine if the comment is relevant:

- **Relevant**: the comment identifies a real issue (bug, style violation, performance concern, missing test, security issue, logic error, etc.) or requests a valid change.
- **Not relevant**: the comment is based on a misunderstanding, is outdated, conflicts with project conventions, or the code is already correct.

### 3c. If RELEVANT -- propose a fix

1. Show the user:
   - Your assessment of the comment
   - The proposed code change (show the before/after or describe the change clearly)
2. Ask: **"Apply this fix? (approve / revise / skip)"**
   - **approve** -- proceed to implement, commit, and reply
   - **revise** -- ask what to change, then re-propose
   - **skip** -- move to next comment
3. Apply the code changes using the appropriate editing tools.
4. Commit the changes:

```bash
git add <changed_files>
git commit -m "$(cat <<'EOF'
fix(pr-review): address review comment on <file>:<line>

<One-line summary of what the comment asked for and what was changed.>

PR-Comment: <html_url of the comment>
EOF
)"
```

5. Capture the commit SHA:

```bash
git rev-parse HEAD
```

6. Reply to the PR comment:

```bash
gh api repos/{owner}/{repo}/pulls/comments/<comment_id>/replies \
  -f body="$(cat <<'EOF'
Fixed in <commit_sha>.

<Brief explanation of the change made and why it addresses the feedback.>
EOF
)"
```

### 3d. If NOT RELEVANT -- explain why

1. Show the user:
   - Your assessment: why the comment is not relevant
   - Supporting evidence (code context, project conventions, etc.)
2. Ask: **"Reply explaining this is not applicable? (approve / revise / skip)"**
   - **approve** -- post the reply
   - **revise** -- adjust the explanation, then re-ask
   - **skip** -- move to next comment
3. Reply to the PR comment:

```bash
gh api repos/{owner}/{repo}/pulls/comments/<comment_id>/replies \
  -f body="$(cat <<'EOF'
Thanks for the feedback! After reviewing, I believe this doesn't need a change because:

<Clear, polite explanation of why the comment is not applicable.>

Happy to discuss further if you see it differently.
EOF
)"
```

For issue-level (non-inline) comments, use the issues comments endpoint instead:

```bash
gh api repos/{owner}/{repo}/issues/<PR_NUMBER>/comments \
  -f body="<reply body>"
```

## Step 4: Summary

After all comments are processed, present a summary:
- Number of comments addressed (with commit SHAs)
- Number of comments marked not relevant (with brief reasons)
- Number of comments skipped
- Remind the user to `git push` when ready

## Safety Rules

- **Never push automatically** -- only commit locally. The user decides when to push.
- **Never reply to a comment without explicit user approval.**
- **Never skip the approval step** -- always wait for the user to confirm.
- **Stage only files related to the current comment** -- do not bundle unrelated changes.
- If a fix touches code that overlaps with another comment, warn the user about potential conflicts.
