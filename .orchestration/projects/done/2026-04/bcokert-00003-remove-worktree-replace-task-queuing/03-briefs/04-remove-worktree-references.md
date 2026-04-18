---
type: brief
slice: 04
project: bcokert-00003-remove-worktree-replace-task-queuing
date: 2026-04-18
---

# Delegation brief — slice 04: remove all remaining worktree references

**Type:** Task (AI agent)
**Date:** 2026-04-18

---

### 1. Intent

Slices 01–03 removed worktrees from the runtime commands. This slice removes them from everything else: the config file users copy into their projects, the init-orchestrator skill that sets up new projects, the READMEs, and the diagrams. After this slice, a fresh `/init-orchestrator` install produces nothing worktree-related, and no documentation describes or references the old worktree model.

The `concurrent-projects.d2` diagram exists solely to show two projects running in parallel worktrees — it needs to be replaced with a diagram showing the queue model instead.

---

### 2. Observable outcomes

**Happy path — config:**
```
Given defaults/config.yaml
Then it has no suggest_worktree setting or comment block
```

**Happy path — init-orchestrator:**
```
Given a project with no .orchestration/ directory
When /init-orchestrator runs
Then no .orchestration/worktrees/ entry is added to .gitignore,
  no worktrees/ directory is created,
  and the output listing has no worktrees/ entry
```

**Happy path — init-orchestrator on existing project with empty worktrees dir:**
```
Given .orchestration/worktrees/ exists and is empty
When /init-orchestrator runs
Then .orchestration/worktrees/ is deleted
```

**Happy path — init-orchestrator on existing project with non-empty worktrees dir:**
```
Given .orchestration/worktrees/ exists and has contents
When /init-orchestrator runs
Then .orchestration/worktrees/ is left intact,
  and user sees: "Found .orchestration/worktrees/ with contents — inspect and remove manually"
```

**Happy path — diagrams:**
```
Given the updated .d2 files
Then artifacts.svg has no "(worktree)" label on the code changes node
  and concurrent-projects.svg shows the queue model, not two worktrees
```

**Happy path — READMEs:**
```
Given README.md and defaults/README.md
Then neither mentions git worktree, worktree branches, or .orchestration/worktrees/
```

---

### 3. Constraints

**Must:**
- Remove the entire `agents.suggest_worktree` block from `defaults/config.yaml` (the setting and its comment).
- In `init-orchestrator.md`: remove Phase 3 step that creates `.orchestration/worktrees/` directory; remove Phase 4 entirely (the `.gitignore` update step for worktrees); remove `worktrees/` from the output directory listing in the skill; add detection logic — if `.orchestration/worktrees/` exists and is empty, delete it; if non-empty, warn and leave.
- Update `docs/diagrams/artifacts.d2`: change the `code` node label from `"code changes\n(worktree)"` to `"code changes"`.
- Replace `docs/diagrams/concurrent-projects.d2` with a diagram showing the queue model: multiple slices across projects feeding into a single sequential queue, one slice executing at a time.
- Re-render both SVGs using `d2 docs/diagrams/artifacts.d2 docs/diagrams/artifacts.svg` and `d2 docs/diagrams/concurrent-projects.d2 docs/diagrams/concurrent-projects.svg`.
- Update `README.md`: remove the "Work isolation by default" bullet and worktree description; update the `/implement` row description; update the `/status` row description; remove the "Worktrees" section; update the concurrent projects diagram reference to describe the queue model; update the file tree (remove `worktrees/` entry from status.md comment); update the "Creates" line in the init section.
- Update `defaults/README.md`: remove worktree column from the commands table; remove `worktrees/` from the file tree; update stage descriptions that mention worktrees.
- Bump `init-orchestrator.md` version. Bump `defaults/config.yaml` is a content change — no version field to bump.
- Do not bump versions on implement.md or review.md (those are handled in slices 01/03).
- Do not commit anything.

**Must not:**
- Remove the `concurrent-projects` diagram entirely — replace it with a queue diagram. The diagram slot in README.md should still exist.
- Touch `.claude/` for config or init — those are copies of `defaults/`.
- Edit SVGs directly — always regenerate from `.d2` source.

**Preferences:**
- The new concurrent-projects diagram should show: slice queue with interleaved project slices (1a, 2a, 1b, 3a) feeding into a single `/implement` executor.

**Escalation triggers:**
- If `d2` is not installed: render step will fail. Report the error, leave the `.d2` files updated, and note that SVGs need manual re-render. Do not block on this.
- If `init-orchestrator.md` has phase numbering that would be disrupted by removing phases 3 and 4 — renumber subsequent phases and update the version bump accordingly.

---

### 4. Done definition

- `grep "worktree" defaults/config.yaml` → no output.
- `grep "worktree" init-orchestrator.md` → no output.
- `grep -i "worktree" README.md` → no output.
- `grep -i "worktree" defaults/README.md` → no output.
- `grep "worktree" docs/diagrams/artifacts.d2` → no output.
- `docs/diagrams/concurrent-projects.d2` describes a queue, not two worktrees.
- Both SVGs are regenerated and match their `.d2` sources.

**Test vectors:**
```
grep "suggest_worktree" defaults/config.yaml
→ no output

grep "worktrees/" init-orchestrator.md
→ no output (except possibly in the worktrees-dir detection/cleanup logic)

grep "git worktree" README.md defaults/README.md
→ no output
```

---

### 5. Breakdown

| # | Step | Deliverable | Done signal |
|---|------|-------------|-------------|
| 1 | Edit `defaults/config.yaml` | `suggest_worktree` block removed | `grep "suggest_worktree" defaults/config.yaml` → no output |
| 2 | Edit `init-orchestrator.md` | Worktree dir creation removed; gitignore step removed; worktrees/ removed from output listing; empty-dir cleanup added; non-empty-dir warning added; version bumped | `grep "worktrees/" init-orchestrator.md` → only matches in cleanup logic, not setup |
| 3 | Edit `docs/diagrams/artifacts.d2` and `docs/diagrams/concurrent-projects.d2` | artifacts: code node label updated; concurrent-projects: rewritten as queue diagram | `grep "worktree" docs/diagrams/artifacts.d2 docs/diagrams/concurrent-projects.d2` → no output |
| 4 | Re-render SVGs | `artifacts.svg` and `concurrent-projects.svg` regenerated | SVG files updated; if d2 absent, report and continue |
| 5 | Edit `README.md` and `defaults/README.md` | All worktree references removed or replaced with queue model language | `grep -i "worktree" README.md defaults/README.md` → no output |
