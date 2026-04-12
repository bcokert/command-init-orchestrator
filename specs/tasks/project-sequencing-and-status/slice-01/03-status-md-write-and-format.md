---
spec: specs/briefs/project-sequencing-and-status/01-project-creation-and-design-interview.md
slice: 01
step: 3
title: Implement status.md write and format
status: done
depends_on: [02-folder-creation-and-id-generation.md]
agent_type: architect
assigned_at: 2026-04-11T15:30:00-07:00
completed_at: 2026-04-11T15:45:00-07:00
---

## Work

Write `status.md` to the project folder immediately after folder creation — before any interview interaction. Format:

```yaml
stage: design_in_progress
project_id: {id}
next_action: complete design interview
transitions:
  - stage: design_in_progress
    timestamp: {ISO 8601 with timezone offset}
    note: project created
```

Timestamp must be ISO 8601 with timezone offset (e.g. `2026-04-11T14:00:00-07:00`), not UTC-normalised.

The status advance to `design_review` (step 4) appends a second transition entry — do not write it here.

## Context

Read first:
- `specs/briefs/project-sequencing-and-status/01-project-creation-and-design-interview.md` — exact required format under Constraints

## Done signal

`status.md` exists in the project folder immediately after folder creation. File matches the required format exactly. Timestamp is valid ISO 8601. Stage is `design_in_progress`. One transition entry present.
