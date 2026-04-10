---
name: migrate
version: 1.0.0
description: |
  Takes an existing spec, brief, or research doc and runs it through the full design → slice → spec → breakdown pipeline. Uses the existing doc to seed the design interview, compressing what's already known. Human reviews deeply at design and slice; lightly at spec.
triggers:
  - /migrate
allowed-tools:
  - Read
  - Write
  - Glob
  - Grep
  - Bash
  - AskUserQuestion
---

# Migrate — Existing Doc Through Full Pipeline

Takes an existing spec, brief, or research doc and runs it through the full pipeline in one session. Review gates let you correct before the next step inherits anything wrong.

```
[research] → design interview → [deep review] → slice → [deep review] → spec → [skim] → breakdown
```

---

## Phase 0 — Load research

Read `.orchestration/config.yaml` and `.orchestration/root-context/LINK.md` (then the linked root context files).

If a file path was passed as argument, read it. This is your research context — existing delegation brief, rough notes, previous spec, anything. Extract the key facts:

- What's being built or changed
- Known current state
- Known constraints or decisions
- What the end state looks like

Hold these as pre-resolved context for the design interview. Don't ask questions the research already answers.

If no file was passed, ask: "Which existing doc are we migrating? (path to file)"

---

## Phase 1 — Design interview

Read and follow `.orchestration/skills/design/SKILL.md` in full.

Seed the context log with facts from Phase 0 as `resolved` items before starting the interview. Only ask about what's genuinely missing or ambiguous — the existing doc compresses the interview significantly.

When the design doc is written and saved, proceed to the review gate.

---

## Review gate 1 — Design

```
Design doc saved: {path}

Highest-leverage review. Check:
- Intent captures the real problem
- Current state is accurate and complete
- Desired end state is observable
- Patterns to follow match what you actually want
- Design decisions are the right calls

Corrections here are free. Corrections after slicing cost more.

Edit the file directly, then say "continue" — or describe what to fix and I'll update it.
```

Wait. Apply any corrections, confirm, proceed.

---

## Phase 2 — Slice

Read and follow `.orchestration/skills/slice/SKILL.md` in full.

Pass the design doc path from Phase 1 as input. When the slices doc is written and saved, proceed to the review gate.

---

## Review gate 2 — Slices

```
Slices doc saved: {path}

Check:
- Are these vertical? Each should deliver something observable end-to-end.
- Are slices small enough? (If one looks like a sprint, it's probably two.)
- Is the sequence right?
- Is each validation signal checkable without reading code?

Edit the file directly, then say "continue".
```

Wait. Apply any corrections, confirm, proceed.

---

## Phase 3 — Spec

Read and follow `.orchestration/skills/spec/SKILL.md` in full.

Pass the slices doc path from Phase 2 as input. When the delegation brief is written and saved, proceed to the review gate.

---

## Review gate 3 — Spec

```
Delegation brief saved: {path}

Light review — agent-facing:
- Intent gives enough context for an agent with no prior knowledge
- Observable outcomes cover happy path and edge cases
- Constraints are specific enough to enforce
- Breakdown maps cleanly to the slices

Say "continue" or flag anything that needs fixing.
```

Wait. Apply any corrections, confirm, proceed.

---

## Phase 4 — Breakdown

Read and follow `.orchestration/skills/breakdown/SKILL.md` in full.

Pass the delegation brief path from Phase 3 as input.

---

## Phase 5 — Done

Report what was produced:
- Design doc: `{path}`
- Slices doc: `{path}`
- Delegation brief: `{path}`
- Task files: `.orchestration/specs/tasks/{spec-id}/` ({N} tasks)
- Dashboard: updated

Next step: `/implement` to kick off the first task.

---

## Behavior rules

- Never skip a review gate.
- If Bdon provides corrections at a gate, apply them before moving on.
- The research context compresses the interview — don't re-ask what you already know, but don't skip questions whose answers you're genuinely unsure of.
- Each phase reads the corresponding skill file and follows it completely before the next gate.
