---
spec: specs/briefs/project-sequencing-and-status/07-review-command.md
slice: 07
step: 1
title: Write review.md Phase 0 — state detection and wrong-command routing
status: done
depends_on: []
agent_type: architect
assigned_at: 2026-04-12T00:00:00Z
completed_at: 2026-04-12T00:00:00Z
---

## Work

Create `defaults/commands/review.md`. Write the frontmatter and Phase 0 only.

Frontmatter:
```yaml
---
version: 1.0.0
description: |
  Closes the signoff loop for a project in signoff_review. Approve path: commits the full execution diff, merges the worktree branch to main, archives the project. Feedback path: writes new slice files to the backlog, sets feedback_pending.
allowed-tools:
  - Read
  - Write
  - Bash
  - Glob
  - Grep
  - AskUserQuestion
---
```

Phase 0 — detect state and route:
1. If a project ID was passed as argument: read its `status.md`, validate it's at `signoff_review`
2. If no argument: scan `.orchestration/projects/*/status.md` for `stage: signoff_review`. If none: "no projects awaiting signoff". If one: use it. If multiple: list and prompt.
3. Wrong-command routing table — `/review` enforces these:

| Stage | Error message |
|-------|---------------|
| Any stage except `signoff_review` | "Project '{id}' is in {stage} — run /design or /implement as appropriate." |
| `feedback_pending` + user tries `/implement` | "Project '{id}' has unprocessed feedback — run /design to spec the next slice." |

## Done signal

Phase 0 correctly routes to signoff_review projects. All wrong-command cases output the correct message and stop.
