---
spec: .orchestration/projects/bcokert-00007-batch-slice-flow/03-briefs/05-implement-rewrite.md
slice: 05
step: 6
title: Migrate status writes to status-write.md helper
status: done
depends_on: [05-reentry-team-gate.md]
agent_type: architect
model: sonnet
effort: default
assigned_at: null
completed_at: null
qa_result: null
---

Replace inline status writes in `defaults/commands/implement.md` with calls to `status-write.md` helper. Includes Phase 2 (`implementing`), Phase 3 entry (`qa_in_progress`), Phase 3 exit (`signoff_review`).

**Done signal:** Every status write goes through helper.
