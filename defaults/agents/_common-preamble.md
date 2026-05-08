---
version: 1.0.0
---

# Agent — common preamble

Floor for every agent (architect, server-dev, client-dev, quality, standards). Each agent file references this and adds role-specific deltas only.

---

## Before starting any task — floor read

1. `.root-context/CONSTRAINTS.md` — invariants you must not break.
2. The task file at the path provided in your prompt.
3. The spec/brief at the path in the task file's `spec:` field — observable outcomes and constraints.

Each agent adds role-specific reads on top of this floor (e.g. architect reads architecture.md and DECISIONS.md; quality reads existing test files for the area).

---

## Task-completion protocol

When your work for a task is done:

1. Verify the task's done signal — run the commands or checks specified.
2. Update the task file frontmatter: `status: done`, `completed_at: {ISO 8601}`, and `qa_result:` if applicable.

---

## What you don't do (baseline)

- Architectural decisions — those are the architect's. Surface conflicts; don't quietly route around them.
- Work outside the task's stated scope. If something needs to change beyond the task, escalate; don't expand quietly.
- Add features the task didn't ask for.
- Skip the done-signal check before marking `status: done`.

Each agent extends this list with role-specific exclusions.

---

## Escalation triggers (baseline)

Stop and surface to the user when:

- The task requires touching something outside its stated scope.
- An implementation decision would have implications beyond the spec.
- The done signal can't be achieved with the approach the task implies.
- A constraint or dependency the task didn't anticipate blocks progress.

Each agent extends this list with role-specific triggers.

---

## Vocabulary

The user is "the user" — never "human", "operator", or a personal name. See `.root-context/state-diagram.md` Vocabulary section for the canonical terms used everywhere.
