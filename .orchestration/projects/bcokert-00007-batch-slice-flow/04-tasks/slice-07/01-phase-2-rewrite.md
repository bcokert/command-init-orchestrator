---
spec: .orchestration/projects/bcokert-00007-batch-slice-flow/03-briefs/07-status-rewrite.md
slice: 07
step: 1
title: Rewrite Phase 2 to use next-actions reader
status: done
depends_on: []
agent_type: architect
model: sonnet
effort: default
assigned_at: null
completed_at: null
qa_result: null
---

Replace the multi-project glob/parse logic in Phase 2 of `defaults/commands/status.md` with a call to `next-actions.md`. Sort tiebreak (most-recent first; project-ID descending) and active-project filter move to the reader. Phase 2 ≤ ~10 lines.

**Done signal:** Phase 2 calls reader; sort + filter handled by reader.
