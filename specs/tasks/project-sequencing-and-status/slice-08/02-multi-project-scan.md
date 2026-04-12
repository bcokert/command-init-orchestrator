---
spec: specs/briefs/project-sequencing-and-status/08-status-v2-multi-project.md
slice: 08
step: 2
title: Write multi-project scan (Phase 2)
status: todo
depends_on: [01-routing-update.md]
agent_type: architect
assigned_at: null
completed_at: null
---

## Work

Write Phase 2 of `defaults/commands/status.md` — discovering all active projects.

Steps:
1. Scan `.orchestration/projects/*/status.md` (exclude `done/` subdirectory). Read each.
2. Run `git worktree list`. For each worktree path listed (besides the main worktree), check if a `status.md` exists at `{worktree_path}/.orchestration/projects/{id}/status.md`. If it does and differs from main, use the worktree version (authoritative).
3. For each project found:
   - If `worktree_path` is set in `status.md` but the directory is missing: mark as `worktree_missing`
   - Otherwise: collect stage, next_action, worktree_path (if any), last transition timestamp
4. Derive time in current stage: `now - last_transition_timestamp`. If timestamp is missing or unparseable: show "unknown".
5. Pass collected data to Phase 3 for rendering.

## Done signal

All active projects discovered across main and active worktrees. Orphaned worktrees (directory missing) flagged as `worktree_missing`. Worktree `status.md` used when it diverges from main.
