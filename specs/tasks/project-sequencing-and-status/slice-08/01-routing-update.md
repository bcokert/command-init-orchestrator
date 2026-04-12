---
spec: specs/briefs/project-sequencing-and-status/08-status-v2-multi-project.md
slice: 08
step: 1
title: Update Phase 0 routing — no-arg vs single-project
status: todo
depends_on: []
agent_type: architect
assigned_at: null
completed_at: null
---

## Work

Update `defaults/commands/status.md` Phase 0 to route based on whether an argument was passed:

- Argument passed: read that project's `status.md`, show single-project detail view (existing v1 behavior — preserve as-is)
- No argument: proceed to Phase 2 (multi-project scan)

Remove the current Phase 2 that prompts for project selection when no argument is passed — that was v1 behavior. The new no-arg mode shows all projects, not a selection prompt.

## Done signal

`/status {id}` shows single-project detail. `/status` with no argument proceeds to multi-project scan without prompting for selection.
