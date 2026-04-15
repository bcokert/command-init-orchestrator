---
type: brief
slice: 08
project: project-sequencing-and-status
design: specs/design/project-sequencing-and-status.md
slice_doc: specs/slices/project-sequencing-and-status/08-status-v2-multi-project.md
status: ready
date: 2026-04-12
---

# Delegation brief — Slice 08: `/status` v2 multi-project

## Intent

Update `defaults/commands/status.md` (the existing v1 single-project command) to support multi-project display. V1 shows detail for one project. V2 shows a summary table of all active projects — across main and active worktrees — plus a brief recap of projects completed this week.

The command is read-only. No writes, no commits, no state changes.

## Observable outcomes

**No-arg status with active projects:**
```
Given three projects exist: one implementing in a worktree, one in design_review, one in signoff_review
When the user runs /status with no argument
Then output shows a summary table: project ID, stage, worktree path (if any), next action, time in current stage
And projects in *_review stages have a reminder of which command unblocks them
And recently completed projects (done this week) are listed below the table, grouped by the username part of the project ID
```

**No-arg status, zero active projects:**
```
Given no projects exist outside of done/
When the user runs /status
Then output: "no active projects — run /design to start one"
And still shows done-this-week recap if any projects completed this week
```

**Single-project detail (existing v1 behavior, preserved):**
```
Given a project ID is passed as argument
When the user runs /status {id}
Then output shows the full detail view: stage, next_action, elapsed time, last 3 transitions
```

**Orphaned worktree:**
```
Given a worktree is registered in git but the directory is missing
When /status runs
Then that project's row shows a warning: "worktree missing — run git worktree prune"
And all other projects display correctly
```

**Worktree status.md diverged from main:**
```
Given a project is implementing in a worktree and its status.md differs from main
When /status runs
Then the worktree version is used (authoritative)
```

## Constraints

**Must:**
- Read `status.md` files only — no artifact scanning
- Run `git worktree list` to discover active worktrees and read their `status.md` directly from those paths
- Exclude projects in `done/` from the active table (they're archived)
- Show done-this-week recap: projects whose `status.md` has a `done` transition timestamped within the last 7 days, grouped by username prefix of the project ID
- Preserve v1 single-project detail view when a project ID is passed

**Must not:**
- Write or modify any files
- Crash if a worktree directory is missing — warn and continue

**Preferences:**
- Table columns: project ID | stage | worktree | next action | time in stage
- Time in stage: derived from the most recent transition timestamp in `status.md` vs now
- Done-this-week section below the active table, not mixed in
- "This week" = last 7 days from current date

**Escalation triggers:**
- `status.md` is malformed or missing required fields: show inline warning for that project, continue rendering others

## Done definition

1. No-arg `/status` shows all non-done projects in a table with stage, worktree, next action, time in stage
2. Projects in `*_review` stages have an unblock reminder
3. Done-this-week recap appears below the table, grouped by username
4. Orphaned worktree shows a warning row, doesn't crash
5. Single-project detail (arg passed) still works as before

## Breakdown

| # | Step | Deliverable | Done signal |
|---|------|-------------|-------------|
| 1 | Update Phase 0 routing in status.md | No-arg routes to multi-project view; arg routes to single-project detail | Both routes work correctly |
| 2 | Write multi-project scan (Phase 2) | Scans .orchestration/projects/*/status.md + active worktrees via git worktree list | All active projects discovered, worktree paths read correctly |
| 3 | Write summary table output | Table with correct columns; *_review reminder; orphaned worktree warning | Table renders correctly for 0, 1, and multiple projects |
| 4 | Write done-this-week recap | Scans done/YYYY-MM/*/status.md for transitions in last 7 days; groups by username | Recap appears below table; empty if nothing done this week |
