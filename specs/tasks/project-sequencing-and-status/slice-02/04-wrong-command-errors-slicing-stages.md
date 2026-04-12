---
spec: specs/briefs/project-sequencing-and-status/02-slicing-step.md
slice: 02
step: 4
title: Add wrong-command errors for slicing stages
status: todo
depends_on: [03-phase5-completion-commit-gate.md]
agent_type: architect
assigned_at: null
completed_at: null
---

## Work

Extend the wrong-command routing table in `defaults/commands/design.md` Phase 0 Step 2 to cover slicing stages. When `/implement` or `/review` is run on a project at `slicing_in_progress` or `slicing_review`:

> "Project '{id}' is in {stage} — run `/design` to continue."

These two stages already exist in the Phase 0 routing table from slice 01 (which covers design stages). Extend that same table — no new mechanism needed.

## Context

Read first:
- `specs/briefs/project-sequencing-and-status/02-slicing-step.md` — wrong-command observable outcome

## Done signal

Running `/implement` on a project at `slicing_in_progress` outputs: "Project '{id}' is in slicing_in_progress — run `/design` to continue." Same for `slicing_review` and for `/review`.
