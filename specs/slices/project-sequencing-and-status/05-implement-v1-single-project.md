---
type: slice
slice: 05
project: project-sequencing-and-status
design: specs/design/project-sequencing-and-status.md
status: draft
---

# Slice 05 — `/implement` v1: single project, sequential

**Goal:** `/implement` selects one `tasks_ready` project, creates a worktree, suggests an agent team, runs tasks sequentially, runs QA, writes a QA report, and advances to `signoff_review`.

## Happy path

- Run `/implement` → shows `tasks_ready` projects → user selects one → worktree education shown → worktree created at `.orchestration/worktrees/{id}` on branch `project/{id}` → agent team suggested from task `agent_type` fields, user confirms → tasks run sequentially with `assigned_at`/`completed_at` timestamps → QA runs → `qa-report-{slice-id}.md` written → status advances to `signoff_review`, commit + push
- `/design` or `/review` while `implementing` → "project is implementing in worktree {path} — run `/implement` to resume, or `/review` once QA is complete"

## Edge cases

- Worktree creation fails (branch exists, disk error): clear error, project stays `tasks_ready`, no partial state
- Agent fails mid-task: task stays `in_progress`, QA detects and reports — does not auto-advance to `done`
- QA failures: fix what the agent team can fix, re-run QA, advance to `signoff_review` only when QA passes. Items requiring a human or unavailable service are noted in the report but don't block advancement.
