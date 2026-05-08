---
version: 2.8.0
description: |
  Execution pipeline. Global queue → all tasks_ready slices → automatic QA → signoff_review. One team gate at start, batched across the whole queue. Scope frozen at entry — no mid-batch re-reads.
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - AskUserQuestion
---

# Implement — task execution pipeline

Take all queued slices from `tasks_ready` to `signoff_review`. Owns: queue selection, sequential task execution, automatic QA.

State, schemas, principles, vocabulary, and crash recovery rules live in `.root-context/state-diagram.md`. Helpers used: `support/next-actions.md` (queue), `support/status-write.md` (frontmatter writes), `support/qa.md` (Phase 3).

---

## Phase 0 — Resolve scope

Run `support/next-actions.md`. Filter to slices at `tasks_ready` or `implementing`. With a project ID arg: restrict to that project.

Sort: `status_updated_at` ascending; tiebreak project ID alphabetical. If all candidates lack `status_updated_at` and no arg was passed: stop and report.

Per-project ordering: slice N blocked until slice N-1 reaches `signoff_review`. Skip blocked candidates; report blockers.

**Wrong-command shortcuts:**
- Project has only `draft` / `review` / `speccing` / `breakdown` slices → "Project '{id}' has slices in planning — run `/plan-project`." Stop.
- Explicit project arg has only `signoff_review` → "Project '{id}' slice {NN} is awaiting signoff — run `/review`." Stop.

The execution list is the unblocked candidates in sort order. **Frozen at entry** — no mid-run re-reads. Slices appearing post-entry are picked up on the next invocation. The first list item is the active slice.

Active slice routing (current state):

| State | Action |
|---|---|
| `tasks_ready` | Phase 1 |
| `implementing` | Resume — find first `in_progress` or runnable `todo` task; skip to Phase 2 |
| All slice tasks `done` | Skip to Phase 3 |

---

## Phase 1 — Implementation.Asking gate

Read all task files for `tasks_ready` slices in scope. Sum `todo` count `{T}` across `{S}` slices. Collect unique `agent_type` values; count tasks per type.

**Re-entry shortcut:** if `observability/team-mix.md` exists for the active project and matches the current scope's team mix, skip the gate and proceed to Phase 2. Otherwise display:

```
Ready to start implementation?

{T} tasks across {S} slice(s):
  Slice {NN} — {title} ({N} tasks)
  ...
Agent team:
  - {agent_type} ({N} tasks)
  - ...

All queued slices run end-to-end with no inter-slice gates. Reply "yes" to begin.
```

Wait for the user's response.

| Response | Action |
|---|---|
| Approval ("yes", "go", "start") | Record team mix to `observability/team-mix.md`; proceed to Phase 2 |
| Adjusted team | Apply the user's edits to in-scope task files; re-display once; wait again |
| Ambiguous | Re-ask once. If still unclear: stop and report. |

---

## Phase 2 — Task execution

`status-write.md` → active slice `status: implementing`.

Execution queue: all `todo` tasks in `04-tasks/slice-{NN}/` ordered by `step`, respecting `depends_on`. A task is runnable only when every dep has `status: done`.

If a `depends_on` reference doesn't exist or isn't `done` when required: stop, report which task is blocked and what's blocking it. "Fix the task's `depends_on` field or complete the prerequisite, then re-run /implement."

For each runnable task:
- Write `assigned_at` to task frontmatter.
- Read the task file and its brief. Surface a kickoff including the task work, done signal, and brief path. Surface `model` and `effort` (defaults: `sonnet` / `default`).
- On completion: write `status: done` and `completed_at`.

If all tasks are `done` on entry: skip to Phase 3.

---

## Phase 3 — QA and signoff

Read and follow `support/qa.md` in full. QA runs automatically — no prompt.

Before invoking: `status-write.md` → `status: qa_in_progress`. Skip if already `qa_in_progress` or beyond (crash resume).

**On QA pass:**
1. `status-write.md` → `status: signoff_review`.
2. Advance to the next slice in the frozen execution list. If any remain at `tasks_ready` or `implementing`: return to Phase 2 for that slice. Do not output the signoff message yet.
3. After every slice in scope is at `signoff_review`:
   ```
   QA passed — {project_id} ({S} slices at signoff_review)

   Run /review to approve each slice (marks done) or provide feedback.
   ※ All slices · signoff_review · QA passed → run /review 📄
   ```
4. Stop. No commit — that happens in `/review`.

---

## Behavior rules (implement deltas)

Shared rules — never commit/push, re-read from disk on resume, skip-if-clean — live in `.root-context/state-diagram.md` Principles.

- Tasks run sequentially. No parallel execution.
- Validate `depends_on` before running every task. A task with an unmet dependency must not run.
- Scope is frozen at Phase 0. Mid-run re-reads are not permitted.
