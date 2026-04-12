---
spec: specs/briefs/project-sequencing-and-status/08-status-v2-multi-project.md
slice: 08
step: 3
title: Write summary table output (Phase 3)
status: todo
depends_on: [02-multi-project-scan.md]
agent_type: architect
assigned_at: null
completed_at: null
---

## Work

Write Phase 3 of `defaults/commands/status.md` — rendering the summary table.

Table format:
```
| Project | Stage | Worktree | Next action | Time in stage |
|---------|-------|----------|-------------|---------------|
| bcokert-00001-auth | implementing | .orch/worktrees/... | run /review after QA | 2h 14m |
| bcokert-00002-login | design_review | — | review design doc, run /design | 45m |
| bcokert-00003-signup | signoff_review | .orch/worktrees/... | run /review | 1d 3h |
```

After the table:
- For each project in a `*_review` stage: one line — "• {id}: run /{command} to continue"
- For orphaned worktrees: "• {id}: worktree missing at {path} — run `git worktree prune`"

If zero active projects: skip the table, output "no active projects — run /design to start one".

Malformed `status.md` (missing required fields): show the project row with "⚠ malformed status.md" in the stage column, continue rendering others.

## Done signal

Table renders correctly for 0, 1, and multiple projects. `*_review` reminders appear below. Orphaned worktree warning appears inline. Malformed status.md shows a warning row without crashing.
