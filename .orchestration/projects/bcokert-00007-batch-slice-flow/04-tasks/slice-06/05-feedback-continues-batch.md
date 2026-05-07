---
spec: .orchestration/projects/bcokert-00007-batch-slice-flow/03-briefs/06-review-batch-rewrite.md
slice: 06
step: 5
title: Feedback path continues batch
status: todo
depends_on: [04-mixed-response-handling.md]
agent_type: architect
model: sonnet
effort: default
assigned_at: null
completed_at: null
qa_result: null
---

On feedback: write dot-notation draft slices with `follow_up_of: NN` per existing format. Continue the batch to the next signoff slice — no pause for /plan-project handoff. Final summary collects approved + feedback counts.

**Done signal:** Feedback creates drafts; batch loop iterates to next signoff; no early exit.
