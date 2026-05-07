---
spec: .orchestration/projects/bcokert-00007-batch-slice-flow/03-briefs/04-plan-project-rewrite.md
slice: 04
step: 5
title: Collapse Phase 4 + Phase 5 design-approval commit
status: todo
depends_on: [04-slicing-gate-batch.md]
agent_type: architect
model: sonnet
effort: default
assigned_at: null
completed_at: null
qa_result: null
---

Merge the duplicated design-approval blocks at Phase 4 (lines 256-263) and Phase 5 (lines 271-276) into one location. Phase 4 transitions to Phase 5 via a single approval block. Phase 5 entry guard remains for crash resume only — references the canonical block.

**Done signal:** Single commit point for design approval; idempotent on re-run.
