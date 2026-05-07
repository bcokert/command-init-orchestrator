---
type: slice
slice: 07
order: 07
project: batch-slice-flow
design: .orchestration/projects/bcokert-00007-batch-slice-flow/01-design/design-01.md
status: tasks_ready
status_updated_at: 2026-05-06T20:03:31-07:00
---

# Slice 07 — /status rewrite (uses reader + table consolidation)

**Goal:** `/status` reads from the shared next-actions reader, merges the abbreviation and next-action tables into one, deduplicates the date-format rule, and shrinks ~27%. Read-only; no behavior change for the user.

## Happy path

- Phase 2 multi-project scan replaced by a `next-actions.md` call. Sort and active-project filter move to the reader.
- State abbreviation table and next-action command table merge into one wider table: `state | abbrev | emoji | command`.
- Two duplicate "Counts format" definitions collapse into one.
- Date-format rule (`MMM D` / omit current year / `—` if absent) hoisted to a single sentence; per-block restatements removed.
- Legacy `reviewed` and `specced` aliases deleted from the table (per design's purge bundle).
- "Behavior rules" trimmed to status-specific deltas.
- `defaults/commands/status.md` ≤ ~125 lines (down from 170). Version bumped.

## Edge cases

- Output formatting must remain visually identical to a regular user — only the source of state changes.
- Design-phase projects (no slices yet): the reader returns a `project_root` tuple; status renders "design in progress" without crashing.
- Empty system: same "no active projects" message and next-step hint.
- Sort tiebreak (most-recent first; project-ID descending) preserved via reader.
- Merged table must still surface every state value; no information loss vs. the two original tables.
