---
type: slice
slice: 03
order: 03
project: orchestrator-bug-fixes
design: .orchestration/projects/bcokert-00001-orchestrator-bug-fixes/01-design/design-01.md
status: signoff_review
status_updated_at: "2026-04-23T00:02:00-07:00"
---

# Slice 03 — plan-project bug fixes

**Goal:** Fix three plan-project bugs: Phase 5 crash-resume gap (missing approveAndCommit), Phase 7 premature commit (fires before agent team confirmation), and bulk slicing approval not triggering immediate spec+breakdown for all approved slices.

## Happy path

- Phase 5 entry: if design doc `status` is `review`, run `approveAndCommit` before proceeding to slicing. The design doc lands at `approved` in the commit.
- Phase 7: the `git commit` for task files runs after the user confirms the agent team, not before. Any agent_type edits the user makes are captured in the commit.
- Slicing gate approval: after the user approves, loop Phase 6+7 for every approved slice in sequence. Slice N reaches `tasks_ready` before slice N+1 is specced — ordering constraint still holds, but all slices complete in one run. A single `/plan-project` approval of N slices leaves all N at `tasks_ready`.

## Edge cases

- Crash resume of Phase 5 with design already at `approved`: skip `approveAndCommit`, proceed normally — don't double-commit.
- If Phase 7 user cancels or doesn't respond, task files are not committed. No orphaned commit with wrong values.
- Crash resume mid-bulk-run (process dies after slice 02 is `tasks_ready`, slices 03-05 still at `review`): Phase 0 detects multiple slices at `review` with prior slice at `tasks_ready`, resumes the bulk loop from the first unfinished slice — no prompt needed.
- State-drift on spec step (brief file exists but slice is still at `review` or `speccing`): Phase 6 crash-resume logic already handles this — brief exists → skip re-write, go straight to breakdown. Ensure this check runs within the bulk loop, not only on standalone re-entry.
- State-drift on breakdown step (task files exist but slice is still at `breakdown`): same — Phase 7 crash-resume deletes and regenerates task files. Ensure this runs within the bulk loop too.
- State-drift on tasks_ready (task files exist and brief exists, but slice status wasn't written): detect this on entry and fast-forward the status to `tasks_ready` rather than re-running breakdown.
- Sync fix to `.claude/commands/plan-project.md` after updating `defaults/`.
