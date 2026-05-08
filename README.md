# command-init-orchestrator

Run `/init-orchestrator` in any git repo. You get a 4-command system for taking ideas from design through implementation to signoff — with structured planning, isolated execution, and human review at the points that matter.

## Why use it

**Single source of truth.** Every project artifact — design doc, slices, briefs, tasks, QA reports — lives in `.orchestration/projects/{id}/`. One folder. Nothing scattered.

**Docs stay in sync.** Design decisions flow through structured stages with committed artifacts at each gate. When a later stage reshapes something, the upstream doc gets updated before moving on. The system makes it harder to let docs go stale than to keep them current.

**Slicing discipline built in.** Work is planned as thin vertical slices — something observable and testable on its own. Small slices mean you validate assumptions early and fail cheap, not at the end.

**Status that reflects reality.** `status.md` is the ground truth for every project. `/status` gives you a table of all active projects, their stage, and how long they've been there. Replaces JIRA-level tracking without needing JIRA.

**Human gates where they matter.** Gates exist after design, slicing, and QA signoff. Not after every step. The system trusts mechanical work and gates judgment calls.

**QA is a first-class citizen.** QA runs automatically at the end of every implementation slice. You can customize what it checks. Nothing reaches signoff without it.

**Project scaffold, not a server.** `/init-orchestrator` installs a scaffold you own — command files in `.claude/commands/`, project structure in `.orchestration/`. Tweak commands, add root context, modify QA checks. No singleton to update, no breaking API.

---

## The 4 commands

| Command | What it does |
|---------|-------------|
| `/plan-project` | Full planning pipeline: design interview → slicing → spec → breakdown. Stops when tasks are ready. Commits at each human approval gate. |
| `/implement` | Execution pipeline: pulls next slice from queue, runs tasks sequentially, runs QA automatically. Stops at signoff for human review. Nothing committed until `/review` approves. |
| `/review` | Closes the loop: approve (commits everything, archives project) or provide feedback (adds new slices to backlog). |
| `/status` | All active projects in a table: stage, next action, time in stage. |

---

## Core concepts

**Slices** are the unit of work. A slice is a thin vertical cut — something someone can observe and verify that it improves the state of the system, even if we had to stop here. You typically plan one slice at a time, implement it, review it, then move to the next. Implementation and signoff feedback may reshape later slices for cohesion as you go.

**The queue** drives execution. `/implement` scans all projects for `tasks_ready` slices, picks the oldest by `status_updated_at`, and runs every queued slice end-to-end without inter-slice gates. Multiple projects' slices interleave by timestamp, on main.

**Human gates** exist at design review, slicing review, and signoff review. Spec → breakdown is automatic; the team runs at /implement (one team gate per batch), not per slice. Between gates the system runs autonomously.

---

## Quick start

```
1. /plan-project — describe what you want to build
2. Review the design doc, edit if needed, iterate until it's right
   Approve: re-run /plan-project to continue to slicing
3. Review slice 01, iterate
   Approve: generates the spec (implementation plan)
4. Review the spec — light pass, the heavy lifting is in design and slicing
   Approve: breaks the spec into tasks
5. /implement — confirm agent team once, all queued slices run end-to-end through QA
6. /review — iterates every signoff slice in the project; per-slice approve/feedback
   Approve all: commits each slice; archives when fully done
   Feedback: creates a follow-up slice (dot-notation, e.g. 5.1); batch continues
```

Run `/status` at any point to see where everything stands.

---

## How a project flows

What gets created at each stage — design doc through archived output:

![Project artifacts: design doc → slices → brief → tasks → code → QA report → archive](docs/diagrams/artifacts.svg)

Every project moves through these stages, with human review gates and retry loops:

![Project lifecycle: all stages, transitions, and decision points](docs/diagrams/lifecycle.svg)

---

## Common patterns

A few patterns worth knowing before you hit them in the wild.

**Pause and resume** — interrupt mid-implementation, re-run picks up from the last completed task:

![Pause and resume: /implement interrupted, re-run picks up from last completed task](docs/diagrams/pause-resume.svg)

**Concurrent projects** — multiple slices queued across projects; `/implement` executes them one at a time from the global queue:

![Concurrent projects: slice queue across projects, one execute at a time](docs/diagrams/concurrent-projects.svg)

**Multi-slice sequence** — backlog advancing in order; future slices stay rough until they become next:

![Multi-slice sequence: slice 01 done, slice 02 current, slice 03+ rough until needed](docs/diagrams/multi-slice-sequence.svg)

**Feedback loop** — `/review` feedback creates a new slice, which flows back through design and implementation:

![Feedback loop: /review feedback → new slice → /plan-project → /implement → /review](docs/diagrams/feedback-loop.svg)

**Project folder layout** — every artifact for a project lives under one directory:

```
.orchestration/projects/{id}/
├── 01-design/          ← design doc (written during /plan-project interview)
├── 02-slices/          ← slice files (one per unit of work)
├── 03-briefs/          ← delegation briefs (one per spec)
├── 04-tasks/           ← task files, organized by slice
│   └── slice-01/
├── 05-qa/              ← QA reports (written automatically after /implement)
└── observability/      ← questions, iterations, decisions logs (planning trace)

.orchestration/support/                      ← shared support files referenced by commands
.orchestration/projects/done/YYYY-MM/{id}/   ← archived after /review approve
```

---

## Install

```bash
/init-orchestrator
```

Installs:
- 4 user commands into `.claude/commands/` — `plan-project`, `implement`, `review`, `status`
- 6 support files into `.orchestration/support/` — `slice`, `spec`, `qa`, `next-actions`, `status-write`, `bdonize`
- 6 agent files into `.claude/agents/` — `_common-preamble`, `architect`, `client-dev`, `quality`, `server-dev`, `standards`
- Creates `.orchestration/projects/` for project data.

Safe to re-run. On a re-run with drifted files, one consolidated update gate offers `accept all`, `review per-file`, or `skip` — no per-file prompts.

---

## Customization

The system is a scaffold, not a service. Everything is a file you own.

**Source of truth: `defaults/`.** All command, agent, and support files are edited in `defaults/` only. `.claude/commands/`, `.claude/agents/`, and `.orchestration/support/` are install targets — never edit them directly.

To pick up the latest source in a project: re-run `/init-orchestrator`. The consolidated update gate offers `accept all`, `review per-file`, or `skip`.

To add project-specific context: drop a `CLAUDE.md` at your project root or add files to `.root-context/`. Commands read these automatically before starting.
