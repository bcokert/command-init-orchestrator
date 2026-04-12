---
type: brief
slice: 03
project: project-sequencing-and-status
design: specs/design/project-sequencing-and-status.md
slice_doc: specs/slices/project-sequencing-and-status/03-spec-and-breakdown.md
status: ready
date: 2026-04-11
---

# Delegation brief — Slice 03: Spec + breakdown → tasks ready

## Intent

Extend `defaults/commands/design.md` Phases 6 and 7 so that after slicing approval, `/design` writes a delegation brief for the next unspecced slice and creates task files from it. After this slice, a project can reach `tasks_ready` and become selectable in `/implement`.

Spec logic lives in `defaults/commands/spec.md` as an internal implementation file. Breakdown logic is inline in design.md (standalone `/breakdown` command removed). The user never calls either directly.

## Observable outcomes

**Approve slices, run /design → spec written:**
```
Given status.md shows stage: slicing_review and at least one slice has status: reviewed or draft
When the user runs /design
Then the lowest-numbered unspecced slice is selected
And a delegation brief is written to .orchestration/projects/{id}/briefs/{NN}-{slug}.md
And the selected slice file frontmatter advances to status: specced
And status.md advances to spec_review
And git commit + push runs
And the spec review gate is shown
```

**Approve spec, run /design → tasks created:**
```
Given status.md shows stage: spec_review
When the user runs /design
Then task files are created in .orchestration/projects/{id}/tasks/slice-{NN}/
And each task file has: spec, slice, step, title, status: todo, depends_on, agent_type, assigned_at: null, completed_at: null
And the slice file advances to status: tasks_ready
And status.md advances to tasks_ready
And git commit + push runs
And output tells the user to run /implement
```

**Resume: spec crashed, no brief file:**
```
Given status.md shows stage: spec_in_progress and brief file does not exist
When the user runs /design
Then spec restarts for that slice
```

**Resume: breakdown crashed, partial task files:**
```
Given status.md shows stage: breakdown_in_progress and tasks/slice-{NN}/ has fewer files than the brief's breakdown table
When the user runs /design
Then all task files for that slice are regenerated (idempotent overwrite)
```

**No collision across slices:**
```
Given tasks/ already contains files from slice 01
When breakdown runs for slice 02
Then slice 02 tasks are written to tasks/slice-02/ without touching tasks/slice-01/
```

**Wrong command:**
```
Given status.md shows stage: spec_in_progress, spec_review, breakdown_in_progress, or tasks_ready
When the user runs /implement (except at tasks_ready) or /review
Then output is: "project is in {stage} — run /design to continue"
Except tasks_ready: "tasks are ready — run /implement to start"
```

## Constraints

**Must:**
- Spec targets the lowest-numbered slice with `status: draft` or `status: reviewed` that comes after all `specced`/`tasks_ready`/done slices — never skip a slice
- Brief format follows the existing delegation brief structure from `defaults/commands/spec.md`: Intent, Observable outcomes, Constraints, Done definition, Breakdown table
- Task file fields: `spec` (path to brief), `slice`, `step`, `title`, `status: todo`, `depends_on` (list of filenames), `agent_type`, `assigned_at: null`, `completed_at: null`
- Task files at `.orchestration/projects/{id}/tasks/slice-{NN}/{task-NN}-{slug}.md`
- Breakdown regeneration is idempotent — re-running produces identical files
- `status.md` updated to `spec_in_progress` before writing brief; `breakdown_in_progress` before writing task files; `tasks_ready` only after all task files confirmed written
- Commit at `spec_review` gate: brief + updated slice file + status.md
- Commit at `tasks_ready` gate: task files + updated slice file + status.md
- Remove `defaults/commands/breakdown.md` (standalone command superseded)

**Must not:**
- Advance slice status to `specced` before the brief is fully written
- Advance slice status to `tasks_ready` before all task files are written
- Mix task files from different slices in the same folder

**Preferences:**
- `depends_on` defaults to sequential (each task depends on the previous). Only make parallel if the spec explicitly marks steps as independent.
- `agent_type` derived from the work described: `architect` for command/prompt files, `server-dev` for Go/backend, `client-dev` for frontend, `quality` for tests

**Escalation triggers:**
- Slice file has `status: draft` and is ambiguous — ask user to clarify before speccing
- Brief's breakdown table has zero rows — stop and ask

## Done definition

1. Running `/design` from `slicing_review` produces a brief at the correct path, advances slice to `specced`, commits + pushes, shows spec gate
2. Running `/design` from `spec_review` produces task files at correct paths, advances slice to `tasks_ready`, commits + pushes, outputs "run /implement"
3. Task files have all required fields including `assigned_at: null` and `completed_at: null`
4. Breakdown crash-resume: partial task files regenerated correctly on re-run
5. Cross-slice isolation: slice 02 tasks in `tasks/slice-02/`, not mixed with slice 01
6. Wrong-command errors correct at all spec/breakdown stages

## Breakdown

| # | Step | Deliverable | Done signal |
|---|------|-------------|-------------|
| 1 | Wire Phase 6 in design.md: spec_in_progress, slice selection, spec write, spec_review gate | Phase 6 selects correct slice, writes brief, advances status, commits, shows gate | Brief at correct path; slice status = specced; git commit contains brief + slice file + status.md |
| 2 | Update spec.md output path | spec.md writes to `.orchestration/projects/{id}/briefs/{NN}-{slug}.md` | Brief appears at correct path with correct format |
| 3 | Wire Phase 7 in design.md: breakdown_in_progress, task creation, resume detection, tasks_ready gate | Phase 7 creates task files, detects partial state on resume, advances to tasks_ready, commits | Task files at correct paths with all required fields; partial-state resume regenerates all correctly |
| 4 | Remove standalone breakdown.md command | `defaults/commands/breakdown.md` deleted | File absent from repo |
| 5 | Add wrong-command errors for spec/breakdown stages | All stages from spec_in_progress through tasks_ready output correct errors for /implement and /review | Error messages include stage name and correct next command |
