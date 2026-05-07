---
spec: .orchestration/projects/bcokert-00007-batch-slice-flow/03-briefs/10-readme-and-diagrams-refresh.md
slice: 10
step: 8
title: Verify all README links resolve
status: todo
depends_on: [07-rerender-svgs.md]
agent_type: quality
model: sonnet
effort: default
assigned_at: null
completed_at: null
qa_result: null
---

Manually walk through every link in `README.md` and `defaults/README.md`. Confirm each resolves to an existing section, file, or anchor (especially in `state-diagram.md` post-slice 01). Fix any broken or stale links found.

**Done signal:** All links resolve; no 404s in the local filesystem or fragment anchors.
