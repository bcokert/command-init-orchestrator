# /init-orchestrator

A Claude Code command that sets up a project-level orchestration layer.

## What it does

Scaffolds the full orchestration structure — dev team agent definitions, root-context linking, task dashboard, and all orchestration commands — in a single run. Safe to re-run: adds missing components and prompts before replacing anything that already exists.

```
.claude/
  commands/        # orchestration commands, callable via /command-name
    pipeline.md, migrate.md, design.md, slice.md, spec.md
    breakdown.md, implement.md, qa.md, commit.md, learn.md

.orchestration/
  README.md
  config.yaml
  agents/          # dev team role definitions
  root-context/    # project context for agents
  specs/           # design docs, slices, briefs, tasks
  dashboard/       # task state
```

## How the install works

Two stages:

**Stage 1 — install to `~/.claude/` (once, or to update)**

```bash
git clone git@github.com:bcokert/command-init-orchestrator.git
cd command-init-orchestrator
./claude-install.sh
```

Installs:
- `~/.claude/commands/init-orchestrator.md` — the `/init-orchestrator` command
- `~/.claude/init-orchestrator/defaults/` — bundled commands, agents, and config (the source of truth for all copies)

Nothing goes into any project yet.

**Stage 2 — init a project (once per project, or to update)**

In any Claude Code session, from your project root:

```
/init-orchestrator
```

Reads from `~/.claude/init-orchestrator/defaults/` and writes into the current project:
- `.claude/commands/` — all 10 orchestration commands, callable via `/command-name`
- `.orchestration/` — agents, README, config, root-context structure, dashboard

## Updating

To get new command versions into a project:

1. Pull this repo and re-run `./claude-install.sh` — updates `~/.claude/`
2. Re-run `/init-orchestrator` in each project — version check fires and offers updates for anything that changed

## Workflow

### Starting a feature

```
/pipeline               → new feature: full design interview → slice → spec → breakdown
/migrate [existing.md]  → existing spec/research: compressed interview → slice → spec → breakdown
```

Both run the full chain in one session with review gates.

### Step by step (manual control)

```
/design     → structured interview → design doc (~200 lines)
/slice      → design doc          → vertical slicing plan
/spec       → slices doc          → delegation brief (agent-ready)
/breakdown  → delegation brief    → task files in .orchestration/specs/tasks/
/implement  → dashboard           → guided kickoff prompt per task
/qa         → completed tasks     → verification report
/commit     → task file           → scoped git commit + dashboard update
/learn      → completed spec      → lessons in root-context/lessons/
```
