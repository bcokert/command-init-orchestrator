---
spec: .orchestration/projects/bcokert-00007-batch-slice-flow/03-briefs/07-status-rewrite.md
slice: 07
step: 2
title: Merge state abbreviation + next-action tables
status: done
depends_on: [01-phase-2-rewrite.md]
agent_type: architect
model: sonnet
effort: default
assigned_at: null
completed_at: null
qa_result: null
---

Combine the state-abbreviations table and next-action-commands table in `defaults/commands/status.md` into one wider table: `state | abbrev | emoji | command`. Drop legacy `reviewed` and `specced` rows.

**Done signal:** Single state table; complete state coverage; legacy rows gone.
