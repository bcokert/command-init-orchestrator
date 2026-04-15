---
type: slice
slice: 4
order: 4
project: bcokert-00001-visual-docs-init-orchestrator
design: .orchestration/projects/bcokert-00001-visual-docs-init-orchestrator/01-design/design-01.md
status: specced
follow_up_of: 01
---

# Slice 4 — Install support commands

**Goal:** The commands `slice.md`, `spec.md`, and `qa.md` in `defaults/commands/` are referenced by the main commands (`design.md`, `implement.md`) but are not installed to target projects by `/init-orchestrator`. A target project has no `defaults/` folder, so these references break. Install them alongside the main commands so everything the orchestration system needs is present in the target project.

## Happy path

- `/init-orchestrator` installs `slice.md`, `spec.md`, `qa.md` to a location accessible to the main commands in the target project
- The location avoids `.claude/commands/` to prevent auto-detection as user-invokable slash commands (users shouldn't see `/slice`, `/spec`, `/qa` in their command list)
- Suggested install target: `.orchestration/support/` — clearly owned by the orchestrator, not surfaced as commands
- All references in `design.md` and `implement.md` to these files are updated to the new install path
- Safe-to-re-run: if files already exist at install target, report drift and skip (same behavior as main commands)
- `defaults/commands/` retains the originals as source of truth

## Edge cases

- Target project already has `.orchestration/support/` with modified versions — follow the same drift-detection pattern as main commands
- Partial install (some support files present, some not) — install missing, report existing
- Commands that reference the old path (e.g. `defaults/commands/qa.md`) — all references must be updated to the new install-relative path before this slice is done
