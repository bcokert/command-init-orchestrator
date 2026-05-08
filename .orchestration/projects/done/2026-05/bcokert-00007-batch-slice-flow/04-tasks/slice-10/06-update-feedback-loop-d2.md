---
spec: .orchestration/projects/bcokert-00007-batch-slice-flow/03-briefs/10-readme-and-diagrams-refresh.md
slice: 10
step: 6
title: Update feedback-loop.d2
status: done
depends_on: [05-update-multi-slice-sequence-d2.md]
agent_type: architect
model: sonnet
effort: default
assigned_at: null
completed_at: null
qa_result: null
---

In `docs/diagrams/feedback-loop.d2`: add a note that batched `/review` continues through subsequent signoff slices; feedback creates dot-notation drafts but does not pause the loop.

**Done signal:** Diagram source carries the batch-continuation note.
