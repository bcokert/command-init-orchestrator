---
type: brief
slice: 03
project: bcokert-00003-remove-worktree-replace-task-queuing
date: 2026-04-18
---

# Delegation brief — slice 03: global queue in implement

**Type:** Task (AI agent)
**Date:** 2026-04-18

---

### 1. Intent

After slice 01, `/implement` still selects a single project by ID or prompt, then runs its tasks. This slice changes that selection logic to a global queue: scan all projects for `tasks_ready` slices, order them by when they entered that state, and execute the next one. A dirty working tree is normal and expected — slices pile up uncommitted until `/review`.

The queue unit is the slice, not the project. Slices from different projects can interleave. Within a project, slice order is always respected regardless of timestamps.

This enables the "set and leave" use case: queue up multiple slices across projects, run `/implement`, and let it work through the queue unattended until a signoff gate.

---

### 2. Observable outcomes

**Happy path — single project:**
```
Given one project with one slice at tasks_ready
When /implement runs with no argument
Then it selects that slice and proceeds as before
```

**Happy path — cross-project queue:**
```
Given project A with slice 01 at tasks_ready (status_updated_at: T1)
  and project B with slice 01 at tasks_ready (status_updated_at: T2, T2 > T1)
When /implement runs with no argument
Then it selects project A slice 01 (earlier timestamp)
```

**Happy path — within-project ordering:**
```
Given project A with slice 01 at tasks_ready (T2) and slice 02 at tasks_ready (T1)
When /implement runs
Then it selects slice 01 regardless of T1 < T2 — project order is respected
```

**Empty queue:**
```
Given no slices at tasks_ready across any project
When /implement runs
Then output: "Nothing in the queue. Run /plan-project to create tasks." Stop.
```

**Dirty working tree:**
```
Given uncommitted changes on main from a previous slice
When /implement selects the next slice from the queue
Then it proceeds normally — dirty tree is not an error
```

**Blocked project:**
```
Given project A with slice 01 at implementing and slice 02 at tasks_ready
When /implement runs
Then it reports "project A slice 02 is blocked — slice 01 must complete first"
  and skips to the next eligible slice from another project (or stops if none)
```

---

### 3. Constraints

**Must:**
- Apply to `defaults/commands/implement.md` as modified by slice 01 (Phase 1 = agent team, Phase 2 = task execution, Phase 3 = QA).
- Replace Phase 0 Step 1 "identify the project" with a queue scan: glob all `02-slices/*.md` across all projects, filter for `status: tasks_ready`, sort by `status_updated_at` ascending, then enforce per-project slice order.
- Per-project slice order rule: for a project where slice N is `tasks_ready`, slice N may only run if all slices with a lower number are at `signoff_review` or `done`. If blocked, report which slice is blocking and skip to the next eligible slice.
- Empty queue: output the prescribed message and stop. Do not fall through to any old "no projects ready" path.
- Dirty working tree: no check, no warning, no block.
- Agent team confirmation still happens per-slice at the start of Phase 1 (unchanged from current flow).
- Bump version to 2.3.0.
- Sync `.claude/commands/implement.md` from defaults after editing.

**Must not:**
- Add a `git stash` or any other tree-state management.
- Change Phase 1 (agent team), Phase 2 (task execution), or Phase 3 (QA) logic.
- Remove the Step 2 wrong-command routing table — update it only if any messages reference worktrees (already handled in slice 01).
- Commit anything.

**Preferences:**
- Queue scan uses Glob + Read on slice frontmatter, not a separate queue file.
- When multiple slices tie on `status_updated_at` (e.g. both are null), use project ID alphabetical order as tiebreak.

**Escalation triggers:**
- If the slice file `status_updated_at` field is absent or unparseable for all queued slices — report and ask rather than silently using a fallback order.

---

### 4. Done definition

- Running `/implement` with no args and multiple `tasks_ready` slices across projects selects the one with the earliest `status_updated_at`.
- Within one project, slice 01 always runs before slice 02 regardless of timestamps.
- No queue-related code references worktrees.
- Empty queue produces "Nothing in the queue. Run /plan-project to create tasks."
- Version is 2.3.0.

**Test vectors:**
```
grep "tasks_ready" defaults/commands/implement.md
→ matches the queue scan description

grep "Nothing in the queue" defaults/commands/implement.md
→ one match

grep "worktree" defaults/commands/implement.md
→ no output (worktrees fully removed by slice 01)

diff defaults/commands/implement.md .claude/commands/implement.md
→ no output
```

---

### 5. Breakdown

| # | Step | Deliverable | Done signal |
|---|------|-------------|-------------|
| 1 | Rewrite Phase 0 Step 1 in `defaults/commands/implement.md` | Global queue scan replaces single-project selection; per-project order enforcement; empty-queue message; blocked-project reporting; version 2.3.0 | Queue logic present; `grep "Nothing in the queue" defaults/commands/implement.md` → one match |
| 2 | Sync `.claude/commands/implement.md` | Copied from defaults | `diff defaults/commands/implement.md .claude/commands/implement.md` → no output |
