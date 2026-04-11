---
type: slices
date: 2026-04-11
design: specs/design/2026-04-10-project-sequencing-and-status.md
feature: project-sequencing-and-status
status: ready
---

# Project sequencing and status — slices

## Overview

10 slices across 5 phases. Each slice is a lean vertical cut designed to catch design mistakes before the next slice builds on it.

Four rules applied throughout:
- **State validation is universal.** At every stage, every command except the correct one outputs a helpful message: what stage the project is in, why that command can't proceed, and which command to run instead. Validation sections call this out explicitly per slice.
- **Status update is always the last step.** Every stage writes its artifacts first, updates `status.md` last. This makes status the authoritative source: if status says a stage is done, it is done. If status says a stage is in progress, the stage did not complete — regardless of what files exist on disk.
- **Resume detects what exists.** When a stage is in progress, the command checks which artifacts already exist before doing any work. Existing files are used as-is (crash happened after write, before status update). Missing files are generated. Status is advanced only after all artifacts for the stage are confirmed present. A crash should never require starting over from the beginning of a stage.
- **Commit after every artifact write; push at every human gate.** Each command commits to git after writing each artifact and after advancing `status.md`. At each review gate — where the command pauses and waits for human input — it also pushes. This makes progress visible in git history, keeps each stage recoverable independent of `status.md`, and lets a pipeline be paused and resumed from any machine. Push target is currently main; branch-per-project is future work.

User education is a requirement in every command slice — contextual output after each stage transition explaining what just happened, where the user is, and what to do next. The education audit in slice 10 verifies coverage.

---

## Phase 1: Design pipeline

### Slice 1 — Project creation + design interview

**Goal:** Running `/design` on a new project creates the project folder, generates the ID, writes `status.md` immediately (before the interview starts), runs the design interview, writes `design-01.md` on completion, and stops at `design_review`. `status.md` is the observable proof the structure and resume logic are correct.

**Changes:**
- Rewrite `defaults/commands/design.md`:
  - Phase 0 (load + resume): read `status.md` first — it is authoritative. If no project folder → create `.orchestration/projects/{id}/`, write `status.md` with `stage: design_in_progress` and first transition entry, then run the interview. If status says `design_review` or later → skip the interview entirely, proceed to the appropriate stage. If status says `design_in_progress` → the interview did not complete last time. Check for `design-01.md`: if it exists (crashed after write, before status update) → use the file, advance status to `design_review`, show review gate. If it does not exist → run the interview from the beginning.
  - Phases 1–3: design interview
  - Phase 4: write `design-01.md`, advance `status.md` to `design_review` with timestamp
  - Phase 5: review gate with education (what just happened, why this is the highest-leverage review, what corrections cost nothing here vs later)
- `status.md` written at project creation, not at interview completion — so any crash is detectable as `design_in_progress` with no `design-01.md`
- Commit after writing `design-01.md` and after advancing status to `design_review`; push before showing the review gate. This establishes the commit/push cadence for all subsequent slices — every artifact write and every gate push follows this same pattern.
- Define `status.md` format: `stage`, `run`, `project_id`, `next_action`, and `transitions` list (each entry: `stage`, `timestamp`, `note`)
- Internal organisation: slicing, spec, and breakdown logic may remain in `slice.md`, `spec.md`, `breakdown.md` as implementation files; `/design` is the only user-facing command that orchestrates them. No requirement to merge or remove those files in this slice.
- Remove `/pipeline` command (superseded by `/design`)

**Key edge cases:**
- Interview crashes mid-way, no `design-01.md`: `status.md` shows `design_in_progress`, file absent → re-run `/design` → system detects incomplete state, restarts interview from the beginning
- Interview completes, writes `design-01.md`, then crashes before status update: `status.md` still shows `design_in_progress`, file present → re-run `/design` → system detects file exists, advances status to `design_review`, shows review gate (no re-interview)
- Project folder exists from aborted earlier attempt with a different slug: treat as a new project, do not reuse the folder
- User runs `/design` with no argument and multiple projects exist at non-complete stages: list them and ask which to resume, or offer to start a new one
- ID sequence collision (two devs, same username prefix, same sequence number — theoretically impossible by design, but): system should detect folder already exists and increment

**Validation:**
- Fresh run: `.orchestration/projects/bcokert-00001-{slug}/` created; `status.md` contains `stage: design_review`, two transitions (`design_in_progress` on create, `design_review` on interview complete), both with ISO 8601 timestamps; `design-01.md` exists
- Interrupted interview, no file (simulate by keeping `status.md` at `design_in_progress`, no `design-01.md`): re-run `/design` → interview restarts from beginning → `design-01.md` written, status advances to `design_review`
- Interrupted interview, file present (simulate by keeping `status.md` at `design_in_progress` with `design-01.md` already written): re-run `/design` → no re-interview, status advances, review gate shown
- Resume at `design_review`: re-run `/design` → shows review gate, no re-interview, no folder changes
- Running `/implement` at `design_in_progress` or `design_review` → "project is in {stage} — run `/design` to continue"
- Running `/review` at `design_in_progress` or `design_review` → "project is in {stage} — run `/design` to continue; `/review` is for projects that have finished implementation"

---

### Slice 2 — Slicing step

**Goal:** After a human approves the design doc, `/design` continues into the slicing phase, writes `slices-01.md`, and stops at `slicing_review`.

**Changes:**
- Extend `defaults/commands/design.md` with slicing phase: runs after `design_review` approval, reads `design-01.md`, produces slices, writes `slices-01.md` to the project folder, advances `status.md` to `slicing_review` with timestamp
- `/design` is the only user entrypoint. Slicing logic may continue to live in `slice.md` as an internal implementation file that `/design` reads and follows — that is an implementation detail, not a user-visible command. `slice.md` path references updated to write to `.orchestration/projects/{id}/slices-{NN}.md`.
- Status advances through `slicing_in_progress` → `slicing_review`, with a transition entry for each
- Review gate includes education: what slices are, why vertical slices matter, what a poorly-cut slice costs in later implementation

**Key edge cases:**
- Slicing crashes mid-way: `status.md` shows `slicing_in_progress`, no `slices-01.md` → re-run `/design` → detects incomplete slicing, restarts slicing phase (design doc intact, used as input again)
- Design doc was manually edited after interview: `/design` re-reads `design-01.md` on resume — always uses the file on disk, not cached content
- Slicing reveals a gap in the design doc: ask user to resolve the ambiguity before writing `slices-01.md`; do not write a slices doc with open questions
- User edits `slices-01.md` directly after it's written: valid — `/design` will read the file as-is when resuming at `slicing_review`

**Validation:**
- Start from `design_review`, approve, re-run `/design` → `slices-01.md` exists in project folder; `status.md` shows `stage: slicing_review`, four transitions total
- Crash during slicing (simulate by deleting `slices-01.md`, setting status to `slicing_in_progress`): re-run `/design` → restarts slicing, writes `slices-01.md` correctly
- Running `/implement` at `slicing_in_progress` or `slicing_review` → "project is in {stage} — run `/design` to continue"
- Running `/review` at `slicing_in_progress` or `slicing_review` → "project is in {stage} — run `/design` to continue; `/review` is for projects that have finished implementation"

---

### Slice 3 — Spec + breakdown → tasks ready

**Goal:** After slicing approval, `/design` writes `spec-01.md` and creates task files in `tasks/`, advances to `tasks_ready`, and the planning pipeline is complete. `/implement` now shows this project as selectable.

**Changes:**
- Extend `defaults/commands/design.md` with spec and breakdown phases, running after `slicing_review` approval
- Spec logic may remain in `spec.md` as an internal implementation file; not a user command
- Breakdown logic may remain in `breakdown.md` as an internal implementation file; `/breakdown` as a standalone user command is removed in this slice
- Task files created at `tasks/{NN}-{slug}.md` with fields: `spec`, `run`, `slice_id`, `step`, `title`, `status: todo`, `depends_on`, `agent_type`, `assigned_at: null`, `completed_at: null`
- `run` and `slice_id` fields are new (not in current task file format) — required for slice-level metrics
- Status advances through `spec_in_progress` → `spec_review` → `tasks_ready`, with timestamps
- Review gate at `spec_review` is a light skim gate with education: what the spec covers, what `/implement` does next
- On `tasks_ready`, education output: "planning is complete — run `/implement` to start implementation"
- Remove standalone `/breakdown` command

**Key edge cases:**
- Breakdown crashes mid-way: partial task files may exist in `tasks/`. On resume, detect incomplete breakdown by comparing task count to spec breakdown table. Regenerate all task files (idempotent write — same content, safe to overwrite).
- Spec reveals an ambiguity in the slices doc: ask user to resolve before writing `spec-01.md`
- `tasks/` folder already contains files from a previous run: new run creates tasks with run number prefix or in a `tasks/run-02/` subfolder — task files from different runs must not collide
- User adds a manual task file to `tasks/`: `/design` ignores files it didn't create; only files matching `{NN}-{slug}.md` from the spec breakdown are managed

**Validation:**
- Start from `slicing_review`, approve, run `/design` → `spec-01.md` and `tasks/` populated with correct task files; `status.md` shows `stage: tasks_ready`, six transitions total
- Each task file has `run: 01`, `slice_id`, `assigned_at: null`, `completed_at: null`
- Partial breakdown (simulate 3 of 5 task files): re-run `/design` → detects mismatch, regenerates all 5 task files correctly
- Running `/implement` now shows this project as selectable — no error
- Running `/review` at `tasks_ready` → "project is in tasks_ready — run `/implement` to start implementation; `/review` is for projects that have finished implementation"

---

## Phase 2: Status (built incrementally)

### Slice 4 — `/status` v1: single project, current stage

**Goal:** `/status {id}` shows a project's current stage, next action, and recent transition history in a concise, scannable format. Validates the `status.md` format is correct and human-readable before `/implement` depends on it.

**Changes:**
- Create `defaults/commands/status.md`: reads one project's `status.md`, outputs:
  - Stage (prominent — readable at a glance)
  - Next action (one line)
  - Elapsed time in current stage
  - Last 3 transitions with timestamps and notes
  - Blocking reason if any
- Visual design: structured layout, consistent field labels, elapsed time in human-readable form (e.g. "2h 14m"). Output should be scannable in under 5 seconds — not a wall of text.
- No-arg mode: lists all project IDs in `.orchestration/projects/` and prompts for a selection

**Key edge cases:**
- Project ID not found: "project {id} not found — run `/status` with no args to list projects"
- `status.md` missing or empty: report the project folder exists but status is unreadable; do not crash
- `status.md` has unexpected fields or missing fields: report what's readable with a warning, surface any missing required fields
- No projects exist at all: "no active projects — run `/design` to start one"
- Project is in `done/`: "project {id} is archived in done/{YYYY-MM} — no active status"

**Validation:**
- Run `/status {id}` at each stage from slice 1–3 (design_in_progress, design_review, slicing_review, tasks_ready): each shows correct stage, correct next action, correct timestamps
- Output is scannable: stage visible at a glance, elapsed time present, next action on one line
- Malformed `status.md` (remove one required field): outputs partial info with a warning about the missing field, does not crash
- Non-existent project ID: correct error message, no crash

---

## Phase 3: Implementation

### Slice 5 — `/implement` v1: single project, sequential

**Goal:** `/implement` selects one project in `tasks_ready`, creates a git worktree for it, suggests an agent team, runs tasks sequentially, runs QA, writes a QA report, and advances to `signoff_review`. Includes contextual education explaining worktrees before creating one.

**Changes:**
- Rewrite `defaults/commands/implement.md`:
  - Phase 0: read all `status.md` files in `.orchestration/projects/`, show projects with `stage: tasks_ready` not already assigned a worktree. If none: "no projects ready for implementation — run `/design` to prepare one."
  - Phase 1: user selects one project
  - Phase 2: **education before action** — explain what a worktree is, what branch will be created, what it means for git state, and how to navigate to the worktree if needed. Confirm before creating.
  - Phase 3: `git worktree add .orchestration/worktrees/{id} project/{id}`, update `status.md` with `worktree_path` and `branch` fields; advance to `implementing` with timestamp
  - Phase 4: suggest agent team from `agent_type` fields in ready tasks; user confirms or adjusts
  - Phase 5: run tasks sequentially respecting `depends_on`; update each task file's `assigned_at` when started and `completed_at` when done; advance task `status` to `in_progress` then `done`
  - Phase 6: run QA — internal, may use `qa.md` as implementation file; `/qa` is no longer a standalone user command
  - Phase 7: write QA report to `.orchestration/projects/{id}/qa-report-01.md`; advance `status.md` to `signoff_review` with timestamp and note (e.g. "QA: 5 pass, 1 fail")
- Add `.orchestration/worktrees/` to `.gitignore`
- Remove standalone `/qa` command

**Key edge cases:**
- Worktree creation fails (branch already exists): clear error — "branch project/{id} already exists; if a previous worktree was not cleaned up, run `git worktree list` to investigate." Do not leave a partial worktree.
- Worktree creation fails (disk/permission error): same — clear error, no `status.md` update, project stays `tasks_ready`
- Agent fails mid-task: task stays `in_progress` with `assigned_at` set but no `completed_at`; QA will detect and report. Do not auto-advance the task to `done`.
- All tasks pass QA: advance to `signoff_review` with positive note
- Some tasks fail QA: still advance to `signoff_review` — human reviews the QA report. QA failure is not a blocker for reaching signoff; it is information for the reviewer.
- `/design` on an `implementing` project: "project is implementing in worktree {path} — run `/implement` to resume, or `/review` once QA is complete"
- `/review` on an `implementing` project: "project is still implementing — run `/implement` to resume"

**Validation:**
- Run `/implement`, select one `tasks_ready` project
- Worktree created at `.orchestration/worktrees/{id}`; `status.md` contains `worktree_path` and `branch`
- Each task file has `assigned_at` and `completed_at` set after completion
- `qa-report-01.md` written to project folder
- `status.md` shows `stage: signoff_review` with QA summary note
- Worktree creation failure (simulate by pre-creating the branch): clear error, project remains `tasks_ready`, no partial files
- Agent task failure (simulate by marking a task as crashing): QA report reflects failure, project still reaches `signoff_review`
- Running `/design` or `/review` mid-implementation outputs correct stage-specific guidance

---

### Slice 6 — `/implement` v2: parallel multi-project

**Goal:** `/implement` can select 2+ projects, create a worktree per project, and run them in parallel (capped at 4). User explicitly chooses parallel vs sequential.

**Changes:**
- Extend `defaults/commands/implement.md`: phase 0 allows multi-select (checkboxes or numbered list); phase 1 asks parallel or sequential — default sequential, with education on the tradeoff (token consumption, machine load, when parallel makes sense)
- Parallel mode: spawn up to 4 project pipelines concurrently, each in its own worktree. If user selects more than 4, ask which 4 to start now and which to queue.
- Each parallel project follows the same lifecycle as slice 5 — independent, isolated in its worktree
- Education: explain how to monitor parallel projects with `/status`, and what happens if one fails while others succeed

**Key edge cases:**
- User selects 5 projects with parallel mode: "parallel mode is capped at 4 — which 4 would you like to start? The remaining project stays in `tasks_ready` for a future `/implement` run."
- One project's worktree creation fails while others succeed: roll back any worktrees already created in this batch, report which project failed and why, leave all selected projects at `tasks_ready`
- One project fails during execution while others continue: failing project stays in its last known state (e.g. `implementing` with incomplete tasks); others proceed to `signoff_review` independently
- User kills the process mid-parallel-run: surviving worktrees remain; re-run `/implement` and the already-in-progress projects are excluded from selection (they show as `implementing`)

**Validation:**
- Run `/implement`, select 2 projects in `tasks_ready`, choose parallel
- Both worktrees created; both projects reach `signoff_review`
- `/status` (no arg) shows both projects with their worktree state
- Simulate worktree failure for project 2 of 2: project 1 worktree rolled back, both projects remain `tasks_ready`
- Sequential mode still works correctly with 2 projects: project 2 does not start until project 1 reaches `signoff_review`

---

## Phase 4: Review + full status

### Slice 7 — `/review` command

**Goal:** `/review` presents the QA report and task output for a `signoff_review` project and handles two paths: approval (done, worktree merged and archived) or feedback (project marked `feedback_pending`, user runs `/design` to start the next run in the same worktree).

**Changes:**
- Create `defaults/commands/review.md`:
  - Phase 0: read `status.md`, verify `stage: signoff_review`. If not → "project is in {stage} — {appropriate next command}"
  - Phase 1: present QA report summary and slice-by-slice task list with statuses
  - Phase 2: ask approve or provide feedback
  - **Approve path:** `git merge project/{id}` into main from within the worktree context, `git worktree remove .orchestration/worktrees/{id}`, move project folder to `.orchestration/projects/done/YYYY-MM/{id}/`, write final `stage: done` transition to `status.md` before moving. Education: what done means (merged, archived, measurable).
  - **Feedback path:** write feedback note to `status.md` transitions log, set `stage: feedback_pending`. Output clearly: "feedback recorded — run `/design` on this project to start the next implementation run. `/design` will pick up in the existing worktree and create run 02 artifacts." Education: explain that this is a new pipeline run, not a restart; the worktree and history are preserved.
- Update `/design` to handle `feedback_pending` as a valid entry state: increment run counter, create `design-02.md`, `slices-02.md` etc. in the existing worktree

**Key edge cases:**
- Approve path: merge fails due to conflicts → "merge failed — resolve conflicts in the worktree at {path}, then re-run `/review`." Do not archive, do not remove worktree, leave project at `signoff_review`.
- Approve path: worktree removal fails → warn, but still archive the project folder. Orphaned worktree can be cleaned with `git worktree prune`.
- Feedback path: user runs `/implement` on a `feedback_pending` project → "project has unprocessed feedback — run `/design` to start the next run, then `/implement` once tasks are ready"
- Feedback path: user runs `/review` again on a `feedback_pending` project → "project is waiting for next design run — run `/design` to start run 02"
- Archive target already exists (e.g. `done/YYYY-MM/{id}/` somehow exists): error with instructions to investigate; do not overwrite

**Validation:**
- **Approve path:** project folder at `done/YYYY-MM/{id}/`; `status.md` shows `stage: done`; worktree removed; branch merged to main
- **Feedback path:** `status.md` shows `stage: feedback_pending` with feedback note; running `/design` on this project creates `design-02.md` in the existing worktree; run counter is 02
- Merge conflict on approve: project stays at `signoff_review`, worktree untouched, clear instructions given
- All wrong commands at `signoff_review` output stage-specific guidance:
  - `/design`: "project is in signoff_review — run `/review` to approve or provide feedback"
  - `/implement`: "project is in signoff_review — run `/review` to approve or provide feedback"

---

### Slice 8 — `/status` v2: multi-project + worktree-aware

**Goal:** `/status` with no argument shows all non-done projects across main and active worktrees — stage, run number, worktree path if present, what's next, last transition. Parallel in-flight projects are clearly distinguishable.

**Changes:**
- Extend `defaults/commands/status.md`: no-arg mode runs `git worktree list` to discover active worktrees, reads each project's `status.md` from its correct path (worktree path takes precedence over main branch path for in-flight projects), renders a summary table
- Table columns: project ID, stage, run, worktree (yes/no + path), next action, time in current stage
- If any project is in a `*_review` stage: reminder below the table of which command unblocks it
- If multiple projects are in worktrees: note which are running in parallel
- Done projects excluded from output

**Key edge cases:**
- Worktree exists in `git worktree list` but the folder is missing (manually deleted): report the inconsistency — "worktree for {id} is registered in git but the directory is missing — run `git worktree prune` to clean up." Don't crash.
- `status.md` in worktree branch has diverged from main branch's copy: always use the worktree version as authoritative for in-flight projects
- Zero projects (fresh repo): "no active projects — run `/design` to start one"
- All projects done: "no active projects — all projects are in done/. Run `/design` to start a new one."
- Large number of projects (20+): table still renders; no truncation without warning

**Validation:**
- With 3 projects in different stages (one `design_review`, one `implementing` in worktree, one `signoff_review`): all three appear in the table with correct info
- Worktree project shows correct path and branch in output
- Done projects do not appear
- Orphaned worktree (manually deleted folder): warning message, other projects still display correctly
- Zero active projects: correct helpful message

---

## Phase 5: Quality and polish

### Slice 9 — Metrics quality + gap surface

**Goal:** Walk through a complete pipeline cycle using a fixture project with a known history. Verify that every metric in the design doc can be computed from the recorded data. Surface any gaps and fix them before the system is considered done.

**Changes:**
- Create a fixture project at `.orchestration/projects/fixture-00001-metrics-test/` with a manually crafted `status.md` and task files that simulate a complete two-run cycle (run 01 done cleanly, run 02 with one QA failure and one fix)
- Fixture includes: all transition stages, all timestamps, task files with `assigned_at`/`completed_at`, `slice_id`, and `run` fields set
- Write a verification checklist: for each metric listed in the design doc ("metrics exposed by the system"), identify which field(s) it reads from and write the query or derivation logic
- Run through the checklist:
  - If a metric can be computed from the fixture → pass
  - If a metric requires data not present in the fixture → identify the gap, add the required field to `status.md` format or task file format, update the fixture, mark pass
  - If a metric is aspirational but structurally impossible from the current model → remove it from the design doc or flag it as "requires future instrumentation"
- Commit the fixture and checklist alongside any format changes

**Key edge cases:**
- Fixture with partial/missing timestamps (simulating a crash mid-pipeline): verify metrics that depend on timestamps degrade gracefully (e.g. "elapsed time: unknown" rather than crash)
- Project with 0 QA iterations (clean first pass): verify iteration count is 0, not null or missing
- Project with 3 QA iterations: verify run count, rework rate, and slice-level metrics all aggregate correctly

**Validation:**
- Every metric in the design doc's "metrics exposed" section traces to a specific field with a named derivation
- Any metric that couldn't be traced is either removed or a new field was added and documented
- Fixture project exists and is well-formed
- Fixture with missing timestamps produces warnings, not errors

---

### Slice 10 — Init-orchestrator + README + education audit

**Goal:** `init-orchestrator` correctly installs the new 4-command structure. README is accurate. Every command has contextual education output that guides new users through the system — especially around worktrees and parallel execution.

**Changes:**
- Update `init-orchestrator.md`: install `/design`, `/implement`, `/review`, `/status`; remove `/pipeline`, standalone `/breakdown`, standalone `/qa`, old `/implement`; create `.orchestration/projects/` folder; add `.orchestration/worktrees/` to `.gitignore`; safe to re-run (adds missing, skips existing, prompts before replacing)
- Rewrite `README.md`: 4-command surface, project lifecycle, worktree model, metrics summary. No implementation details. Written for a developer who has never seen the system.
- Education audit: read every command file. For each, verify:
  - Contextual output after every stage transition (what just happened, where you are, what's next)
  - Clear error messages with stage + correct command for every wrong-command case
  - Worktree explanation before any worktree action in `/implement`
  - Parallel mode explanation with tradeoffs in `/implement` v2
  - Fix any gaps found before closing this slice

**Key edge cases:**
- Re-running `init-orchestrator` on a repo with existing projects: must not overwrite `.orchestration/projects/` or any `status.md` files. Installs only missing commands.
- Partially installed state (some commands present, some missing): detects and repairs, reports what was added
- Repo with no `.orchestration/` at all: creates full structure from scratch
- Repo with old command structure (pre-this-redesign): detects old commands, prompts before removing, installs new ones

**Validation:**
- Run `init-orchestrator` on a fresh project: all 4 commands present, old commands absent, `.orchestration/projects/` exists, `.gitignore` updated
- Re-run `init-orchestrator` with existing projects: no data loss, only missing commands added
- README accurately describes the system as implemented — no stale references to old folder paths or removed commands
- Education audit: a user reading only README and following error messages from wrong commands can figure out what to do next without reading command source
