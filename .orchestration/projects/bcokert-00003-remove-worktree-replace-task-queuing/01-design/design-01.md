---
type: design
date: 2026-04-18
feature: remove-worktrees-queue-model
project_id: bcokert-00003-remove-worktree-replace-task-queuing
status: ready
---

# Remove worktrees — queue-based execution model

## Intent

The orchestrator creates a git worktree per project when implementation starts. Each worktree is an isolated branch (`project/{id}`) at `.orchestration/worktrees/{id}`. At signoff, the branch merges to main and the directory is removed.

The original rationale was parallel project isolation — two projects running simultaneously couldn't trample each other's files. In practice, the gates are sequential by design, and the worktree machinery adds meaningful complexity: branch creation, merge conflicts, missing-directory errors, cross-path file reads in every command, and an onboarding explanation that exists only to justify its own existence.

This removes worktrees entirely. All implementation runs on main. Execution remains serial (one slice at a time), but slices from multiple projects can queue up and run sequentially without manual re-triggering. The queue unit is the slice, not the project.

## Current state

- `/implement` creates `.orchestration/worktrees/{id}` on branch `project/{id}` before any task runs.
- Task execution, file reads/writes, and status updates are scoped to the worktree path.
- `/status` reads `status.md` from the worktree as authoritative; falls back to main.
- `/review` commits from the worktree, merges to main, then removes the worktree.
- Merge conflicts at review preserve the worktree and require manual resolution.
- `status.md` carries `worktree_path` and `branch` fields.
- `config.yaml` has a `suggest_worktree` setting.
- `.gitignore` includes `.orchestration/worktrees/`.
- `init-orchestrator.md` adds the `.gitignore` entry on setup.
- Diagrams (`artifacts.d2`, `concurrent-projects.d2`) reference worktrees.
- `README.md` and `defaults/README.md` describe the worktree model.
- `/implement` is scoped to a single project; the execution queue is per-project.

## Desired end state

- No worktrees anywhere: no creation, no branches, no merge step, no directory cleanup.
- All task execution in the main working tree; push target is main (local and remote).
- The execution queue is global across projects: all `tasks_ready` slices across all projects, ordered by when they entered that state, with per-project slice ordering preserved.
- `/implement` picks the next slice from the global queue regardless of which project it belongs to.
- Slices from different projects can interleave (`1a → 2a → 1b → 3a` is valid).
- Each slice still has its own QA pass, signoff gate, and human `/review` — no gates removed.
- `/review` commits and pushes from main; no merge step.
- `/status` reads only from main; no worktree path resolution.
- `status.md` has no `worktree_path` or `branch` fields.
- `config.yaml` has no worktree-related settings.
- All worktree references removed: commands, support files, diagrams, README files, `.gitignore`, `init-orchestrator.md`.

## Patterns to follow

- Delete over deprecate. Worktrees are gone, not toggled off. No config flag to re-enable.
- The stage sequence in plan-project and implement is the routing source of truth. Remove the `worktree_created` transition note from implement; don't introduce a replacement stage.
- Per-slice signoff gate is unchanged. The queue just lets multiple slices run unattended before review.
- Agent team confirmation stays per-slice (team planned in plan-project Phase 7; implement re-confirms at slice start).
- Diagrams: update `.d2` source first, re-render SVGs. Never edit SVGs directly.
- Version bump required for every `defaults/` file change. Patch for pure removals; minor for new queue behaviour.

## Key edge cases

- **Multiple slices from the same project queued**: per-project slice order must be preserved. Slice 02 must not start until slice 01 is at `signoff_review` or `done`.
- **Queue is empty**: `/implement` stops — "Nothing in the queue. Run /plan-project to create tasks."
- **Dirty working tree on `/implement` entry**: stop and warn. Starting on a dirty tree mixes prior work into the new slice's diff. User must `/review` pending work first.
- **Old `status.md` with `worktree_path` still set**: implement and status ignore unknown fields silently.
- **Old `worktree_created` transition note in history**: status display must not error on unknown transition names — show what it knows, skip what it doesn't.
- **All queued slices belong to a project that's blocked** (e.g. waiting for review): handle gracefully; report blocked state rather than silently skipping.

## Resolved design decisions

**Queue ordering across projects.** Order by `status_updated_at` on the slice file when its status last became `tasks_ready`. Per-project slice number order is always respected regardless of timestamps. **Why:** no new infrastructure needed; timestamps are already written. **Rejected:** an explicit queue file — more state to corrupt, no benefit for serial execution.

**Commit and push target.** Commit and push directly to main, locally and remotely. **Why:** project branches existed to isolate worktrees; without worktrees there's no isolation need. Feature-branch collaboration is explicitly out of scope here. **Rejected:** keep per-project local branches — adds most of the worktree complexity back without the isolation.

**Dirty-tree guard.** `/implement` checks for uncommitted changes on entry and stops if the tree is dirty. **Why:** executing tasks on a dirty tree folds prior uncommitted work into the new slice's diff, making review meaningless. **Rejected:** auto-stash — hides state, produces confusing restores.

**`suggest_worktree` config setting.** Remove entirely (not commented out, not deprecated). **Why:** a dead setting pointing at a removed feature is noise in every user's config file. **Rejected:** leave with a comment — still appears in configs shipped by `/init-orchestrator`.

## Agent decisions

**`worktree_created` transition note.** Appears in `status.md` history for any project that ran implement under the old model. Not a stage — just a note. Removing it from implement is enough; existing history entries are inert. Alternative: add an explicit parsing guard. Unnecessary — transition history is displayed, not used for routing.

**Queue stored implicitly.** The queue is derived at runtime by scanning all projects for `tasks_ready` slices and sorting by timestamp. Alternative: explicit `.orchestration/queue.md`. Not warranted — the implicit model is sufficient for serial execution and avoids a new file type to maintain.

**No migration path for old worktree projects.** The only active project in-flight (bcokert-00002) is in a different repo and hasn't entered `implementing` yet. No migration tooling needed. Old `worktree_path` fields are silently ignored by the updated commands.
