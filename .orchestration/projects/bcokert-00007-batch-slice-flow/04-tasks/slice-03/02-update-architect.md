---
spec: .orchestration/projects/bcokert-00007-batch-slice-flow/03-briefs/03-agent-preamble-extraction.md
slice: 03
step: 2
title: Update architect.md
status: todo
depends_on: [01-write-common-preamble.md]
agent_type: architect
model: sonnet
effort: default
assigned_at: null
completed_at: null
qa_result: null
---

Trim `defaults/agents/architect.md` to role-specific deltas. Reference `_common-preamble.md` for the shared content. Purge "Bdon" → "the user". Bump version.

**Done signal:** File ≤ original − duplicated content; references preamble; no "Bdon" in file.
