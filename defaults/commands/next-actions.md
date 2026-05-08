---
version: 1.0.0
description: |
  Shared reader. Returns next-action tuples for every active project: design status, slice statuses, and the legal next verbs per artifact. Commands call it on entry, filter to scope, run their batch.
allowed-tools:
  - Read
  - Glob
  - Bash
---

# Next-actions reader

Single source of truth for "what's available to act on right now". Every command (`/plan-project`, `/implement`, `/review`, `/status`) calls this on entry and filters the result to its scope.

State definitions, vocabulary, and frontmatter schemas live in `.root-context/state-diagram.md`. This file is the reader, not the schema.

---

## Output

A list of tuples — `SliceNextActions`, `DesignNextActions`, or `ProjectNextActions` (per `artifact_kind`):

```
{
  project_id: string,
  artifact_kind: "project_root" | "design" | "slice",
  artifact_id: string,           // for slice: the slice number ("01", "5.1"); for design: "design-01"; for project_root: ""
  status: string,                // current status from frontmatter (or "—" for project_root with no design yet)
  status_updated_at: string?,    // ISO 8601, may be null on first emission
  next_actions: [string]         // legal verbs in this state, e.g. ["/plan-project", "/implement", "/review"]
}
```

Sorted: most recently updated first; project ID descending tiebreak.

---

## Scope

- Glob `.orchestration/projects/*/`. Exclude any path under `done/`.
- For each active project:
  - If `01-design/design-{NN}.md` exists, emit a `design` tuple (read frontmatter `status`).
  - If no design and no slice files yet, emit a `project_root` tuple with `status: "new"` and `next_actions: ["/plan-project"]`.
  - For each slice file in `02-slices/*.md`, emit a `slice` tuple (read `slice:`, `status:`, `status_updated_at:`).

Sort within a project by slice number ascending.

---

## next_actions per state

Map slice/design status → legal next verbs:

| status | next_actions |
|--------|--------------|
| `draft`, `review`, `speccing`, `breakdown` (slice) | `["/plan-project"]` |
| `tasks_ready` (slice) | `["/implement"]` |
| `implementing`, `qa_in_progress` (slice) | `["/implement"]` (resume) |
| `signoff_review` (slice) | `["/review"]` |
| `done` (slice) | `[]` |
| `in_progress`, `review` (design) | `["/plan-project"]` |
| `approved` (design) | `["/plan-project"]` (slicing) or `[]` if all slices done |
| `new` (project_root) | `["/plan-project"]` |

---

## Failure mode

If a glob or read fails mid-scan: surface the error to the caller and stop. No partial scope execution. The caller decides whether to retry or halt.

---

## Behavior rules

- Frontmatter only — never reads brief or task files.
- Excludes `done/` always; never returns archived projects.
- Sort order is stable for the same on-disk state.
- The schema for tuple fields lives in `.root-context/state-diagram.md` (Frontmatter schemas section). Update there, not here.
