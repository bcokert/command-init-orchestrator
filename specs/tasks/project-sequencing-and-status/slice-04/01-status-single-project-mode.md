---
spec: specs/briefs/project-sequencing-and-status/04-status-v1.md
slice: 04
step: 1
title: Create status.md command — single-project mode
status: todo
depends_on: []
agent_type: architect
assigned_at: null
completed_at: null
---

## Work

Create `defaults/commands/status.md` with:

**Phase 0 — Detect mode**

If a project ID was passed as argument: proceed to Phase 1 (single-project mode).
If no argument: proceed to Phase 2 (no-arg mode).

**Phase 1 — Single-project detail view**

1. Resolve path: `.orchestration/projects/{id}/status.md`
2. If project folder does not exist: output "project {id} not found — run `/status` with no args to list projects". Stop.
3. Read `status.md`. Parse: `stage`, `next_action`, `transitions` list.
4. Compute elapsed time in current stage: time since the most recent transition's timestamp. Format as human-readable (e.g. `2h 14m`, `3d 7h`).
5. Display:

```
project:   {id}
stage:     {stage}
next:      {next_action}
elapsed:   {elapsed} (since {stage} at {timestamp of most recent transition})

Recent transitions:
  {timestamp}  {stage}  {note}
  {timestamp}  {stage}  {note}
  {timestamp}  {stage}  {note}
```

Show last 3 transitions, most recent first. If fewer than 3, show what exists.

## Context

Read first:
- `specs/briefs/project-sequencing-and-status/04-status-v1.md` — display format and constraints

## Done signal

`/status {id}` on a project with valid `status.md` outputs stage, next_action, elapsed time, and last 3 transitions in the correct format.
