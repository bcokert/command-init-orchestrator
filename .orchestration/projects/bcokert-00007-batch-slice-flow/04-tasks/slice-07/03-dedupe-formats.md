---
spec: .orchestration/projects/bcokert-00007-batch-slice-flow/03-briefs/07-status-rewrite.md
slice: 07
step: 3
title: Dedupe count format + hoist date-format rule
status: todo
depends_on: [02-merge-state-tables.md]
agent_type: architect
model: sonnet
effort: default
assigned_at: null
completed_at: null
qa_result: null
---

Collapse the two duplicate "Counts format" definitions in `defaults/commands/status.md` into one. Hoist the date-format rule (MMM D / omit current year / `—` if absent) to a single sentence; remove per-render-block restatements.

**Done signal:** Each definition appears once.
