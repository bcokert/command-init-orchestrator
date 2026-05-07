---
spec: .orchestration/projects/bcokert-00007-batch-slice-flow/03-briefs/05-implement-rewrite.md
slice: 05
step: 5
title: Re-entry team-gate logic
status: todo
depends_on: [04-cut-mid-batch-reread.md]
agent_type: architect
model: sonnet
effort: default
assigned_at: null
completed_at: null
qa_result: null
---

Implement re-entry logic in Phase 1: record team mix per run to `.orchestration/projects/{id}/observability/`. On re-entry, if the team mix matches the prior recorded run, skip the team gate and proceed directly. Otherwise re-fire the gate once for the remaining batch.

**Done signal:** Phase 1 reads/writes recorded team mix; team gate skips when matches.
