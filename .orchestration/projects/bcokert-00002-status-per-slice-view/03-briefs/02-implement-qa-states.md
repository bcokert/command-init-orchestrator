---
type: brief
slice: 02
project: bcokert-00002-status-per-slice-view
spec: .orchestration/projects/bcokert-00002-status-per-slice-view/02-slices/02-implement-qa-states.md
date: 2026-04-17
---

# Delegation brief — slice 02: implement qa states + timestamps

**Type:** Task (AI agent)
**Date:** 2026-04-17

---

## 1. Intent

Slice 03 needs to display the current state and entry timestamp for every active slice.
The status command will read `status` and `status_updated_at` from each slice file.
Slice 01 adds those writes to plan-project. This slice adds them to implement and review —
the commands that own the four states plan-project doesn't touch:
`implementing`, `qa_in_progress`, `signoff_review`, and `done`.

Today implement writes `status: signoff_review` on QA pass with no timestamp, and writes
nothing for `implementing` or `qa_in_progress`. Review writes nothing to slice files at all.

After this slice: every state transition in the full slice state machine writes
`status: X` + `status_updated_at` to the slice file at the moment it happens.

**Files to change:**
- `defaults/commands/implement.md` and `.claude/commands/implement.md` — 3 insertion points
- `defaults/commands/review.md` and `.claude/commands/review.md` — 1 insertion point
- Both pairs must be updated identically.

---

## 2. Observable outcomes

**Implementing state**
```
Given   implement Phase 3 step 1 writes stage: implementing to status.md
When    task execution starts (first time, not on resume)
Then    the slice file at {worktree_path}/.orchestration/projects/{id}/02-slices/ has
        status: implementing
        status_updated_at: {current ISO 8601 timestamp with timezone offset}
```

**QA in progress state**
```
Given   all tasks are done and Phase 4 is entered
When    QA begins (before qa.md is invoked)
Then    the slice file has:
        status: qa_in_progress
        status_updated_at: {current timestamp}
```

**Signoff review state (existing write, add timestamp)**
```
Given   QA passes
When    implement sets status: signoff_review on the slice file
Then    the slice file has:
        status: signoff_review
        status_updated_at: {current timestamp}
        (previously: status: signoff_review written, no timestamp)
```

**Done state**
```
Given   a project is in signoff_review and /review runs Phase 1 approve path
When    the approve steps run (before git add in the worktree commit)
Then    the slice file has:
        status: done
        status_updated_at: {current timestamp}
```

**Resume after crash — qa_in_progress**
```
Given   implement resumes and the slice file already shows status: qa_in_progress
When    Phase 4 is re-entered
Then    implement does NOT re-write status: qa_in_progress — it reads the slice file first
        and only writes if the current status is not already qa_in_progress or later
```

**Slice file not found**
```
Given   implement tries to write a slice state but can't locate the slice file
When    the Glob/path resolution returns no match
Then    implement logs "warning: could not find slice file for slice {NN} — skipping status write"
        and continues execution without crashing
```

---

## 3. Constraints

**Must:**
- Write slice status using the worktree path: `{worktree_path}/.orchestration/projects/{id}/02-slices/`.
  `worktree_path` is in `status.md`. The Glob pattern to find the slice file:
  `{worktree_path}/.orchestration/projects/{id}/02-slices/[0-9][0-9]-*.md` filtered to
  where `slice:` frontmatter equals the current slice number.
- `status_updated_at` format: ISO 8601 with timezone offset (e.g. `2026-04-17T10:30:00-07:00`).
- Overwrite `status_updated_at` on every status change — including on a crash-resume re-entry
  to a state that wasn't already set.
- `status: done` must be written to the slice file **before** `git add .` in review.md Phase 1
  step 1, so that it's included in the approve commit.
- Bump `implement.md` version: `2.0.0 → 2.1.0` (minor — new behaviour).
- Bump `review.md` version: `1.0.0 → 1.1.0` (minor — new behaviour).
- Both `.claude/commands/` and `defaults/commands/` files must be updated identically.

**Must not:**
- Write to slice files in the main worktree. All writes go to the worktree path so they're
  included in the uncommitted diff that review.md commits.
- Crash if the slice file isn't found — warn and continue.
- Re-write `qa_in_progress` if the slice is already at that state or later on resume.
- Touch any other command files (plan-project, status, qa).

**Preferences:**
- Add the slice file write immediately before or after the status.md write at each transition
  point — keeps the two writes co-located, easy to read.
- Use a small helper note in the text (comment or inline prose) to describe where to find
  the slice file if the Glob pattern isn't self-evident.

**Escalation triggers:**
- If `defaults/` and `.claude/commands/` implement or review files have diverged beyond
  the version field: stop and report the diff before making any edits.
- If review.md Phase 1 approve path structure has changed significantly (step numbers differ
  from what's described here): stop and re-read before placing the `status: done` write.

---

## 4. Done definition

Verify without reading the implementation:

1. `grep "qa_in_progress" defaults/commands/implement.md` — returns a match in Phase 4
2. `grep "status_updated_at" defaults/commands/implement.md` — returns matches in Phase 3
   and Phase 4 (3 total: implementing, qa_in_progress, signoff_review)
3. `grep "status: done" defaults/commands/review.md` — returns a match in Phase 1 approve path
4. `grep "status_updated_at" defaults/commands/review.md` — returns a match near `status: done`
5. `grep "^version:" defaults/commands/implement.md` → `version: 2.1.0`
6. `grep "^version:" defaults/commands/review.md` → `version: 1.1.0`
7. `.claude/commands/` copies match defaults on version + Phase 3/4 content:
   `diff defaults/commands/implement.md .claude/commands/implement.md` — only metadata
   differences acceptable, not content.

**Test vectors — implement.md Phase 3 (implementing write):**
The text at the Phase 3 step 1 location should read approximately:
> Write `stage: implementing` to `status.md`... Also write `status: implementing` and
> `status_updated_at: {current ISO 8601 timestamp}` to the slice file at
> `{worktree_path}/.orchestration/projects/{id}/02-slices/`.

**Test vectors — review.md Phase 1 (done write):**
The text before "git add ." in Phase 1 approve path should read approximately:
> Write `status: done` and `status_updated_at: {current ISO 8601 timestamp}` to the slice
> file in the worktree at `{worktree_path}/.orchestration/projects/{id}/02-slices/`.

---

## 5. Breakdown

| # | Step | Deliverable | Done signal |
|---|------|-------------|-------------|
| 1 | Update `defaults/commands/implement.md` Phase 3 step 1 — add slice file write for `status: implementing` + `status_updated_at` alongside existing status.md write | implement.md Phase 3 updated | `grep "qa_in_progress\|implementing" defaults/commands/implement.md` returns Phase 3 match |
| 2 | Update `defaults/commands/implement.md` Phase 4 — add `status: qa_in_progress` + `status_updated_at` write before QA runs; add `status_updated_at` to existing `status: signoff_review` write; add resume guard for qa_in_progress | implement.md Phase 4 updated | `grep "status_updated_at" defaults/commands/implement.md` returns 3 matches |
| 3 | Bump `defaults/commands/implement.md` version `2.0.0 → 2.1.0` | Version bumped | `grep "^version:" defaults/commands/implement.md` → `version: 2.1.0` |
| 4 | Update `defaults/commands/review.md` Phase 1 approve path — add `status: done` + `status_updated_at` write to slice file before the worktree `git add .` step | review.md Phase 1 updated | `grep "status: done\|status_updated_at" defaults/commands/review.md` returns match in Phase 1 |
| 5 | Bump `defaults/commands/review.md` version `1.0.0 → 1.1.0` | Version bumped | `grep "^version:" defaults/commands/review.md` → `version: 1.1.0` |
| 6 | Sync all changes to `.claude/commands/implement.md` and `.claude/commands/review.md` identically | Both .claude/ copies updated | diff of content sections shows no difference vs defaults/ |
