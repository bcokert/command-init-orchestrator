---
spec: .orchestration/projects/bcokert-00007-batch-slice-flow/03-briefs/06-review-batch-rewrite.md
slice: 06
step: 6
title: Archive eligibility check at end-of-batch only
status: done
depends_on: [05-feedback-continues-batch.md]
agent_type: architect
model: sonnet
effort: default
assigned_at: null
completed_at: null
qa_result: null
---

Move archive eligibility check from per-slice (Phase 1 step 3) to end-of-batch. Conditions: all original slices reached `done` AND no draft slices were created from feedback during this run. Otherwise: report "Approved {N}, feedback on {M}; run /plan-project to advance feedback".

**Done signal:** Archive logic fires once after batch loop; conditions documented in command.
