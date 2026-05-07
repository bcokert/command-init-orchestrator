---
spec: .orchestration/projects/bcokert-00007-batch-slice-flow/03-briefs/08-support-files-cleanup.md
slice: 08
step: 1
title: Fix qa.md description path
status: todo
depends_on: []
agent_type: architect
model: sonnet
effort: default
assigned_at: null
completed_at: null
qa_result: null
---

In `defaults/commands/qa.md` line 1, fix the description's output path: writes go to `.orchestration/projects/{id}/05-qa/slice-{NN}-qa-report.md` (matches Phase 3 actual write), not `.orchestration/dashboard/{spec-id}-qa.md`.

**Done signal:** Description path matches Phase 3 actual write.
