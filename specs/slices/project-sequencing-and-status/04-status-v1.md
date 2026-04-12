---
type: slice
slice: 04
project: project-sequencing-and-status
design: specs/design/project-sequencing-and-status.md
status: draft
---

# Slice 04 — `/status` v1: single project

**Goal:** `/status {id}` shows a project's current stage, next action, elapsed time, and recent transitions in a concise scannable layout. Validates `status.md` format is readable before `/implement` depends on it.

## Happy path

- `/status {id}` at any stage from slices 1–3 → correct stage, next action, elapsed time, last 3 transitions with timestamps; output scans in under 5 seconds
- No-arg mode: lists all project IDs, prompts for selection

## Edge cases

- Project ID not found → "project {id} not found — run `/status` with no args to list projects"
- `status.md` missing or malformed → reports what's readable, warns on missing fields, does not crash
- No projects exist → "no active projects — run `/design` to start one"
