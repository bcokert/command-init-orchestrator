---
type: slice
slice: 6
order: 6
project: bcokert-00001-visual-docs-init-orchestrator
design: .orchestration/projects/bcokert-00001-visual-docs-init-orchestrator/01-design/design-01.md
status: specced
follow_up_of: 01
---

# Slice 6 — /plan vs /design rename

**Goal:** The planning command is currently called `/design`, but "design" is a substep of the overall planning process — the system itself calls it the "planning stage". `/plan` is a more accurate name. Before renaming, verify `/plan` doesn't conflict with any Claude Code built-in commands. If it conflicts, propose and evaluate alternatives (`/blueprint`, `/spec`, `/scope`, etc.). If no conflict, rename everything that references `/design`.

## Happy path

- Research confirms `/plan` is not a Claude Code reserved command (or conflict found and alternative chosen)
- `defaults/commands/design.md` renamed to `defaults/commands/plan.md`
- All internal references to `/design` within command files updated to `/plan`
- `README.md` updated: every mention of `/design` updated to the new name
- `artifacts.d2` and `lifecycle.d2` updated: `/design` labels in diagrams replaced
- `artifacts.svg` and `lifecycle.svg` regenerated
- `init-orchestrator.md` (the installer command) updated to install `plan.md` instead of `design.md`
- A note in the README or command docs clarifying that "design" is a phase within planning, not the command name

## Edge cases

- Claude Code built-in conflict: `/plan` is reserved or conflicts — must choose an alternative and verify that too before any rename
- Partial rename: if any reference to `/design` is missed, the system will have inconsistent command names — do a thorough grep after rename to catch stragglers
- Existing installed projects: they have `.claude/commands/design.md` installed. The installer's re-run behavior handles drift — note in the README that re-running `/plan` (the new name) after upgrade replaces the old `design.md`
- The command file itself refers to the previous command name internally (e.g., "run /design to continue") — these must all be updated
