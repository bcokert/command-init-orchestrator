---
spec: .orchestration/projects/bcokert-00007-batch-slice-flow/03-briefs/06-review-batch-rewrite.md
slice: 06
step: 7
title: Status-write migration + rules trim + mirror + verify
status: todo
depends_on: [06-archive-end-of-batch.md]
agent_type: quality
model: sonnet
effort: default
assigned_at: null
completed_at: null
qa_result: null
---

Replace inline status writes with `status-write.md` helper. Trim Behavior rules to review-specific deltas. Replace "operator" / "human" with "user". Mirror to `.claude/commands/review.md`. Bump version (minor). Verify: line count ≤ 78; grep clean.

**Done signal:** Both files match; ≤ 78 lines; grep clean.
