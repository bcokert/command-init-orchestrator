---
type: brief
slice: 03
project: bcokert-00002-status-per-slice-view
spec: .orchestration/projects/bcokert-00002-status-per-slice-view/02-slices/03-status-command-revamp.md
date: 2026-04-17
---

# Delegation brief — slice 03: status command per-slice grouped view

**Type:** Task (AI agent)
**Date:** 2026-04-17

---

## 1. Intent

`/status` with no args currently shows one row per project: id, stage, worktree,
next action, time in stage. That's fine for single-slice projects but useless once a
project has multiple slices in different states. You can see "spec_in_progress" but not
which slice, how far along, or what's waiting on you.

The revamp replaces the flat Phase 3 table with a grouped view: one header per active
project, one row per slice. The project header gives aggregate progress at a glance; slice
rows give the state detail. Done projects are excluded entirely. The done-this-week section
(Phase 4) is removed.

Phase 1 (single-project detail view, invoked with a project ID arg) is unchanged.

**Files to change:**
- `defaults/commands/status.md` and `.claude/commands/status.md`
- Both must be updated identically. Version bump: `2.0.0 → 3.0.0` (major — breaking change).

---

## 2. Observable outcomes

**Multi-project view — happy path**
```
Given   two active projects: one with 2 slices (1 done, 1 implementing),
        one with 0 slices (still in design)
When    /status is run with no args
Then    output shows:

  bcokert-00002-status-per-slice-view  started 2026-04-16  2/4 slices  3/10 tasks
    plan-project timestamps  draft → specced  since 2026-04-17 10:00  →  run /plan-project to break down
    implement qa states      draft → reviewed  since 2026-04-17 10:00  →  run /plan-project to spec

  bcokert-00001-some-other  started 2026-04-10  0/0 slices  0/0 tasks

  (no slice rows for projects with 0 slices)
```

**Done slice row**
```
Given   a slice with status: done
When    rendered in the grouped view
Then    row shows: ✓ {title}  done {date} {time}
        No state transition line. If status_updated_at is missing: ✓ {title}  done —
```

**Missing status_updated_at**
```
Given   a slice file has no status_updated_at field
When    rendered as an active slice row
Then    row shows: {title}  {previous} → {current}  since —  →  {next action}
        (dash in place of datetime, row still rendered)
```

**Unknown slice status**
```
Given   a slice file has status: someunknownvalue
When    rendered
Then    row shows: {title}  ⚠ unknown state
        No transition line. No next action.
```

**Missing task directory**
```
Given   a slice has no 04-tasks/slice-NN/ directory
When    task counts are computed for that slice
Then    count renders as 0/0 — no crash
```

**All projects done**
```
Given   no active projects (all in done/ or none exist)
When    /status is run
Then    output: "no active projects — run /plan-project to start one"
```

**Project sort**
```
Given   project A last updated 3 days ago, project B last updated 1 hour ago
When    rendered
Then    project B appears first (most recently updated)
```

**Worktree slice files**
```
Given   a project is implementing with a worktree at .orchestration/worktrees/{id}
When    rendering slice rows
Then    slice files are read from {worktree_path}/.orchestration/projects/{id}/02-slices/
        (worktree is authoritative — it has the latest status writes from implement)
```

---

## 3. Constraints

**Must:**
- Replace Phase 2 multi-project scan + Phase 3 table with the new grouped view. Phase 1
  (single-project) is untouched.
- Remove Phase 4 (done-this-week). The section is deleted entirely.
- Output format:
  ```
  {project_id}  started {YYYY-MM-DD}  {done}/{total} slices  {done}/{total} tasks
    {slice title}  {previous state} → {current state}  since {YYYY-MM-DD HH:MM}  →  {next action}
    ✓ {slice title}  done {YYYY-MM-DD HH:MM}
  ```
  Two-space indent for slice rows. Blank line between projects.
- Derive `{previous state}` deterministically from the state machine sequence:
  `draft → reviewed → specced → tasks_ready → implementing → qa_in_progress → signoff_review → done`
  Previous of `draft` = `(new)` or omit the previous field.
- Derive `{next action}` from this table (exact strings):

  | State | Next action |
  |-------|-------------|
  | `draft` | review slice, set `status: reviewed`, re-run `/plan-project` |
  | `reviewed` | run `/plan-project` to spec |
  | `specced` | run `/plan-project` to break down |
  | `tasks_ready` | run `/implement` to start |
  | `implementing` | in progress — run `/implement` to resume |
  | `qa_in_progress` | QA running — run `/implement` to resume |
  | `signoff_review` | run `/review` to approve or give feedback |

- "Started" date: timestamp of the earliest (last) transition in `status.md` transitions list
  (typically the `design_in_progress` entry with note "project created"). If transitions is
  empty or unparseable: show `—`.
- Slice count: total = count of `.md` files in `02-slices/`. Done count = files where
  `status: done`.
- Task count: total = count `.md` files in `04-tasks/slice-*/` across all slice subdirs.
  Done = files where `status: done` in frontmatter. If the directory doesn't exist: 0/0.
- Sort projects: most recently updated first. "Most recently updated" = the latest timestamp
  across all of: the most recent `status.md` transition, and any `status_updated_at` field
  in slice files. If a project has no parseable timestamps: sort it last.
- For projects with a worktree (`worktree_path` set and directory exists): read slice files
  from `{worktree_path}/.orchestration/projects/{id}/02-slices/` — the worktree has the
  authoritative slice state during implementation. `status.md` worktree logic unchanged.
- Partial reads over crashes. Missing field → inline warning/dash, never stop.
- Bump version `2.0.0 → 3.0.0` in both files.

**Must not:**
- Change Phase 1 (single-project detail view) at all.
- Add filter or sort arguments — those are a future extension, explicitly out of scope.
- Crash if `02-slices/` or `04-tasks/` directories are absent.
- Show done projects in the grouped view.
- Keep Phase 4 (done-this-week). Remove it entirely.

**Preferences:**
- `status_updated_at` format in slice files is ISO 8601 with timezone offset. When rendering
  "since {date} {time}", display as local date and time (drop the timezone suffix for display).
  E.g. `2026-04-17T10:30:00-07:00` → `2026-04-17 10:30`.
- Slice rows sorted by slice number (ascending) within each project — natural file order.
- If a project is in a planning stage (design_review, slicing_review, etc.) with 0 slice
  files yet, show just the header with `0/0 slices  0/0 tasks`. No slice rows.

**Escalation triggers:**
- If the `status.md` structure for worktree projects differs significantly from what Phase 2
  currently handles: stop and re-read `implement.md` Phase 1 for the worktree_path format.
- If the `.claude/` and `defaults/` copies of status.md have diverged beyond version: stop
  and report before editing.

---

## 4. Done definition

Verify without reading implementation:

1. Run `/status` (or invoke the command) in a repo with at least one active project that
   has slice files. Output shows grouped format with project header and slice rows — not a
   flat table.

2. `grep "Phase 4\|Done this week\|done-this-week" defaults/commands/status.md` — no matches
   (Phase 4 removed).

3. `grep "^version:" defaults/commands/status.md` → `version: 3.0.0`
4. `grep "^version:" .claude/commands/status.md` → `version: 3.0.0`

5. `grep "status_updated_at\|since" defaults/commands/status.md` — returns matches in the
   Phase 2/3 rendering logic, confirming the field is read and displayed.

6. Manual spot-check with a slice file that has no `status_updated_at`:
   - Output shows `since —` in the row (not a crash, not an empty string).

7. Manual spot-check with a slice file that has `status: someunknown`:
   - Row shows `⚠ unknown state` (no transition line, no next action).

**Test vector — exact row formats:**
```
# Active slice (has status_updated_at)
  plan-project timestamps  draft → specced  since 2026-04-17 10:00  →  run /plan-project to break down

# Active slice (missing status_updated_at)
  implement qa states  draft → reviewed  since —  →  run /plan-project to spec

# Done slice
  ✓ some completed slice  done 2026-04-10 14:22

# Unknown status
  broken slice  ⚠ unknown state
```

---

## 5. Breakdown

| # | Step | Deliverable | Done signal |
|---|------|-------------|-------------|
| 1 | Rewrite `defaults/commands/status.md` Phase 2 multi-project scan — extend data collection to also read slice files per project (status, status_updated_at, title from `# Slice NN — ...` heading), task counts from `04-tasks/slice-*/`, and project start date from transitions | Updated Phase 2 | File reads slice data in addition to project status.md |
| 2 | Rewrite `defaults/commands/status.md` Phase 3 — replace flat table with grouped project + slice view using the output format specified above; handle all edge cases (missing fields, unknown status, 0 slices, worktree reads) | Updated Phase 3 | Grouped format described, all edge cases covered |
| 3 | Remove Phase 4 (done-this-week) entirely from `defaults/commands/status.md` | Phase 4 deleted | `grep "Done this week" defaults/commands/status.md` → no match |
| 4 | Bump version `2.0.0 → 3.0.0` in `defaults/commands/status.md` | Version bumped | `grep "^version:" defaults/commands/status.md` → `version: 3.0.0` |
| 5 | Sync all changes identically to `.claude/commands/status.md` | .claude/ copy updated | `diff` of Phase 2/3 content shows no difference vs defaults/ |
