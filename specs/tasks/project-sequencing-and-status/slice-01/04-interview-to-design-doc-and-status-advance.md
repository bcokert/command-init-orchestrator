---
spec: specs/briefs/project-sequencing-and-status/01-project-creation-and-design-interview.md
slice: 01
step: 4
title: Wire interview through to design-01.md write and status advance
status: todo
depends_on: [03-status-md-write-and-format.md]
agent_type: architect
assigned_at: null
completed_at: null
---

## Work

Connect the design interview phases to the new project structure:

- Interview phases (discovery, writing, bdonizing) run as before — existing logic in `design.md` is reused
- On interview completion, write `design-01.md` to `.orchestration/projects/{id}/design-01.md`
- After `design-01.md` is written, append a second transition to `status.md`:
  ```yaml
  - stage: design_review
    timestamp: {ISO 8601}
    note: design interview complete
  ```
- Update `next_action` field in `status.md` to `review design doc and run /design to continue`
- Status advance (`stage: design_review`) is the last write operation before commit

## Context

Read first:
- `specs/briefs/project-sequencing-and-status/01-project-creation-and-design-interview.md` — observable outcomes and "status update is always last" constraint

## Done signal

`design-01.md` exists at the correct path after interview completes. `status.md` shows `stage: design_review` with two transitions, second timestamp after first. `next_action` is updated.
