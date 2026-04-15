---
spec: specs/briefs/project-sequencing-and-status/02-slicing-step.md
slice: 02
step: 1
title: Wire Phase 5 — slicing_in_progress status and resume detection
status: done
depends_on: []
agent_type: architect
assigned_at: null
completed_at: null
---

## Work

In `defaults/commands/design.md` Phase 5, add the status transition and resume logic before any slice files are written:

1. When Phase 5 begins (entering from `design_review` approval), write `slicing_in_progress` to `status.md` as the first operation.
2. On resume (entering Phase 5 with `status: slicing_in_progress`):
   - Check `.orchestration/projects/{id}/slices/` for existing files.
   - If any exist (partial output): discard them all, log "previous slicing incomplete — regenerating", proceed with full slicing.
   - If none exist: proceed with full slicing.
3. Always re-read `design-{NN}.md` from disk before slicing — never use cached content.

## Context

Read first:
- `specs/briefs/project-sequencing-and-status/02-slicing-step.md` — resume observable outcomes and "status advance is always last" constraint

## Done signal

`status.md` shows `slicing_in_progress` before any slice file exists. Simulating partial output (some files in `slices/`) triggers full regeneration with a log message.
