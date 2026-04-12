---
type: slice
slice: 06
project: project-sequencing-and-status
design: specs/design/project-sequencing-and-status.md
status: draft
---

# Slice 06 — `/implement` v2: parallel multi-project

**Goal:** `/implement` can select 2+ projects, create a worktree per project, and run them in parallel (capped at 4). User explicitly chooses parallel vs sequential.

## Happy path

- Select 2+ projects → choose parallel or sequential (default: sequential) → parallel creates all worktrees, runs up to 4 concurrently → each project independently reaches `signoff_review` → `/status` shows all with worktree state
- Parallel mode education: token consumption, machine load, monitoring with `/status`

## Edge cases

- User selects 5 projects, parallel mode: "capped at 4 — which 4 to start? Remainder stays `tasks_ready`"
- Worktree creation fails for one project in a batch: roll back all worktrees created in this batch, leave all selected projects at `tasks_ready`, report which failed
- One project fails mid-execution while others continue: failing project stays in last known state; others proceed independently
