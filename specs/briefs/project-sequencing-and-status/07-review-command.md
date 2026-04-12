---
type: brief
slice: 07
project: project-sequencing-and-status
design: specs/design/project-sequencing-and-status.md
slice_doc: specs/slices/project-sequencing-and-status/07-review-command.md
status: ready
date: 2026-04-12
---

# Delegation brief — Slice 07: `/review` command

## Intent

Create `defaults/commands/review.md`. This command closes the signoff loop: it runs on a project in `signoff_review` and either approves (merges the worktree branch to main, archives the project) or captures feedback (adds new slice files to the backlog and routes back to `/design`).

`/review` is the only place commits happen for the execution pipeline. All implementation changes, task status updates, and the QA report have been sitting uncommitted since `/implement` ran — the reviewer sees the full diff, then `/review` commits it all as one coherent unit.

## Observable outcomes

**Approve path:**
```
Given a project is in stage: signoff_review
When the user runs /review and approves
Then the uncommitted diff (implementation + task files + QA report) is committed and pushed
And the worktree branch is merged to main
And git worktree remove is run on the worktree directory
And the project folder is moved to .orchestration/projects/done/YYYY-MM/{id}/
And status.md stage is set to: done
```

**Feedback path:**
```
Given a project is in stage: signoff_review
When the user runs /review and provides feedback
Then the feedback is written as one or more new slice files in 02-slices/ with status: draft
And status.md stage is set to: feedback_pending
And output: "feedback recorded — run /design to spec the next slice"
And no commit happens (user approves the feedback slices first via /design)
```

**Merge conflict on approve:**
```
Given a project is approved
When the branch merge to main fails with a conflict
Then the project stays at signoff_review
And the worktree is preserved (not removed)
And output includes instructions to resolve manually then re-run /review
```

**Wrong command at signoff_review:**
```
Given a project is in signoff_review
When any command other than /review is run
Then output: "project '{id}' is awaiting signoff — run /review to approve or provide feedback"
```

**feedback_pending, user tries /implement:**
```
Given a project is in feedback_pending
When the user runs /implement
Then output: "project '{id}' has unprocessed feedback — run /design to spec the next slice"
```

## Constraints

**Must:**
- Commit the full uncommitted execution diff on approve (implementation files + task files + QA report + slice status + status.md)
- Commit message: `"Slice {NN} complete — {project_id}"`
- Push after commit; report failure clearly but don't block archive
- Remove worktree only after successful merge (`git worktree remove`)
- Archive: move `.orchestration/projects/{id}/` to `.orchestration/projects/done/YYYY-MM/{id}/`
- Check for uncommitted changes before `git worktree remove` — if found, warn and stop
- On feedback: write new slice files with correct frontmatter (`status: draft`, `order` field, `follow_up_of` if applicable)

**Must not:**
- Commit anything during the feedback path (feedback slices are reviewed via /design first)
- Remove the worktree until merge succeeds
- Overwrite an existing archive target (fail with instructions if target exists)

**Preferences:**
- On approve: show a brief summary before asking for confirmation — QA result, slice title, number of files changed
- Follow-up slice numbering: derive from the highest existing order value in 02-slices/ (e.g. if 05 is last, first follow-up is 05.1)

**Escalation triggers:**
- Archive target already exists: stop, report, ask how to proceed
- `git worktree remove` fails for a reason other than uncommitted changes: stop and report

## Done definition

1. `/review` on a `signoff_review` project presents the summary and asks approve or feedback
2. Approve path commits, pushes, merges, removes worktree, archives — in that order
3. Feedback path writes slice files with correct frontmatter, sets `feedback_pending`, no commit
4. Merge conflict leaves project at `signoff_review` with worktree intact and instructions
5. All wrong-command states produce correct error messages pointing to `/review`

## Breakdown

| # | Step | Deliverable | Done signal |
|---|------|-------------|-------------|
| 1 | Write review.md Phase 0: detect state, wrong-command routing | Phase 0 with routing table covering signoff_review (correct) and all other stages (wrong) | All wrong-command cases produce correct output |
| 2 | Write approve path (Phase 1) | Commit → push → merge → worktree remove → archive → status done | approve path executes in correct order; merge conflict stays at signoff_review |
| 3 | Write feedback path (Phase 2) | New slice files written, status set to feedback_pending, no commit | Feedback files have correct frontmatter; /design unblocks |
| 4 | Write behavior rules | Rules covering commit timing, worktree safety check, archive collision | Rules enforce constraints above |
