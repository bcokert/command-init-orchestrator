---
spec: .orchestration/projects/bcokert-00007-batch-slice-flow/03-briefs/04-plan-project-rewrite.md
slice: 04
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

Rewrite Phase 0 in `defaults/commands/plan-project.md` to call `next-actions.md` and filter to /plan-project's scope. Delete dead routing rows: `reviewed`, `specced`, the mutually-exclusive "no slice in {…}" row, the `feedback_pending project` reference at line 226. Phase 0 ≤ ~25 lines.

**Done signal:** Phase 0 collapses to reader call + filter; dead rows gone.
