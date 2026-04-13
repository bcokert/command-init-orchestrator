---
version: 1.0.0
description: |
  Closes the signoff loop for a project in signoff_review. Approve path: commits the full execution diff, merges the worktree branch to main, removes the worktree, archives the project. Feedback path: writes new slice files to the backlog, sets feedback_pending.
allowed-tools:
  - Read
  - Write
  - Bash
  - Glob
  - Grep
  - AskUserQuestion
---

# Review — Signoff and close

Your job is to close out a project at `signoff_review`: either approve it (commit, merge, archive) or capture feedback (new slice files, back to `/design`).

---

## Phase 0 — Detect state and route

### Step 1 — Identify the project

If a project ID was passed as argument: read `.orchestration/projects/{id}/status.md`, validate `stage: signoff_review`.

If no argument:
1. Scan `.orchestration/projects/*/status.md` for `stage: signoff_review`.
2. If none: "No projects awaiting signoff. Run /implement to execute tasks, or /design to start a new project." Stop.
3. If one: use it.
4. If multiple: list them and prompt selection.

### Step 2 — Wrong-command routing

| Stage | Error message |
|-------|---------------|
| `design_in_progress`, `design_review`, `slicing_in_progress`, `slicing_review`, `spec_in_progress`, `spec_review`, `breakdown_in_progress`, `tasks_ready` | "Project '{id}' is in {stage} — run `/design` to continue." |
| `implementing` | "Project '{id}' is still implementing in worktree {worktree_path} — run `/implement` to resume, or wait for QA to complete." |
| `feedback_pending` + `/implement` attempt | "Project '{id}' has unprocessed feedback — run `/design` to spec the next slice." |
| `done` | "Project '{id}' is already done." |

---

## Phase 1 — Approve path

Present a summary before asking:
- Slice title and number
- QA result (from the QA report in `05-qa/`)
- Number of uncommitted files changed (run `git status` in the worktree)

Ask: "Approve and close this slice, or provide feedback?"

**On approval:**

1. **Commit** — from the worktree directory:
   ```bash
   git add .
   git commit -m "Slice {NN} complete — {project_id}"
   ```

2. **Push:**
   ```bash
   git push origin project/{id}
   ```
   If push fails: report clearly and continue. Don't block the rest.

3. **Merge** — from the main worktree:
   ```bash
   git merge project/{id}
   ```
   If merge fails (conflict): leave project at `signoff_review`, preserve the worktree, output:
   ```
   Merge conflict — resolve manually in the worktree at {worktree_path},
   then re-run /review to complete the signoff.
   ```
   Stop.

4. **Remove worktree** — check for uncommitted changes first:
   ```bash
   git status --porcelain
   ```
   If dirty: "Worktree has uncommitted changes at {worktree_path}. These should have been committed as part of the approve step — check what's uncommitted with `git status` in the worktree, then re-run /review." Stop.
   If clean:
   ```bash
   git worktree remove .orchestration/worktrees/{id}
   ```

5. **Archive** — check target doesn't exist:
   ```bash
   # target: .orchestration/projects/done/YYYY-MM/{id}/
   ```
   If target exists: "Archive target already exists at {path} — resolve manually before re-running /review." Stop.
   Otherwise:
   ```bash
   mkdir -p .orchestration/projects/done/YYYY-MM/
   mv .orchestration/projects/{id}/ .orchestration/projects/done/YYYY-MM/{id}/
   ```

6. **Update status.md** (now at archive path):
   ```yaml
   stage: done
   transitions:
     - stage: done
       timestamp: {ISO 8601}
       note: slice {NN} approved — worktree removed, archived to done/YYYY-MM/{id}
   ```

7. **Push final state:**
   ```bash
   git add .orchestration/projects/done/YYYY-MM/{id}/status.md
   git commit -m "Slice {NN} done — {project_id}"
   git push
   ```

8. Output:
   ```
   Slice {NN} done — {project_id}

   Archived to .orchestration/projects/done/YYYY-MM/{id}/
   Branch project/{id} merged to main.
   ```

---

## Phase 2 — Feedback path

Ask the user to describe their feedback. Capture all distinct issues or improvements before writing anything.

For each piece of feedback:

1. Derive a slug (kebab-case, max 5 words).
2. Determine order: find the highest `order` value among slice files in `.orchestration/projects/{id}/02-slices/`. Add 1 for a clean new slice (e.g. `6` → `7`), or use dot notation (`6.1`) if the feedback is specifically a follow-up to a named slice.
3. Write `.orchestration/projects/{id}/02-slices/{order}-{slug}.md`:
   ```markdown
   ---
   type: slice
   slice: {order}
   order: {order}
   project: {id}
   design: {path to design doc}
   status: draft
   follow_up_of: {NN}   # only if this is a follow-up to a specific slice
   ---

   # Slice {order} — {title}

   **Goal:** {derived from feedback — 1-2 sentences}

   ## Happy path

   - {rough bullet from feedback}

   ## Edge cases

   - {rough bullet if applicable}
   ```

4. Update `status.md`:
   ```yaml
   stage: feedback_pending
   next_action: run /design to review and spec the next slice
   transitions:
     - stage: feedback_pending
       timestamp: {ISO 8601}
       note: {N} feedback slice(s) added
   ```

5. Output:
   ```
   Feedback recorded — {N} new slice(s) added to backlog.

   Run /design to review and spec the next slice.
   ```

No commit. Feedback slices are reviewed via `/design` before anything is committed.

---

## Behavior rules

- Only run on `signoff_review` projects. Any other stage: route correctly and stop.
- The approve commit includes everything uncommitted in the worktree — implementation files, task status files, QA report, slice status, status.md. This is the one commit for the entire execution pipeline. Do not cherry-pick.
- Never remove the worktree until the merge succeeds. A failed merge leaves the project at `signoff_review` with the worktree intact.
- Check for uncommitted changes before `git worktree remove`. If dirty, stop and warn — do not force-remove.
- Never overwrite an existing archive target. Fail with clear instructions.
- Feedback path: no commit. The slice files are `draft` and require human review via `/design` before any commit happens.
- Always re-read `status.md` and slice files from disk. Never use session-cached state.
