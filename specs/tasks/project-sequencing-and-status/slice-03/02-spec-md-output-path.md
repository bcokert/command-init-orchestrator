---
spec: specs/briefs/project-sequencing-and-status/03-spec-and-breakdown.md
slice: 03
step: 2
title: Update spec.md output path
status: done
depends_on: [01-phase6-spec-write-and-gate.md]
agent_type: architect
assigned_at: null
completed_at: null
---

## Work

Update `defaults/commands/spec.md` so its save path writes to `.orchestration/projects/{id}/briefs/{NN}-{slug}.md`.

Path change only — brief format, stress-test logic, and escalation rules unchanged.

## Context

Read first:
- `defaults/commands/spec.md` — current save path instructions (Phase 4)

## Done signal

Brief appears at `.orchestration/projects/{id}/briefs/{NN}-{slug}.md` after spec runs. Existing brief format and content are unchanged.
