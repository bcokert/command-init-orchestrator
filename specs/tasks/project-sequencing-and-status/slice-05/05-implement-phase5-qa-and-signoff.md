---
spec: specs/briefs/project-sequencing-and-status/05-implement-v1-single-project.md
slice: 05
step: 5
title: Phase 5 — auto-QA and signoff_review advance
status: done
depends_on: [04-implement-phase4-task-execution.md]
agent_type: architect
assigned_at: null
completed_at: null
---

## Work

Add Phase 5 to `defaults/commands/implement.md`:

1. When all tasks are `done`, automatically proceed to QA — no user prompt.
2. Read and follow `defaults/commands/qa.md` in full for the current slice.
3. QA runs fix-and-retry (as defined in qa.md Phase 1.5) — don't duplicate that logic here, just invoke it.
4. On QA pass:
   - Slice file frontmatter: `status: signoff_review`
   - `status.md`:
     ```yaml
     stage: signoff_review
     next_action: run /review to approve or provide feedback
     transitions:
       - stage: signoff_review
         timestamp: {ISO 8601}
         note: QA passed
     ```
   - Output:
     ```
     QA passed — {project_id} slice {NN}

     Review the output. When ready, run /review to approve (marks done)
     or provide feedback (creates new slice in backlog).
     ```
   - Stop. No commit — that happens in /review.

## Context

Read first:
- `specs/briefs/project-sequencing-and-status/05-implement-v1-single-project.md`
- `defaults/commands/qa.md` — QA runs automatically, fix-and-retry before reporting

## Done signal

QA triggers without prompting after last task completes. Slice file shows `signoff_review`. `status.md` shows `signoff_review`. No commit made. User instructed to run /review.
