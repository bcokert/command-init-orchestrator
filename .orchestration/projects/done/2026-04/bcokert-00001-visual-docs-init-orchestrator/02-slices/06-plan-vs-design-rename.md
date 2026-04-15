---
type: slice
slice: 6
order: 6
project: bcokert-00001-visual-docs-init-orchestrator
design: .orchestration/projects/bcokert-00001-visual-docs-init-orchestrator/01-design/design-01.md
status: tasks_ready
follow_up_of: 01
---

# Slice 6 — /plan-project vs /design rename

**Goal:** The planning command is currently called `/design`, but "design" is a substep of the overall planning process — the system itself calls it the "planning stage". `/plan-project` is a more accurate name. Rename everything: command file, all internal references, README, diagrams, init-orchestrator.

## Happy path

- `defaults/commands/design.md` renamed to `defaults/commands/plan-project.md`
- All internal references to `/design` within command files updated to `/plan-project`
- `README.md` updated: every mention of `/design` updated to `/plan-project`
- `artifacts.d2` and `lifecycle.d2` updated: `/design` labels in diagrams replaced
- `artifacts.svg` and `lifecycle.svg` regenerated
- `init-orchestrator.md` (the installer command) updated to install `plan-project.md` instead of `design.md`

## Edge cases

- Partial rename: if any reference to `/design` is missed, the system will have inconsistent command names — do a thorough grep after rename to catch stragglers
- Existing installed projects: they have `.claude/commands/design.md` installed. The installer's re-run behavior handles drift — note in the README that re-running `/plan-project` (the new name) after upgrade replaces the old `design.md`
- The command file itself refers to the previous command name internally (e.g., "run /design to continue") — these must all be updated
