---
type: slice
slice: 06
order: 06
project: batch-slice-flow
design: .orchestration/projects/bcokert-00007-batch-slice-flow/01-design/design-01.md
status: tasks_ready
status_updated_at: 2026-05-06T20:03:31-07:00
---

# Slice 06 — /review batch rewrite (one project, all signoff slices)

**Goal:** `/review` becomes one-project-at-a-time, batches through every signoff slice in that project without per-slice prompts, auto-stages untracked files with a summary line, archives only when all slices are done. Mixed responses handled per-slice. ~54% shrinkage.

## Happy path

- Phase 0 collapses to a `next-actions.md` call filtered to `signoff_review`. With a project-ID arg → that project. Without → if one project has signoff slices, auto-pick; if multiple, prompt at project level (not slice level).
- Iterate the chosen project's signoff slices in slice-number order. Each iteration: surface QA result + uncommitted-file count, ask approve / feedback / ambiguous.
- Approve path: write `status: done` (via `status-write.md`); `git add .orchestration/projects/{id}/`; auto-stage tracked-modified and untracked files outside `.orchestration/` with one summary line ("Staging: N orchestration, M source, K untracked"); `git commit "Slice {NN} complete — {project_id}"`. Continue to next signoff slice.
- Feedback path: write draft slices with `follow_up_of: {NN}` and dot-notation order. Continue to next signoff slice — no pause for `/plan-project` handoff.
- Ambiguous: re-ask once on the same slice; if still ambiguous, default to feedback.
- After the batch: archive eligibility check runs once. Archive only when all original slices `done` AND no draft slices created from feedback during this run. Otherwise: print "Approved {N}, feedback on {M}; run /plan-project to advance feedback".
- Per-untracked-file `yes/no` prompts deleted.
- "Behavior rules" trimmed to review-specific deltas.
- `defaults/commands/review.md` ≤ ~78 lines (down from 171). Version bumped.

## Edge cases

- Multiple projects with signoff slices: project-level prompt only (one /review run = one project per design).
- Surprising untracked file appears in summary (e.g. an unrelated edit): user can abort the commit before it runs.
- Crash mid-batch: on resume, /review re-reads slice statuses, picks up the first remaining `signoff_review` slice.
- Single-slice batch: same code path, no special-casing.
- Archive target collision: stop with manual-resolve message; do not overwrite.
