---
spec: .orchestration/projects/bcokert-00007-batch-slice-flow/03-briefs/10-readme-and-diagrams-refresh.md
slice: 10
step: 2
title: defaults/README.md update — links not re-lists
status: done
depends_on: [01-readme-update.md]
agent_type: architect
model: sonnet
effort: default
assigned_at: null
completed_at: null
qa_result: null
---

In `defaults/README.md`: replace the stage table with a link to `state-diagram.md` (e.g. `#slice-states` or `#schemas`). Replace the folder-layout block with a link. Purge `feedback_pending` mention. Describe agents and support file classes (or link to canonical inventory in `init-orchestrator.md`).

**Done signal:** No re-listed tables; links present; `grep -n 'feedback_pending' defaults/README.md` returns no matches.
