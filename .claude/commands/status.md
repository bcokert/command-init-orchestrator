---
version: 3.4.0
description: |
  Reads project and slice state from .orchestration/projects/. With a project ID arg: single-project detail view. Without: grouped view — one section per active project, with every slice listed in its current state. Read-only — never modifies files.
allowed-tools:
  - Read
  - Glob
  - Bash
  - AskUserQuestion
---

# Status — Project summary

Your job is to read project status and display it clearly. Never modify any file.

---

## Phase 0 — Detect mode

If a project ID was passed as argument: proceed to Phase 1 (single-project detail view).

If no argument: proceed to Phase 2 (multi-project scan).

---

## Phase 1 — Single-project detail view

1. Check `.orchestration/projects/{id}/` exists.
   - If not: > "project {id} not found — run `/status` with no args to list projects". Stop.
   - If path is under `done/`: > "project {id} is archived under .orchestration/projects/done/". Stop.

2. Read slice files at `.orchestration/projects/{id}/02-slices/*.md`.

3. Read design doc at `.orchestration/projects/{id}/01-design/design-01.md` for the `date:` field (start date). If absent: use `—`.

4. Display: project header line followed by slice rows, using the same format as Phase 3.

```
**{id}** · {MMM D} · {slice_counts} · {task_counts}
  {slice rows — same format as Phase 3}
```

If no slice files exist: show header only with `—` for all counts.

---

## Phase 2 — Multi-project scan

1. Glob `.orchestration/projects/*` (no trailing slash). Filter results to directories only — plain files in `projects/` are not projects. Exclude any path under `done/` subdirectory.

2. Collect all active projects. For each directory:
   - If no `01-design/` and no `02-slices/` subdirectory exists: exclude entirely. Do not show.
   - **Design-phase project** (has `01-design/design-01.md` but no `02-slices/` directory):
     - Read `status:` from `design-01.md` frontmatter. If absent or unreadable: use `in_progress`.
     - Read `date:` from `design-01.md` for sort order. If absent: sort last.
     - These projects render a single-line entry in Phase 3 (see design-phase row format below). Skip slice/task collection.
   - **Slice-based project** (has `02-slices/` directory):
     - **Start date:** `date:` field from `.orchestration/projects/{id}/01-design/design-01.md`. If design doc absent or `date:` unparseable: `—`.
     - **Slice data:** Glob `.orchestration/projects/{id}/02-slices/*.md`. For each file, read:
       - `slice:` frontmatter field (slice number)
       - `status:` frontmatter field
       - `status_updated_at:` frontmatter field (may be absent)
       - Title from the first `# Slice {NN} — ...` heading line
       - If frontmatter is unreadable: record as unknown-status slice, warn once per project
     - **Slice counts:** total = count of slice files; done = count where `status: done`
     - **Task counts:** Glob `.orchestration/projects/{id}/04-tasks/slice-*/**.md`. Total = count of all .md files. Done = count where `status: done` in frontmatter. If directory absent: 0/0. If a task file is unreadable or lacks `status`: exclude from done count, warn once per slice.
     - **Most recently updated timestamp:** latest `status_updated_at` across all slice files. If no slice timestamps exist: fall back to design doc `date:` field. Used for sort order.

3. Sort projects: most recently updated first (highest `most recently updated timestamp`). Design-phase projects use their `date:` field as the timestamp. Projects with no parseable timestamps: sort last. Secondary sort: project ID descending.

4. Proceed to Phase 3.

---

## Phase 3 — Grouped project view

If no active projects found:
> "no active projects — run `/plan-project` to start one"
Stop.

Otherwise, for each project (sorted most recently updated first):

**Design-phase project** (no `02-slices/` directory):
```
**{id}** · {MMM D} · design: {design_status}  →  **`/plan-project`**
```
- Date from `date:` field in design doc. Omit year if current year. Use `—` if absent.
- `design_status`: `status:` field from design doc frontmatter. If absent: `in_progress`.

**Project header line** (slice-based project):
```
**{id}** · {MMM D} · {slice_counts} · {task_counts}
```
- Date = start date from design doc `date:` field. Omit year if current year. Use `—` if absent.
- If no slice files readable at all: show header only.

**Count format** for `{slice_counts}` and `{task_counts}`:

Render `✅{X} 🤖{Y} 👤{Z} of {T} slices` (or `tasks`). Omit any emoji–number pair where the count is 0. If all counts are 0, show `0 slices`.

Bucket definitions:

| Emoji | Slice states |
|-------|-------------|
| ✅ | `done` |
| 🤖 | `implementing`, `qa_in_progress` |
| 👤 | `draft`, `review`, `signoff_review` |
| ⏳ | `speccing`, `breakdown`, `tasks_ready` |

Task states: ✅ = `done`, 🤖 = `in_progress`, ⏳ = `todo`. Tasks never appear in 👤.

Format: `✅{X} 🤖{Y} 👤{Z} ⏳{W} of {T} slices`. Omit any pair where the count is 0.

**Slice rows** (sorted by slice number ascending, 2-space indent, one line each):

Done slice:
```
  {NN}  {title}  ✅  {MMM D HH:MM}
```

Active slice:
```
  {NN}  {title}  {emoji} `{prev}→{curr}`  {MMM D HH:MM}  →  **`/{cmd}`**
```

Rules:
- Strip `Slice NN — ` prefix from title. Truncate at 52 chars, append `…` if needed.
- Date from `status_updated_at`: `MMM D HH:MM` (local time, no timezone, no year if current year). If absent: `—`.
- State abbreviations:

  | Full state | Abbrev | Emoji prefix |
  |------------|--------|--------------|
  | `draft` | `draft` | 👤 |
  | `review` | `review` | 👤 |
  | `speccing` | `speccing` | *(none)* |
  | `breakdown` | `bkdn` | *(none)* |
  | `tasks_ready` | `ready` | *(none)* |
  | `implementing` | `impl` | 🤖 |
  | `qa_in_progress` | `qa` | 🤖 |
  | `signoff_review` | `signoff` | 👤 |

  Legacy aliases: `reviewed` is treated identically to `review` (same bucket, abbrev, emoji, routing). `specced` is treated as ⏳ routing to `/plan-project`.

- `{prev}→{curr}`: no spaces around `→`. Derive previous from the state machine sequence above. If no previous (state is `draft`): show just `{curr}` with no arrow.
- Next action command in bold code: **`/{cmd}`**

  | State | Command |
  |-------|---------|
  | `draft` | `/plan-project` |
  | `review` | `/plan-project` |
  | `speccing` | `/plan-project` |
  | `breakdown` | `/plan-project` |
  | `tasks_ready` | `/implement` |
  | `implementing` | `/implement` |
  | `qa_in_progress` | `/implement` |
  | `signoff_review` | `/review` |

- If `status` missing or unrecognised: `  {NN}  {title}  ⚠ unknown state`

Projects with no slice files: show header only.

Blank line between projects.

---

## Behavior rules

- Read-only. Never write, edit, or delete any file under any circumstance.
- Partial reads are better than crashes. Show what's readable, warn on gaps.
- Done projects are excluded entirely (they live under `done/` subdirectory and are excluded by the glob).
