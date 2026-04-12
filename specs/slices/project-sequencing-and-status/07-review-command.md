---
type: slice
slice: 07
project: project-sequencing-and-status
design: specs/design/project-sequencing-and-status.md
status: specced
---

# Slice 07 — `/review` command

**Goal:** `/review` on a `signoff_review` project either approves (merges worktree, archives to `done/YYYY-MM/`) or records feedback (adds new slice files to the backlog, user runs `/design` to continue).

## Happy path

- **Approve:** QA report + slice summary presented → human approves → branch merged to main → `git worktree remove` → project moved to `done/YYYY-MM/{id}/` → `stage: done` committed + pushed
- **Feedback:** feedback recorded as new slice files in `02-slices/` with `status: draft` → `stage: feedback_pending` set → output: "feedback recorded — run `/design` to spec the next slice"
- All wrong commands at `signoff_review` → "project is in signoff_review — run `/review`"

## Edge cases

- Approve, merge fails (conflict): project stays `signoff_review`, worktree preserved, instructions to resolve manually then re-run `/review`
- Feedback, user runs `/implement` on `feedback_pending` project: "project has unprocessed feedback — run `/design` to spec the next slice"
- Archive target already exists: error with instructions, no overwrite
