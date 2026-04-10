---
description: |
  Sets up .orchestration/ in the current project. Copies commands to .claude/commands/, creates dev team agents, initializes dashboard and root-context structure. Safe to re-run: adds missing components and asks before replacing anything. Self-contained: no runtime dependency on root commands.
allowed-tools:
  - Read
  - Write
  - Bash
  - Glob
  - AskUserQuestion
---

# Init Orchestrator

Sets up the orchestration layer for a project. Safe to re-run — adds missing components and prompts before replacing anything that already exists.

The structure it creates:

```
.claude/
  commands/                — orchestration commands, callable via /command-name
    pipeline.md
    migrate.md
    design.md
    slice.md
    spec.md
    breakdown.md
    implement.md
    learn.md
    qa.md
    commit.md

.orchestration/
  README.md              — how to use the system
  config.yaml            — project-level config
  agents/                — dev team role definitions
    lead.md
    architect.md
    standards.md
    server-dev.md
    client-dev.md
    quality.md
  root-context/          — project context for agents (separate from user-curated)
    LINK.md              — pointer to project root-context if one exists
    lessons/             — /learn outputs go here
  specs/                 — all planning artifacts, scoped by type
    design/              — /design outputs (~200 line design docs)
    slices/              — /slice outputs (slicing plans)
    briefs/              — /spec outputs (delegation briefs)
    tasks/               — /breakdown outputs, one folder per spec
      {spec-id}/
        NN-{slug}.md
  dashboard/
    summary.md           — overall spec/task state (single source of truth)
    {spec-id}.md         — per-spec task queue
    {spec-id}-qa.md      — QA reports
```

---

## Phase 0 — Check what exists

Check if `.orchestration/` already exists:

```bash
ls .orchestration/ 2>/dev/null
```

Also check `.claude/commands/` for existing orchestration commands:

```bash
ls .claude/commands/ 2>/dev/null
```

If neither exists: create the full structure (no prompting needed, this is the first run).

If either exists: scan what's there and apply the re-run logic below.

---

## Phase 1 — Handle existing components (re-run case)

For each component, apply this logic:

**Commands** — for each command in the set (design, slice, spec, breakdown, implement, learn, qa, commit, pipeline, migrate):
- Missing from `.claude/commands/`: copy it in, no prompt
- Same version as source: skip
- Different version: ask "Command `{name}` is at v{old} locally, v{new} available. Update? (yes/no)"

To check the version, read the `version:` field from the frontmatter of each file. Source versions are in `~/.claude/init-orchestrator/defaults/commands/{name}.md`.

**Agents** — for each agent file in defaults:
- Missing: copy in, no prompt
- Exists: ask "Agent `{name}` already exists. Replace with default? (yes/no)"

**README.md**:
- Missing: write it, no prompt
- Exists: ask "README.md already exists. Replace? (yes/no)"

**config.yaml**:
- Missing: write it, no prompt
- Exists: skip (config is project-specific, never auto-replace)

**dashboard/**:
- Missing: initialize summary.md, no prompt
- Exists: skip (dashboard is live state, never touch)

---

## Phase 2 — Copy commands

All commands are bundled inside this command's defaults.

Source: `~/.claude/init-orchestrator/defaults/commands/`
Target: `.claude/commands/` in the current project

Commands: `pipeline`, `migrate`, `design`, `slice`, `spec`, `breakdown`, `implement`, `learn`, `qa`, `commit`

For each: read `~/.claude/init-orchestrator/defaults/commands/{name}.md`, write to `.claude/commands/{name}.md`.

Create `.claude/commands/` if it doesn't exist.

If a source file doesn't exist, note it and skip — don't fail the whole init.

---

## Phase 3 — Write agents

Read each file from `~/.claude/init-orchestrator/defaults/agents/` and write to `.orchestration/agents/`.

Files: `lead.md`, `architect.md`, `standards.md`, `server-dev.md`, `client-dev.md`, `quality.md`.

---

## Phase 4 — Write README and config

Write `~/.claude/init-orchestrator/defaults/README.md` to `.orchestration/README.md`.
Write `~/.claude/init-orchestrator/defaults/config.yaml` to `.orchestration/config.yaml` (only if it doesn't exist).

---

## Phase 5 — Handle root context

Check if `.root-context/` exists at the project root:

```bash
ls .root-context/ 2>/dev/null
```

**If it exists:**

Ask:

> ".root-context/ exists at the project root. This is dev context the orchestration system should know about. Options:
> 1. Create a pointer — .orchestration/root-context/LINK.md points to .root-context/ (recommended: keeps them separate)
> 2. Leave it — I'll note the path but not create any link
>
> Which? (1 or 2)"

If option 1: write `.orchestration/root-context/LINK.md`:

```markdown
# Root Context Location

This project's root context lives at `.root-context/` in the project root.

Agents should read those files for architecture, constraints, and decisions before starting any task. Key files:
- `.root-context/architecture.md` — system design and tech stack
- `.root-context/CONSTRAINTS.md` — invariants every implementation must preserve
- `.root-context/DECISIONS.md` — ADR log

Lessons from past work are stored separately in `.orchestration/root-context/lessons/`.
```

If option 2: create `.orchestration/root-context/LINK.md` with just the path noted, no pointer behavior.

**If `.root-context/` does not exist:**

Create `.orchestration/root-context/README.md`:

```markdown
# Root Context

No root-context found at project root. Add one at `.root-context/` with:
- `architecture.md` — system design and tech stack
- `CONSTRAINTS.md` — invariants every implementation must preserve
- `DECISIONS.md` — ADR log

Until then, agents will have limited project context.
```

Create the `lessons/` directory placeholder by writing `.orchestration/root-context/lessons/.gitkeep` (empty file).

---

## Phase 6 — Initialize dashboard

If `.orchestration/dashboard/summary.md` doesn't exist, create it:

```markdown
---
updated: {today}
---

# Orchestration Summary

## Active specs

| ID | Title | Status | Tasks | Done | QA |
|----|-------|--------|-------|------|----|

## Blocked

*(none)*

## Learning

*(no lessons yet — run /learn after completing a spec)*
```

---

## Phase 7 — Done

Report what was created or updated. Show the full structure with a tree. Remind Bdon of the workflow:

> "Orchestration ready. Workflow: /design → /slice → /spec → /breakdown → /implement → /qa → /commit → /learn"

---

## Behavior rules

- Never auto-replace config.yaml or dashboard files. Those are live state.
- Never replace existing files without asking (except first-run where nothing exists).
- If a source command file is missing from `~/.claude/init-orchestrator/defaults/commands/`, note it and continue — don't fail the whole init.
- Write files using absolute paths (resolve `~` to the actual home directory via `echo $HOME`).
