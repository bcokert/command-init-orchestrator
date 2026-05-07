---
spec: .orchestration/projects/bcokert-00007-batch-slice-flow/03-briefs/02-shared-support-files.md
slice: 02
step: 2
title: Write status-write.md
status: todo
depends_on: [01-write-next-actions.md]
agent_type: architect
model: sonnet
effort: default
assigned_at: null
completed_at: null
qa_result: null
---

Write `defaults/commands/status-write.md` with documented contract:
- Inputs: `(project_id, slice_NN, new_status)`.
- Action: Glob the slice file by `slice:` frontmatter; write `status:` and `status_updated_at: {ISO 8601 with timezone offset}`. Warn-and-continue if not found.
- Frontmatter only — no logging side effects, no iterations.md write.

**Done signal:** File exists with version 1.0.0; "frontmatter only" stated.
