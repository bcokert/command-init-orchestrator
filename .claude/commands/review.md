---
version: 1.6.0
description: |
  Closes signoff loop for a project. One run = one project. Iterates every signoff_review slice; auto-stages on approve; archives only when all slices are done with no feedback drafts. Feedback creates dot-notation drafts and continues the batch.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - AskUserQuestion
---

# Review — signoff and close

Close out a project at `signoff_review`: approve (commit, archive on full completion) or capture feedback (new draft slices, batch continues). One run = one project.

State, schemas, principles, vocabulary, and crash recovery rules live in `.root-context/state-diagram.md`. Helpers used: `support/next-actions.md` (scope), `support/status-write.md` (frontmatter writes).

---

## Phase 0 — Resolve scope

Run `support/next-actions.md`. Filter to slices at `signoff_review`. With a project ID arg: restrict to that project. Without an arg: if one project has signoff slices, auto-pick. If multiple, prompt at project level (not slice level): "Which project to review? {list}".

If none: "No slices awaiting signoff. Run /implement to execute tasks, or /plan-project to start a new project." Stop.

The chosen project's signoff slices, in slice-number order, are the batch.

---

## Phase 1 — Iterate the batch

For each slice in the batch:

1. Surface a summary: title + number, QA result (from `05-qa/slice-{NN}-qa-report.md`), uncommitted-file count (`git status --porcelain | wc -l`).
2. Ask: "Approve, feedback, or other?"
3. Classify the response:

| Signal | Action |
|---|---|
| Approval | Approve path (below) |
| Feedback | Feedback path (below) |
| Ambiguous | Re-ask once. Still ambiguous → default to feedback (recoverable; accidental approval would commit). |

### Approve path

1. `status-write.md` → `status: done`.
2. Stage:
   - `git add .orchestration/projects/{id}/`.
   - Auto-stage tracked-modified files outside `.orchestration/{id}/` (`M` / `MM` in `git status --porcelain`).
   - Auto-stage untracked files outside `.orchestration/` (`??` in `git status --porcelain`).
3. Show one-line staging summary: `Staging: {N} orchestration, {M} source, {K} untracked`. User can abort the commit if the summary looks wrong.
4. `git commit -m "Slice {NN} complete — {project_id}"`.
5. Continue to the next slice in the batch.

### Feedback path

For each distinct issue in the response:

1. Slug from feedback (kebab-case, max 5 words).
2. Order: `{NN}.{n}` dot-notation (n = next available index after the slice number).
3. Write `02-slices/{order}-{slug}.md` per the slice schema in `.root-context/state-diagram.md`. Set `status: draft` and `follow_up_of: {NN}`.

No commit on the feedback path. Continue to the next slice in the batch.

---

## Phase 2 — End-of-batch summary

After the loop:

- Count slices in the project that ended at `done` and slices with `follow_up_of:` drafts created during this run.
- Archive eligibility: all original slices `done` AND zero feedback-drafts created this run.

**On archive:**
1. Target: `.orchestration/projects/done/YYYY-MM/{id}/`. If exists: stop with "Archive target already exists at {path} — resolve manually."
2. `mkdir -p .orchestration/projects/done/YYYY-MM/`
3. `mv .orchestration/projects/{id}/ .orchestration/projects/done/YYYY-MM/{id}/`
4. `git add -A && git commit -m "Archive — {project_id}"`
5. Output: `Archived to .orchestration/projects/done/YYYY-MM/{id}/`. Stop.

**On not-archive:**
```
Approved {N}, feedback on {M}.
{If M > 0: Run /plan-project to advance the {M} feedback slice(s).}
{If unfinished other-state slices: list them with their next command.}
※ Project {id} · review batch complete
```

---

## Behavior rules (review deltas)

Shared rules — re-read from disk on resume, skip-if-clean — live in `.root-context/state-diagram.md` Principles.

- One /review run = one project. Iterate every signoff slice in that project as a batch.
- The approve commit per slice bundles all its uncommitted work (orchestration + source). One commit per slice — not cherry-picked.
- Feedback path never commits. Drafts are reviewed via `/plan-project` later.
- Never overwrite an existing archive target. Stop with manual-resolve message.
- `follow_up_of:` is the canonical signal for feedback drafts. `/plan-project` Phase 0 picks them up.
