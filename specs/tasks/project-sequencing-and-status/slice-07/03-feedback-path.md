---
spec: specs/briefs/project-sequencing-and-status/07-review-command.md
slice: 07
step: 3
title: Write feedback path (Phase 2)
status: todo
depends_on: [02-approve-path.md]
agent_type: architect
assigned_at: null
completed_at: null
---

## Work

Write Phase 2 of `defaults/commands/review.md` — the feedback path.

Steps:
1. Ask the user to describe their feedback. Capture it (one or more distinct issues or improvements).
2. For each piece of feedback, write a new slice file at `.orchestration/projects/{id}/02-slices/{next-order}-{slug}.md`.
   - Derive `next-order`: find the highest `order` value among existing slice files, increment by 1 (or 0.1 for a follow-up to a specific slice if the user indicates that). Use integer for a clean next slice, dot notation only if it's clearly a follow-up to a specific slice.
   - Frontmatter: `type: slice`, `slice: {order}`, `order: {order}`, `project: {id}`, `design: {path}`, `status: draft`. Add `follow_up_of: {NN}` if the feedback is specifically about a prior slice.
   - Content: Goal derived from feedback. Happy path and edge cases left as rough draft bullets.
3. Update `status.md`: `stage: feedback_pending`, append transition.
4. Output:
   ```
   Feedback recorded — {N} new slice(s) added to backlog.

   Run /design to review and spec the next slice.
   ```
5. No commit. The feedback slices go through the normal review gate in `/design` before anything is committed.

## Done signal

Feedback slice files have correct frontmatter and are written to `02-slices/`. `status.md` is set to `feedback_pending`. No commit happens. `/design` unblocks the project.
