---
spec: .orchestration/projects/bcokert-00007-batch-slice-flow/03-briefs/05-implement-rewrite.md
slice: 05
step: 7
title: Behavior rules trim + vocabulary + mirror + version + verify
status: todo
depends_on: [06-status-write-migration.md]
agent_type: quality
model: sonnet
effort: default
assigned_at: null
completed_at: null
qa_result: null
---

Trim Behavior rules to implement-specific deltas (link shared rules to state-diagram.md). Replace "operator" / "human" with "user". Mirror to `.claude/commands/implement.md`. Bump version (minor). Verify: line count ≤ 95; grep clean for legacy actor terms.

**Done signal:** Both files match; ≤ 95 lines; grep clean.
