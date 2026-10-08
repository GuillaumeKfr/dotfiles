---
name: comment-style
description: >
  Shared tone and format rules for any user-facing comment we publish: PR
  review comments and replies, issues, Slack messages, etc. Load it before
  drafting any comment body.
---

# Comment style

Applies to every user-facing comment or reply body we publish (PRs, issues, Slack, ...). Commit messages are not comments — they keep the repo's own style.

## Tone and wording

- **Describe the issue, not the author.** "This can NPE when X" — not "you forgot to handle X".
- **Be concrete and specific.** Point at the exact symptom or scenario; avoid "this seems off" or "consider refactoring".
- **Suggest, don't mandate.** Phrase fixes as proposals ("consider...", "could become...") unless it's a clear bug or security issue.
- **One thought per comment.** If a finding contains two unrelated points, split it.
- **No throat-clearing.** No "great PR overall, but...", no "I think maybe you might want to consider...".
- **Plain prose after the label.** No headers or titles inside comment bodies.

## Format (Conventional Comments)

For new review comments (not replies or other channels). Follows https://conventionalcomments.org/ :

    **<label> (<decorations>):** <subject>

    <optional discussion>

- Labels: `praise`, `nitpick`, `suggestion`, `issue`, `todo`, `question`, `thought`, `chore`, `note`.
- Decorations (optional, comma-separated): `blocking`, `non-blocking`, `if-minor`.
- Use `question` when intent is unclear rather than asserting a defect.
