---
spec: specs/briefs/project-sequencing-and-status/06-implement-v2-concurrent.md
slice: 06
step: 2
title: Update wrong-command routing for concurrent state
status: todo
depends_on: [01-project-selection-logic.md]
agent_type: architect
assigned_at: null
completed_at: null
---

## Work

Update the wrong-command routing table in `defaults/commands/implement.md` Phase 0 Step 2 to handle the case where multiple projects can be in `implementing` simultaneously.

The current table has a single `implementing` row. It needs to account for:
- User passes a specific `implementing` project ID → route to resume (correct command)
- User passes no argument and only `implementing` projects exist → list them, prompt to pass an ID
- No change needed for stages that were already wrong (`design_in_progress`, `signoff_review`, etc.)

Also update the error message for `signoff_review` to work per-project — a user might have one project awaiting signoff while another is still implementing.

## Done signal

All wrong-command cases produce accurate messages. Messages are correct when 0, 1, or multiple projects are in `implementing` simultaneously.
