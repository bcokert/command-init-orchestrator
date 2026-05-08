---
spec: .orchestration/projects/bcokert-00007-batch-slice-flow/03-briefs/06-review-batch-rewrite.md
slice: 06
step: 4
title: Mixed-response handling — re-ask once, default to feedback
status: done
depends_on: [03-auto-stage-summary.md]
agent_type: architect
model: sonnet
effort: default
assigned_at: null
completed_at: null
qa_result: null
---

Implement per-slice prompt accepting approve / feedback / ambiguous. On ambiguous: re-ask once on the same slice. If still ambiguous, default to feedback (recoverable; accidental approval would commit).

**Done signal:** Per-slice classification logic visible; default-to-feedback on stuck ambiguity.
