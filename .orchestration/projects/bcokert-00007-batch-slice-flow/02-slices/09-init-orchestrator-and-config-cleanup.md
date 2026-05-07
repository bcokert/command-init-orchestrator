---
type: slice
slice: 09
order: 09
project: batch-slice-flow
design: .orchestration/projects/bcokert-00007-batch-slice-flow/01-design/design-01.md
status: tasks_ready
status_updated_at: 2026-05-06T20:03:31-07:00
---

# Slice 09 — init-orchestrator consolidated gate + delete defaults/config.yaml

**Goal:** `/init-orchestrator` presents one consolidated update gate ("N files would update — accept all / review per-file / skip") instead of N per-file prompts. The orphan `defaults/config.yaml` is deleted. The three install loops (commands / support / agents) collapse into one.

## Happy path

- A re-run on a downstream repo with N drifted files asks once: "{N} files would update — accept all / review per-file / skip". "accept all" applies all updates with a summary. "review per-file" falls back to today's per-file flow. "skip" leaves the install untouched and reports which files would have changed.
- Install loops at `init-orchestrator.md:78-83` (commands), `:85-94` (support), `:96-105` (agents) collapse into one parameterised loop driven by a file-class table.
- `defaults/config.yaml` deleted from the repo. Verified that no command, agent, or support file references it.
- Documentation in `init-orchestrator.md` reflects the new gate UX.
- "Old 7-command files" detection list at `init-orchestrator.md:44` annotated to clarify the path/class distinction (some legacy names overlap with current support file names).
- `init-orchestrator.md` version bumped.

## Edge cases

- "skip" must report the would-have-updated paths so the user can run a follow-up. No silent no-op.
- "review per-file" must function exactly as today's flow (regression test: walk through each file).
- A re-run with zero drift: skip the gate entirely, report "all files current".
- A re-run on a fresh checkout (no `.claude/commands/`): no gate; the install just runs with a "Installing N files" summary.
- `defaults/config.yaml` deletion must not break any test or script. Audit imports and references before deletion.
