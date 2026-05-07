---
type: slice
slice: 05
order: 05
project: batch-slice-flow
design: .orchestration/projects/bcokert-00007-batch-slice-flow/01-design/design-01.md
status: draft
---

# Slice 05 — /implement rewrite (scope-frozen + batch + shrinkage)

**Goal:** `/implement` runs its full queue end-to-end with one team-confirmation gate, scope frozen on entry, no mid-batch re-reads. Legacy "review more slices first" branch removed. Uses shared reader and status-write helper. ~29% shrinkage.

## Happy path

- Phase 0 collapses to a `next-actions.md` call filtered to `tasks_ready` and `implementing`. Sort and tiebreak logic moves to the reader.
- Phase 1 surfaces the aggregated team across all in-scope slices. One confirmation gate per run. "Review more slices first" branch deleted; matching state-diagram transition already gone (slice 01).
- Phase 2 task execution and Phase 3 QA preserve crash-resume semantics. Status writes use `status-write.md` helper.
- Mid-batch re-read at lines 113-115 deleted — execution list computed at Phase 0 entry is authoritative for the run. Slices appearing post-entry picked up on next invocation.
- Re-entry behavior: if all slices in scope already match a previously-recorded team mix, skip the team gate. Record team mix per run in `observability/`.
- "Behavior rules" trimmed to implement-specific deltas; shared rules link to `state-diagram.md`.
- Duplicate "all tasks done → Phase 3" route row deleted.
- Vocabulary: replace "operator" / "human" with "user".
- `defaults/commands/implement.md` ≤ ~95 lines (down from 134). Version bumped.

## Edge cases

- Crash mid-slice (Phase 2): on resume, find first `in_progress` or runnable `todo` task by reading task file statuses; team gate refires (team mix may have changed during downtime).
- Crash between slices: re-read execution list at start of next invocation; do not assume "scope frozen" survived the crash.
- Empty queue: report and stop with "Run /plan-project to create tasks".
- depends_on validation: a task whose dependency isn't `done` blocks the run; report the blocker and exit cleanly.
- Mixed-state on entry (one slice `signoff_review`, another `tasks_ready`): the surfacing tells the user both options exist; user names what to do.
