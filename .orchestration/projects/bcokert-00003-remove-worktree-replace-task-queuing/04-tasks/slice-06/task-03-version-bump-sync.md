---
type: task
slice: 06
step: 3
project: bcokert-00003-remove-worktree-replace-task-queuing
brief: .orchestration/projects/bcokert-00003-remove-worktree-replace-task-queuing/03-briefs/06-fix-review-multi-slice-archive.md
agent_type: general-purpose
model: sonnet
effort: default
status: done
assigned_at: 2026-04-19T09:08:00-07:00
completed_at: 2026-04-19T09:09:00-07:00
depends_on: [task-02-archive-eligibility-gate]
---

# Task 03 — Bump version to 1.3.0 and sync to .claude/commands/

Bump `defaults/commands/review.md` version from 1.2.0 to 1.3.0. Then copy the file to `.claude/commands/review.md` so the local install stays in sync.

**Done signal:**
```
grep "^version:" defaults/commands/review.md → version: 1.3.0
diff defaults/commands/review.md .claude/commands/review.md → no output
```
