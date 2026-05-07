# Brief 03 — agent preamble extraction

**Type:** Task (AI agent)
**Date:** 2026-05-06

## 1. Intent

Five agent files share ~30 lines of duplicated read-order, "what you don't do", escalation triggers, and task-completion protocol. Extracting these into a `_common-preamble.md` cuts the per-invocation read tax and stops drift between agent files. "Bdon" purged from the agent files in the same pass since they ship to downstream users.

## 2. Observable outcomes

```
Given the five agent files before this slice
When a reader looks for "what does the agent read first"
Then each agent's read-order is its role-specific extension; the floor lives in _common-preamble.md
```

```
Given the five agent files after this slice
When a reader greps for "Bdon"
Then no matches in any agent file
```

```
Given a downstream repo running /init-orchestrator after this slice
When the agent-file install loop runs
Then _common-preamble.md installs alongside the five role agents
```

## 3. Constraints

**Must:**
- _common-preamble.md holds: floor read-order (.root-context/CONSTRAINTS.md + the task file), shared "What you don't do" baseline, common escalation triggers, task-completion protocol (`status: done` write).
- Each agent file references _common-preamble.md and lists role-specific deltas only.
- "Bdon" replaced with "the user" everywhere in agent files.

**Must not:**
- Lose role-specific behavior (e.g., architect's architecture trigger list, server-dev's Go-specific reads).
- Embed project-specific paths or content into _common-preamble.md (it ships to downstream users).
- Skip version bumps on the changed agent files.

**Preferences:**
- Keep role-specific deltas terse — one-line additions where possible.

**Escalation triggers:**
- If common-preamble's escalation list contradicts an agent's specific trigger, surface and resolve.

## 4. Done definition

- `defaults/agents/_common-preamble.md` exists.
- Five agent files reference _common-preamble.md.
- Combined agent corpus shrinks by ≥ 25 lines.
- `grep -in 'Bdon' defaults/agents/` returns no matches.
- init-orchestrator.md installs _common-preamble.md alongside the five agents.

## 5. Breakdown

| # | Step | Deliverable | Done signal |
|---|------|-------------|-------------|
| 1 | Write _common-preamble.md | Floor read-order, "what you don't do" baseline, escalation triggers, task-completion protocol | File exists with version 1.0.0 |
| 2 | Update architect.md | Trim duplicated content; reference preamble; purge Bdon; bump version | File ≤ original lines − duplicated content |
| 3 | Update server-dev.md | Same pattern | Same |
| 4 | Update client-dev.md | Same pattern | Same |
| 5 | Update quality.md | Same pattern | Same |
| 6 | Update standards.md | Same pattern; purge Bdon | Same |
| 7 | Update init-orchestrator.md | Install _common-preamble.md alongside agents | Install loop references it |
