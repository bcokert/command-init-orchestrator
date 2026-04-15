---
spec: specs/briefs/project-sequencing-and-status/02-slicing-step.md
slice: 02
step: 2
title: Update slice.md output path and format
status: done
depends_on: [01-phase5-status-and-resume.md]
agent_type: architect
assigned_at: null
completed_at: null
---

## Work

Update `defaults/commands/slice.md` so slicing produces individual files at the correct path with the correct frontmatter:

- Output path: `.orchestration/projects/{id}/slices/{NN}-{slug}.md` (one file per slice)
- Each file frontmatter: `type: slice`, `slice: {NN}`, `project: {project_id}`, `design: {path}`, `status: draft`
- Slice 01 (next to implement): full detail — Goal + complete Happy path + complete Edge cases
- Slices 02+: rough — Goal + 2-3 rough bullets each section, clearly marked as draft
- Logic changes: path only. Slicing interview logic, vertical-slice rules, and stress-test steps unchanged.

## Context

Read first:
- `specs/briefs/project-sequencing-and-status/02-slicing-step.md` — slice file format under Constraints
- `defaults/commands/slice.md` — current implementation to understand what changes vs what stays

## Done signal

Slice files appear at `.orchestration/projects/{id}/slices/{NN}-{slug}.md` with correct frontmatter. Slice 01 is detailed; subsequent slices are rough. Existing slicing logic (vertical checks, stress test) is unchanged.
