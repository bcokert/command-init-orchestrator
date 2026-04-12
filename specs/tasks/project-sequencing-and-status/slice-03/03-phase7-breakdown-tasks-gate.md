---
spec: specs/briefs/project-sequencing-and-status/03-spec-and-breakdown.md
slice: 03
step: 3
title: Wire Phase 7 — breakdown_in_progress, task creation, resume detection, tasks_ready gate
status: done
depends_on: [02-spec-md-output-path.md]
agent_type: architect
assigned_at: null
completed_at: null
---

## Work

In `defaults/commands/design.md` Phase 7:

1. On entry from `spec_review` approval: write `breakdown_in_progress` to `status.md` first.
2. Read the brief's breakdown table (Section — Breakdown). If zero rows: stop and ask.
3. For each row, create `.orchestration/projects/{id}/tasks/slice-{NN}/{task-NN}-{slug}.md` with:
   - `spec`, `slice`, `step`, `title`, `status: todo`
   - `depends_on`: sequential by default (each depends on previous); parallel only if brief explicitly marks steps as independent
   - `agent_type`: derived from work description (`architect` for command/prompt files, `server-dev` for Go/backend, `client-dev` for frontend, `quality` for tests)
   - `assigned_at: null`, `completed_at: null`
4. Resume detection: count existing task files in `tasks/slice-{NN}/` and compare to breakdown table row count. If mismatch: regenerate all (idempotent overwrite).
5. Update slice file frontmatter: `status: tasks_ready`.
6. Append to `status.md`: `stage: tasks_ready`, timestamp, note (`{N} tasks created for slice {NN}`).
7. Commit: task files + slice file + `status.md`. Message: `"Tasks ready — {project_id} slice {NN} ({N} tasks)"`. Push.
8. Output: `"Tasks ready — run /implement to start implementation."`

## Context

Read first:
- `specs/briefs/project-sequencing-and-status/03-spec-and-breakdown.md` — task file fields and cross-slice isolation constraint

## Done signal

Task files at `tasks/slice-{NN}/` with all required fields. Partial task count triggers full regeneration. `git show --stat HEAD` shows task files + slice file + `status.md` only. Slice status = `tasks_ready`.
