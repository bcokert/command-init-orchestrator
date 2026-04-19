---
type: slice
slice: 02
order: 02
project: remove-worktrees-queue-model
design: .orchestration/projects/bcokert-00003-remove-worktree-replace-task-queuing/01-design/design-01.md
status: done
status_updated_at: 2026-04-18T10:15:00-07:00
---

# Slice 02 — Status command reads from main only

**Goal:** Remove all worktree-reading logic from the status command. No `git worktree list`, no worktree path resolution, no `worktree_missing` state.

## Happy path

- `/status` shows correct project state without running `git worktree list`.
- Single-project detail view has no `worktree:` field in output.
- Summary table has no `worktree_missing` warning rows.
- `slice_base_path` is always `.orchestration/projects/{id}`.

## Edge cases

- `status.md` still has `worktree_path` field (old project): field is ignored, not displayed.
- Old `worktree_missing` warning path: code path removed, not left as dead branch.

## Files touched

- `defaults/commands/status.md` — remove `git worktree list` call; remove worktree path resolution; remove `worktree_missing` handling; remove `worktree:` from single-project output; remove worktree behavior rules
- `.claude/commands/status.md` — sync from defaults
