**Type:** Task (AI agent)
**Date:** 2026-04-22

---

### 1. Intent

`.root-context/state-diagram.md` is declared the canonical architecture of the orchestration system. No enforcement mechanism backs that claim. Slices get specced, broken down, and implemented without any check against the diagram. The resulting drift has produced real bugs: commits happening at wrong times, inconsistent slice independence behavior, state machine semantics contradicting what the diagram says.

This task adds enforcement via two rule additions to CLAUDE.md (project-local, not the global command files):

1. **Spec-write time (plan-project breakdown):** any slice whose implementation changes state machine behavior must have "update state-diagram.md and affected root-context files" as its first breakdown task. The agent writes this task before any other breakdown step for that slice.

2. **Implementation time (implementing agent):** if the agent encounters a task that changes state machine behavior and the diagram update hasn't run yet in this slice, it adds the diagram-update task first, before proceeding.

Both rules also cover the cohesion pass: after any `.root-context/` file is updated during implementation, the implementing agent sweeps all unimplemented current-project artifacts (design docs, slices, briefs, task files) for consistency.

The rule lives in `CLAUDE.md` because the agent reads it at session start and it stays in scope for all operations. No command files change.

---

### 2. Observable outcomes

**Happy path — state-machine-touching breakdown**
```
Given a breakdown for a slice that adds a new state or transition
When plan-project writes the task list
Then task 01 is "update state-diagram.md and affected root-context files"
  before any implementation tasks appear
```

**Diagram already current**
```
Given the diagram-update task runs and the diagram already reflects the change
When the task completes
Then it records "confirmed: no update needed" and marks done
  (not a silent skip — the record is the artifact)
```

**Brief missing the diagram task**
```
Given a brief that predates this rule, with no diagram task in the breakdown
When the implementing agent reads its first task
Then it detects the missing diagram task, adds it before the first existing task,
  and proceeds
```

**Root-context update triggers cohesion pass**
```
Given any .root-context/ file is updated during implementation
When the update completes
Then the implementing agent runs a forward cohesion pass over all unimplemented
  artifacts in the current project (design docs, slices, briefs, task files)
```

**Ambiguity defaults to inclusion**
```
Given it's unclear whether a change touches state machine behavior
When the agent makes the call at breakdown time
Then it includes the diagram-update task
  (false positive beats false negative)
```

**Cohesion pass respects in-flight tasks**
```
Given tasks are already at done or in_progress when the cohesion pass runs
When the pass sweeps artifacts
Then only unimplemented artifacts are updated; done/in-progress tasks are not re-opened
```

---

### 3. Constraints

**Must:**
- Add a "Diagram-first enforcement" section to `CLAUDE.md` in the project root.
- Name trigger conditions precisely: adding, removing, or changing transitions, states, guards, or key behavioral principles.
- Name non-trigger conditions explicitly: renaming, docs-only changes, observability additions that don't affect transitions or states.
- State the first-task requirement at both spec-write time and implementation-start time.
- State the "confirm no update needed" requirement — task must run, record, and mark done even when the diagram is already correct.
- State the cohesion pass rule with the correct trigger: any `.root-context/` file update (not just state machine behavior changes).
- State the scope: current project only. Other projects reload root-context on their next plan-project entry.
- State the ambiguity policy: when unclear, include the diagram task.

**Must not:**
- Modify any file in `defaults/commands/`, `.claude/commands/`, or any agent definition.
- Apply the rule retroactively to already-done tasks.

**Preferences:**
- Keep the CLAUDE.md section tight. It's a rule, not a tutorial.
- Mirror the trigger/non-trigger language from `state-diagram.md` where it already exists.

**Escalation triggers:**
- CLAUDE.md already has a conflicting rule that overlaps with what you're adding: stop, describe the conflict, and ask before proceeding.

---

### 4. Done definition

All items below are checkable by reading `CLAUDE.md` — no code required.

1. `CLAUDE.md` has a new section explicitly named or titled "Diagram-first enforcement" (or equivalent clear heading).
2. Section lists trigger conditions and includes: transitions, states, guards, key behavioral principles.
3. Section lists non-trigger conditions and includes: renaming, docs-only, observability.
4. Section states the "first task in breakdown" rule at spec-write time.
5. Section states the implementation-start detection rule (implementing agent adds missing task).
6. Section states the "confirm no update needed" policy — task runs regardless, records outcome.
7. Section states cohesion pass triggers on "any `.root-context/` file update."
8. Section states current-project-only scope.
9. Section states ambiguity policy (include when unclear).

**Test vectors:**

| # | Input | Expected |
|---|-------|----------|
| T1 | Read the trigger list in the new section | "transitions," "states," "guards," and "key behavioral principles" all appear |
| T2 | Read the non-trigger list | "renaming," "docs-only," and "observability" (or equivalent) all appear |
| T3 | Read for the implementation-start check | Section describes an implementing agent adding the task if missing — not just "check it exists" |
| T4 | Read for the cohesion pass trigger | Trigger is "any .root-context/ file updated," not limited to "state machine behavior changed" |
| T5 | Read for the "no update needed" policy | Confirms task must run and record, not skip |

---

### 5. Breakdown

| # | Step | Deliverable | Done signal |
|---|------|-------------|-------------|
| 1 | Add "Diagram-first enforcement" section to `CLAUDE.md` | Updated `CLAUDE.md` with the complete rule block | Section exists; all 9 Done definition items present |
| 2 | QA: verify section against done definition and test vectors | QA report: each test vector checked, each Done definition item confirmed or flagged | All T1–T5 pass; any gaps fixed before marking done |
