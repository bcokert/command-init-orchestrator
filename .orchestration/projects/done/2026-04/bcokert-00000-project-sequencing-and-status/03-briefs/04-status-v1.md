---
type: brief
slice: 04
project: project-sequencing-and-status
design: specs/design/project-sequencing-and-status.md
slice_doc: specs/slices/project-sequencing-and-status/04-status-v1.md
status: ready
date: 2026-04-11
---

# Delegation brief — Slice 04: `/status` v1

## Intent

Create `defaults/commands/status.md` — the `/status` command. It reads `status.md` files from `.orchestration/projects/` and displays a concise, scannable summary. Two modes: with a project ID arg (single project detail view), without (list all projects and prompt selection).

This slice also validates that the `status.md` format written by `/design` (slices 01–03) is actually readable in practice. If `/status` can't produce an accurate summary, the format is wrong — fix the format, not the command.

No existing file to modify. This is a new command file.

## Observable outcomes

**With project ID arg — project found:**
```
Given .orchestration/projects/{id}/status.md exists
When the user runs /status {id}
Then output shows: project ID, current stage, next action, elapsed time in current stage, last 3 transitions with timestamps and notes
And output scans in under 5 seconds
```

**With project ID arg — not found:**
```
Given no project folder exists for {id}
When the user runs /status {id}
Then output is: "project {id} not found — run /status with no args to list projects"
```

**No-arg mode — projects exist:**
```
Given .orchestration/projects/ has 1+ project folders with status.md
When the user runs /status
Then output lists all non-done project IDs with their current stage
And user is prompted to select one for detail view
And output includes brief education on other ways to call /status (e.g. /status {id} to skip selection)
```

**No-arg mode — no projects:**
```
Given .orchestration/projects/ is absent or has no project folders
When the user runs /status
Then output is: "no active projects — run /design to start one"
```

**Malformed status.md:**
```
Given .orchestration/projects/{id}/status.md exists but is missing fields or unparseable
When the user runs /status {id}
Then output shows whatever is readable, with a warning for each missing/unparseable field
And does not crash
```

## Constraints

**Must:**
- Read `status.md` only — no artifact scanning, no dashboard files
- Display for single-project view: `project_id`, `stage`, `next_action`, elapsed time in current stage (derived from the timestamp of the most recent transition), last 3 transitions with ISO 8601 timestamps and notes
- Elapsed time format: human-readable (e.g. `2h 14m`, `3d 7h`)
- No-arg list: show all projects where stage is not `done`. Done projects are archived and not in the active folder.
- Partial reads on malformed `status.md`: show what's there, warn on gaps, don't crash

**Must not:**
- Modify any file — `/status` is read-only
- Scan artifact files (designs, briefs, tasks) — only `status.md` matters
- Show done/archived projects in the active list (they've been moved to `done/YYYY-MM/`)

**Preferences:**
- Scannable layout — label-aligned, not prose. Single-project view fits on one screen.
- Stage name in the list view is enough context; next_action only needed in detail view

**Escalation triggers:**
- `.orchestration/projects/` directory exists but is completely empty: output "no active projects — run /design to start one"
- `status.md` exists but has no `stage` field and no `transitions` — warn and note the file is unreadable, suggest checking the file manually

## Done definition

1. `/status {id}` on a project with valid `status.md` outputs stage, next_action, elapsed time, and last 3 transitions correctly
2. `/status {id}` on unknown ID outputs correct error
3. `/status` with no args lists all active projects and prompts selection
4. `/status` with no args when no projects exist outputs correct message
5. `/status {id}` on a project with missing or malformed `status.md` fields: shows readable fields, warns on gaps, does not crash
6. Command is read-only — no files modified under any path

## Breakdown

| # | Step | Deliverable | Done signal |
|---|------|-------------|-------------|
| 1 | Create `defaults/commands/status.md` — single-project mode | Phase 0 (detect mode), Phase 1 (read + display single project: stage, next_action, elapsed, last 3 transitions) | `/status {id}` on valid project shows correct formatted output |
| 2 | Add no-arg mode | Phase 2 (scan projects/, list active projects, prompt selection, education) | `/status` with no args lists projects and prompts correctly; no projects → correct message |
| 3 | Add error handling | Project not found, malformed status.md partial read with field-level warnings | All error paths output correct messages without crashing |
