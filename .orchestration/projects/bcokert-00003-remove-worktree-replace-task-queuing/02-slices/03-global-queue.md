---
type: slice
slice: 03
order: 03
project: remove-worktrees-queue-model
design: .orchestration/projects/bcokert-00003-remove-worktree-replace-task-queuing/01-design/design-01.md
status: done
status_updated_at: 2026-04-18T10:15:00-07:00
---

# Slice 03 — Global queue in implement

**Goal:** `/implement` selects the next available slice from a global queue across all projects, not just one project. Ordering: by `status_updated_at` on the slice file when it reached `tasks_ready`; per-project slice number order always respected.

## Happy path

- With one project in `tasks_ready`: behaves as before.
- With two projects both in `tasks_ready`: picks the slice whose `status_updated_at` is earliest.
- Within a project, slice 01 runs before 02 regardless of timestamps.
- `/implement` with empty queue: "Nothing in the queue. Run /plan-project to create tasks." Stop.
- Dirty working tree: expected and allowed. Slices accumulate uncommitted changes until `/review` commits them. The queue does not gate on tree cleanliness.
- Adding new slices to the queue while one is running: always possible via `/plan-project`, which is independent of `/implement`.

## Edge cases

- All queued slices blocked (e.g. slice 01 of a project is at `implementing` but not done, so slice 02 can't start): reports which project/slice is blocking rather than silently skipping.
- Multiple slices from same project: ordering by timestamp must not cause slice 02 to run before slice 01.
- Agent team confirmation happens per-slice at start (unchanged from current flow).

## Files touched

- `defaults/commands/implement.md` — replace single-project selection with global queue scan; add dirty-tree guard on entry; add empty-queue message; update routing table descriptions
- `.claude/commands/implement.md` — sync from defaults
