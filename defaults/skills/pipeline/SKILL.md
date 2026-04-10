---
name: pipeline
version: 1.0.0
description: |
  Runs the full design → slice → spec → breakdown pipeline for a new feature or change. Starts with a fresh design interview, no prior research. Human reviews deeply at design and slice; lightly at spec.
triggers:
  - /pipeline
allowed-tools:
  - Read
  - Write
  - Glob
  - Grep
  - Bash
  - AskUserQuestion
---

# Pipeline — New Feature Full Flow

Runs the complete pipeline in one session for something new. Review gates between each step let you correct before the next step inherits anything wrong.

```
design interview → [deep review] → slice → [deep review] → spec → [skim] → breakdown
```

For migrating an existing spec or research doc through the pipeline, use `/migrate` instead.

---

## Phase 0 — Load context

Read `.orchestration/config.yaml` and `.orchestration/root-context/LINK.md` (then the linked root context files).

If Bdon has described what he wants to build in the conversation, start from that. If nothing has been described yet, ask: "What are we building?"

---

## Phase 1 — Design interview

Read and follow `.orchestration/skills/design/SKILL.md` in full.

No pre-seeded context — this is a fresh start. Run the full interview until all questions are resolved.

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
- Each phase reads the corresponding skill file and follows it completely before the next gate.
