---
spec: specs/briefs/project-sequencing-and-status/09-metrics-quality.md
slice: 09
step: 1
title: Build fixture project
status: todo
depends_on: []
agent_type: architect
assigned_at: null
completed_at: null
---

## Work

Create `.orchestration/projects/fixture-00001-metrics-test/` with hand-crafted files representing a complete two-slice project history:

**Slice 01 — clean run:**
- `01-design/design-01.md` — minimal design doc
- `02-slices/01-clean-slice.md` — status: done
- `03-briefs/01-clean-slice.md` — minimal brief
- `04-tasks/slice-01/01-task.md` — status: done, assigned_at + completed_at set
- `04-tasks/slice-01/02-task.md` — status: done, assigned_at + completed_at set
- `05-qa/slice-01-qa-report.md` — status: passed

**Slice 02 — QA failure + feedback:**
- `02-slices/02-failing-slice.md` — status: done
- `03-briefs/02-failing-slice.md` — minimal brief
- `04-tasks/slice-02/01-task.md` — status: done
- `04-tasks/slice-02/02-task.md` — status: done
- `05-qa/slice-02-qa-report.md` — status: partial (one task failed, was fixed)
- `02-slices/02.1-feedback-slice.md` — status: done (feedback slice that followed)

**status.md** — complete transitions log covering all stages from design_in_progress through done, all with ISO 8601 timestamps. Include: worktree_path, branch fields.

All timestamps must be plausible (slice 01 completes before slice 02 starts, etc.).

## Done signal

Fixture folder exists with complete structure. All timestamps are present and chronologically consistent. Two-slice history is fully represented.
