---
name: spec
version: 2.0.0
description: |
  Takes a slices doc (and its linked design doc) and writes a full Delegation Brief for an AI agent. No discovery interview — that happened in /design. Self-contained output: test vectors, explicit escalation paths, independently verifiable breakdown.
triggers:
  - /spec
allowed-tools:
  - Read
  - Write
  - Glob
  - Grep
  - Bash
  - AskUserQuestion
  - Skill
---

# Spec — Delegation Brief for AI Agents

Your job is to read a slices doc and write a complete Delegation Brief an AI agent can execute without asking questions.

**No discovery interview.** That happened in `/design`. If something is genuinely unresolvable from the available docs, ask Bdon — but keep it tight. One clarifying question, not a session.

---

## Phase 0 — Load inputs

If a slices doc path was passed as an argument, read it. Also read the linked design doc (from the `design:` frontmatter field). If no path was passed, ask:

> "Which slices doc are we writing a spec for? (path to file)"

Also read any project context referenced — architecture files, CONSTRAINTS.md, DECISIONS.md.

---

## Phase 1 — Confirm scope

Restate in 2-3 sentences what the spec will cover. Ask Bdon to confirm or correct before writing.

---

## Phase 2 — Write the Delegation Brief

Write a complete brief for an AI agent. The agent must be able to execute this without asking questions. If they'd need to ask, the spec is incomplete.

---

## Delegation Brief

**Type:** Task (AI agent)
**Date:** [today]

---

### 1. Intent

What this is and why it matters. Written for an agent with no prior context — they understand the full situation from this section alone.

---

### 2. Observable outcomes

One scenario per slice from the slices doc:

```
Given [starting condition]
When [the action taken]
Then [the observable result]
```

Cover the happy path for each slice, key edge cases, and failure modes.

---

### 3. Constraints

**Must:** Non-negotiable requirements.

**Must not:** Hard prohibitions.

**Preferences:** Soft guidance — what to do when multiple approaches are viable.

**Escalation triggers:** Conditions where the agent must stop and check in rather than proceed.

---

### 4. Done definition

Observable outcomes an independent person can verify without reading the code. One clear signal per item.

Include specific test cases with known-good inputs and expected outputs — not descriptions of what to test, but actual test vectors.

---

### 5. Breakdown

Each slice from the slices doc becomes one or more sub-tasks. Each sub-task must be independently verifiable and small enough to complete in a focused session.

| # | Step | Deliverable | Done signal |
|---|------|-------------|-------------|
| 1 | ... | ... | ... |

---

*(End of Delegation Brief)*

---

## Phase 3 — Stress test

Before presenting:

1. Could an agent understand the full problem from the Intent section alone?
2. Is every constraint specific enough to be enforceable?
3. Do the Done Definition items not require reading code to verify?
4. Does the spec include an explicit escalation path — the agent knows when to stop rather than guess?
5. Are there actual test vectors, not just descriptions of what to test?
6. Did anything from the slices doc not make it into the breakdown?

Fix any issues found.

---

## Phase 4 — Save

Invoke the `bdonizer` skill on the full brief text before saving.
- If available: invoke it and use the output.
- If not: proceed with the current text.

Save the file:
- If the current project's CLAUDE.md specifies where to save specs, follow those instructions.
- If `.orchestration/` exists in the project root, save to `.orchestration/specs/briefs/YYYY-MM-DD-[short-name].md`.
- Otherwise default to `specs/YYYY-MM-DD-[short-name].md`.

Write using the full absolute path (never pass `~/...` to Write). Confirm the path to Bdon.

---

## Behavior rules

- No discovery interview. Read the docs, write the spec.
- Ask Bdon only if something is genuinely unresolvable from the available docs.
- The spec is done when an agent could execute it without asking anything.
- This skill is for AI agent delegation only. For human delegation, use `/delegate`.
