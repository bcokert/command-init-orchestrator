---
type: brief
slice: 05
project: project-sequencing-and-status
design: specs/design/project-sequencing-and-status.md
slice_doc: specs/slices/project-sequencing-and-status/05-implement-v1-single-project.md
status: ready
date: 2026-04-12
---

# Delegation brief — Slice 05: `/implement` v1

## Intent

Rewrite `defaults/commands/implement.md` as the new `/implement` command. The current file is a placeholder from the old dashboard-based system. The new version owns the execution half of the pipeline: project selection → worktree creation → sequential task execution → automatic QA → signoff_review.

This is v1: one project at a time, tasks run sequentially. Parallel execution across projects comes in slice 06.

## Observable outcomes

**Project selection:**
```
Given one or more projects have status: tasks_ready
When the user runs /implement
Then the command lists tasks_ready projects and prompts selection
And if a project ID is passed as argument, it uses that directly
```

**Wrong command at implementing stage:**
```
Given status.md shows stage: implementing
When the user runs /design or /review
Then output is: "project {id} is implementing in worktree {path} — run /implement to resume, or /review once QA is complete"
```

**Worktree creation — first time:**
```
Given git worktree list shows only the main worktree (no prior worktrees)
When /implement creates the worktree
Then fuller education is shown explaining what worktrees are and why they're used
And the worktree is created at .orchestration/worktrees/{id} on branch project/{id}
And status.md is updated with worktree_path and branch
```

**Worktree creation — repeat use:**
```
Given git worktree list shows prior worktrees have existed
When /implement creates the worktree
Then a brief confirmation is shown: "worktree created — working on branch project/{id}"
And the worktree is created and status.md updated
```

**Worktree creation fails:**
```
Given git worktree add fails (branch conflict, disk error, permissions)
When the error occurs
Then a clear error is shown
And status.md is NOT updated
And the project stays at tasks_ready
```

**Task execution:**
```
Given a worktree exists and agent team is confirmed
When tasks run
Then tasks execute sequentially in depends_on order
And each task's assigned_at is set when it starts
And each task's completed_at is set when it finishes
And status.md stage advances to implementing before first task runs
```

**QA runs automatically:**
```
Given all tasks are marked done
When the last task completes
Then QA runs automatically without user prompting
Then on QA pass: slice advances to signoff_review, user told to run /review
```

## Constraints

**Must:**
- Rewrite `defaults/commands/implement.md` completely — the current file is the old system
- Wrong-command routing table: add `implementing` stage rows (see design.md Phase 0 Step 2)
- Detect first-time worktree use via `git worktree list` — if output has only one line (main worktree), show full education; otherwise brief confirmation only
- Write `worktree_path` and `branch` to `status.md` after successful worktree creation
- On worktree failure: no `status.md` update, no partial state, project stays `tasks_ready`
- Write `status.md` stage to `implementing` before executing any task
- `assigned_at`: ISO 8601 timestamp written to task file frontmatter when task starts
- `completed_at`: ISO 8601 timestamp written when task finishes
- Task execution order respects `depends_on` — never start a task before its dependencies are done
- QA runs automatically after all tasks complete — read and follow `defaults/commands/qa.md`
- After QA pass: slice file → `status: signoff_review`, `status.md` stage → `signoff_review`. No commit — commit happens in `/review`
- Agent team suggestion: collect unique `agent_type` values from ready tasks, suggest that set, user confirms or adjusts before any task runs

**Must not:**
- Commit at worktree creation or task completion — commit cadence belongs to `/review`
- Run tasks in parallel (v1 is sequential only)
- Skip `depends_on` validation
- Auto-confirm the agent team without user input

**Preferences:**
- Worktrees directory: `.orchestration/worktrees/` — create if absent
- Branch name: `project/{id}`
- If no `tasks_ready` projects exist: "no projects ready — run /design to get to tasks_ready"

**Escalation triggers:**
- Task file references a `depends_on` that doesn't exist or isn't `done` — stop and report which task is blocked and why
- All tasks already `done` when `/implement` is called — skip to QA directly

## Done definition

1. `defaults/commands/implement.md` fully rewritten — old dashboard references gone
2. `/implement` with no `tasks_ready` projects outputs correct message
3. Worktree created at correct path/branch; `status.md` has `worktree_path` and `branch`
4. First-time detection: `git worktree list` single-line → full education; multi-line → brief confirmation
5. Worktree failure leaves project at `tasks_ready`, no `status.md` change
6. Task execution: `assigned_at`/`completed_at` timestamps written; `depends_on` order respected
7. QA triggers automatically on last task completion
8. Wrong-command routing: `/design` or `/review` at `implementing` outputs correct error

## Breakdown

| # | Step | Deliverable | Done signal |
|---|------|-------------|-------------|
| 1 | Rewrite implement.md — Phase 0 state detection + wrong-command routing + project selection | Phase 0 detects mode, wrong-command table covers `implementing`, Phase 1 lists `tasks_ready` projects | Wrong-command error correct; project list shown |
| 2 | Phase 2 — worktree creation + first-time education | Worktree created at correct path; `status.md` updated; failure leaves no partial state; first-time detection works | Worktree at `.orchestration/worktrees/{id}`; status has `worktree_path`; failure keeps `tasks_ready` |
| 3 | Phase 3 — agent team suggestion | Unique `agent_type` values collected from tasks; team shown; user confirms before any execution | Agent team displayed; execution blocked until confirmation |
| 4 | Phase 4 — sequential task execution with timestamps | Tasks run in `depends_on` order; `assigned_at`/`completed_at` written per task; `status.md` advances to `implementing` first | Task files have correct timestamps; `depends_on` violations blocked |
| 5 | Phase 5 — auto-QA + signoff_review advance | QA triggers on last task done; on pass: slice → `signoff_review`, `status.md` updated, user told to run /review | QA runs without prompting; correct state after pass |
