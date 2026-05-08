---
version: 2.1.0
description: |
  Takes a slices doc (and its linked design doc) and writes a full Delegation Brief for an AI agent. No discovery interview — that happened in /plan-project. Self-contained output: test vectors, explicit escalation paths, independently verifiable breakdown.
allowed-tools:
  - Read
  - Write
  - Glob
  - Grep
  - Bash
  - AskUserQuestion
---

# Spec — delegation brief for AI agents

Read a slices doc and write a complete Delegation Brief an AI agent can execute without asking questions.

**No discovery interview.** That happened in `/plan-project`. If something is genuinely unresolvable from the available docs, ask the user — one clarifying question, not a session.

State, schemas, principles live in `.root-context/state-diagram.md`. Helper used: `support/bdonize.md` (voice).

---

## Phase 0 — Load inputs

If a slices doc path was passed as argument, read it. Also read the linked design doc (from the `design:` frontmatter field). If no path was passed: "Which slices doc are we writing a spec for? (path to file)".

Also read any project context referenced — architecture files, CONSTRAINTS.md, DECISIONS.md.

---

## Phase 1 — Confirm scope

Restate in 2-3 sentences what the spec will cover. Ask the user to confirm or correct before writing.

---

## Phase 2 — Write the delegation brief

A complete brief the agent can execute without asking. If they'd need to ask, the spec is incomplete.

```markdown
# Brief {NN} — {title}

**Type:** Task (AI agent)
**Date:** [today]

## 1. Intent

What this is and why it matters. Written for an agent with no prior context — they understand the full situation from this section alone.

## 2. Observable outcomes

One scenario per slice from the slices doc:

Given [starting condition]
When [the action taken]
Then [the observable result]

Cover the happy path for each slice, key edge cases, and failure modes.

## 3. Constraints

**Must:** Non-negotiable requirements.
**Must not:** Hard prohibitions.
**Preferences:** Soft guidance — what to do when multiple approaches are viable.
**Escalation triggers:** Conditions where the agent must stop and check in rather than proceed.

## 4. Done definition

Observable outcomes an independent person can verify without reading code. One clear signal per item. Include specific test vectors — known-good inputs and expected outputs.

## 5. Breakdown

Each slice from the slices doc becomes one or more sub-tasks. Each sub-task is independently verifiable and small enough for a focused session.

| # | Step | Deliverable | Done signal |
|---|------|-------------|-------------|
| 1 | ... | ... | ... |
```

---

## Phase 3 — Stress test

1. Could an agent understand the full problem from Intent alone?
2. Is every constraint specific enough to be enforceable?
3. Do Done Definition items verify without reading code?
4. Does the spec include an explicit escalation path?
5. Test vectors present, not just descriptions of what to test?
6. Did anything from the slices doc not make it into the breakdown?

Fix any issues.

---

## Phase 4 — Bdonize and save

Apply voice patterns inline per `support/bdonize.md` before saving.

Save to `.orchestration/projects/{id}/03-briefs/{NN}-{slug}.md`. When called from `/plan-project`, the project id and slice number are passed as context. When called standalone, derive from the project folder structure.

Write using the full absolute path. Confirm the path.

---

## Behavior rules (spec deltas)

Shared rules live in `.root-context/state-diagram.md`.

- No discovery interview. Read the docs, write the spec.
- Ask the user only if something is genuinely unresolvable from the available docs.
- The spec is done when an agent could execute it without asking anything.
