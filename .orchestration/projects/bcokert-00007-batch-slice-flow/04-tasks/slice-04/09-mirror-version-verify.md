---
spec: .orchestration/projects/bcokert-00007-batch-slice-flow/03-briefs/04-plan-project-rewrite.md
slice: 04
step: 9
title: Mirror to .claude/ + version bump + verify size and vocabulary
status: done
depends_on: [08-bdonize-reference-rules-trim-vocab.md]
agent_type: quality
model: sonnet
effort: default
assigned_at: null
completed_at: null
qa_result: null
---

Copy `defaults/commands/plan-project.md` to `.claude/commands/plan-project.md`. Bump version (minor — significant behavior changes). Verify: line count ≤ 290; grep for legacy terms returns clean (`Bdon`, `human`, `operator`, `reviewed`, `specced`, `feedback_pending`, `status: ready`).

**Done signal:** Both files match; size + grep checks pass.
