---
type: slice
slice: 04
order: 04
project: remove-worktrees-queue-model
design: .orchestration/projects/bcokert-00003-remove-worktree-replace-task-queuing/01-design/design-01.md
status: reviewed
status_updated_at: 2026-04-18T00:00:00-07:00
---

# Slice 04 — Remove all remaining worktree references

**Goal:** No worktree reference anywhere in shipped files: config, gitignore, init-orchestrator, READMEs, diagrams. A fresh `/init-orchestrator` install produces nothing worktree-related.

## Happy path

- `config.yaml` has no `suggest_worktree` setting.
- `.gitignore` has no `.orchestration/worktrees/` entry (removed from init-orchestrator output).
- `init-orchestrator.md` no longer adds the worktrees gitignore entry during setup.
- Diagrams updated: no worktree boxes, arrows, or labels.
- READMEs describe the queue model, not worktrees; no mention of `git worktree` commands.

## Edge cases

- Running `/init-orchestrator` on an existing project that has `.orchestration/worktrees/` in `.gitignore`: no change made to `.gitignore` (init-orchestrator is additive only).
- `.orchestration/worktrees/` directory present and empty: delete it.
- `.orchestration/worktrees/` directory present and non-empty: leave it, warn the user ("Found .orchestration/worktrees/ with contents — inspect and remove manually").

## Files touched

- `defaults/config.yaml` — remove `suggest_worktree` setting and its comment block
- `defaults/commands/init-orchestrator.md` (the skill) — remove gitignore step for worktrees
- `defaults/README.md` — update worktree references
- `README.md` — update worktree references
- `docs/diagrams/artifacts.d2` — remove worktree artifacts
- `docs/diagrams/artifacts.svg` — re-render from d2
- `docs/diagrams/concurrent-projects.d2` — update or remove (worktrees were the whole point of this diagram)
- `docs/diagrams/concurrent-projects.svg` — re-render from d2
