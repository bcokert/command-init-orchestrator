---
type: brief
slice: 01
project: bcokert-00001-orchestrator-bug-fixes
date: 2026-04-23
---

# Delegation brief — Slice 01: Agent file cleanup

**Type:** Task (AI agent)
**Date:** 2026-04-23

---

### 1. Intent

The orchestrator ships 6 agent files in `defaults/agents/` that get copied into user projects when they run `/init-orchestrator`. All 6 were written for an old layout that no longer exists. They reference `.orchestration/root-context/LINK.md`, `.orchestration/specs/briefs/`, `.orchestration/specs/tasks/{spec-id}/`, `.orchestration/dashboard/`, and `.orchestration/config.yaml` — none of which exist in the current system.

The current layout uses `.root-context/` directly for architecture/constraints/decisions, `.orchestration/projects/{id}/03-briefs/` for briefs, and `.orchestration/projects/{id}/04-tasks/slice-{NN}/` for task files. The implement.md command provides agents with their task file path directly — agents don't need to locate it themselves.

One agent (`lead.md`) describes a dashboard-and-config-yaml orchestration model that was replaced entirely by `implement.md`. It has no current use. Remove it.

This slice fixes all 5 remaining agent files in place and removes lead.md. The same changes apply to both `defaults/agents/` (the source shipped to users) and `.claude/agents/` (the local dogfood copy). Every modified file gets a version bump.

`init-orchestrator.md` currently lists `lead.md` in its install manifest and shows it in its output template. That needs updating too.

---

### 2. Observable outcomes

**Agent files reference correct paths**

```
Given defaults/agents/architect.md exists
When an agent reads it
Then it finds no references to .orchestration/root-context/LINK.md,
  .orchestration/specs/briefs/, .orchestration/dashboard/, or .orchestration/config.yaml
```

```
Given defaults/agents/standards.md exists
When an agent reads it
Then it finds no reference to .orchestration/root-context/lessons/
```

```
Given defaults/agents/client-dev.md or server-dev.md
When an agent reads the "When you're done" section
Then it contains no reference to the dashboard
```

**lead.md removed**

```
Given a fresh clone of this repo
When you list defaults/agents/ and .claude/agents/
Then lead.md is absent from both directories
```

**init-orchestrator.md updated**

```
Given init-orchestrator.md
When you read it
Then: description says "5 agents" not "6 agents"
  lead.md does not appear in the install list
  lead.md does not appear in the output template
```

**Version numbers bumped**

```
Given any agent file that was modified (not lead.md — it's deleted)
When you read its frontmatter
Then version: field is higher than 1.0.0
```

**Local copies in sync**

```
Given defaults/agents/{file}.md and .claude/agents/{file}.md
When you diff them for each of the 5 remaining agents
Then they are identical
```

---

### 3. Constraints

**Must:**
- Fix every stale path reference in all 5 remaining agent files.
- Remove `lead.md` from `defaults/agents/` and `.claude/agents/`.
- Update `init-orchestrator.md` to remove lead.md from: (a) the description count, (b) the install list at line ~99, (c) the output template at lines ~190–195.
- Bump version on every agent file that was modified. Patch bump minimum; use minor if behavior description changed.
- Keep `defaults/agents/` and `.claude/agents/` identical for the 5 remaining files.

**Must not:**
- Change any agent file's role description, responsibilities, or behavioral rules beyond what's required to fix stale paths.
- Add new agent files.
- Modify any command files (that's other slices).
- Attempt to update or delete `lead.md` in user-installed projects — this fix covers defaults and local only.

**Preferences:**
- For the "Before starting" sections: replace the `.orchestration/root-context/LINK.md` step with direct references to `.root-context/architecture.md`, `.root-context/DECISIONS.md`, and `.root-context/CONSTRAINTS.md` as applicable. Match the pattern already visible in architect.md (lines 15–17 of current file show what already works).
- For task/brief paths in client-dev.md and server-dev.md: update to `.orchestration/projects/{id}/04-tasks/slice-{NN}/{NN}-{slug}.md` and `.orchestration/projects/{id}/03-briefs/{NN}-{slug}.md`. Note that implement.md provides the task file path directly to agents — these lines are orientation, not navigation instructions.
- Remove dashboard references from client-dev.md and server-dev.md "When you're done" sections rather than replacing them with something new.

**Escalation triggers:**
- A path reference is ambiguous — the old path doesn't map cleanly to a current path. Stop and ask rather than guessing.
- `init-orchestrator.md` has references to `lead.md` not covered in the list above. Surface them before removing.

---

### 4. Done definition

Verifiable without reading implementation intent:

1. `ls defaults/agents/` — output contains exactly: `architect.md`, `client-dev.md`, `quality.md`, `server-dev.md`, `standards.md`. No `lead.md`.
2. `ls .claude/agents/` — same 5 files, no `lead.md`.
3. `grep -r "root-context/LINK" defaults/agents/ .claude/agents/` — no output.
4. `grep -r "specs/briefs\|specs/tasks\|dashboard\|config\.yaml" defaults/agents/ .claude/agents/` — no output.
5. `grep -n "root-context/lessons" defaults/agents/standards.md .claude/agents/standards.md` — no output.
6. `grep -n "lead\.md" init-orchestrator.md` — no output.
7. `grep -n "6 agents" init-orchestrator.md` — no output (should now say "5 agents").
8. For each of the 5 modified agent files: `version:` field in frontmatter is not `1.0.0`.
9. `diff defaults/agents/architect.md .claude/agents/architect.md` — no output (repeat for all 5).

---

### 5. Breakdown

| # | Step | Deliverable | Done signal |
|---|------|-------------|-------------|
| 1 | Fix `architect.md` — remove LINK.md step, fix briefs path | Updated `defaults/agents/architect.md` | `grep "root-context/LINK\|specs/briefs" defaults/agents/architect.md` → no output; version bumped |
| 2 | Fix `quality.md` — remove LINK.md step | Updated `defaults/agents/quality.md` | `grep "root-context/LINK" defaults/agents/quality.md` → no output; version bumped |
| 3 | Fix `standards.md` — remove LINK.md step, remove lessons/ reference | Updated `defaults/agents/standards.md` | `grep "root-context/LINK\|root-context/lessons" defaults/agents/standards.md` → no output; version bumped |
| 4 | Fix `client-dev.md` — remove LINK.md step, fix task/brief paths, remove dashboard reference | Updated `defaults/agents/client-dev.md` | `grep "root-context/LINK\|specs/tasks\|specs/briefs\|dashboard" defaults/agents/client-dev.md` → no output; version bumped |
| 5 | Fix `server-dev.md` — same as client-dev.md | Updated `defaults/agents/server-dev.md` | `grep "root-context/LINK\|specs/tasks\|specs/briefs\|dashboard" defaults/agents/server-dev.md` → no output; version bumped |
| 6 | Delete `lead.md` from `defaults/agents/` | File absent | `ls defaults/agents/lead.md` → no such file |
| 7 | Sync all 5 fixed files to `.claude/agents/` | `.claude/agents/` identical to `defaults/agents/` for all 5 files | `diff defaults/agents/architect.md .claude/agents/architect.md` (repeat ×5) → no output |
| 8 | Delete `lead.md` from `.claude/agents/` | File absent | `ls .claude/agents/lead.md` → no such file |
| 9 | Update `init-orchestrator.md` — remove lead.md from description count, install list, and output template | Updated `init-orchestrator.md` | `grep "lead\.md\|6 agents" init-orchestrator.md` → no output |
