---
spec: .orchestration/projects/bcokert-00007-batch-slice-flow/03-briefs/10-readme-and-diagrams-refresh.md
slice: 10
step: 5
title: Update multi-slice-sequence.d2
status: todo
depends_on: [04-update-state-machine-d2.md]
agent_type: architect
model: sonnet
effort: default
assigned_at: null
completed_at: null
qa_result: null
---

In `docs/diagrams/multi-slice-sequence.d2`: correct the archive timing — archive only on full project completion, not after each individual slice. Intermediate slice approvals show `done` (not archived); a final archive node appears only after the last slice.

**Done signal:** Diagram source reflects archive-on-full-completion timing.
