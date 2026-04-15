---
spec: specs/briefs/project-sequencing-and-status/04-status-v1.md
slice: 04
step: 2
title: Add no-arg mode — list projects and prompt selection
status: done
depends_on: [01-status-single-project-mode.md]
agent_type: architect
assigned_at: null
completed_at: null
---

## Work

Add Phase 2 to `defaults/commands/status.md`:

**Phase 2 — No-arg mode**

1. Check if `.orchestration/projects/` exists. If not: output "no active projects — run `/design` to start one". Stop.
2. Scan `.orchestration/projects/*/status.md`. Collect all projects where `stage` is not `done`.
3. If none found: output "no active projects — run `/design` to start one". Stop.
4. List projects:

```
Active projects:

  {id}  {stage}
  {id}  {stage}

Run /status {id} for details, or select:
```

5. Prompt user to select a project ID.
6. Once selected, run Phase 1 for that project.
7. After displaying detail, show brief education:

```
Tip: run /status {id} directly to skip this list.
```

## Context

Read first:
- `specs/briefs/project-sequencing-and-status/04-status-v1.md` — no-arg mode constraints and education requirement

## Done signal

`/status` with no args lists active projects and prompts selection. Selecting a project shows the detail view. No projects → correct message.
