---
version: 3.5.0
description: |
  Reads project and slice state via the next-actions reader. With a project ID arg: single-project detail view. Without: grouped view — one section per active project, with every slice listed in its current state. Read-only.
allowed-tools:
  - Read
  - Glob
  - Bash
---

# Status — project summary

Display project status. Never modify any file.

State, schemas, vocabulary, and the canonical state list live in `.root-context/state-diagram.md`. Helpers used: `support/next-actions.md`.

---

## Phase 0 — Detect mode

If a project ID was passed as argument: Phase 1 (single-project detail).
Otherwise: Phase 2 (multi-project scan).

---

## Phase 1 — Single-project detail

1. If `.orchestration/projects/{id}/` doesn't exist: "project {id} not found — run `/status` with no args to list projects". Stop.
2. If `{id}` is under `done/`: "project {id} is archived under .orchestration/projects/done/". Stop.
3. Run `support/next-actions.md` filtered to `{id}`. Read `01-design/design-01.md`'s `date:` for the start date (fallback: `—`).
4. Render: project header line + slice rows (Phase 3 format).

If no slice files yet: header only with `—` for counts.

---

## Phase 2 — Multi-project scan

1. Run `support/next-actions.md` (no filter — every active project).
2. Group tuples by `project_id`. For each project:
   - Start date: `date:` from `01-design/design-01.md`. `—` if absent.
   - Slice counts: total slices; per-bucket counts (see Phase 3).
   - Task counts: glob `04-tasks/slice-*/**.md`; total / done by `status:` frontmatter. If a task file is unreadable or lacks status: exclude from done count, warn once per slice.
   - Most-recently-updated timestamp: latest `status_updated_at` across slice tuples. Fallback: design `date:`.
3. Sort projects: most recently updated first; project ID descending tiebreak. No-timestamp projects sort last.

Proceed to Phase 3.

---

## Phase 3 — Render

If no active projects: "no active projects — run `/plan-project` to start one". Stop.

Otherwise, for each project (sorted):

**Design-phase project** (no `02-slices/`):
```
**{id}** · {MMM D} · design: {design_status}  →  **`/plan-project`**
```

**Slice-based project header:**
```
**{id}** · {MMM D} · {slice_counts} · {task_counts}
```

**Counts format:** `✅{X} 🤖{Y} 👤{Z} ⏳{W} of {T} slices` (or `tasks`). Omit any emoji-pair where count = 0. If all 0: `0 slices`.

| Emoji | Slice states | Task states |
|-------|--------------|-------------|
| ✅ | `done` | `done` |
| 🤖 | `implementing`, `qa_in_progress` | `in_progress` |
| 👤 | `draft`, `review`, `signoff_review` | (never) |
| ⏳ | `speccing`, `breakdown`, `tasks_ready` | `todo` |

**Slice rows** (sorted by slice number ascending, 2-space indent, one line each):

Done slice:
```
  {NN}  {title}  ✅  {MMM D HH:MM}
```

Active slice:
```
  {NN}  {title}  {emoji} `{prev}→{curr}`  {MMM D HH:MM}  →  **`/{cmd}`**
```

**State table** (single source — emoji + abbreviation + next command):

| State | Abbrev | Emoji | Command |
|---|---|---|---|
| `draft` | draft | 👤 | `/plan-project` |
| `review` | review | 👤 | `/plan-project` |
| `speccing` | speccing | ⏳ | `/plan-project` |
| `breakdown` | bkdn | ⏳ | `/plan-project` |
| `tasks_ready` | ready | ⏳ | `/implement` |
| `implementing` | impl | 🤖 | `/implement` |
| `qa_in_progress` | qa | 🤖 | `/implement` |
| `signoff_review` | signoff | 👤 | `/review` |

**Date format throughout:** `MMM D` for project lines (`MMM D HH:MM` for slice rows). Omit year if current year. `—` if absent.

**Other formatting rules:**
- Strip `Slice NN — ` prefix from title. Truncate at 52 chars, append `…` if needed.
- `{prev}→{curr}`: no spaces around `→`. Previous derived from state-machine sequence in `state-diagram.md`. Skip arrow when `curr == draft`.
- Unknown state: `  {NN}  {title}  ⚠ unknown state`.
- Projects with no slice files: header only.
- Blank line between projects.

---

## Behavior rules (status deltas)

Shared rules — re-read from disk on every invocation, vocabulary canonical — live in `.root-context/state-diagram.md`.

- Read-only. Never write, edit, or delete any file.
- Partial reads beat crashes. Show what's readable; warn on gaps.
- `done/` projects excluded by the next-actions reader.
