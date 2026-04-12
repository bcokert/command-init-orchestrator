---
spec: specs/briefs/project-sequencing-and-status/03-spec-and-breakdown.md
slice: 03
step: 1
title: Wire Phase 6 — spec_in_progress, slice selection, spec write, spec_review gate
status: todo
depends_on: []
agent_type: architect
assigned_at: null
completed_at: null
---

## Work

In `defaults/commands/design.md` Phase 6:

1. On entry from `slicing_review` approval: write `spec_in_progress` to `status.md` first.
2. Select the target slice: lowest-numbered slice file in `.orchestration/projects/{id}/slices/` with `status: draft` or `status: reviewed` that comes after all slices with `status: specced`, `tasks_ready`, or `done`. Never skip a slice.
3. If the slice is `draft` and ambiguous: stop and ask the user to clarify before proceeding.
4. Read and follow `defaults/commands/spec.md` to produce the delegation brief.
5. Write brief to `.orchestration/projects/{id}/briefs/{NN}-{slug}.md`.
6. Update slice file frontmatter: `status: specced`.
7. Append to `status.md`: `stage: spec_review`, timestamp, note.
8. Commit: brief + slice file + `status.md`. Message: `"Spec complete — {project_id} slice {NN}"`. Push.
9. Show spec review gate (light review copy from design.md Phase 6).

On resume from `spec_in_progress` with no brief file: restart spec for that slice.
On resume from `spec_review`: show gate immediately, no re-spec.

## Context

Read first:
- `specs/briefs/project-sequencing-and-status/03-spec-and-breakdown.md` — slice selection rule and commit constraints

## Done signal

Running `/design` from `slicing_review` produces brief at correct path. Slice status = `specced`. `git show --stat HEAD` shows brief + slice file + `status.md` only.
