---
type: design
date: 2026-04-16
feature: status-per-slice-view
project_id: bcokert-00002-status-per-slice-view
status: ready
---

# Status — per-slice view

## Intent

The `/status` command currently shows one row per project. That's fine when
each project is a single undivided effort, but as projects accumulate slices
in different states the table becomes too coarse to act on. You can see that
something is `spec_in_progress` but not which slice, how far along, or what's
waiting on you.

The revamp replaces the flat project table with a grouped view: one section per
active project, with every slice listed underneath. The goal is a view that's
useful daily ("what do I need to pick up?") and equally useful after a few
weeks away ("what is the state of everything, from scratch?").

## Current state

- Phase 2 renders a single-row-per-project table: id, stage, worktree, next_action, elapsed.
- Phase 1 (single project, `project_id` arg) shows project-level transitions and elapsed time.
- No slice-level visibility in either view.
- Done-this-week section runs at the end of Phase 2.
- Slice files store `status` (draft → reviewed → specced → tasks_ready → implementing → done)
  but no timestamp on status changes. `qa_in_progress` and `signoff_review` are project-level
  stages set by implement — they are not currently reflected in slice file status.
- Task files store `assigned_at` and `completed_at`.

## Desired end state

- Multi-project view groups output by project. Each project has a one-line header,
  followed by one row per slice.
- Project header: id · start date · slice progress · task progress.
- Active slice row: title + state transition line (previous → current, datetime, next action).
- Done slice row: condensed — title + done datetime only. No state lines.
- Projects with no slices yet (still in design/slicing) show the header with 0/0 placeholders.
- Done projects are excluded entirely.
- Done-this-week section removed.
- Slice state timestamps are stored on write — requires adding `status_updated_at`
  to slice file frontmatter wherever slice status changes (plan-project, implement).
- The full slice state machine is extended to include QA and signoff:
  `draft → reviewed → specced → tasks_ready → implementing → qa_in_progress → signoff_review → done`.
  The implement command sets `qa_in_progress` when QA begins and `signoff_review` when QA passes.
  This makes QA state visible in the status view and machine-readable for a future dashboard.
- Single-project view (Phase 1) is unchanged for now. Filter/sort args (`--owner`, `--sort`)
  are a future extension and are out of scope here.
- Diagram and README updates are in scope: the lifecycle diagram (`lifecycle.d2`) needs the
  two new slice states, `artifacts.d2` needs the updated slice frontmatter fields, and both
  `README.md` and `defaults/README.md` need prose updated if they describe the slice state
  machine or implement flow.
- Default sort order for projects: most recently updated first (latest transition timestamp
  across any slice in the project). Secondary sort: project id descending.

## Patterns to follow

- Read-only command. Status never modifies a file.
- Partial reads over crashes — missing field produces a warning inline, not a stop.
- Slice state machine is:
  `draft → reviewed → specced → tasks_ready → implementing → qa_in_progress → signoff_review → done`.
  Next action is derived from current state (deterministic mapping below).
- Task counts come from counting `.md` files in `04-tasks/slice-{NN}/`. Done task count
  comes from files where `status: done` in frontmatter. No assumption about file naming.
- The `status_updated_at` write happens in plan-project (slice status changes) and
  implement (slice transitions to `implementing`, `qa_in_progress`, `signoff_review`, and `done`).
  Other commands don't touch slice status.
- Don't add filter/sort to Phase 2 in this pass — keep scope tight.

## Derived next-action mapping

| Current slice state | Next action |
|---------------------|-------------|
| `draft`             | review slice, set `status: reviewed`, re-run `/plan-project` |
| `reviewed`          | run `/plan-project` to spec |
| `specced`           | run `/plan-project` to break down |
| `tasks_ready`       | run `/implement` to start |
| `implementing`      | in progress — run `/implement` to resume |
| `qa_in_progress`    | QA running — run `/implement` to resume |
| `signoff_review`    | QA passed — run `/review` to approve or give feedback |
| `done`              | (condensed row — no next action shown) |

## Key edge cases

- Project with zero slices: header renders with `0/0 slices · 0/0 tasks`. No slice rows.
- Slice file exists but `status` field is missing or unrecognised: show `⚠ unknown state`
  in place of the state, no state transition line.
- `status_updated_at` absent (slice predates this feature): show datetime as `—`.
- Task directory missing for a slice: count as 0/0, no crash.
- Task file unreadable or missing `status` field: exclude from done count, warn once per slice.
- All projects done: "no active projects — run `/plan-project` to start one".
- Most-recently-updated sort: if a project has no transitions at all (malformed), sort it last.
- Done slice with missing done timestamp: show `done —` rather than crashing.
- Slice in `signoff_review`: treated as active (not condensed), shows next action "run `/review`".

## Resolved design decisions

**Add `status_updated_at` to slice frontmatter.**
Why: the desired view needs "datetime entered current state" per slice. It's not derivable
from existing data. The only clean option is writing it when status changes.
Rejected: reading from project `status.md` transitions and correlating by stage name — brittle,
breaks for multi-slice projects where the same stage name recurs.

**Remove done-this-week section.**
Why: done slices are now visible inline within each project. The dedicated recap section is
redundant. Removing it reduces output length and eliminates an edge case (7-day window logic).
Rejected: keeping it as a compact footer — adds complexity for information already visible.

**No per-slice start date.**
Why: creates clutter without adding orientation value. Project start date gives the temporal
anchor; slice dates are implied by the transition timestamps.
Rejected: keeping it — Bdon explicitly dropped it during the interview.

**Task count across all slices.**
Why: project-level progress bar should reflect total scope, not just the active slice.
Rejected: per-slice task count on the header — confusing when the header represents the
whole project.

**Sort projects by most recently updated.**
Why: the thing you worked on last is the most likely thing you want to look at first.
ID-based sort is available as a future flag.
Rejected: alphabetical/id sort as default — less useful for daily use.

## Agent decisions

**Project header format.**
Decision: `{id}  started {date}  {N}/{N} slices  {N}/{N} tasks`
Context: no specific format was requested. Tight, scannable, no decorative characters.
Alternative: progress bar (`[===--]`) — adds visual noise without adding information.

**State transition line format.**
Decision: `{previous} → {current}  since {date} {time}  →  {next action}`
Context: Bdon described it as "previous → current + datetime → next action". This is a
direct rendering of that mental model.
Alternative: multi-line per field — more readable at a glance, but much taller output.

**Done slice format.**
Decision: `✓ {title}  done {date} {time}`
Context: minimal, visually distinct from active slices, datetime still present for orientation.
Alternative: single checkmark with just date (no time) — losing time precision without
clear benefit.

**`status_updated_at` format.**
Decision: ISO 8601 with timezone offset, same as existing transition timestamps.
Context: consistent with the rest of the status system.
Alternative: Unix timestamp — no human readability benefit.

**Out-of-scope: Phase 1 filter/sort.**
Decision: Phase 1 unchanged. Filter/sort noted for a future project.
Context: the immediate pain is the multi-project view. Phase 1 works for single-project
lookups and adding arg parsing is a separate piece of work.
