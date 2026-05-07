---
spec: .orchestration/projects/bcokert-00007-batch-slice-flow/03-briefs/05-implement-rewrite.md
slice: 05
step: 3
title: Cut "review more slices first" branch
status: todo
depends_on: [02-phase-0-rewrite.md]
agent_type: architect
model: sonnet
effort: default
assigned_at: null
completed_at: null
qa_result: null
---

Delete the "review more slices first" branch from Phase 1 in `defaults/commands/implement.md`. The user can run /plan-project directly if they want to review more slices.

**Done signal:** `grep -n 'review more slices first' defaults/commands/implement.md` returns no matches.
