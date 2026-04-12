---
spec: specs/briefs/project-sequencing-and-status/02-slicing-step.md
slice: 02
step: 3
title: Wire Phase 5 completion — slicing_review, commit, push, gate
status: todo
depends_on: [02-slice-md-path-and-format.md]
agent_type: architect
assigned_at: null
completed_at: null
---

## Work

After all slice files are written, complete Phase 5 in `defaults/commands/design.md`:

1. Append to `status.md`:
   ```yaml
   stage: slicing_review
   next_action: review slice files and run /design to continue to spec
   transitions:
     - stage: slicing_review
       timestamp: {ISO 8601}
       note: {N} slices created
   ```
2. Commit: `git add .orchestration/projects/{id}/slices/ .orchestration/projects/{id}/status.md`
3. Commit message: `"Slicing complete — {project_id} ({N} slices)"`
4. Push. If push fails: report clearly, continue — status is committed locally.
5. Show slicing review gate:
   ```
   Slicing complete — {project_id}

   {N} slice files in .orchestration/projects/{id}/slices/

   Slice 01 is fully detailed — ready to spec. Slices 02+ are rough
   drafts; flesh them out when they become next.

   Edit slice files directly if anything needs changing.
   When ready, run /design to continue to spec for slice 01.
   ```

## Context

Read first:
- `specs/briefs/project-sequencing-and-status/02-slicing-step.md` — commit constraints and gate copy

## Done signal

`git show --stat HEAD` after slicing shows only slice files and `status.md`. Gate displayed with correct copy. Status shows `slicing_review` with correct transition timestamp.
