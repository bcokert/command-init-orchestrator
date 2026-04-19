---
type: task
slice: 06
step: 2
project: bcokert-00003-remove-worktree-replace-task-queuing
brief: .orchestration/projects/bcokert-00003-remove-worktree-replace-task-queuing/03-briefs/06-fix-review-multi-slice-archive.md
agent_type: general-purpose
model: sonnet
effort: default
status: done
assigned_at: 2026-04-19T09:06:00-07:00
completed_at: 2026-04-19T09:08:00-07:00
depends_on: [task-01-rewrite-phase0-routing]
---

# Task 02 — Add archive eligibility gate to Phase 1

In `defaults/commands/review.md` Phase 1 (approve path), after writing `status: done` to the slice file and committing, add an archive eligibility check: read all slice files in the project's `02-slices/` directory and check their `status` fields. Only archive if every slice is `status: done`. If any are not done: output "Slice {NN} done — {N} slices remaining. Run /plan-project or /implement to continue." and stop.

Edge case: if a slice file cannot be read, treat it as not-done (conservative) and log a warning.

**Done signal:**
```
grep "slices remaining" defaults/commands/review.md → one match
```
