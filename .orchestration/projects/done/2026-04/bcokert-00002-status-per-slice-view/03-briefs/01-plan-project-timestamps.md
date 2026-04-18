---
type: brief
slice: 01
project: bcokert-00002-status-per-slice-view
spec: .orchestration/projects/bcokert-00002-status-per-slice-view/02-slices/01-plan-project-timestamps.md
date: 2026-04-17
---

# Delegation brief — slice 01: plan-project timestamps

**Type:** Task (AI agent)
**Date:** 2026-04-17

---

## 1. Intent

The `/status` command revamp (slice 03) will show a "datetime entered current state" line
for every active slice. That requires a machine-readable timestamp stored on each slice file
when its status last changed. Nothing writes that timestamp today.

This slice adds `status_updated_at` to slice file frontmatter in every place that
`plan-project` writes or changes a slice's `status` field:

1. **Phase 5 — slicing**: slice files are created with `status: draft`. Add `status_updated_at`
   here by updating the slice file format in `slice.md`.
2. **Phase 6 — spec**: slice status is updated to `specced`. Add `status_updated_at` update here.
3. **Phase 7 — breakdown**: slice status is updated to `tasks_ready`. Add `status_updated_at` update here.

The implement command (slice 02) will add its own timestamps for `implementing`,
`qa_in_progress`, `signoff_review`, and `done`. That's out of scope here.

Both command files (`.claude/commands/plan-project.md` and `defaults/commands/plan-project.md`)
must be updated identically — the `.claude/` copy is the local dogfood install.

---

## 2. Observable outcomes

**Happy path — slice creation**
```
Given   plan-project runs Phase 5 slicing on any design doc
When    slice files are written to 02-slices/
Then    each file's frontmatter contains both `status: draft` and
        `status_updated_at: {ISO 8601 with timezone offset}` set to the current time
```

**Happy path — spec stage**
```
Given   a slice file exists with status: reviewed
When    plan-project Phase 6 completes and updates the slice to status: specced
Then    the slice file frontmatter shows `status: specced` AND
        `status_updated_at` updated to the current timestamp
```

**Happy path — breakdown stage**
```
Given   a slice file exists with status: specced
When    plan-project Phase 7 completes and updates the slice to status: tasks_ready
Then    the slice file frontmatter shows `status: tasks_ready` AND
        `status_updated_at` updated to the current timestamp
```

**Edge case — resume after crash**
```
Given   a slice file already has status_updated_at from a previous run
When    plan-project updates the slice status again
Then    status_updated_at is overwritten with the new timestamp, not skipped
```

**Edge case — legacy slice files**
```
Given   a slice file exists that was created before this change (no status_updated_at field)
When    the status command reads it
Then    no change is needed here — the status command (slice 03) handles missing fields by
        displaying `—`. This slice does not backfill existing files.
```

---

## 3. Constraints

**Must:**
- Write `status_updated_at` as ISO 8601 with timezone offset (e.g. `2026-04-17T10:30:00-07:00`),
  matching the format already used for transition timestamps in `status.md`.
- Update `status_updated_at` every time `status` changes — including overwrites on resume.
- Update both `defaults/commands/plan-project.md` and `.claude/commands/plan-project.md`
  with identical changes.
- Update `.orchestration/support/slice.md` to include `status_updated_at` in the slice
  frontmatter template (so newly created slice files automatically carry the field).
- Bump version in both plan-project files: `2.2.0 → 2.2.1` (patch — new field on existing writes).

**Must not:**
- Change the slice frontmatter format beyond adding `status_updated_at`.
- Modify any other command files (implement.md, review.md, status.md are out of scope).
- Backfill `status_updated_at` on existing slice files — no migration, no retroactive writes.
- Change any field names or formats already in the slice template.

**Preferences:**
- Place `status_updated_at` on the line immediately after `status` in the frontmatter. Consistent
  ordering makes diffs easier to read.
- Where plan-project already says "Update slice file frontmatter: `status: X`", extend the
  instruction to read "Update slice file frontmatter: `status: X` and `status_updated_at:
  {current ISO 8601 timestamp with timezone offset}`".

**Escalation triggers:**
- If `defaults/` and `.claude/commands/` plan-project files have diverged beyond the version
  field (content differs in Phase 5/6/7 sections): stop and report the diff. Do not attempt
  to reconcile silently.
- If `slice.md` already contains a `status_updated_at` field (someone else added it): stop
  and check whether it matches the format required here before proceeding.

---

## 4. Done definition

These are independently verifiable without reading the implementation:

1. `grep "status_updated_at" .orchestration/support/slice.md` — returns a match showing
   `status_updated_at: {ISO 8601 with timezone offset}` in the frontmatter template block.

2. `grep "status_updated_at" defaults/commands/plan-project.md` — returns matches in
   Phase 6 ("After writing") and Phase 7 ("After creating all task files") sections.

3. `grep "status_updated_at" .claude/commands/plan-project.md` — same result as (2).

4. `grep "^version:" defaults/commands/plan-project.md` → `version: 2.2.1`

5. `grep "^version:" .claude/commands/plan-project.md` → `version: 2.2.1`

6. `diff <(grep -A2 "version:" defaults/commands/plan-project.md) <(grep -A2 "version:" .claude/commands/plan-project.md)` — no diff in the relevant Phase 5/6/7 sections (content is identical).

**Test vector — slice file frontmatter after Phase 5:**
```
---
type: slice
slice: 01
order: 1
project: some-feature
design: .orchestration/projects/.../01-design/design-01.md
status: draft
status_updated_at: 2026-04-17T10:30:00-07:00
---
```
The `status_updated_at` value will differ (it's the real timestamp at write time) — verify
the field is present and is a valid ISO 8601 datetime with timezone offset.

---

## 5. Breakdown

| # | Step | Deliverable | Done signal |
|---|------|-------------|-------------|
| 1 | Update `slice.md` frontmatter template to include `status_updated_at` field after `status: draft` | `.orchestration/support/slice.md` updated | `grep "status_updated_at" .orchestration/support/slice.md` returns a match in the frontmatter block |
| 2 | Update `defaults/commands/plan-project.md` Phase 6 "After writing" — extend slice frontmatter update to also write `status_updated_at` | `defaults/commands/plan-project.md` Phase 6 updated | `grep "status_updated_at" defaults/commands/plan-project.md` returns match in Phase 6 section |
| 3 | Update `defaults/commands/plan-project.md` Phase 7 "After creating all task files" — extend slice frontmatter update to also write `status_updated_at` | `defaults/commands/plan-project.md` Phase 7 updated | `grep "status_updated_at" defaults/commands/plan-project.md` returns match in Phase 7 section |
| 4 | Bump version in `defaults/commands/plan-project.md` from `2.2.0` to `2.2.1` | Version bumped | `grep "^version:" defaults/commands/plan-project.md` → `version: 2.2.1` |
| 5 | Sync all changes to `.claude/commands/plan-project.md` identically (steps 2–4) | `.claude/commands/plan-project.md` matches `defaults/` | `diff` of Phase 6, Phase 7, and version sections shows no difference |
