---
type: brief
slice: 02
project: bcokert-00003-remove-worktree-replace-task-queuing
date: 2026-04-18
---

# Delegation brief — slice 02: status command reads from main only

**Type:** Task (AI agent)
**Date:** 2026-04-18

---

### 1. Intent

Slice 01 removed worktrees from the execution path. This slice removes the corresponding worktree-reading logic from `/status`. The status command currently runs `git worktree list`, resolves per-worktree `status.md` paths as authoritative, and flags orphaned worktrees as `worktree_missing`. None of that applies in the new model — there are no worktrees, and `status.md` on main is always authoritative.

After this slice, `/status` reads only from `.orchestration/projects/`. The output is simpler and the worktree-related warning states are gone.

---

### 2. Observable outcomes

**Happy path:**
```
Given any active projects on main
When /status runs
Then no git worktree list command is executed,
  output has no worktree: field,
  and slice_base_path is always .orchestration/projects/{id}
```

**Edge — old status.md with worktree_path:**
```
Given a status.md that still has worktree_path set
When /status runs
Then the field is ignored and not displayed
```

**Edge — worktree_missing warning path removed:**
```
Given no worktrees exist
When /status runs
Then no worktree_missing warning rows appear; the code path is gone, not just unreachable
```

---

### 3. Constraints

**Must:**
- Remove the `git worktree list` call from Phase 2 entirely.
- Remove the worktree path resolution block in Phase 2 (lines that check `{worktree_path}/.orchestration/projects/{id}/status.md`).
- Remove `worktree_path` and `worktree_missing` from the collected fields in Phase 2.
- Remove `worktree_missing` warning row from Phase 3 output.
- Remove `worktree:` field from the Phase 1 single-project detail view output block.
- Remove the two worktree behavior rules at the bottom of the file.
- Update the `description:` frontmatter to remove "active worktrees" reference.
- Bump version: 3.1.0 → 3.2.0.
- Sync `.claude/commands/status.md` from defaults after editing.

**Must not:**
- Remove the done-project exclusion logic — that's separate from worktrees.
- Change any slice state display logic, bucket definitions, or sort order.
- Commit anything.

**Escalation triggers:**
- If removing the worktree resolution block would leave Phase 2 with a gap in logic that breaks slice reading — stop and flag rather than patch around it.

---

### 4. Done definition

- `defaults/commands/status.md` has no mention of `git worktree`, `worktree_path`, `worktree_missing`, or `worktree:`.
- Phase 2 does not call any git command to list worktrees.
- Phase 1 detail view output template has no `worktree:` line.
- Version is 3.2.0.

**Test vectors:**
```
grep -n "worktree" defaults/commands/status.md
→ no output

diff defaults/commands/status.md .claude/commands/status.md
→ no output
```

---

### 5. Breakdown

| # | Step | Deliverable | Done signal |
|---|------|-------------|-------------|
| 1 | Edit `defaults/commands/status.md` | All worktree logic removed: `git worktree list`, path resolution, `worktree_missing`, `worktree:` field, behavior rules; description updated; version 3.2.0 | `grep "worktree" defaults/commands/status.md` → no output |
| 2 | Sync `.claude/commands/status.md` | Copied from defaults | `diff defaults/commands/status.md .claude/commands/status.md` → no output |
