---
spec: specs/briefs/project-sequencing-and-status/05.1-post-qa-design-alignment.md
slice: 05.1
step: 3
title: Add post-QA design alignment phase to qa.md
status: done
depends_on: [02-agent-surfacing-tasks-ready-gate.md]
agent_type: architect
assigned_at: 2026-04-11T00:00:00Z
completed_at: 2026-04-11T00:00:00Z
---

## Work

In `defaults/commands/qa.md`, add a new phase between the fix-and-retry loop (Phase 1.5) and the signoff_review advance (Phase 3). Call it Phase 2 — Design alignment. Renumber current Phase 2 (Write QA report) to Phase 3 and Phase 3 (Advance to signoff_review) to Phase 4.

**New Phase 2 — Design alignment**

After QA passes:

1. Read the design doc (`01-design/design-{NN}.md`) and all slice files in `02-slices/` with `status: draft` or `status: reviewed` (future unimplemented slices).
2. For each, ask: does what was just implemented conflict with, clarify, or invalidate anything here?
3. If a future slice scope significantly overlaps with what was just implemented: stop and ask before modifying.
4. Apply any updates directly to the affected files. Leave them uncommitted.
5. Produce a summary:
   - If no changes: one line — "no design or slice updates needed"
   - If changes: one bullet per changed file with one sentence explaining why

Include the summary in the Phase 4 (signoff_review) gate output.

## Done signal

qa.md has a Phase 2 between fix-and-retry and QA report. signoff_review output includes alignment summary. Changed files are not committed.
