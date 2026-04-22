---
type: slice
slice: 03
order: 03
project: state-machine-refactor
design: .orchestration/projects/bcokert-00004-state-machine-refactor/01-design/design-01.md
status: done
status_updated_at: 2026-04-22T00:25:00-04:00
---

# Slice 03 — Commit timing

**Goal:** Commits in plan-project happen at approval gates, not at phase entry. planIteration stages the previous iteration's changes before each new pass, keeping the unstaged diff clean.

## Happy path

- First task: confirm `.root-context/state-diagram.md` accurately reflects the commit timing behavior being implemented here (approveAndCommit at gates, planIteration staging). Note any discrepancies; update if found.
- Phase-entry `git add / git commit` blocks removed from plan-project. No commit runs at the top of Design, Slicing, Spec, or Breakdown phases.
- Approval at Design.Review → `approveAndCommit(design)` runs immediately in the same run; design doc status set to `approved`.
- Approval at Slicing.Review → `approveAndCommit(slices)` runs immediately; slice statuses updated.
- planIteration begins each pass with `git add .orchestration/` (and related root-context/CLAUDE.md changes). Previous iteration's artifacts move to staging. Current pass starts with a clean unstaged diff.
- Code files appearing unstaged during the staging step trigger a confirmation prompt before staging.
- Version bumped (minor) on `defaults/commands/plan-project.md`.

## Edge cases

- **First planIteration on a new project** (nothing staged yet): `git add` is a no-op for previous changes; continues normally.
- **`git add` fails during planIteration staging**: surface to operator, wait for resolution, do not advance state.
- **Phase entry detects uncommitted changes from a previous run** (crash recovery): re-read slice/design status from disk; route correctly without committing stale artifacts.
