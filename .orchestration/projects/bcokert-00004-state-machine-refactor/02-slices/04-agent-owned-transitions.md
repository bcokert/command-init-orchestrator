---
type: slice
slice: 04
order: 04
project: state-machine-refactor
design: .orchestration/projects/bcokert-00004-state-machine-refactor/01-design/design-01.md
status: tasks_ready
status_updated_at: 2026-04-21T12:05:00-04:00
---

# Slice 04 — Agent-owned status transitions

**Goal:** The agent writes all slice frontmatter status transitions. Operators respond to conversation prompts; they never need to edit frontmatter manually.

## Happy path

- plan-project gate prompts ask for approval in conversation. On approval, agent writes `status: review` (or the next status) to the relevant slice file before advancing.
- "set `status: reviewed` when ready" instruction removed from `defaults/commands/slice.md`.
- Slice status values updated to use `review` (not `reviewed`) throughout `slice.md`.
- plan-project routing logic accepts both `review` and `reviewed` as equivalent (soft migration for existing projects).
- Version bumped (minor) on `defaults/commands/plan-project.md` and `defaults/commands/slice.md`.

## Edge cases

- **Operator edits frontmatter directly anyway**: agent detects the value on next disk read and routes correctly. No failure.
- **Old projects with `reviewed` in frontmatter**: treated as `review` for all routing and display purposes.
- **Agent writes wrong status due to logic error**: surface on next run — disk read always re-derives state, inconsistent status is visible and correctable.
