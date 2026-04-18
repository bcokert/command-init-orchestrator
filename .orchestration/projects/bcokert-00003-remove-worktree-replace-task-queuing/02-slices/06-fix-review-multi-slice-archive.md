---
type: slice
slice: 06
order: 06
project: remove-worktrees-queue-model
design: .orchestration/projects/bcokert-00003-remove-worktree-replace-task-queuing/01-design/design-01.md
status: draft
---

# Slice 06 — Fix /review premature archive for multi-slice projects

**Goal:** `/review` currently archives the project after any approved slice. For multi-slice projects, it should only archive when all slices are done. If slices remain, it should reset the project to `tasks_ready` and prompt the user to run `/implement`.

## Happy path

- User approves slice 02 of a 5-slice project. `/review` commits the changes, then checks remaining slice statuses.
- Remaining slices (03–05) are still `tasks_ready` / `todo`. `/review` updates `status.md` to `tasks_ready` (not `done`) and outputs: "Slice 02 done — N slices remaining. Run /implement to continue."
- When the final slice is approved and no `todo`/`tasks_ready` slices remain, `/review` archives as normal.

## Edge cases

- All slices show `done` on approval of the last one: archive proceeds as today.
- Slice file statuses unreadable: treat conservatively — do not archive, warn and leave at `tasks_ready`.
- `/status` should correctly show the project as active (not done) after a mid-project slice approval.
