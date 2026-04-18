---
version: 2.3.0
description: |
  Execution pipeline: global queue scan → next slice execution → automatic QA → signoff_review. Resumes from wherever the selected slice left off. Stops at signoff_review for human approval via /review.
allowed-tools:
  - Read
  - Write
  - Glob
  - Grep
  - Bash
  - AskUserQuestion
---

# Implement — Task execution pipeline

Your job is to take the next queued slice from `tasks_ready` to `signoff_review`. You own: queue selection, sequential task execution, and automatic QA.

---

## Phase 0 — Detect state and route

### Step 1 — Select next slice from global queue

If a project ID was passed as argument: read `.orchestration/projects/{id}/status.md`, validate the project is at `tasks_ready` or `implementing`, and select its lowest-numbered slice that is at `tasks_ready` (or any in-progress slice if the project is `implementing`). This determines `{id}` and `{NN}`.

If no argument:
1. Glob all `.orchestration/projects/*/02-slices/*.md` (excluding `done/`). Read each file's `slice:`, `status:`, and `status_updated_at:` frontmatter fields.
2. Filter to slices with `status: tasks_ready`.
3. If no slices found: "Nothing in the queue. Run /plan-project to create tasks." Stop.
4. Sort by `status_updated_at` ascending (oldest first). Tiebreak: project ID alphabetically. If `status_updated_at` is absent or unparseable on all candidates: report "Cannot determine queue order — all queued slices are missing status_updated_at. Set the field or pass a project ID directly." Stop.
5. Enforce per-project slice order: for each candidate slice N in project P, check whether any lower-numbered slice in project P is not at `signoff_review` or `done`. If so, report: "Project {P} slice {N} is blocked — slice {M} must reach signoff_review first." Skip this candidate.
6. Select the first unblocked candidate. This determines `{id}` and `{NN}` for the remainder of the command.
7. If no unblocked candidates remain: report all blocked slices and stop. "No eligible slices in the queue. Resolve the blockers listed above or run /plan-project."

### Step 2 — Wrong-command routing table

Check this table before doing any work. `/implement` enforces its own rows.

| Stage | Wrong command | Error message |
|-------|---------------|---------------|
| `design_in_progress`, `design_review`, `slicing_in_progress`, `slicing_review`, `spec_in_progress`, `spec_review`, `breakdown_in_progress` | `/implement` | "Project '{id}' is in {stage} — run `/plan-project` to continue." |
| `implementing` | `/plan-project` or `/review` | "Project '{id}' is implementing — run `/implement` to resume, or `/review` once QA is complete." |
| `signoff_review` | `/implement` with this specific project ID | "Project '{id}' is awaiting signoff — run `/review` to approve or provide feedback." |
| `feedback_pending` | `/implement` | "Project '{id}' has unprocessed feedback — run `/plan-project` to spec the next slice." |

### Step 3 — Route by selected slice state

| Slice state | Action |
|-------------|--------|
| `tasks_ready` | Proceed to Phase 1 |
| `implementing` | Resume — find first `in_progress` or next runnable `todo` task for slice `{NN}` by reading task file statuses from disk, skip to Phase 2 |
| All slice `{NN}` tasks `done` | Skip directly to Phase 3 (QA) |

---

## Phase 1 — Agent team

1. Read all task files in `.orchestration/projects/{id}/04-tasks/slice-*/` with `status: todo`.
2. Collect unique `agent_type` values. Count tasks per type.
3. Display:
   ```
   Suggested agent team for {id}:
     - {agent_type} ({N} tasks)
     - {agent_type} ({N} tasks)

   Confirm or adjust before tasks begin:
   ```
4. Wait for user confirmation. User may remove types or add others.
5. Do not proceed to Phase 2 until confirmed.

---

## Phase 2 — Task execution

1. Write `implementing` to `status.md` before executing any task:
   ```yaml
   stage: implementing
   next_action: executing tasks
   transitions:
     - stage: implementing
       timestamp: {ISO 8601}
       note: task execution started
   ```
   Also write `status: implementing` and `status_updated_at: {current ISO 8601 timestamp with timezone offset}` to the slice file at `.orchestration/projects/{id}/02-slices/` (Glob for the file where `slice:` frontmatter matches the current slice number). If the slice file can't be found: log "warning: could not find slice file for slice {NN} — skipping status write" and continue.

2. Build the execution queue: all `todo` tasks in `.orchestration/projects/{id}/04-tasks/slice-{NN}/` ordered by `step`, respecting `depends_on`. A task is runnable only when all tasks named in its `depends_on` list have `status: done`.

3. If a `depends_on` reference doesn't exist or isn't `done` when required: stop and report which task is blocked and what's blocking it. Output: "Fix the task's `depends_on` field or complete the prerequisite task, then re-run /implement."

4. For each task in order:
   - Write `assigned_at: {ISO 8601}` to task file frontmatter.
   - Present the task: read the task file and the brief it references. Provide a kickoff that includes the task work, its done signal, and the brief path for full context.
   - When task completes: write `status: done` and `completed_at: {ISO 8601}` to task file frontmatter.
   - Proceed to next task.

5. If all tasks are already `done` on entry: skip directly to Phase 3.

---

## Phase 3 — QA and signoff

Read and follow `.orchestration/support/qa.md` in full. QA runs automatically — no prompt.

Before invoking QA: write `status: qa_in_progress` and `status_updated_at: {current ISO 8601 timestamp with timezone offset}` to the slice file at `.orchestration/projects/{id}/02-slices/`. Use the same Glob pattern as Phase 2 to locate it. If the slice file already shows `status: qa_in_progress` or a later state (e.g. on crash-resume): skip this write. If the file can't be found: log a warning and continue.

On QA pass:
1. Slice file frontmatter: `status: signoff_review` and `status_updated_at: {current ISO 8601 timestamp with timezone offset}`
2. Update `status.md`:
   ```yaml
   stage: signoff_review
   next_action: run /review to approve or provide feedback
   transitions:
     - stage: signoff_review
       timestamp: {ISO 8601}
       note: QA passed
   ```
3. Output:
   ```
   QA passed — {project_id} slice {NN}

   Review the output. When ready, run /review to approve (marks done)
   or provide feedback (creates a new slice in the backlog).
   ※ Slice {NN} · stage 10/10 signoff_review · QA passed → run /review to approve 📄
   ```
4. Stop. No commit — that happens in `/review` on approval.

---

## Behavior rules

- Never `git add` or `git commit` anything — not during task execution, not after QA, not at signoff_review. All changes (implementation files, task status updates, QA report, slice status, status.md) must stay uncommitted so the human can review the full diff. The commit happens in `/review` when the human approves.
- Never run tasks in parallel — v1 is sequential only.
- Always validate `depends_on` before running a task. A task with an unmet dependency must not run.
- Resume by reading task file statuses from disk. Never assume state from the current session.
- If the queue is empty (no `tasks_ready` slices), report and stop per Step 1.
