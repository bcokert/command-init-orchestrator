---
spec: .orchestration/projects/bcokert-00007-batch-slice-flow/03-briefs/06-review-batch-rewrite.md
slice: 06
step: 2
title: Rewrite Phase 0 — project-level scope
status: done
depends_on: [01-confirm-state-diagram.md]
agent_type: architect
model: sonnet
effort: default
assigned_at: null
completed_at: null
qa_result: null
---

Rewrite Phase 0 in `defaults/commands/review.md` to call `next-actions.md` filtered to `signoff_review`. With project ID arg → that project. Without → if one project has signoff slices, auto-pick; if multiple, prompt at project level (not slice level). Iterate signoff slices in slice-number order. Phase 0 ≤ ~10 lines.

**Done signal:** Project-level scope; iteration in slice-number order; no slice-level prompt.
