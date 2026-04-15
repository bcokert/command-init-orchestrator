---
spec: specs/briefs/project-sequencing-and-status/04-status-v1.md
slice: 04
step: 3
title: Add error handling — malformed status.md and missing fields
status: done
depends_on: [02-status-no-arg-mode.md]
agent_type: architect
assigned_at: null
completed_at: null
---

## Work

Extend Phase 1 in `defaults/commands/status.md` to handle malformed or partial `status.md`:

1. After reading `status.md`, check each expected field: `stage`, `next_action`, `transitions`.
2. For each missing or unparseable field: show the field name with a warning instead of its value:
   ```
   stage:    [missing — check status.md]
   next:     [missing — check status.md]
   ```
3. If `transitions` is missing or empty: show "no transitions recorded" in place of the transitions block.
4. If the entire file is absent (project folder exists but no status.md): output a specific warning:
   ```
   project {id} exists but status.md is missing — the project may be in an inconsistent state.
   ```
5. Never crash — always show as much as is readable.

Also handle: `stage` present but value is `done` — the project has been archived. Output:
```
project {id} is done and has been archived to .orchestration/projects/done/
```

## Context

Read first:
- `specs/briefs/project-sequencing-and-status/04-status-v1.md` — malformed status.md constraints

## Done signal

`/status {id}` on a project with a missing `stage` field shows warning for that field, displays remaining fields normally, does not crash. Project folder with no status.md shows specific warning.
