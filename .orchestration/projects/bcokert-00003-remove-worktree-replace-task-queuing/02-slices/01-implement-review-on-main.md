---
type: slice
slice: 01
order: 01
project: remove-worktrees-queue-model
design: .orchestration/projects/bcokert-00003-remove-worktree-replace-task-queuing/01-design/design-01.md
status: done
status_updated_at: 2026-04-18T09:30:00-07:00
---

# Slice 01 — Implement and review run on main

**Goal:** Remove worktrees from the implement/review execution path. No worktree is created, no branch is switched, no merge step happens. All changes accumulate on main and commit there at review.

## Happy path

- Running `/implement` on a `tasks_ready` project starts task execution immediately — no `git worktree add`, no branch creation, no directory at `.orchestration/worktrees/`.
- `status.md` no longer gets `worktree_path` or `branch` fields written during implementation.
- Slice file status writes in Phase 3 use the main project path (`.orchestration/projects/{id}/02-slices/`) not a worktree path.
- After all tasks complete and QA passes, `/review` commits and pushes all changes from main with no merge step.
- The signoff commit includes implementation files, task status updates, QA report, and slice status — same as before, just from main.

## Edge cases

- Old `status.md` with `worktree_path` set: implement ignores the field silently and proceeds normally.
- Old `worktree_created` transition note in history: no error — transition history is displayed only, not used for routing.
- Routing table error messages that referenced worktree paths (e.g. "implementing in worktree {path}"): updated to drop the path.
- Resume detection (`implementing` stage on re-entry): checks task file statuses — any task with `status: in_progress` or the first `status: todo` task is the resume point. No directory existence check.

## Files touched

- `defaults/commands/implement.md` — remove Phase 1 entirely; remove `worktree_path`/`branch` from all status.md writes; fix slice file path references; update routing error message; simplify resume logic
- `.claude/commands/implement.md` — sync from defaults
- `defaults/commands/review.md` — remove merge phase; remove worktree-remove phase; commit directly from main; fix slice file path to use main project path; update behavior rules
- `.claude/commands/review.md` — sync from defaults
