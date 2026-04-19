---
type: task
slice: 06
step: 1
project: bcokert-00003-remove-worktree-replace-task-queuing
brief: .orchestration/projects/bcokert-00003-remove-worktree-replace-task-queuing/03-briefs/06-fix-review-multi-slice-archive.md
agent_type: general-purpose
model: sonnet
effort: default
status: done
assigned_at: 2026-04-19T09:05:00-07:00
completed_at: 2026-04-19T09:06:00-07:00
depends_on: []
---

# Task 01 — Rewrite Phase 0 routing in review.md

Edit `defaults/commands/review.md` Phase 0 Step 1 to scan slice files for `status: signoff_review` instead of scanning `status.md` for `stage: signoff_review`. Remove Step 2 (wrong-command routing table) — it's predicated on reading status.md stage. Add a clean "no work" fallback message.

Also update the with-argument path: when a project ID is passed, find the `signoff_review` slice within that project's `02-slices/` directory instead of reading status.md stage.

**Done signal:**
```
grep "status: signoff_review" defaults/commands/review.md → at least one match
grep "stage: signoff_review" defaults/commands/review.md → no output
```
