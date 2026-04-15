---
spec: specs/briefs/project-sequencing-and-status/01-project-creation-and-design-interview.md
slice: 01
step: 2
title: Implement project folder creation and ID generation
status: done
depends_on: [01-phase-0-resume-logic.md]
agent_type: architect
assigned_at: 2026-04-11T15:30:00-07:00
completed_at: 2026-04-11T15:45:00-07:00
---

## Work

Add the folder creation and ID generation logic to `defaults/commands/design.md`:

- Read github username via `git config user.name`; fall back to prefix of `git config user.email`
- Derive slug from the project name: lowercase, kebab-case, max 5 words, strip common stop words (the, a, an, for, of, in, to)
- Scan `.orchestration/projects/` for existing folders matching `{username}-*` to find the highest current sequence number; new project gets highest + 1, zero-padded to 5 digits
- If folder already exists at the derived path (collision): increment sequence and retry
- Create `.orchestration/projects/{id}/` — create `.orchestration/projects/` if it doesn't exist

## Context

Read first:
- `specs/briefs/project-sequencing-and-status/01-project-creation-and-design-interview.md` — ID format spec and collision handling requirements

## Done signal

Folder created at correct path with correct ID format. Running twice with the same username produces `bcokert-00001-*` then `bcokert-00002-*`. Simulating a collision (pre-existing folder) produces an incremented ID.
