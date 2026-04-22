---
version: 1.4.1
description: |
  Closes the signoff loop for a slice in signoff_review. Approve path: commits the full execution diff from main, archives the project if all slices are done. Feedback path: writes new draft slice files to the backlog for /plan-project to pick up.
allowed-tools:
  - Read
  - Write
  - Bash
  - Glob
  - Grep
  - AskUserQuestion
---

# Review — Signoff and close

Your job is to close out a project at `signoff_review`: either approve it (commit, archive) or capture feedback (new slice files, back to `/plan-project`).

---

## Phase 0 — Detect state and route

### Step 1 — Identify the slice

If a project ID was passed as argument:
1. Glob `.orchestration/projects/{id}/02-slices/*.md`. Read each file's frontmatter.
2. Find the slice with `status: signoff_review`.
3. If none found: "No slices awaiting signoff in {id}. Run /implement to continue." Stop.
4. If multiple found: list them and prompt selection.

If no argument:
1. Glob `.orchestration/projects/*/02-slices/*.md` (excluding `done/`). Read each file's frontmatter.
2. Filter to slices with `status: signoff_review`.
3. If none: "No slices awaiting signoff. Run /implement to execute tasks, or /plan-project to start a new project." Stop.
4. If one: use it. Extract `{id}` from the path.
5. If multiple: list all and prompt selection.

---

## Phase 1 — Approve path

Present a summary before asking:
- Slice title and number
- QA result (from the QA report in `05-qa/`)
- Number of uncommitted files changed (run `git status` from the project root)

Ask: "Approve and close this slice, or provide feedback?"

**On approval:**

1. **Write slice done state** — before committing, write `status: done` and `status_updated_at: {current ISO 8601 timestamp with timezone offset}` to the slice file at `.orchestration/projects/{id}/02-slices/` (Glob for the file where `slice:` frontmatter matches the current slice number). If the file can't be found: log a warning and continue.

2. **Commit** — from the project root:
   ```bash
   git add -A
   git commit -m "Slice {NN} complete — {project_id}"
   ```

3. **Archive eligibility check** — Glob all slice files at `.orchestration/projects/{id}/02-slices/*.md`. Read each file's `status` frontmatter field.
   - If any slice file cannot be read: log "warning: could not read {path} — treating as not-done" and count it as not-done.
   - Count slices where `status` is not `done`. Call this `remaining`.
   - If `remaining > 0`:
     ```
     Slice {NN} done — {remaining} slices remaining. Run /plan-project or /implement to continue.
     ※ Slice {NN} · done · approved → {remaining} slices remaining
     ```
     Stop. Do not archive.
   - If `remaining == 0`: proceed to archive.

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

6. **Commit final state:**
   ```bash
   git add -A
   git commit -m "Archive — {project_id}"
   ```

7. Output:
   ```
   Slice {NN} done — {project_id}

   Archived to .orchestration/projects/done/YYYY-MM/{id}/
   ※ Slice {NN} · done · slice {NN} approved → project complete
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

4. Output:
   ```
   Feedback recorded — {N} new slice(s) added to backlog.

   Run /plan-project to review and spec the next slice.
   ※ Slice {NN} · {N} feedback slice(s) added → run /plan-project to spec next 📄
   ```

No commit. Feedback slices are reviewed via `/plan-project` before anything is committed.

---

## Behavior rules

- Only run when a slice with `status: signoff_review` exists. If none found: report and stop per Phase 0.
- The approve commit includes everything uncommitted on main — implementation files, task status files, QA report, slice status. This is the one commit for the entire execution pipeline. Do not cherry-pick.
- Never overwrite an existing archive target. Fail with clear instructions.
- Feedback path: no commit. The slice files are `draft` and require human review via `/plan-project` before any commit happens.
- Always re-read slice files from disk. Never use session-cached state.
- Feedback detection: plan-project identifies pending feedback by finding draft slices with `follow_up_of:` set. No stored state needed.
