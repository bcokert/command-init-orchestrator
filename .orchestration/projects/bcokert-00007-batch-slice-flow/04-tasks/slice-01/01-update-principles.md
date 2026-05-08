---
spec: .orchestration/projects/bcokert-00007-batch-slice-flow/03-briefs/01-state-diagram-anchor.md
slice: 01
step: 1
title: Update Principles section
status: done
depends_on: []
agent_type: architect
model: sonnet
effort: default
assigned_at: 2026-05-06T20:10:00-07:00
completed_at: 2026-05-06T20:11:00-07:00
qa_result: null
---

Add "Batch is the default" to the Principles section in `.root-context/state-diagram.md`. Add a "Crash recovery" subsection consolidating re-read-from-disk, idempotent spec/breakdown, and brief+tasks fast-forward (rules currently scattered in command files and the Error handling section).

**Done signal:** Grep finds the new principle text and Crash recovery subsection.
