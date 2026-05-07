---
type: slice
slice: 03
order: 03
project: batch-slice-flow
design: .orchestration/projects/bcokert-00007-batch-slice-flow/01-design/design-01.md
status: tasks_ready
status_updated_at: 2026-05-06T20:03:31-07:00
---

# Slice 03 — agent preamble extraction

**Goal:** Five agent files share a common preamble (`_common-preamble.md`) covering the canonical read-floor (`.root-context/CONSTRAINTS.md` + the task file), the shared "What you don't do" baseline, common escalation triggers, and the task-completion protocol. Each agent file lists role-specific deltas only. "Bdon" purged from agent files.

## Happy path

- `defaults/agents/_common-preamble.md` exists with the floor read-order, "What you don't do" baseline, common escalation triggers, and `status: done` write protocol.
- Each of `architect.md`, `server-dev.md`, `client-dev.md`, `quality.md`, `standards.md` references `_common-preamble.md` and lists only role-specific additions (e.g. architect adds architecture trigger list; server-dev adds backend-specific reads).
- Agent corpus shrinks by ~30 lines combined; the duplicated read-order block (4 files), "What you don't do" overlap (3 files), and identical "Escalate when" prose (5 files) collapse to single sources.
- `Bdon` removed from `architect.md:56`, `standards.md:60`, and any other agent files where it appears. Replaced with "the user".
- `init-orchestrator.md` installs `_common-preamble.md` alongside the agent files.

## Edge cases

- Each agent file currently has its own read-order; the preamble is the floor (not the full set). Role-specific reads stay in the agent file.
- If the common preamble's escalation triggers conflict with an agent's specific ones, surface the conflict and resolve in the agent file.
- The common-preamble file must not include Bdon, project-specific paths, or other defaults-incompatible content — it ships to downstream users.
- Agent file version bumps required (per defaults rule).
- An agent file that was already silent on a category in the preamble (e.g. quality has no "What you don't do") becomes covered by the preamble — verify this doesn't introduce a behavior change.
