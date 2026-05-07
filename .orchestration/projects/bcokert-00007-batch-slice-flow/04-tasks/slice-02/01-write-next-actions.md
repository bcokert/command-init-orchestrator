---
spec: .orchestration/projects/bcokert-00007-batch-slice-flow/03-briefs/02-shared-support-files.md
slice: 02
step: 1
title: Write next-actions.md
status: todo
depends_on: []
agent_type: architect
model: sonnet
effort: default
assigned_at: null
completed_at: null
qa_result: null
---

Write `defaults/commands/next-actions.md` with documented contract:
- Input: none (or optional project_id filter).
- Output: list of tuples `(project_id, artifact_kind, artifact_id, status, status_updated_at, next_actions)` where `artifact_kind ∈ {project_root, design, slice}` and `next_actions` is a list of legal verbs.
- Excludes paths under `done/`.
- Tuple shape names (e.g. `SliceNextActions`) — Go-struct portable.

**Done signal:** File exists at `defaults/commands/next-actions.md` with version 1.0.0.
