---
spec: specs/briefs/project-sequencing-and-status/06-implement-v2-concurrent.md
slice: 06
step: 1
title: Update project selection to allow concurrent implementing projects
status: done
depends_on: []
agent_type: architect
assigned_at: 2026-04-12T00:00:00Z
completed_at: 2026-04-12T00:00:00Z
---

## Work

Update Phase 0 of `defaults/commands/implement.md` so that project selection filters to `tasks_ready` only, without being blocked by already-`implementing` projects.

When no argument is passed and there are no `tasks_ready` projects:
- If there are `implementing` projects: list them and output "no projects ready — pass a project ID to resume one of the above"
- If there are no `implementing` projects either: "no projects ready — run /design to start one"

When `tasks_ready` projects exist, list them for selection as before — regardless of how many projects are already in `implementing`.

## Done signal

Running `/implement` with an already-implementing project present shows `tasks_ready` projects for selection, not the in-flight one. All combinations (0 ready + 0 running, 0 ready + N running, N ready + M running) produce correct output.
