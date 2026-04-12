---
spec: specs/briefs/project-sequencing-and-status/06-implement-v2-concurrent.md
slice: 06
step: 3
title: Update worktree resume detection
status: done
depends_on: [02-wrong-command-routing-concurrent.md]
agent_type: architect
assigned_at: 2026-04-12T00:00:00Z
completed_at: 2026-04-12T00:00:00Z
---

## Work

Update `defaults/commands/implement.md` Phase 1 (worktree creation) to check whether a worktree already exists before creating one.

On resume (project is `implementing` with `worktree_path` set):
1. Check if the directory at `worktree_path` exists
2. If it exists: skip `git worktree add`, proceed directly to Phase 3 (task execution)
3. If it's missing: warn "worktree directory missing at {worktree_path} — run `git worktree prune` to clean up, then re-run /implement to create a fresh worktree"

On first run (project is `tasks_ready`): behavior unchanged — create the worktree as before.

## Done signal

Resuming an `implementing` project does not attempt to create a duplicate worktree. Missing worktree directory produces a clear warning without crashing.
