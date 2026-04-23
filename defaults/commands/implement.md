---
version: 2.7.0
description: |
  Execution pipeline: global queue scan → all tasks_ready slices → automatic QA → signoff_review. Runs all queued slices in sequence. Stops when all are at signoff_review for human approval via /review.
allowed-tools:
  - Read
  - Write
  - Glob
  - Grep
  - Bash
  - AskUserQuestion
---

# Implement — Task execution pipeline

Your job is to take all queued slices from `tasks_ready` to `signoff_review`. You own: queue selection, sequential task execution, and automatic QA.

---

## Phase 0 — Detect state and route

### Step 1 — Select next slice from global queue

If a project ID was passed as argument: glob `.orchestration/projects/{id}/02-slices/*.md`, validate the project has at least one slice at `tasks_ready` or `implementing`, and select its lowest-numbered slice at `tasks_ready` (or the in-progress slice if any is `implementing`). This determines `{id}` and `{NN}`.

If no argument:
1. Glob all `.orchestration/projects/*/02-slices/*.md` (excluding `done/`). Read each file's `slice:`, `status:`, and `status_updated_at:` frontmatter fields.
2. Filter to slices with `status: tasks_ready`.
3. If no slices found: "Nothing in the queue. Run /plan-project to create tasks." Stop.
4. Sort by `status_updated_at` ascending (oldest first). Tiebreak: project ID alphabetically. If `status_updated_at` is absent or unparseable on all candidates: report "Cannot determine queue order — all queued slices are missing status_updated_at. Set the field or pass a project ID directly." Stop.
5. Enforce per-project slice order: for each candidate slice N in project P, check whether any lower-numbered slice in project P is not at `signoff_review` or `done`. If so, report: "Project {P} slice {N} is blocked — slice {M} must reach signoff_review first." Skip this candidate.
6. Collect all unblocked candidates into an ordered execution list (sorted as above). If the list is empty: report all blocked slices and stop. "No eligible slices in the queue. Resolve the blockers listed above or run /plan-project."
7. The first item in the execution list is the active slice. This determines `{id}` and `{NN}` for Phase 1 and the initial Phase 2 cycle. After each slice reaches `signoff_review`, re-read slice states from disk and advance to the next slice in the list.

### Step 2 — Wrong-command routing

Check these conditions before doing any work. Stop if any match.

| Condition | Error message |
|-----------|---------------|
| Selected project has no slice at `tasks_ready` or `implementing`, but has slices in `draft`, `reviewed`, or `specced` | "Project '{id}' has slices in planning — run `/plan-project` to continue." |
| Selected project has a slice at `signoff_review` and was explicitly passed as the project ID | "Project '{id}' slice {NN} is awaiting signoff — run `/review` to approve or provide feedback." |

### Step 3 — Route by active slice state

The active slice is the first item in the execution list that is not already at `signoff_review`. Route based on its current state:

| Slice state | Action |
|-------------|--------|
| `tasks_ready` | Proceed to Phase 1 |
| `implementing` | Resume — find first `in_progress` or next runnable `todo` task for slice `{NN}` by reading task file statuses from disk, skip to Phase 2 |
| `signoff_review` | Already done this run — advance to the next slice in the execution list. If none remain, stop. |
| All slice `{NN}` tasks `done` | Skip directly to Phase 3 (QA) |

---

## Phase 1 — Implementation.Asking gate

1. Glob all `.orchestration/projects/*/02-slices/*.md`. Identify every slice at `tasks_ready` across all projects (not just the selected one).
2. For each `tasks_ready` slice found: read its task files and count those with `status: todo`. Sum across all slices for a total task count `{T}` across `{S}` slices.
3. Collect unique `agent_type` values from those task files. Count tasks per type.
4. Display:
   ```
   Ready to start implementation?

   {T} tasks across {S} slice(s):
   {for each slice: "  Slice {NN} — {title} ({N} tasks)"}
   Agent team:
     - {agent_type} ({N} tasks)
     - {agent_type} ({N} tasks)

   All queued slices will run in sequence. Reply "yes" to begin,
   or "review more slices first" to plan more before executing.
   ```
5. Wait for operator response.

   | Response | Action |
   |----------|--------|
   | Approval ("yes", "go", "start", etc.) | Proceed to Phase 2 |
   | "Review more slices first" (or similar) | List any slices not yet at `tasks_ready` (in `draft`, `review`, `reviewed`, `speccing`, or `breakdown` state) and tell the operator: "Run `/plan-project` to advance those slices, then re-run `/implement` to return here." Stop. |
   | Ambiguous | Ask once to clarify. |

6. Do not proceed to Phase 2 until the operator explicitly approves. User may adjust the agent team before approving.

---

## Phase 2 — Task execution

1. Write `status: implementing` and `status_updated_at: {current ISO 8601 timestamp with timezone offset}` to the slice file at `.orchestration/projects/{id}/02-slices/` (Glob for the file where `slice:` frontmatter matches the current slice number). If the slice file can't be found: log "warning: could not find slice file for slice {NN} — skipping status write" and continue.

2. Build the execution queue: all `todo` tasks in `.orchestration/projects/{id}/04-tasks/slice-{NN}/` ordered by `step`, respecting `depends_on`. A task is runnable only when all tasks named in its `depends_on` list have `status: done`.

3. If a `depends_on` reference doesn't exist or isn't `done` when required: stop and report which task is blocked and what's blocking it. Output: "Fix the task's `depends_on` field or complete the prerequisite task, then re-run /implement."

4. For each task in order:
   - Write `assigned_at: {ISO 8601}` to task file frontmatter.
   - Present the task: read the task file and the brief it references. Provide a kickoff that includes the task work, its done signal, and the brief path for full context. Surface the task's `model` and `effort` values (default to `sonnet`/`default` if fields are absent).
   - When task completes: write `status: done` and `completed_at: {ISO 8601}` to task file frontmatter.
   - Proceed to next task.

5. If all tasks are already `done` on entry: skip directly to Phase 3.

---

## Phase 3 — QA and signoff

Read and follow `.orchestration/support/qa.md` in full. QA runs automatically — no prompt.

Before invoking QA: write `status: qa_in_progress` and `status_updated_at: {current ISO 8601 timestamp with timezone offset}` to the slice file at `.orchestration/projects/{id}/02-slices/`. Use the same Glob pattern as Phase 2 to locate it. If the slice file already shows `status: qa_in_progress` or a later state (e.g. on crash-resume): skip this write. If the file can't be found: log a warning and continue.

On QA pass:
1. Slice file frontmatter: `status: signoff_review` and `status_updated_at: {current ISO 8601 timestamp with timezone offset}`
2. Re-read the execution list from disk. Check whether any remaining slices are still at `tasks_ready` or `implementing`.
   - If yes: advance to the next slice — return to Phase 2 for it. Do not output the signoff message yet.
   - If no (all slices in the execution list are now at `signoff_review`): output the final summary and stop.
3. Final output (after all slices reach `signoff_review`):
   ```
   QA passed — {project_id} ({S} slices at signoff_review)

   Review the output. When ready, run /review to approve each slice (marks done)
   or provide feedback (creates new slices in the backlog).
   ※ All slices · signoff_review · QA passed → run /review to approve 📄
   ```
4. Stop. No commit — that happens in `/review` on approval.

---

## Behavior rules

- Never `git add` or `git commit` anything — not during task execution, not after QA, not at signoff_review. All changes (implementation files, task status updates, QA report, slice status) must stay uncommitted so the human can review the full diff. The commit happens in `/review` when the human approves.
- Never run tasks in parallel — v1 is sequential only.
- Always validate `depends_on` before running a task. A task with an unmet dependency must not run.
- Resume by reading task file statuses from disk. Never assume state from the current session.
- If the queue is empty (no `tasks_ready` slices), report and stop per Step 1.
