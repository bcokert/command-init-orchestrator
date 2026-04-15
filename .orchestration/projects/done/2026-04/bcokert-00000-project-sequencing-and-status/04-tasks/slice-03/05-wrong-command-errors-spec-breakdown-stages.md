---
spec: specs/briefs/project-sequencing-and-status/03-spec-and-breakdown.md
slice: 03
step: 5
title: Add wrong-command errors for spec and breakdown stages
status: done
depends_on: [04-remove-breakdown-command.md]
agent_type: architect
assigned_at: null
completed_at: null
---

## Work

Extend the wrong-command routing table in `defaults/commands/design.md` Phase 0 Step 2 to cover spec and breakdown stages:

- `spec_in_progress`, `spec_review`, `breakdown_in_progress`: `/implement` or `/review` → "Project '{id}' is in {stage} — run `/design` to continue."
- `tasks_ready`: `/review` → "Project '{id}' is in tasks_ready — run `/implement` to start implementation." `/implement` is valid at this stage (no error).

Same extension pattern as slices 01 and 02 — add rows to the existing routing table.

## Context

Read first:
- `specs/briefs/project-sequencing-and-status/03-spec-and-breakdown.md` — wrong-command observable outcomes

## Done signal

Running `/implement` at `spec_in_progress` outputs correct error. Running `/review` at `tasks_ready` outputs correct error. Running `/implement` at `tasks_ready` does not error.
