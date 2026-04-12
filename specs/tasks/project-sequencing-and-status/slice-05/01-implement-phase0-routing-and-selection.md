---
spec: specs/briefs/project-sequencing-and-status/05-implement-v1-single-project.md
slice: 05
step: 1
title: Rewrite implement.md — Phase 0 routing, wrong-command table, project selection
status: todo
depends_on: []
agent_type: architect
assigned_at: null
completed_at: null
---

## Work

Rewrite `defaults/commands/implement.md` from scratch. The current file is the old dashboard-based system — discard it entirely.

**Phase 0 — Detect state and route**

1. If a project ID was passed as argument: validate it exists and is at `tasks_ready` or `implementing`, then route accordingly.
2. If no argument: scan `.orchestration/projects/*/status.md` for projects with `stage: tasks_ready`. If none: "no projects ready — run /design to get to tasks_ready". If one: use it. If multiple: list and prompt selection.
3. Wrong-command routing: extend the routing table (same pattern as design.md Phase 0 Step 2). Add row for `implementing`:

| Stage | Wrong command | Error message |
|-------|---------------|---------------|
| `implementing` | `/design` or `/review` | "Project '{id}' is implementing in worktree {path} — run `/implement` to resume, or `/review` once QA is complete." |

Read `worktree_path` from `status.md` to populate {path} in the error message.

**Resume from `implementing`:** read task files — find the first task that is `in_progress` or the next `todo` with all dependencies done — resume from there (Phase 4).

## Context

Read first:
- `specs/briefs/project-sequencing-and-status/05-implement-v1-single-project.md`
- `defaults/commands/design.md` Phase 0 — follow the same routing table pattern

## Done signal

Wrong-command error for `implementing` stage outputs correct message with worktree path. No `tasks_ready` projects outputs correct message. Multiple projects prompts selection.
