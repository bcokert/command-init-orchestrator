---
type: slice
slice: 02
order: 02
project: batch-slice-flow
design: .orchestration/projects/bcokert-00007-batch-slice-flow/01-design/design-01.md
status: draft
---

# Slice 02 — shared support files (next-actions, status-write, bdonize)

**Goal:** Three new shared support files exist with documented contracts: `next-actions.md` (queue/state reader), `status-write.md` (frontmatter helper), `bdonize.md` (voice block). `init-orchestrator` registers them so they install cleanly. No commands consume them yet — slices 04-08 do that.

## Happy path

- `defaults/commands/next-actions.md` defines the contract: input none, output a list of tuples `(project_id, artifact_kind, artifact_id, status, status_updated_at, next_actions)` where `artifact_kind ∈ {project_root, design, slice}` and `next_actions` is a list of legal verbs. Tuple shape named `SliceNextActions` (or `ProjectNextActions` for project_root). Excludes `done/`.
- `defaults/commands/status-write.md` defines the contract: inputs `(project_id, slice_NN, new_status)`, action writes `status:` and `status_updated_at: {ISO 8601 with timezone offset}` to the slice file (Glob by `slice:` frontmatter), warn-and-continue if not found. Frontmatter only — no logging side effects.
- `defaults/commands/bdonize.md` holds the consolidated voice block (strip AI patterns, tune to voice, sentence-case headings) currently duplicated across slice/spec/plan-project. References-only from those files in slice 08.
- `init-orchestrator.md` lists the three new support files in its install loop so a re-run on a downstream repo installs them at `.orchestration/support/{next-actions,status-write,bdonize}.md`.
- A test re-run of `/init-orchestrator` against a fresh checkout installs the three files at the right paths.

## Edge cases

- The reader's `excluding done/` filter must match the implicit filter every command currently uses. Validate against the four current Phase 0 globs.
- Status-write must handle missing slice files gracefully (warn + continue) — at least one consumer (`/qa`) currently silent-fails this.
- `bdonize.md` content must match what slice/spec/plan-project currently restate verbatim, so slice 08's references are equivalent.
- init-orchestrator's per-file version-check loop currently fires per file; this slice doesn't change that loop's UX (slice 09 does), only adds three rows to its file list.
- New support files version-bump from 1.0.0; future edits bump per CLAUDE.md rule.
