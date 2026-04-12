---
spec: specs/briefs/project-sequencing-and-status/05-implement-v1-single-project.md
slice: 05
step: 3
title: Phase 3 — agent team suggestion
status: todo
depends_on: [02-implement-phase2-worktree.md]
agent_type: architect
assigned_at: null
completed_at: null
---

## Work

Add Phase 3 to `defaults/commands/implement.md`:

1. Read all task files in `.orchestration/projects/{id}/tasks/slice-{NN}/` with `status: todo`.
2. Collect the unique set of `agent_type` values across those tasks.
3. Display suggested team:
   ```
   Suggested agent team for {id}:
     - {agent_type} ({N} tasks)
     - {agent_type} ({N} tasks)

   Confirm or adjust before tasks begin:
   ```
4. Wait for user confirmation. User can remove agent types or add others.
5. Do not proceed to Phase 4 until confirmed.

## Context

Read first:
- `specs/briefs/project-sequencing-and-status/05-implement-v1-single-project.md`

## Done signal

Agent team displayed with task counts per type. Execution blocked until user confirms. Adjusted team (user removes a type) is reflected in the confirmed set.
