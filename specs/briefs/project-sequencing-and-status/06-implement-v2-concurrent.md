---
type: brief
slice: 06
project: project-sequencing-and-status
design: specs/design/project-sequencing-and-status.md
slice_doc: specs/slices/project-sequencing-and-status/06-implement-v2-parallel.md
status: ready
date: 2026-04-12
---

# Delegation brief — Slice 06: `/implement` v2 concurrent projects

## Intent

Extend `defaults/commands/implement.md` to support concurrent projects. The v1 implementation (slice 05) handles one project at a time. This slice removes that restriction: multiple projects can be in `implementing` simultaneously because each gets its own worktree on its own branch. Starting a new project while others are running is the expected workflow, not an edge case.

The core change is simple: `/implement` should offer all `tasks_ready` projects regardless of how many are already in flight. The worktree isolation already handles the rest.

## Observable outcomes

**Start a second project while one is already implementing:**
```
Given project A is in stage: implementing with worktree at .orchestration/worktrees/project-a
And project B is in stage: tasks_ready
When the user runs /implement
Then project B is offered for selection (project A is not — it's already running)
And a new worktree is created for project B
And both projects proceed independently
```

**Resume a running project:**
```
Given project A is in stage: implementing
When the user runs /implement with project A's ID
Then the command resumes from the first in_progress or next todo task
```

**No tasks_ready, nothing to resume:**
```
Given no projects are in tasks_ready
And all implementing projects are already running
When the user runs /implement
Then output: "no projects ready — run /design to start one"
```

**Only implementing projects, no tasks_ready:**
```
Given one or more projects are in implementing
And no projects are in tasks_ready
When the user runs /implement with no argument
Then output: "project '{id}' is already running in {worktree_path} — pass a project ID to resume it"
And lists the implementing projects so the user knows what to pass
```

**One project fails mid-task:**
```
Given project A and project B are both implementing
When a task in project A fails
Then project B is unaffected and continues
And project A stays at the last known task state with a clear error
```

## Constraints

**Must:**
- Show all `tasks_ready` projects regardless of how many are in `implementing`
- Treat concurrent projects as the normal case, not an edge case
- Resume detection: if a project has `worktree_path` set and the worktree exists, offer resume; if the worktree directory is missing, warn and leave at `implementing` (don't create a duplicate)

**Must not:**
- Offer already-implementing projects for new selection (they're already running)
- Cap concurrent projects at any fixed number — worktrees are cheap, the user decides how many to run

**Preferences:**
- If multiple `tasks_ready` projects exist and no argument was passed, list them and prompt selection — same as v1
- Wrong-command routing table stays the same; only the selection logic changes

**Escalation triggers:**
- Worktree directory missing for an `implementing` project: warn, suggest `git worktree prune`, don't auto-delete

## Done definition

1. Running `/implement` with projects already in `implementing` shows `tasks_ready` projects, not in-flight ones
2. Two projects can be in `implementing` simultaneously with separate worktrees on separate branches
3. "no projects ready" message accounts for whether there are already-running projects (names them) vs truly nothing
4. Resume still works: passing an implementing project's ID resumes it from where it left off

## Breakdown

| # | Step | Deliverable | Done signal |
|---|------|-------------|-------------|
| 1 | Update project selection in implement.md Phase 0 | Selection filters to `tasks_ready` only, lists implementing projects separately if user runs with no arg and nothing is ready | Selection logic handles all combinations of tasks_ready vs implementing correctly |
| 2 | Update wrong-command routing for concurrent state | Error messages account for multiple implementing projects | Messages are accurate when 0, 1, or multiple projects are in flight |
| 3 | Update worktree resume detection | Resume detects existing worktree directory; warns if directory missing | No duplicate worktrees created on resume |
