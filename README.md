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

Once initialized:

```
/design → /slice → /spec → /breakdown → /implement → /qa → /commit → /learn
```
