---
spec: .orchestration/projects/bcokert-00007-batch-slice-flow/03-briefs/08-support-files-cleanup.md
slice: 08
step: 2
title: qa.md — reviewed→review, Bdon→user, version bump
status: todo
depends_on: [01-fix-qa-description-path.md]
agent_type: architect
model: sonnet
effort: default
assigned_at: null
completed_at: null
qa_result: null
---

In `defaults/commands/qa.md`: replace `reviewed` (line 70) with `review`. Replace "Bdon" (line 121 and elsewhere) with "the user". Bump version (patch).

**Done signal:** `grep -nw 'reviewed\|Bdon' defaults/commands/qa.md` returns no matches.
