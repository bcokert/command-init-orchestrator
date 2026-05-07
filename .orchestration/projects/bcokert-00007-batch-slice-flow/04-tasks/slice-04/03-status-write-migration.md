---
spec: .orchestration/projects/bcokert-00007-batch-slice-flow/03-briefs/04-plan-project-rewrite.md
slice: 04
step: 3
title: Migrate status writes to status-write.md helper
status: todo
depends_on: [02-phase-0-rewrite.md]
agent_type: architect
model: sonnet
effort: default
assigned_at: null
completed_at: null
qa_result: null
---

Replace every inline status write in `defaults/commands/plan-project.md` with a call to `status-write.md` helper. Add the four currently-missing `status_updated_at` writes (Phase 5 lines 302, 322 and equivalents). Every status transition must include the timestamp.

**Done signal:** Every Phase 5/6/7 status write goes through helper; no orphaned `status_updated_at`-less writes.
