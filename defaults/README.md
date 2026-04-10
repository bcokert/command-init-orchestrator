# Orchestration System

AI-assisted dev team orchestration for complex, multi-slice projects. Manages the full lifecycle from design through implementation, QA, and learning.

---

## Workflow

### Starting a feature

```
/pipeline               → new feature: full design interview → slice → spec → breakdown
/migrate [existing.md]  → existing spec/research: compressed interview → slice → spec → breakdown
```

Both run the full chain in one session with review gates. Use `/pipeline` for new work, `/migrate` to push an existing doc through the new process.

### Step by step (if you want manual control)

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

**Deep review gates:** design and slices — this is where wrong assumptions get caught early.
**Light review:** spec, task files — agent-facing, skim for coherence.
**No review:** implement, qa, commit, learn — mechanical or guided, just run them.

---

## File locations

Everything lives inside `.orchestration/`. One folder, fully self-contained.

```
.orchestration/
  README.md                     — this file
  config.yaml                   — project config
  skills/                       — local copies of all skills
  agents/                       — dev team role definitions
  root-context/
    LINK.md                     — pointer to .root-context/ if it exists
    lessons/                    — /learn outputs
  specs/
    design/                     — /design outputs (~200 line design docs)
    slices/                     — /slice outputs (slicing plans)
    briefs/                     — /spec outputs (delegation briefs)
    tasks/                      — /breakdown outputs
      {spec-id}/                — one folder per spec
        NN-{slug}.md            — one file per task
  dashboard/
    summary.md                  — overall state (all specs)
    {spec-id}.md                — per-spec task queue
    {spec-id}-qa.md             — QA report per spec
```

---

## Dashboard

`dashboard/summary.md` — single file showing all active specs, their task counts, and QA status. Every skill that changes project state updates this file.

`dashboard/{spec-id}.md` — per-spec task queue. Shows each task, its status, agent type, and dependencies. Also contains the kickoff prompt template.

**Status values:**
- Spec: `draft` → `ready` → `in-progress` → `done`
- Task: `todo` → `in-progress` → `done` | `blocked`
- QA: `—` → `pending-manual` → `passed` | `failed` | `partial`

---

## Dev team agents

Agents are role definitions in `.claude/agents/`. Each defines the role's focus, priorities, and expected behaviors for this project.

| Role | File | Use for |
|------|------|---------|
| Lead | `lead.md` | Orchestrating the team, deciding task order |
| Architect | `architect.md` | Structure decisions, ADR review |
| Standards | `standards.md` | Code quality, convention enforcement |
| Server dev | `server-dev.md` | Backend, API, daemon, vault layer |
| Client dev | `client-dev.md` | Frontend, web app, UI |
| Quality | `quality.md` | Tests, QA reports, done signal verification |

To use an agent role: start a new Claude Code session, read the role file, then read the task file.

Example kickoff:
```
Read .claude/agents/server-dev.md for your role context.
Read .orchestration/specs/tasks/m1-read-path/03-vault-layer.md and implement it.
Read the full spec at .orchestration/specs/briefs/2026-04-08-m1-read-path.md for context.
When done, update the task file status to "done".
```

---

## Root context

`.orchestration/root-context/LINK.md` — points to the project's root context at `.root-context/`. Agents should read those files before starting any task.

`.orchestration/root-context/lessons/` — lessons extracted by `/learn` from completed specs. These are agent-facing and separate from the human-curated root context.

---

## Updating the system

To get new skill versions or add missing agents: re-run `/init-orchestrator`. It will diff versions and ask before replacing anything.

---

## What this doesn't do (yet)

- Parallel task execution (worktrees) — sequential by default
- Automated agent spawning — guided-manual kickoff via /implement
- Live UI for dashboard — plain markdown for now
- CI integration — local only
