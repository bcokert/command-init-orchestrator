---
version: 2.0.0
description: |
  Execution pipeline for a single project: project selection → worktree creation → sequential task execution → automatic QA → signoff_review. Resumes from wherever the project left off. Stops at signoff_review for human approval via /review.
allowed-tools:
  - Read
  - Write
  - Glob
  - Grep
  - Bash
  - AskUserQuestion
---

# Implement — Task execution pipeline

Your job is to take a project from `tasks_ready` to `signoff_review`. You own: project selection, worktree creation, sequential task execution, and automatic QA.

---

## Phase 0 — Detect state and route

### Step 1 — Identify the project

If a project ID was passed as argument: read `.orchestration/projects/{id}/status.md` and validate the project is at `tasks_ready` or `implementing`.

If no argument:
1. Scan `.orchestration/projects/*/status.md`. Collect projects by stage.
2. Separate into two lists: `tasks_ready` and `implementing`.
3. If `tasks_ready` is non-empty: list them and prompt selection (even if `implementing` projects exist — concurrent execution is normal).
4. If `tasks_ready` is empty and `implementing` is non-empty:
   - List the implementing projects with their worktree paths.
   - Output: "No projects ready to start. Pass a project ID to resume one of the above."
   - Stop.
5. If both lists are empty: "No projects ready — run /design to start one." Stop.

### Step 2 — Wrong-command routing table

Check this table before doing any work. `/implement` enforces its own rows.

| Stage | Wrong command | Error message |
|-------|---------------|---------------|
| `design_in_progress`, `design_review`, `slicing_in_progress`, `slicing_review`, `spec_in_progress`, `spec_review`, `breakdown_in_progress` | `/implement` | "Project '{id}' is in {stage} — run `/design` to continue." |
| `implementing` | `/design` or `/review` | "Project '{id}' is implementing in worktree {worktree_path} — run `/implement` to resume, or `/review` once QA is complete." |
| `signoff_review` | `/implement` with this specific project ID | "Project '{id}' is awaiting signoff — run `/review` to approve or provide feedback." |
| `feedback_pending` | `/implement` | "Project '{id}' has unprocessed feedback — run `/design` to spec the next slice." |

### Step 3 — Route by current stage

| Stage | Action |
|-------|--------|
| `tasks_ready` | Proceed to Phase 1 |
| `implementing` | Resume — find first `in_progress` or next runnable `todo` task, skip to Phase 3 |
| All tasks `done`, stage `implementing` | Skip directly to Phase 4 (QA) |

---

## Phase 1 — Worktree creation

**On resume** (project is `implementing` with `worktree_path` set in `status.md`):
1. Check if the directory at `worktree_path` exists.
2. If it exists: skip worktree creation entirely. Proceed to Phase 2.
3. If the directory is missing: output "Worktree directory missing at {worktree_path}. Run `git worktree prune` to clean up, then re-run /implement to create a fresh worktree." Stop.

**On first run** (project is `tasks_ready`):
1. Create `.orchestration/worktrees/` if it doesn't exist.

2. Detect first-time use: run `git worktree list`. If the output has only one line (main worktree only), this is the first worktree this repo has used.

3. Run:
   ```bash
   git worktree add .orchestration/worktrees/{id} -b project/{id}
   ```

4. **On failure** (non-zero exit): output a clear error describing what failed. Do NOT update `status.md`. Project stays at `tasks_ready`. Stop.

5. **On success:** update `status.md` — append transition and add fields:
   ```yaml
   worktree_path: .orchestration/worktrees/{id}
   branch: project/{id}
   transitions:
     - stage: worktree_created
       timestamp: {ISO 8601}
       note: worktree created at .orchestration/worktrees/{id}
   ```

6. Show education:
   - **First time** (single-line `git worktree list`): explain what worktrees are — isolated working directories on a dedicated branch, one per project, all agents scoped to the worktree path so parallel projects can't conflict, main branch stays clean for planning. Explain what happens next.
   - **Repeat use**: "worktree created — working on branch project/{id}"

---

## Phase 2 — Agent team

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
5. Do not proceed to Phase 3 until confirmed.

---

## Phase 3 — Task execution

1. Write `implementing` to `status.md` before executing any task:
   ```yaml
   stage: implementing
   next_action: executing tasks
   transitions:
     - stage: implementing
       timestamp: {ISO 8601}
       note: task execution started
   ```

2. Build the execution queue: all `todo` tasks in `.orchestration/projects/{id}/04-tasks/slice-{NN}/` ordered by `step`, respecting `depends_on`. A task is runnable only when all tasks named in its `depends_on` list have `status: done`.

3. If a `depends_on` reference doesn't exist or isn't `done` when required: stop and report which task is blocked and what's blocking it.

4. For each task in order:
   - Write `assigned_at: {ISO 8601}` to task file frontmatter.
   - Present the task: read the task file and the brief it references. Provide a kickoff that includes the task work, its done signal, and the brief path for full context.
   - When task completes: write `status: done` and `completed_at: {ISO 8601}` to task file frontmatter.
   - Proceed to next task.

5. If all tasks are already `done` on entry: skip directly to Phase 4.

---

## Phase 4 — QA and signoff

Read and follow `defaults/commands/qa.md` in full. QA runs automatically — no prompt.

On QA pass:
1. Slice file frontmatter: `status: signoff_review`
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
   ```
4. Stop. No commit — that happens in `/review` on approval.

---

## Behavior rules

- Never `git add` or `git commit` anything — not during task execution, not after QA, not at signoff_review. All changes (implementation files, task status updates, QA report, slice status, status.md) must stay uncommitted so the human can review the full diff. The commit happens in `/review` when the human approves.
- Never run tasks in parallel — v1 is sequential only.
- Always validate `depends_on` before running a task. A task with an unmet dependency must not run.
- Resume by reading task file statuses from disk. Never assume state from the current session.
- If no `tasks_ready` projects exist, say so clearly and stop.
