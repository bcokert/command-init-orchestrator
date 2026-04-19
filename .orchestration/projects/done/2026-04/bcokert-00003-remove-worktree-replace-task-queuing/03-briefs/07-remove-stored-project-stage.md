**Type:** Task (AI agent)
**Date:** 2026-04-19

---

### 1. Intent

The orchestrator currently stores project-level state (`stage`, `next_action`, `transitions`) in `status.md`. Every command reads this file to decide what to do next, and every phase writes a new stage to it when it completes. The file is the authoritative routing source — if it's stale or wrong, commands misbehave.

This slice eliminates `status.md` entirely. All project state is derived from artifacts already on disk: directory existence proves the project exists, the design doc's `date:` field is the creation timestamp, and slice file `status:` fields are the full routing source. No new files are introduced — the data was always there.

Two behavioral changes come with this:

**Ordering constraint.** Slice N cannot advance to any state until slice N-1 is already at that state or further. Spec slice N only when slice N-1 is already `specced`; break down slice N only when N-1 is `tasks_ready`. Implementation is already enforced by the queue (slice 03). This constraint is checked at gate time in plan-project.

**Independent spec/breakdown.** Multiple slices can be specced or broken down in parallel, subject to the ordering constraint. Previously plan-project enforced strict sequential processing. Now the lowest-numbered eligible slice is selected, but earlier slices and later slices can progress concurrently once the ordering constraint allows it.

---

### 2. Observable outcomes

**Project creation — no status.md written**
```
Given /plan-project is run with no existing project
When it creates a new project directory
Then only the directory is created — no status.md is written
And the design interview starts immediately
```

**plan-project routing — artifact-based**
```
Given a project with a design doc and two slice files (01: tasks_ready, 02: reviewed)
When /plan-project is run with no argument
Then it selects slice 02 for spec (eligible: slice 01 is tasks_ready ≥ specced)
And does not touch status.md at any point
```

**plan-project routing — ordering constraint blocks**
```
Given a project with slices (01: reviewed, 02: reviewed)
When /plan-project is run
Then it selects slice 01 for spec
And reports that slice 02 cannot be specced until slice 01 reaches specced
```

**plan-project gate commits — no status.md staged**
```
Given spec for slice 03 is approved
When plan-project commits the spec gate
Then git add includes the brief and slice file but NOT status.md
And status.md is absent from the commit entirely
```

**review — project identified via slice scan**
```
Given two projects each have one slice at signoff_review
When /review is run with no argument
Then it lists both slices and prompts which to approve
And does not read status.md from either project
```

**review approve — no status.md write**
```
Given a slice is approved
When /review commits and (if all slices done) archives
Then status.md is not written anywhere in the process
And archive detection uses slice file statuses to determine if all slices are done
```

**review feedback — no feedback_pending written to status.md**
```
Given feedback is captured and draft slices with follow_up_of: are written
When /review finishes the feedback path
Then no status.md is written
And plan-project detects feedback pending by finding draft slices with follow_up_of: set
```

**status command Phase 1 — slice table not transitions**
```
Given /status bcokert-00003-remove-worktree-replace-task-queuing is run
When the project has 3 slices (01: done, 02: implementing, 03: reviewed)
Then the output shows a project header and per-slice rows (same format as multi-project view)
And no stage/next_action/elapsed/transitions block appears
```

**status command Phase 2 — start date from design doc**
```
Given a project whose design doc has date: 2026-04-17
When /status is run (no arg)
Then the project header shows Apr 17 as start date
And the sort key uses the latest slice status_updated_at, falling back to design doc date
```

**Old status.md silently ignored**
```
Given a project that still has a status.md from before this slice
When any command reads it
Then the file is not read — commands derive state from artifacts only
And no error is raised
```

---

### 3. Constraints

**Must:**
- Eliminate all `status.md` reads and writes from plan-project, implement, review, and status command
- Enforce the ordering constraint in plan-project slice selection: before speccing slice N, slice N-1 must be at `specced` or beyond; before breakdown of slice N, slice N-1 must be at `tasks_ready` or beyond. Slice 01 has no prior, so no constraint.
- Remove `status.md` from all `git add` lines in plan-project's gate commits
- update review's project-identification logic to scan slice files for `status: signoff_review`
- Update status command Phase 1 to show the slice table instead of the stage/transitions block
- Update status command Phase 2 to read start date from design doc `date:` field; sort key = latest slice `status_updated_at`, fallback to design doc `date:`
- Bump version for every file changed in `defaults/`: minor bump for behavioral changes, patch for pure removals. Plan-project and review qualify for minor; implement and status command qualify for minor too (routing behavior changes). init-orchestrator qualifies for patch.
- Sync all changed `defaults/commands/` files to `.claude/commands/`

**Must not:**
- Remove or modify the archive path (project moves to `done/YYYY-MM/{id}/` on all-slices-done)
- Change the approve commit (`git add -A`) — only remove the `status.md` updates around it
- Alter the queue scan logic in implement (done in slice 03)
- Break existing projects that still have a `status.md` — commands must not error on its presence; they just ignore it
- Remove `follow_up_of:` from feedback slice format — it's how feedback pending is detected

**Preferences:**
- When multiple slices are eligible for spec simultaneously, pick the lowest-numbered one
- When reporting the ordering constraint block, name both slices and the required state: "Slice {N-1} must reach {state} before slice {N} can advance"
- plan-project priority when multiple conditions are true: signoff_review redirect beats implementing redirect beats spec/breakdown work beats tasks_ready redirect

**Escalation triggers:**
- If a slice file is unreadable during routing: stop and report — do not silently skip a slice and potentially advance out of order
- If `01-design/design-01.md` is missing but slices exist: stop and report inconsistent state — do not run interview

---

### 4. Done definition

- Running `/plan-project` on a brand new project: no `status.md` file created; only the directory and design interview flow
- Running `/plan-project` on a project with slices 01–02 both `reviewed`: selects slice 01 for spec; reports slice 02 blocked until 01 is specced
- Running `/plan-project` on a project with slice 01 `specced` and slice 02 `reviewed`: selects slice 02 for spec (eligible — 01 is already specced)
- Running `/review` with no arg on a project: scans slice files for `signoff_review`; does not read status.md
- After `/review` approves a non-final slice: no `status.md` written; correct "N slices remaining" message
- After `/review` approves the last slice: archive proceeds; no `status.md` written
- Running `/status` with a project ID: shows slice table with project header; no stage/transitions block
- Running `/status` with no arg: project start date sourced from design doc; sort order by slice timestamps
- `grep -r "status\.md"` across `defaults/commands/` finds no reads or writes in plan-project, implement, review, or status command (may still appear in comments or old-format-compatibility notes)
- All four `defaults/commands/` files have bumped `version:` fields; `.claude/commands/` copies match

---

### 5. Breakdown

| # | Step | Deliverable | Done signal |
|---|------|-------------|-------------|
| 1 | Rewrite plan-project.md | Phase 0 routing is artifact-based; project creation writes no status.md; gate commits exclude status.md; slice selection enforces ordering constraint; wrong-command routing uses slice states | No status.md read or write anywhere in plan-project; ordering constraint reported correctly for blocked slices; version bumped minor |
| 2 | Update implement.md | Wrong-command routing replaces project-stage checks with slice-state checks; Step 1 project validation reads slice files not status.md | No stage: field referenced in implement routing table; version bumped |
| 3 | Rewrite review.md | Phase 0 scans slice files for signoff_review; approve path removes status.md writes; feedback path removes feedback_pending status.md write; archive check uses slice statuses | /review with no arg scans slices not status.md; no status.md written on approve or feedback; version bumped minor |
| 4 | Update status command | Phase 1 redesigned to show slice table (project header + same rows as Phase 3); Phase 2 start date from design doc date:; Phase 2 sort key from slice status_updated_at timestamps | Phase 1 shows no stage/elapsed/transitions; Phase 2 project header date matches design doc; version bumped minor |
| 5 | Update init-orchestrator.md + sync all | Remove any status.md references from init-orchestrator.md; copy updated defaults/commands/ files to .claude/commands/; verify version fields match across defaults/ and local install | init-orchestrator.md has no status.md mention; .claude/commands/ files match defaults/commands/ |
