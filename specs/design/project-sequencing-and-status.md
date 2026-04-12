---
type: design
date: 2026-04-10
feature: project-sequencing-and-status
status: ready
---

# Project sequencing and status

## Intent

The current orchestrator tracks artifact types in separate folders — designs here, slices there, briefs somewhere else — with no single thread connecting them to a project, no way to know where a project is in the pipeline without reading multiple files, and no collision resistance when multiple developers work in parallel. A project exists as a set of files that happen to share a naming convention, not as a coherent unit.

This redesign introduces a project as a first-class folder, a sequencing ID that ties all artifacts together, a status file that is always the single source of truth, and four commands that resume deterministically from whatever state the project is in. The goal is a system where any developer can look at `.orchestration/projects/` and immediately understand what's happening — no context required. All of it with the raw data to support strong metrics in place for observability and future improvement of every step.

## Current state

- Artifact folders are top-level: `specs/design/`, `specs/slices/`, `specs/briefs/`, `specs/tasks/`, `dashboard/`
- No stable ID links a design doc to its slices doc, spec, tasks, and QA report
- Status lives in frontmatter across multiple files — fragmented, hard to aggregate
- `/pipeline` runs the full flow in one session but has no resume capability; if interrupted, you start over
- `/implement` is a human kickoff guide, not an agent execution command
- `/qa` and `/breakdown` are separate manual commands, not part of a continuous flow
- No multi-dev collision resistance in naming
- No concept of QA feedback iterations — a project has one pass, no structured way to handle review feedback

## Desired end state

- Each project lives in `.orchestration/projects/{id}/` — one folder, all artifacts, all runs
- The ID is `{github-username}-{zero-padded-seq}-{slug}`, e.g. `bcokert-00001-auth-redesign` — collision-resistant across devs, sequential within a dev
- `status.md` in each project folder is the single source of truth: current pipeline stage, current run number, blocking reason, next action, and a timestamped log of every state transition
- A project is a set of independent slices, each with its own pipeline (reviewed → specced → tasks_ready → implementing → qa → done). Review feedback adds new slices to the backlog — no separate "run" concept.
- Tasks are a flat sequential list across all slices, with dependency metadata; each task knows which slice it belongs to
- Four commands cover the full lifecycle, each resuming from `status.md`:
  - `/design` — runs design → slicing → spec → breakdown; stops when tasks are ready for execution
  - `/implement` — lets user select 1+ ready projects, creates a git worktree per project, then runs task execution → QA → report; stops when report is ready for review
  - `/review` — closes the project (done) or triggers the next pipeline run back into `/design`; both paths operate within the existing worktree
  - `/status` — reads all project `status.md` files (including active worktrees) and summarizes non-done projects with their current stage and worktree state
- Every state transition is timestamped in `status.md` and every task completion is timestamped in the task file, enabling measurement at task, slice, and project level — active processing vs waiting for human approval, and cross-project comparisons like whether fewer slices correlates with faster delivery
- Done projects are archived to `.orchestration/projects/done/YYYY-MM/{id}/`
- `status.md` is the interface for any future external export (Jira, Linear, etc.) and for metrics dashboards — no structural changes needed to add those later
- All commands validate the project's current state before acting and fail with a clear explanation if the project isn't in the right stage, telling the user which command to run instead

## Patterns to follow

- Status is deterministic from file state, not from command history. Any command can read `status.md` and know exactly what to do next without knowing what ran before.
- Resume over restart. Every command checks status first and picks up mid-stage if interrupted.
- Fail by educating. If a command is called on a project in the wrong state, it doesn't guess or silently do nothing — it tells the user exactly what stage the project is in and which command to run next and briefly why.
- Progressive pipeline runs, not special-case QA modes. A QA iteration is just another pipeline run scoped to the feedback. The system doesn't distinguish — it just increments the run counter.
- Artifact versioning by run number, not by date. `design-01.md` is clearer than `2026-04-10-design.md` when you're looking at run state. Dates belong in frontmatter, not filenames.
- Status.md is append-friendly. Runs are logged in order; current state is always the last entry. Reading it top-to-bottom tells the project's story.
- Timestamp every state transition. State changes without timestamps are invisible to metrics. Every write to `status.md` includes an ISO 8601 timestamp. This is the raw material for all future measurement.
- Worktrees are execution boundaries. Once `/implement` assigns a project to a worktree, all subsequent work — including new design rounds — happens in that worktree. Agents are scoped to their worktree path. Main branch is planning only.
- Dogfood `/status` against real `status.md` files. If `/status` can't summarize a project correctly, the status format is broken. Fix the format, not the command.

## Key edge cases

- **Status update is always last.** Every stage writes its artifacts first, updates `status.md` last. Status is the authoritative completion signal — not file existence. If status says a stage is done, it is done. If status says in progress, it is not done regardless of what files exist on disk.
- **Mid-stage crash, no output file:** Status shows the stage as in progress, output file absent. Re-running the command detects this and regenerates the file from scratch.
- **Mid-stage crash, output file present:** File was written but status wasn't advanced (crashed between write and status update). Re-running detects the file, uses it as-is, advances status. No regeneration needed.
- **Partial breakdown (some task files written, not all):** Task count is validated against the spec breakdown table on resume. Mismatches trigger full regeneration — task writes are idempotent.
- **Worktree creation failure:** If `git worktree add` fails (branch conflict, disk error, permissions), no `status.md` update is written — the project stays at `tasks_ready`. No partial worktree state.
- **Worktree merge conflict on signoff:** Merge is attempted; if it fails, the project stays at `signoff_review` with a conflict note. Worktree is preserved for manual resolution. Archive does not happen until merge succeeds.
- **Manual edits to artifact files:** All commands re-read files from disk on resume — they never cache content from a previous session. Manual edits are always picked up.
- **Wrong command at any stage:** Every command checks `status.md` before doing any work. If the project is not in a valid state for that command, the output names the current stage, explains why the command can't proceed, and states which command to run instead. No silent failures, no partial runs.
- **Cross-slice task collision:** Task files from different slices must not overwrite each other. Task files are stored with a slice prefix or in a slice-namespaced path; breakdown is idempotent within a slice.
- **Orphaned worktree (directory manually deleted):** `git worktree list` still shows the registration. `/status` detects the missing directory and reports it, suggesting `git worktree prune`. Does not crash.

## Resolved design decisions

### Project folder as the project identity

**Decision:** A project is a folder at `.orchestration/projects/{id}/`, not a set of files with matching names in separate type folders.

**Why:** All artifacts for a project are co-located. You can `ls` a project and see its complete state. Moving a project to `done/` is one folder move. No cross-folder linkage to maintain.

**Rejected alternatives:** Keeping type-based top-level folders (current) — loses the project-as-unit property and makes resume logic fragile.

---

### Collision-resistant ID format

**Decision:** `{github-username}-{zero-padded-5-digit-seq}-{slug}`, e.g. `bcokert-00001-auth-redesign`. Sequence is per-developer. Slug is derived from the project name at creation time, kebab-case, max ~5 words.

**Why:** GitHub usernames are globally unique. Two devs on the same repo can't produce the same ID. Same dev doing two things in parallel produces different IDs. Collisions within a dev are real conflicts that must be resolved — which is correct behaviour.

**Rejected alternatives:** UUIDs — unreadable, unsortable. Pure sequence — collides across devs. Date prefix — collides if two projects start the same day.

---

### status.md as single source of truth

**Decision:** Each project has a `status.md` that tracks: current pipeline stage, next slice to work on, blocking reason (if any), next action, worktree path and branch (once assigned), and an append-only `transitions` log — one entry per state change, each with stage name, ISO 8601 timestamp, and an optional note. Each slice file tracks its own status in frontmatter (`draft`, `reviewed`, `specced`, `tasks_ready`, `implementing`, `qa`, `done`). All commands read `status.md` first; none infer state from artifact existence alone.

**Why:** Artifact existence is a useful hint but not sufficient — a file can exist in a broken or partial state. One authoritative file is always current and readable by humans, agents, and future tooling alike. The transitions log is the raw source for all metrics — time in each stage, wait time vs active time, iteration count — without any additional instrumentation.

**Rejected alternatives:** Deriving status from which files exist — brittle, doesn't handle partial writes or interrupted commands. Separate metrics file — second source of truth. Frontmatter-only tracking — loses history; you can't reconstruct what happened or measure it.

---

### Slices as independent units

**Decision:** A project is a set of independent slices. Each slice has its own pipeline: reviewed → specced → tasks_ready → implementing → qa → done. Slices are stored as individual files (one per slice) in `.orchestration/projects/{id}/slices/`. Review feedback creates new slice files added to the project backlog — there is no "run" concept. Tasks from all slices share one flat list with slice metadata and dependency links.

Slice files target 30–50 lines, hard cap at 100. A slice that can't be described in 100 lines is too big.

The design doc covers the whole project vision. Slicing produces N individual slice files. The user reviews the next slice (and optionally more) before it can be specced. Future slices are intentionally rough until they become next — implementation and QA of the current slice will reshape them anyway. The human can review the next slice while the current one is being implemented, which is the intended parallelism.

**Why:** One combined slices doc requires reviewing everything upfront — most of it will change before it's ever implemented. Individual slice files let the user focus on what's actually next, encourages small batches, and prevents over-planning. Review feedback naturally extends the backlog by adding new slice files rather than requiring a separate "iteration run" concept.

**Rejected alternatives:** One combined slices doc — requires full upfront review, doesn't scale, changes before it matters. A "runs" model (run 01, run 02) — unnecessary abstraction when slices are already the right unit. Pre-speccing all slices — locks in decisions that implementation will invalidate.

---

### Four commands, full lifecycle coverage

**Decision:** `/design`, `/implement`, `/review`, `/status`. No other commands exposed to users.

- `/design` owns: design interview → slices → spec → breakdown → tasks_ready
- `/implement` owns: project selection → worktree creation → task execution (multi-agent) → QA → QA report
- `/review` owns: signoff (done) OR feedback capture → triggers `/design` for next run within the worktree
- `/status` owns: read all `status.md` files across main and active worktrees, summarize non-done projects

**Why:** The current seven-command surface (`/design`, `/slice`, `/spec`, `/breakdown`, `/implement`, `/qa`, `/pipeline`) requires the user to know the sequence and manage their own state. Three action commands + one read command is the right surface. Status drives resume, not the user's memory.

**Rejected alternatives:** Keeping current command set — no resume, user must manage state. Single `/go` command — loses the natural human review gates between design and execution.

---

### /implement: project selection, worktrees, and multi-agent execution

**Decision:** `/implement` runs in three steps:

1. **Project selection.** Shows all projects in `tasks_ready` state (not already in a worktree, not in progress). User selects 1+ projects to kick off.

2. **Worktree creation.** For each selected project, system creates a git worktree at `.orchestration/worktrees/{id}` on branch `project/{id}`. Updates `status.md` with `worktree_path` and `branch`. From this point, all work for that project happens in the worktree — including any future design rounds triggered by `/review`.

3. **Execution.** User chooses parallel or sequential. Default: sequential. Parallel capped at 4 concurrent projects. Within each project, tasks run sequentially respecting `depends_on`. Agent team is suggested from the `agent_type` fields present in ready tasks (tasks needing only `client-dev` suggest just that agent; mixed tasks suggest the full team). User confirms or adjusts before agents start.

**Why:** Worktrees give each project an isolated branch context — agents know their scope from the working directory, parallel projects can't conflict, and main branch stays clean for planning. Suggesting the agent team from task metadata rather than asking an open question reduces friction without sacrificing control.

**Rejected alternatives:** Running all implementation in main — blocks parallel projects and pollutes the planning branch. Asking the user to name agents explicitly — they shouldn't need to know which agents exist.

---

### Auto-commit between stages, push at stage gates

**Decision:** At each human review gate, the commit and push happen when the human **approves and moves forward** — not when the gate is first reached, and not during corrections. While a human is reviewing and making edits, no commits happen. The commit is the signal that the gate has been passed. One commit per gate, not per artifact or correction.

This means:
- Human approves design → commit (`design-01.md` + `status.md`) + push → slicing begins
- Human approves slices → commit (`slices-01.md` + `status.md`) + push → spec begins
- Human approves spec → commit (`spec-01.md` + all task files + `status.md`) + push → ready for implement
- Human approves at signoff → commit (all implementation changes + task files + QA report + `status.md`) + push → done

The execution pipeline (implement → QA → signoff_review) is a special case: nothing is committed until the human approves at signoff. All implementation file changes, task status updates (`assigned_at`, `completed_at`), the QA report, and slice/status.md updates stay uncommitted so the human can see the full diff when reviewing. This is the point — the reviewer needs to see exactly what changed.

Push target is currently main. A branch-per-project model (push to `project/{id}`) is the right eventual shape but deferred — the commit cadence and gate-push behaviour are established now so the branch model can be layered on later without changing anything else.

**Why:** One commit per gate produces a git log that reads like a project journal — "finished design", "finished slicing", "tasks ready". Each diff is coherent: the design commit shows only the design doc, not interleaved status noise. This makes it easy to see what changed between stages and to audit any step. Gate pushes ensure a completed stage isn't lost to a local disk failure and let collaborators see progress without pulling mid-stage noise.

**Rejected alternatives:** Commit after every artifact write — too granular, buries meaningful diffs in noise, makes `git log` unreadable. Commit only at project completion — loses per-stage history and doesn't help with mid-pipeline crashes. Opt-in commits — inconsistent, defeats the purpose.

---

### Done archiving with month subfolders

**Decision:** Completed projects are moved to `.orchestration/projects/done/YYYY-MM/{id}/`. Status set to `done` before move.

**Why:** Done projects accumulate. Month subfolders prevent flat-folder sprawl while preserving easy manual browsing. The move is a single operation that also serves as the completion signal.

---

### /status dogfoods status.md

**Decision:** `/status` reads only `status.md` files — no artifact scanning, no dashboard files. `/status` also runs `git worktree list` to discover active worktrees and reads their `status.md` files directly from those paths. If it can't produce an accurate summary, the status format needs fixing.

**Why:** Ensures the status format stays honest. If the format drifts or becomes incomplete, `/status` breaks visibly rather than silently degrading. Worktree-aware reading ensures in-flight projects don't disappear from status just because their branch hasn't merged yet.

---

### Command state validation — fail by educating

**Decision:** Every command begins by reading `status.md` and checking whether the project is in a valid state for that command. If not, it outputs: what stage the project is currently in, why that means this command can't proceed, and which command to run instead. It then stops — no partial work.

Valid entry points per command:
- `/design` — any stage from `new` through `spec_review`, plus re-entry after a `/review` feedback round
- `/implement` — only `tasks_ready`
- `/review` — only `signoff_review`

**Why:** Silent no-ops or partial runs are confusing. A clear error that tells you the next step costs nothing and prevents the user from accidentally triggering work out of order.

**Rejected alternatives:** Letting commands auto-redirect to the right command — adds complexity and hides what the system is doing. Failing silently — worst option.

---

### Worktree lifecycle

**Decision:** Worktrees are created at `/implement` time, not at project creation. Workflow:

1. `/implement` shows all projects with status `tasks_ready` (not already in a worktree, not in progress).
2. User selects 1+ projects.
3. For each, system runs `git worktree add .orchestration/worktrees/{id} project/{id}`, creating both the worktree directory and a dedicated branch.
4. `.orchestration/worktrees/` is gitignored (local filesystem paths); the branches themselves are tracked.
5. User chooses parallel or sequential execution. Default: sequential. Parallel capped at 4 concurrent projects (prevents resource exhaustion, consistent with pi-cortex patterns).
6. `status.md` is updated with `worktree_path` and `branch` fields once the worktree is created.
7. All subsequent work — task execution, QA, design rounds — happens in the worktree. Main branch is read-only for that project.
8. On final signoff, the worktree branch is merged to main, the worktree directory is removed (`git worktree remove`), and the project is archived to `done/`.
9. Safe removal: system checks for uncommitted changes before removing the worktree. If found, it warns and stops.

**Why:** Worktrees are the clean solution to parallel project execution without branch conflicts. Once a project is in a worktree, every agent knows its scope implicitly from the working directory. Main branch stays clean for planning.

**Rejected alternatives:** Running all implementation in main — conflicts with parallel projects. Creating worktrees at project creation — worktrees exist for months before implementation starts, cluttering the repo.

---

### Timestamps on every state transition

**Decision:** `status.md` includes a `transitions` log — an append-only list of entries, each with: stage name, ISO 8601 timestamp, and optionally a note (e.g. "human approved design", "QA failed — 2 tasks"). Every write to `status.md` that changes the pipeline stage appends a new entry.

**Why:** Timestamps are the raw material for all future measurement. Adding them costs nothing at write time. Not adding them is irreversible — you can't reconstruct historical timing from file state alone.

---

### Metrics exposed by the system

**Decision:** The slice is the fundamental unit of measurement. A project is a set of slices; a pipeline run produces 1+ slices; tasks belong to slices. Metrics are tracked at task, slice, and project levels. The transitions log in `status.md` plus timestamps in task files provide the raw data for all of this without additional instrumentation.

**Task-level**
- Time from task assigned to task done (agent processing time per task)
- Time per task by agent type (reveals which agent types are slower or have higher rework rates)
- QA pass/fail per task on first attempt

**Slice-level** (the primary unit)
- Total time per slice: from slice creation to slice QA pass
- Active time vs wait time within a slice (time agents worked vs time waiting for human gates)
- QA pass rate per slice (tasks in this slice that passed QA without rework / total tasks in slice)
- Number of tasks per slice (sizing signal — large task count may indicate slice was too broad)
- Whether a slice required a follow-up run (slice produced a run N+1 to address its gaps)
- Time from slice spec_approved to first task started (queue wait time)

**Project-level**
- Total wall-clock time from project start to done
- Total slice count (original plan vs total including feedback slices — delta is a proxy for how well the initial plan held up)
- Number of feedback slices added post-QA (proxy for first-pass quality)
- Active processing time vs human wait time across the whole project
- Whether more or fewer slices correlated with faster completion or fewer QA feedback rounds (cross-project comparison)

**Cross-project comparative** (answers the "are more slices better?" question)
- Projects grouped by total slice count: avg completion time, avg QA iteration count, avg rework rate
- Slice size distribution (tasks per slice) vs QA pass rate — validates the "smaller slices ship cleaner" hypothesis
- Time in planning (design + slicing + spec) vs time in execution (implement + QA), per project — reveals where the system's bottlenecks actually are

These are computed on read (by `/status`, a future dashboard, or a flamegraph tool) — not stored as derived data. `status.md` and task file timestamps are the only write targets.

**Rejected alternatives:** A separate metrics file — creates a second source of truth. Logging to an external system at write time — adds a dependency before we've validated the format. Pre-aggregating metrics at write time — premature; the raw transitions log is more flexible.
