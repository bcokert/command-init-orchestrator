---
type: slice
slice: 07
order: 07
project: remove-worktrees-queue-model
design: .orchestration/projects/bcokert-00003-remove-worktree-replace-task-queuing/01-design/design-01.md
status: draft
---

# Slice 07 — Eliminate stored project state; derive everything from slices

**Goal:** status.md is eliminated entirely. All project state is derived from artifacts on disk: directory existence, design doc, and slice files. Slice files carry their own `transitions` list. Slice ordering is enforced: slice N cannot advance to state X until slice N-1 is already at state X or beyond. Spec and breakdown of later slices can proceed in parallel with earlier slices, subject to this constraint. Implementation order is strict: slice N cannot begin implementing until slices 1..N-1 are all at `signoff_review` or `done`.

## Happy path

- **status.md eliminated:** no file written, read, or expected anywhere. Project presence = directory exists (not under `done/`). Created date = design doc `date:` field. All routing state = slice files.
- **Slice ordering constraint:** before advancing slice N to any state, slice N-1 must already be at that state or further. Enforced at gate time — plan-project checks when selecting which slice to spec or break down; implement queue selection already enforces the implementation variant (slice 03). For slice 01, no prior slice constraint applies.
- **Slice file transitions:** each slice file gains a `transitions` list (timestamp + note per state change). Full history of a slice is readable from the slice file alone.
- **plan-project routing** derives resume point entirely from artifacts:
  - No project directory → create directory, run interview
  - Directory exists, no `01-design/design-01.md` → interview incomplete, run interview
  - Design doc exists, no `02-slices/*.md` → run slicing
  - Slice files exist, no slice is `reviewed` or beyond → lowest draft slice is unreviewed; stop and prompt user to review it and set `status: reviewed`
  - A slice is `reviewed` and its prior slice is at `specced` or beyond (or it is slice 01) → spec it. If brief already exists for this slice: show spec gate (waiting for user confirmation). If not: run spec.
  - A slice is `specced` and its prior slice is at `tasks_ready` or beyond (or it is slice 01) → break it down. Check task files: if count matches brief → breakdown was completed (slice file should already be `tasks_ready`); if files missing or count mismatches → re-run breakdown.
  - Any slice is `implementing` or `qa_in_progress` → "run /implement to continue"
  - Any slice is `signoff_review` → "run /review to approve"
  - All slices are `tasks_ready` or beyond, none currently implementing → "run /implement"
  - When multiple slices are eligible for spec or breakdown, pick the lowest-numbered eligible one.
- **plan-project wrong-command routing:** remove all `stage`-based rows. Replace with slice-state checks: if any slice is `implementing`, `qa_in_progress`, or `signoff_review` output the appropriate redirect.
- **plan-project project scan (Step 1):** remove status.md scan. Replace with: glob all `.orchestration/projects/*/` directories (excluding `done/`). Active projects are those with a directory present.
- **plan-project gate commits:** remove `status.md` from all `git add` lines across all phases. Never written, never staged.
- **plan-project project creation (Step 4):** create the project directory only. No status.md written. Load context and run interview.
- **implement:** no change beyond slice 03. Queue selection already reads slice states. Wrong-command routing: replace project-level `stage` checks with slice-state checks — if no slice is at `tasks_ready` or `implementing`, nothing to implement.
- **review Phase 0 — project identification:** replace `status.md` scan for `stage: signoff_review` with a scan of `02-slices/*.md` across all active projects for `status: signoff_review`. Same single/multiple/none disambiguation logic applies.
- **review feedback path:** `feedback_pending` is no longer stored. A project has feedback pending when it has draft slices with `follow_up_of:` field set. Plan-project handles these naturally via the "unreviewed draft slice" routing — no distinct state or detection needed.
- **review approve path:** remove all `status.md` writes (stage: done, transitions). Archive check and move unchanged. Done status is implicit: archived projects live under `done/YYYY-MM/{id}/` and are excluded from active scans by path.
- **status command Phase 1 (single-project):** drop `stage`, `next_action`, `elapsed`, and transitions block entirely. Show: project header derived from design doc `date:` + slice table (same output as Phase 3 scoped to this project). If project folder does not exist: "project {id} not found." If folder exists but no slice files: show header only with `—` for counts.
- **status command Phase 2 — start date:** source from design doc `date:` field (not from status.md transitions). If no design doc: use `—`.
- **status command Phase 2 — sort key:** latest `status_updated_at` across all slice files for the project. Fall back to design doc `date:` if no slice timestamps exist.
- **init-orchestrator:** remove any reference to status.md from install output, setup notes, or version output. No status.md is created on setup.

## Edge cases

- **Old status.md still present:** silently ignored. No command reads it or writes to it after this slice ships.
- **No design doc, directory exists:** treated as design_in_progress — plan-project re-runs interview. No error.
- **Ordering constraint blocks advancement:** plan-project stops and reports: "Slice {N-1} must reach {required_state} before slice {N} can advance. Run /plan-project to advance slice {N-1} first."
- **All queued slices blocked by ordering constraint:** implement reports per-slice blocked state (already handled by slice 03 queue logic).
- **Feedback slices (follow_up_of: set):** detected as draft slices in normal routing. Plan-project prompts user to review. No special state needed.
- **Pre-slice project (design complete, no slices yet):** status command shows project header with `—` for all counts, created date from design doc.
- **Multiple slices eligible for spec simultaneously:** plan-project picks the lowest-numbered. User can pass a slice number as argument to override (existing behaviour).
- **status.md absent:** not an error. No command expects it.
- **Archive path collision:** unchanged from current review.md — fail with clear instructions if target exists.
