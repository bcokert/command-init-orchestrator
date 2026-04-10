# /init-orchestrator

A Claude Code command that sets up a project-level orchestration layer under `.orchestration/`.

## What it does

Scaffolds the full orchestration structure — bundled skills, dev team agent definitions, root-context linking, and a task dashboard — in a single run. Safe to re-run: adds missing components and prompts before replacing anything that already exists.

```
.orchestration/
  README.md
  config.yaml
  skills/          # local copies of orchestration skills
  agents/          # dev team role definitions
  root-context/    # project context for agents
  specs/           # design docs, slices, briefs, tasks
  dashboard/       # task state
```

## Install

```bash
git clone git@github.com:bcokert/command-init-orchestrator.git
cd command-init-orchestrator
./claude-install.sh
```

Installs to `~/.claude/commands/init-orchestrator/`.

## Usage

In any Claude Code session, from your project root:

```
/init-orchestrator
```

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
