---
spec: .orchestration/projects/bcokert-00007-batch-slice-flow/03-briefs/05-implement-rewrite.md
slice: 05
step: 2
title: Rewrite Phase 0 to use next-actions reader
status: done
depends_on: [01-confirm-state-diagram.md]
agent_type: architect
model: sonnet
effort: default
assigned_at: null
completed_at: null
qa_result: null
---

Rewrite Phase 0 in `defaults/commands/implement.md` to call `next-actions.md` filtered to `tasks_ready` and `implementing`. Cut the duplicate "all tasks done → Phase 3" routing row at line 54. Phase 0 ≤ ~15 lines.

**Done signal:** Phase 0 collapses to reader call + filter; duplicate row gone.
