---
spec: specs/briefs/project-sequencing-and-status/03-spec-and-breakdown.md
slice: 03
step: 4
title: Remove standalone breakdown.md command
status: todo
depends_on: [03-phase7-breakdown-tasks-gate.md]
agent_type: architect
assigned_at: null
completed_at: null
---

## Work

Delete `defaults/commands/breakdown.md`. Breakdown logic is now internal to `/design` Phase 7.

Verify no other command file references `/breakdown` as a user-facing command before deleting. If any do, update those references to point to `/design` instead.

## Context

Read first:
- `defaults/commands/breakdown.md` — confirm it's safe to remove (no unique logic that hasn't been replicated in Phase 7)

## Done signal

`defaults/commands/breakdown.md` absent from repo. No other command file refers to `/breakdown` as a standalone command.
