---
type: slice
slice: 04
order: 04
project: orchestrator-bug-fixes
design: .orchestration/projects/bcokert-00001-orchestrator-bug-fixes/01-design/design-01.md
status: done
status_updated_at: "2026-04-23T00:03:00-07:00"
---

# Slice 04 — implement multi-slice behavior

**Goal:** implement.md processes all tasks_ready slices in sequence, not just one. Phase 1 display aligns with actual behavior.

## Happy path

- Phase 0 collects all slices at tasks_ready or beyond, ordered by slice number.
- Slices execute one at a time in order; each goes through QA (which may update future slices) before the next starts.
- All slices reach signoff_review before /implement exits.
- Phase 1 summary shows all slices that will run, not just one.
- Crash resume: a partially-completed run reads slice states from disk, skips already-done slices, picks up at the first incomplete one.

## Edge cases

- Slices at `implementing` or `qa_in_progress` on entry: treat as the current in-progress slice, resume it.
- Slices at `signoff_review` on entry: already done this run — skip.
- If a slice fails QA and stays at qa_in_progress: don't advance to the next slice. Surface the failure and stop.
