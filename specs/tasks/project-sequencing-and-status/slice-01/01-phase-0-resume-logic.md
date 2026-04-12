---
spec: specs/briefs/project-sequencing-and-status/01-project-creation-and-design-interview.md
slice: 01
step: 1
title: Rewrite design.md phase 0 — project detection and resume logic
status: done
depends_on: []
agent_type: architect
assigned_at: 2026-04-11T15:30:00-07:00
completed_at: 2026-04-11T15:45:00-07:00
---

## Work

Rewrite phase 0 of `defaults/commands/design.md` to handle all four entry states:

1. **No project folder** → proceed to creation (step 2 handles this)
2. **Folder exists, status `design_in_progress`, no `design-01.md`** → inform user interview didn't complete, restart interview
3. **Folder exists, status `design_in_progress`, `design-01.md` exists** → skip interview, advance status to `design_review`, show review gate
4. **Folder exists, status `design_review` or later** → show review gate or forward to correct stage

Phase 0 must read `status.md` first — it is authoritative. File existence is checked only to handle the partial-state case within `design_in_progress`.

If no argument is passed and multiple projects exist at non-complete stages, list them and ask which to resume or offer to start a new one.

## Context

Read first:
- `specs/briefs/project-sequencing-and-status/01-project-creation-and-design-interview.md` — full brief with observable outcomes and constraints
- `specs/design/project-sequencing-and-status.md` — "status update is always last" invariant and resume logic

## Done signal

Running `/design` in each of the four states produces the correct behaviour per the observable outcomes in the brief. Verified by reading the updated phase 0 and confirming each branch is handled.
