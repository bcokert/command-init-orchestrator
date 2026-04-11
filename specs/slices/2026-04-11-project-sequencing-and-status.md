---
type: slices
date: 2026-04-11
design: specs/design/2026-04-10-project-sequencing-and-status.md
feature: project-sequencing-and-status
status: ready
---

# Project sequencing and status — slices

## Overview

10 slices across 5 phases. Phases 1–3 establish the full pipeline; phase 4 closes the loop; phase 5 validates quality and installs everything. Each slice is a lean vertical cut that catches design mistakes before the next slice builds on it.

User education is a requirement in every command slice — contextual guidance after each action explaining where the user is, what just happened, and what to do next. The education audit in slice 10 verifies coverage.

---

## Phase 1: Design pipeline

### Slice 1 — Project creation + design interview

**Goal:** Running `/design` on a new project creates the project folder, generates the ID, initialises `status.md`, runs the design interview, writes `design-01.md`, and stops at `design_review`. The status file is the observable proof the structure is correct.

**Changes:**
- Rewrite `defaults/commands/design.md`: phase 0 creates `.orchestration/projects/{id}/` and `status.md`; phases 1–3 run the interview and write `design-01.md`; phase 4 advances status to `design_review` with timestamp; phase 5 displays the review gate with contextual education (what just happened, why the user is reviewing here, what corrections at this stage cost nothing)
- Define `status.md` format: `stage`, `run`, `project_id`, `next_action`, `transitions` list; each transition has `stage`, `timestamp`, `note`
- Remove or stub `/pipeline` command (it is superseded by `/design`)

**Validation:**
- Run `/design` on a new project
- `.orchestration/projects/bcokert-00001-{slug}/` exists
- `status.md` contains `stage: design_review`, one transition entry with ISO 8601 timestamp
- `design-01.md` exists and matches the interview output
- Running `/design` again on the same project resumes at `design_review` (no duplicate folder, no lost content)
- Running `/implement` on this project outputs a clear error: "project is in design_review — run /design to continue"

---

### Slice 2 — Slicing step

**Goal:** After a human approves the design doc, `/design` continues with the slicing phase, writes `slices-01.md`, and stops at `slicing_review`.

**Changes:**
- Extend `defaults/commands/design.md` with the slicing phase: reads `design-01.md`, runs slicing logic (currently in `slice.md`), writes `slices-01.md`, advances status to `slicing_review` with timestamp
- Update `defaults/commands/slice.md` to write to `.orchestration/projects/{id}/slices-{NN}.md` (path update only, logic unchanged)
- Review gate includes education: what slices are, why they must be vertical, what a bad slice costs downstream

**Validation:**
- Start from `design_review`, approve design, run `/design`
- `slices-01.md` exists in the project folder
- `status.md` shows `stage: slicing_review`, two transitions total
- Interrupt mid-slicing, re-run `/design` — resumes at slicing, does not re-run the interview
- Running `/implement` on this project outputs: "project is in slicing_review — run /design to continue"

---

### Slice 3 — Spec + breakdown → tasks ready

**Goal:** After slicing approval, `/design` writes `spec-01.md` and creates task files in `tasks/`, then stops at `tasks_ready`. The planning pipeline is complete.

**Changes:**
- Extend `defaults/commands/design.md` with spec and breakdown phases: reads `slices-01.md`, writes `spec-01.md`, creates `tasks/NN-{slug}.md` files with `run`, `slice_id`, `status`, `depends_on`, `agent_type`, `assigned_at`, `completed_at` fields
- Update `defaults/commands/spec.md` and `defaults/commands/breakdown.md` for new paths
- Task files gain `run` and `slice_id` fields to support slice-level metrics
- Status advances to `tasks_ready` with timestamp; review gate includes education: what the spec + tasks are, what `/implement` does next
- Remove standalone `/breakdown` command (now internal to `/design`)

**Validation:**
- Start from `slicing_review`, approve slices, run `/design`
- `spec-01.md` exists
- `tasks/` folder contains one file per breakdown row, each with correct frontmatter
- `status.md` shows `stage: tasks_ready`, three transitions
- Running `/implement` on this project no longer errors — it shows the project as selectable

---

## Phase 2: Status (built incrementally)

### Slice 4 — `/status` v1: single project, current stage

**Goal:** `/status` can be pointed at one project and report its current stage, what's next, and recent transitions. Validates the status.md format is human-readable before /implement depends on it.

**Changes:**
- Create `defaults/commands/status.md`: reads one project's `status.md`, outputs current stage, next action, last 3 transitions with timestamps, and a one-line summary of what's blocking (if anything)
- Accepts a project ID as argument; if omitted, lists all projects in `.orchestration/projects/` and asks which one

**Validation:**
- Run `/status bcokert-00001-{slug}`
- Output shows correct stage, correct next action, timestamps from the transitions log
- Output is accurate after each of slices 1–3 (run /status at design_review, slicing_review, tasks_ready — each shows the right state)

---

## Phase 3: Implementation

### Slice 5 — `/implement` v1: single project, sequential

**Goal:** `/implement` selects one project in `tasks_ready`, creates a git worktree for it, suggests an agent team, runs tasks sequentially, runs QA, writes a QA report, and advances the project to `signoff_review`. Includes contextual education about worktrees.

**Changes:**
- Rewrite `defaults/commands/implement.md`: phase 0 shows `tasks_ready` projects; phase 1 selects one; phase 2 creates worktree (`git worktree add .orchestration/worktrees/{id} project/{id}`), updates `status.md` with `worktree_path` and `branch`; phase 3 suggests agent team from `agent_type` fields, user confirms; phase 4 runs tasks sequentially; phase 5 runs QA; phase 6 writes QA report and advances to `signoff_review`
- Add worktree education: after worktree creation, explain what a worktree is, why the project now lives in its own branch, what that means for their git state, and how to navigate to it if needed
- Add `.orchestration/worktrees/` to `.gitignore`
- Rewrite `defaults/commands/qa.md` to write QA report to `.orchestration/projects/{id}/qa-report-{NN}.md`; remove standalone `/qa` usage — QA is now internal to `/implement`
- Task files gain `assigned_at` and `completed_at` timestamps when agents start and finish them

**Validation:**
- Run `/implement` with one project in `tasks_ready`
- Worktree created at `.orchestration/worktrees/{id}`
- `status.md` contains `worktree_path` and `branch`, plus `stage: signoff_review`
- `qa-report-01.md` exists in project folder
- Task files have `completed_at` timestamps
- Running `/implement` again on this project outputs: "project is in signoff_review — run /review to continue"
- `/status` now shows worktree path and branch for this project

---

### Slice 6 — `/implement` v2: parallel multi-project

**Goal:** `/implement` can select 2+ projects, create a worktree per project, and execute them in parallel (capped at 4). User chooses parallel vs sequential.

**Changes:**
- Extend `defaults/commands/implement.md`: phase 0 allows multi-select; phase 1 asks parallel or sequential (default: sequential); parallel mode spawns up to 4 concurrent project pipelines, each in its own worktree
- Education: explain what parallel mode means for token consumption and machine load; explain why the cap exists; show how to check in on parallel projects with `/status`

**Validation:**
- Run `/implement`, select 2 projects both in `tasks_ready`
- 2 worktrees created
- Both projects reach `signoff_review`
- `/status` (no arg) shows both projects with their worktree state and current stage
- Sequential mode still works correctly (projects run one after another, not simultaneously)

---

## Phase 4: Review + full status

### Slice 7 — `/review` command

**Goal:** `/review` reads a `signoff_review` project, presents the QA report and task diffs, and handles two paths: approval (project is done, worktree merged and archived) or feedback (project is marked ready for next design run, user manually runs `/design` to start it).

**Changes:**
- Create `defaults/commands/review.md`: phase 0 loads project from `status.md`; phase 1 presents QA report and slice-by-slice summary; phase 2 asks: approve or provide feedback
  - **Approve path:** merge worktree branch to main, `git worktree remove`, move project folder to `.orchestration/projects/done/YYYY-MM/{id}/`, update `status.md` to `stage: done` with timestamp
  - **Feedback path:** record feedback note in `status.md` transitions log, set `stage: feedback_pending`, output: "run /design to start the next pipeline run on this project"
- Education: explain what "done" means (merged, archived, measurable); explain what feedback triggers (a new run, not a restart); explain that `/design` will pick up in the correct worktree context
- `/design` updated to handle `feedback_pending` as a valid entry state, incrementing run counter and creating `design-02.md`

**Validation:**
- **Approve path:** project folder moves to `done/YYYY-MM/`, worktree removed, `status.md` shows `stage: done`, branch merged to main
- **Feedback path:** `status.md` shows `stage: feedback_pending` with feedback note; running `/design` on this project starts run 02, creates `design-02.md`, `slices-02.md` etc.
- Running `/review` on a project not in `signoff_review` outputs: "project is in {stage} — {which command to run}"

---

### Slice 8 — `/status` v2: multi-project + worktree-aware

**Goal:** `/status` with no arguments shows all non-done projects across main and active worktrees — stage, run number, worktree if present, what's next. Done projects are excluded. Parallel in-flight projects are clearly distinguishable.

**Changes:**
- Extend `defaults/commands/status.md`: no-arg mode runs `git worktree list` to discover active worktrees, reads each project's `status.md`, renders a summary table: project ID, stage, run, worktree (if any), next action, last transition timestamp
- Education in output: if any project is in a `*_review` stage, remind user which command unblocks it; if multiple worktrees are active, note which are parallel and how to check in on each

**Validation:**
- With 3 projects in different stages (one in `design_review`, one `implementing` in a worktree, one `signoff_review`), `/status` shows all three correctly
- Worktree project shows `worktree_path` and `branch` in output
- Done projects do not appear
- `/status` on a repo with no projects outputs a helpful "no active projects" message, not an error

---

## Phase 5: Quality and polish

### Slice 9 — Metrics quality + gap surface

**Goal:** Run a complete pipeline cycle (new project → done) and verify that all timestamps are present at task, slice, and project level. Output a report listing what can be computed from the current data and what gaps exist.

**Changes:**
- Create a fixture project with a known history (manually crafted `status.md` and task files with transitions, timestamps, slice IDs)
- Write a verification checklist: for each metric in the design doc's "metrics exposed" decision, can it be computed from the fixture data? What queries would compute it?
- Surface gaps: missing timestamps, metrics that require data not currently recorded, metrics that would require cross-project aggregation that doesn't yet exist
- If gaps are found, update `status.md` format or task file format accordingly before closing this slice

**Validation:**
- Every metric listed in the design doc can be traced to a specific field in `status.md` or a task file
- Any metric that can't be traced is either removed from the design doc or a new field is added to support it
- The verification checklist is committed alongside the fixture

---

### Slice 10 — Init-orchestrator + README + education audit

**Goal:** `init-orchestrator` installs the new 4-command structure. README accurately describes the system. Every command has contextual education output that helps users understand where they are and what's happening. Education is especially clear around worktrees and parallel execution.

**Changes:**
- Update `init-orchestrator.md`: install `/design`, `/implement`, `/review`, `/status`; remove `/pipeline`, `/breakdown` (standalone), `/qa` (standalone), old `/implement`; create `.orchestration/projects/` folder structure; add `.orchestration/worktrees/` to `.gitignore`
- Rewrite `README.md`: describe the 4-command surface, the project lifecycle, worktree model, and metrics. No implementation details — just what the user needs to know to use it.
- Education audit: read every command file, verify each has: (a) contextual output after key actions explaining stage + next step, (b) clear error messages with "run X instead", (c) worktree explanation where relevant. Fix any gaps found.

**Validation:**
- Run `init-orchestrator` on a fresh project; all 4 commands available, old commands absent, `.orchestration/projects/` exists
- README accurately describes the system as implemented (no stale references to old commands or folder structure)
- Each command file has education annotations at every stage transition
- A new user reading only the README and error messages from a wrong command can figure out what to do next without reading the code
