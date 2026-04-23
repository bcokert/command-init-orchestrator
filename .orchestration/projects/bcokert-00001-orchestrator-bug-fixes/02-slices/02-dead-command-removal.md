---
type: slice
slice: 02
order: 02
project: orchestrator-bug-fixes
design: .orchestration/projects/bcokert-00001-orchestrator-bug-fixes/01-design/design-01.md
status: done
status_updated_at: "2026-04-23T00:01:00-07:00"
---

# Slice 02 — Dead command removal

**Goal:** Remove unused command files from defaults and local installs. Create TODO.md for deferred features. Add CLAUDE.md sync rule.

## Happy path

- `learn.md`, `commit.md`, `migrate.md` absent from `defaults/commands/` and `.claude/commands/`.
- `TODO.md` exists at project root with the following deferred features:
  - Deep observability tracking
  - Observability dashboards — status and full-system monitoring
  - System-wide expansion: multi-repo or cloud-based orchestrator state serving an org-wide SDLC process (ACD)
  - Better agent team execution — pass full tasklist to a team, let it self-organize with inter-agent communication (Claude teams)
  - Research and dynamic context — dynamic research agents build domain context on demand, compress it before planners/implementers receive it (vertical codebase slices → research doc → compress)
  - Learning via SME feedback over time (corrections and real knowledge gain)
  - Learning via test feedback and human fixes (corrections and gates)
  - Test case evolution and hardening from feedback (bugs always covered; why they happened feeds learning + evals)
  - Self-improving feedback loop — outputs and feedback feed back in, generate learning, improve the system with less human oversight over time
  - Root context discovery — identify weak root context, ensure a strong base of rules, immutable knowledge, standards, best practices, and working style is defined up front to prevent drift
- `CLAUDE.md` has a new rule: any change to `defaults/` agent or command files requires a cohesion pass over related artifacts.

## Edge cases

- If any of the three files are referenced by `init-orchestrator.md` or another command, remove the reference before deleting. Check before assuming they're cleanly unused.
- TODO.md is at project root, not inside `.orchestration/` — keep it there.
