---
version: 2.0.0
description: |
  Reads status.md files from .orchestration/projects/ and active worktrees. With a project ID arg: single-project detail view. Without: summary table of all active projects plus a done-this-week recap. Read-only — never modifies files.
allowed-tools:
  - Read
  - Glob
  - Bash
  - AskUserQuestion
---

# Status — Project summary

Your job is to read project status and display it clearly. Never modify any file.

---

## Phase 0 — Detect mode

If a project ID was passed as argument: proceed to Phase 1 (single-project detail view).

If no argument: proceed to Phase 2 (multi-project scan).

---

## Phase 1 — Single-project detail view

1. Resolve path: `.orchestration/projects/{id}/status.md`. Also check active worktrees — if `worktree_path` is set and the directory exists, read `status.md` from the worktree path (authoritative).

2. If the project folder does not exist:
   > "project {id} not found — run `/status` with no args to list projects"
   Stop.

3. If the folder exists but `status.md` is absent:
   > "project {id} exists but status.md is missing — the project may be in an inconsistent state."
   Stop.

4. Read `status.md`. For each expected field (`stage`, `next_action`, `transitions`): if missing or unparseable, note it — display a warning in place of the value rather than crashing.

5. If `stage` is `done`:
   > "project {id} is done and has been archived to .orchestration/projects/done/"
   Stop.

6. Compute elapsed time in current stage: time since the most recent transition's timestamp. Format human-readable: `2h 14m`, `3d 7h`, etc.

7. Display:

```
project:   {id}
stage:     {stage}          (or "[missing — check status.md]" if absent)
next:      {next_action}    (or "[missing]" if absent)
elapsed:   {elapsed} (since {stage} at {timestamp of most recent transition})
worktree:  {worktree_path}  (if set)

Recent transitions:
  {timestamp}  {stage}  {note}
  {timestamp}  {stage}  {note}
  {timestamp}  {stage}  {note}
```

Show last 3 transitions, most recent first. If fewer than 3, show what exists. If `transitions` is missing or empty: show "no transitions recorded".

If any field produced a warning, append after the display block:
```
Warning: {field} is missing or unreadable in status.md
```

---

## Phase 2 — Multi-project scan

1. Scan `.orchestration/projects/*/status.md`. Exclude files under `done/` subdirectory.

2. Run `git worktree list`. For each worktree path (excluding the main worktree):
   - Check if a `status.md` exists at `{worktree_path}/.orchestration/projects/{id}/status.md`.
   - If it exists and differs from main: use the worktree version (authoritative).
   - If the worktree path is registered in git but the directory is missing: flag as `worktree_missing`.

3. Collect all active projects. For each:
   - `stage` from status.md
   - `next_action` from status.md
   - `worktree_path` if set
   - Elapsed time in current stage: `now - last_transition_timestamp`. If timestamp missing: "unknown"
   - Flag: `worktree_missing` if applicable

4. Proceed to Phase 3.

---

## Phase 3 — Summary table

If no active projects found:
> "no active projects — run `/design` to start one"
Skip to Phase 4 (done-this-week recap still runs).

Otherwise, render the table:

```
| Project | Stage | Worktree | Next action | Time in stage |
|---------|-------|----------|-------------|---------------|
| {id}    | {stage} | {path or —} | {next_action} | {elapsed} |
```

Below the table:
- For each project in a `*_review` stage: one line — "• {id}: run /{command} to continue"
  - `design_review` → `/design`
  - `slicing_review` → `/design`
  - `spec_review` → `/design`
  - `signoff_review` → `/review`
- For each `worktree_missing` project: "• {id}: worktree missing at {path} — run `git worktree prune`"
- For each `status.md` with missing required fields: show project row with "⚠ malformed status.md" in the stage column

---

## Phase 4 — Done this week

Scan `.orchestration/projects/done/*/*/status.md` (YYYY-MM subdirs).

For each: find the `done` transition in the `transitions` log. If the timestamp is within the last 7 days: include it.

Group results by username (first segment of the project ID, e.g. `bcokert` from `bcokert-00001-auth-redesign`).

If any results:
```
Done this week:
  {username}: {slug} (Mon Apr 10), {slug} (Tue Apr 11)
  {username}: {slug} (Sun Apr 9)
```

If nothing done in the last 7 days: omit this section entirely.

---

## Behavior rules

- Read-only. Never write, edit, or delete any file under any circumstance.
- Partial reads are better than crashes. Show what's readable, warn on gaps.
- Elapsed time is derived from the most recent transition timestamp. If transitions are missing, show "unknown".
- Worktree `status.md` is authoritative over main when it diverges — the worktree is where current work lives.
- Orphaned worktrees (directory missing) produce a warning row, not a crash.
- Done projects are excluded from the active table. They appear only in the done-this-week recap (if recent).
