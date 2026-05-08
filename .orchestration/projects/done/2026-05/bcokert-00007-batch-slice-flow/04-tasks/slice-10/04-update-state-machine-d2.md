---
spec: .orchestration/projects/bcokert-00007-batch-slice-flow/03-briefs/10-readme-and-diagrams-refresh.md
slice: 10
step: 4
title: Update state-machine.d2
status: done
depends_on: [03-update-lifecycle-d2.md]
agent_type: architect
model: sonnet
effort: default
assigned_at: null
completed_at: null
qa_result: null
---

In `docs/diagrams/state-machine.d2`: remove the `wantMoreSlicesBrokenDown` edge from `Implementation.Asking → Slicing.Review`. Retarget the `Signoff.Approved → Slicing.Review` edge into the three batch-aware transitions. Add `Implementation.QA → Implementation.Running` edge. Collapse the `Slicing.Generating` self-loop.

**Done signal:** All four diagram changes present in the .d2 source.
