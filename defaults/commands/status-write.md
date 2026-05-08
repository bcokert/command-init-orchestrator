---
version: 1.0.0
description: |
  Shared helper for writing a slice's status frontmatter. Frontmatter only — no logging side effects. Glob by `slice:` field; warn-and-continue if the file is missing.
allowed-tools:
  - Read
  - Edit
  - Glob
---

# Status-write helper

Single helper for the most-repeated logic in the orchestrator: writing `status:` and `status_updated_at:` to a slice file. Replaces ~8 inline restatements across `/plan-project`, `/implement`, `/review`, and `qa.md`.

---

## Inputs

- `project_id` — e.g. `bcokert-00007-batch-slice-flow`
- `slice_NN` — slice number to update (matches `slice:` frontmatter)
- `new_status` — one of the values in the slice schema (`draft`, `review`, `speccing`, `breakdown`, `tasks_ready`, `implementing`, `qa_in_progress`, `signoff_review`, `done`)

---

## Action

1. Glob `.orchestration/projects/{project_id}/02-slices/*.md`.
2. Read each file's frontmatter; pick the one where `slice:` matches `slice_NN`.
3. If not found: log "warning: could not find slice file for slice {slice_NN} in {project_id} — skipping status write" and return.
4. Edit the frontmatter:
   - Set `status:` to `new_status`.
   - Set `status_updated_at:` to a fresh ISO 8601 timestamp with timezone offset (e.g. `2026-05-06T14:33:00-07:00`).
5. Done.

---

## Constraints

- **Frontmatter only.** Do not append to `iterations.md`, do not write to `decisions.md`, do not commit. Logging the iteration is `planIteration`'s job, not this helper's.
- **Single-write atomic.** Both `status:` and `status_updated_at:` change in the same edit. Don't write one without the other.
- **No body changes.** Only the YAML frontmatter is touched.

---

## Failure mode

- Slice file not found: log warning, return cleanly. The caller continues.
- Edit fails (filesystem error, permissions): surface to the user, stop. The caller decides whether to retry or halt.

---

## Behavior rules

- Caller responsibility: ensure `new_status` is a legal transition for the current state per `.root-context/state-diagram.md`. This helper does not validate transitions.
- Idempotent on the same input: writing the same status with a fresh timestamp is fine and may happen during crash recovery.
