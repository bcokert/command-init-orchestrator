---
spec: .orchestration/projects/bcokert-00007-batch-slice-flow/03-briefs/10-readme-and-diagrams-refresh.md
slice: 10
step: 3
title: Update lifecycle.d2
status: todo
depends_on: [02-defaults-readme-update.md]
agent_type: architect
model: sonnet
effort: default
assigned_at: null
completed_at: null
qa_result: null
---

In `docs/diagrams/lifecycle.d2`: remove the `spec_review` diamond gate. Spec → breakdown becomes one auto stage. Remove the edit-and-retry self-loop on the now-deleted gate.

**Done signal:** No spec_review nodes or edges in the .d2 source.
