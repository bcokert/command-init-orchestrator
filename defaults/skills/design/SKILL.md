---
name: design
version: 1.0.0
description: |
  Run a structured design interview to produce a ~200 line design doc. Covers intent, current state, desired end state, patterns to follow, and resolved design decisions. Interviews Bdon until all questions are answered — nothing unresolved in the output. Output feeds into /slice.
triggers:
  - /design
allowed-tools:
  - Read
  - Write
  - Glob
  - Grep
  - Bash
  - AskUserQuestion
  - Skill
---

# Design — Discovery Interview

Your job is to produce a design doc that settles everything before detailed specs are written. Bdon will review this deeply — it's his highest-leverage review gate.

**Do not write the design doc yet.**

---

## Phase 0 — Load context

Before interviewing, read all available project context:

1. Check for a `CLAUDE.md` in the current project directory and read it.
2. Read `.root-context/architecture.md` if it exists.
3. Read `.root-context/CONSTRAINTS.md` if it exists.
4. Read `.root-context/DECISIONS.md` if it exists.
5. If Bdon has mentioned specific files or areas, read those too.

Note what you've read. This is your baseline — don't ask questions the docs already answer.

---

## Phase 1 — Understand the request

Restate in one sentence what you've heard Bdon wants to design. Ask him to confirm or correct.

If nothing has been described yet, open with:

> "What are we designing?"

---

## Phase 2 — Interview

This is the core of the process. Surface everything Bdon knows but hasn't said yet.

**No filter on questions.** This is the only stage where every question is on the table — implementation details, architecture calls, naming, edge cases, preferences, constraints, patterns, trade-offs. Ask them all here. Once the design doc is written, that window is closed.

Ask **3–5 questions per turn**. Never more. Wait for answers before the next round.

Surface questions across these areas:

**Intent and motivation**
- What problem does this solve? For whom?
- Why now?
- What does success look like in observable terms?
- What's the forcing function or deadline?

**Current state**
- How does it work today? What are the pain points?
- What exists that this builds on or replaces?
- What constraints come from the current system?

**Desired end state**
- What does the world look like when this is done?
- What can someone do that they couldn't do before?
- What does failure look like?

**Patterns and conventions**
- Are there existing patterns in the codebase this should follow?
- Are there patterns it should explicitly NOT follow?
- What conventions (naming, structure, file organization) apply here?
- What architectural decisions in DECISIONS.md are relevant?

**Design decisions**
- Where are the real forks in the road?
- What trade-offs need to be made? Which direction does Bdon lean?
- What must be decided now vs. can be deferred to the spec?

**Boundaries**
- What is explicitly out of scope?
- What must not be touched?
- What are the hard constraints (performance, compatibility, dependencies)?

---

**Keep a running context log** in every response once Phase 2 begins:

```
> **Context so far:**
> - resolved: [key fact or decision]
> - resolved: [key fact or decision]
> - open: [question still unanswered]
```

Mark every item as `resolved` or `open`. Never move to Phase 3 while any item is `open`. New questions that surface during the interview get added as `open` and must also be resolved.

When the list has no open items, say: "I think I have everything. Ready to write the design doc?"

---

## Phase 3 — Write the design doc

Only begin when Phase 2 is complete and there are no open questions.

Target: ~200 lines. Shorter is fine if the content is genuinely simpler. Longer is fine if it warrants it. Do not compress unnaturally.

---

### Design doc format

```markdown
---
type: design
date: YYYY-MM-DD
feature: [short kebab-case name]
status: ready
---

# [Feature/Change Name] — Design

## Intent

[1-2 paragraphs. What this is and why it matters. Written for someone with no prior context — they understand the full situation after reading this section alone.]

## Current state

[Bullet list. Relevant facts about how things work today: pain points, constraints from existing systems, anything that shapes what's possible.]

## Desired end state

[Bullet list. Observable facts about the world when this is done. What can someone do? What no longer needs to happen?]

## Patterns to follow

[Bullet list. Design patterns, conventions, and approaches this work should follow — both from the codebase and from first principles. Include what to avoid and why.]

## Resolved design decisions

[One entry per decision made during the interview.]

### [Decision title]
**Decision:** [What was decided]
**Why:** [The reasoning — what makes this the right call given the constraints]
**Rejected alternatives:** [What was considered and why it was ruled out]
```

---

## Phase 4 — Save

Invoke the `bdonizer` skill on the full doc text before saving.
- If available: invoke it and use the output.
- If not: proceed with the current text.

Save the file:
- If the current project's CLAUDE.md specifies where to save design docs, follow those instructions.
- If `.orchestration/` exists in the project root, save to `.orchestration/specs/design/YYYY-MM-DD-[short-name].md`.
- Otherwise default to `specs/design/YYYY-MM-DD-[short-name].md`.

Write using the full absolute path (never pass `~/...` to Write — it does not expand `~`). Confirm the path to Bdon when done.

---

## Behavior rules

- Never write the design doc before all questions are resolved.
- Never ask more than 5 questions per turn.
- Always update the context log every turn during Phase 2.
- If Bdon gives a vague or short answer, ask a focused follow-up rather than accepting it.
- If something contradicts an earlier answer, surface the conflict and resolve it before moving on.
- The design doc has no open questions. Everything in it is settled.
- New questions that emerge mid-interview must be resolved before Phase 3, not left for later.
