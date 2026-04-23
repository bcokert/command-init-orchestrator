---
type: slice
slice: 03
order: 03
project: orchestrator-bug-fixes
design: .orchestration/projects/bcokert-00001-orchestrator-bug-fixes/01-design/design-01.md
status: draft
---

# Slice 03 — plan-project bug fixes

**Goal:** Fix the Phase 5 crash-resume gap (missing approveAndCommit) and the Phase 7 premature commit (fires before agent team confirmation).

## Happy path

- Phase 5 entry: if design doc `status` is `review`, run `approveAndCommit` before proceeding to slicing. The design doc lands at `approved` in the commit.
- Phase 7: the `git commit` for task files runs after the user confirms the agent team, not before. Any agent_type edits the user makes are captured in the commit.

## Edge cases

- Crash resume of Phase 5 with design already at `approved`: skip `approveAndCommit`, proceed normally — don't double-commit.
- If Phase 7 user cancels or doesn't respond, task files are not committed. No orphaned commit with wrong values.
- Sync fix to `.claude/commands/plan-project.md` after updating `defaults/`.
