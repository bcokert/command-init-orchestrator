---
type: slice
slice: 06
order: 6
project: project-sequencing-and-status
design: specs/design/project-sequencing-and-status.md
status: tasks_ready
---

# Slice 06 — `/implement` v2: concurrent projects

**Goal:** Multiple projects can be in `implementing` simultaneously. Each gets its own worktree on its own branch. Starting a new project while others are running is normal — `/implement` selects from all `tasks_ready` projects, regardless of what's already in flight.

## Happy path

- One project already `implementing` → user runs `/implement` again → sees `tasks_ready` projects listed (not the in-flight one) → picks one → new worktree created → both projects run concurrently on separate branches
- `/status` (no arg) lists all active projects: each shows stage, worktree path, branch, next action, time in stage
- Each project reaches `signoff_review` independently — `/review` runs per-project, not as a batch

## Edge cases

- All `tasks_ready` projects already have worktrees (resuming after crash): `/implement` resumes the right one without creating a duplicate
- Two projects in `implementing` simultaneously, one fails mid-task: other project unaffected, failing project stays at last known task state
- User runs `/implement` with no `tasks_ready` projects and nothing `implementing`: "no projects ready — run /design to start one"
- User runs `/implement` when only `implementing` projects exist: "project '{id}' is already running in {worktree_path} — run /implement to resume it" (routes to resume)
