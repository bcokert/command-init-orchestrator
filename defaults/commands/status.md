---
version: 1.0.0
description: |
  Reads status.md files from .orchestration/projects/ and displays a concise summary. With a project ID arg: single-project detail view. Without: lists all active projects and prompts selection. Read-only — never modifies files.
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

If a project ID was passed as argument: proceed to Phase 1 (single-project mode).

If no argument: proceed to Phase 2 (no-arg mode).

---

## Phase 1 — Single-project detail view

1. Resolve path: `.orchestration/projects/{id}/status.md`

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

## Phase 2 — No-arg mode

1. Check if `.orchestration/projects/` exists. If not:
   > "no active projects — run `/design` to start one"
   Stop.

2. Scan `.orchestration/projects/*/status.md`. For each file found: read `stage`. Collect all projects where `stage` is not `done` (and not under `done/` subfolder).

3. If no active projects found:
   > "no active projects — run `/design` to start one"
   Stop.

4. List projects:

```
Active projects:

  {id}    {stage}
  {id}    {stage}

Run /status {id} for details, or select one:
```

5. Prompt user to select a project ID.

6. Once selected, run Phase 1 for that project.

7. After displaying detail, show:
   > Tip: run `/status {id}` directly to skip this list.

---

## Behavior rules

- Read-only. Never write, edit, or delete any file under any circumstance.
- Partial reads are better than crashes. Show what's readable, warn on gaps.
- Elapsed time is derived from the most recent transition timestamp. If transitions are missing, omit elapsed.
- Only active projects appear in the list. Done projects have been archived and are not shown.
