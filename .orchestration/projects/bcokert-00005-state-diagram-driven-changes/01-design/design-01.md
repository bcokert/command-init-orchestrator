---
type: design
date: 2026-04-21
feature: state-diagram-driven-changes
project_id: bcokert-00005-state-diagram-driven-changes
status: review
---

# State diagram driven changes — Design

## Intent

`.root-context/state-diagram.md` is the canonical architecture of the orchestration system. It defines every valid state, transition, and key behavioral rule. In practice, that status is aspirational — the diagram can be bypassed silently. Slices get specced and implemented without anyone checking whether the proposed change conflicts with or requires updating the diagram. The drift that results is the source of the bugs Bdon has seen: commits landing at wrong times, slice independence behaving inconsistently, behavior contradicting what the state machine says.

This project adds enforcement. Any slice whose implementation changes state machine behavior (transitions, states, key rules) must include "update state-diagram.md and any affected root-context files" as its first task. After that update, the agent runs a forward cohesion pass on all unimplemented artifacts in the current project. This is automatic — the agent enforces it at spec/breakdown time via a rule in this project's CLAUDE.md.

## Current state

- `.root-context/state-diagram.md` is declared source of truth in CLAUDE.md and in the existing design docs.
- No enforcement mechanism exists. The agent can write specs, task breakdowns, and implement slices without ever referencing the diagram.
- plan-project breakdown derives tasks from the brief's breakdown table only. There is no step that checks whether state machine behavior is being changed.
- Known drift incidents: commits happening at wrong times, inconsistent slice independence behavior.
- `.root-context/` currently contains only `state-diagram.md`. The rule should cover any future root-context files as well.

## Desired end state

- CLAUDE.md contains an explicit, automatic rule: any spec brief for a slice that modifies state machine behavior must have "update state-diagram.md and affected root-context files" as the first breakdown step.
- At implementation time, if an implementing agent encounters a task that changes state machine behavior and the diagram hasn't been updated yet in this slice, it stops and updates it first.
- After any root-context file is updated during implementation, the agent runs a forward cohesion pass: all unimplemented artifacts in the current project (design docs, slices, briefs, task files) are reviewed and updated for consistency with the new root-context content.
- Scope is current project only. Other active projects pick up root-context changes the next time plan-project runs for them, which already runs a fresh context load on entry.
- The rule is general — it covers all `.root-context/` files, not just `state-diagram.md`. The diagram is the primary case but not the only one.

## Patterns to follow

- CLAUDE.md is the right enforcement point. The agent reads it at session start; rules there are always in scope.
- Do not modify `defaults/commands/plan-project.md` for this. The CLAUDE.md rule instructs the agent at spec/breakdown writing time to include the diagram update as a task. That's sufficient without modifying the generic command.
- "State machine behavior" means: adding, removing, or changing transitions; adding or removing states; changing guards; changing key behavioral principles. Renaming files, updating docs, or adding observability that doesn't affect transitions/states does not trigger the rule.
- Cohesion pass follows `updateArtifacts` semantics from `state-diagram.md`: forward pass over all unimplemented artifacts in order, update each for consistency, surface new open questions if any.
- This rule applies to project `bcokert-00004-state-machine-refactor` as well, treated as if the diagram was just created (which it effectively was). The breakdown for whichever 00004 slice first touches state machine behavior should have a diagram verification/update task first.

## Key edge cases

- **Slice touches state machine behavior but diagram is already up to date**: the first task runs, confirms no update needed, documents that, and proceeds. Not a no-op — the confirmation is the artifact.
- **Multiple slices in a project all touch state machine behavior**: each gets the diagram-update task as its first step. Slices run in order; the second slice's diagram task confirms or extends the first slice's update.
- **Root-context update triggers cohesion pass during active implementation**: cohesion pass covers unimplemented artifacts only. Tasks already marked `done` or `implementing` are not re-opened. Cohesion pass may update future task files.
- **Spec is written without the rule being followed (old behavior)**: if the brief's breakdown table has no diagram-update step but should, the implementing agent catches it. Rule applies at both spec-write time and implementation-start time.
- **Agent doesn't know whether a change affects state machine behavior**: err on the side of including the diagram task. False positives (confirming no update needed) are cheaper than false negatives (missing a diagram update).

## Resolved design decisions

**CLAUDE.md as enforcement location, not defaults/commands.** The rule is project-specific — the state diagram and root-context are not universal concepts across all orchestrator installs. Putting it in this project's CLAUDE.md keeps it scoped correctly and doesn't bloat the generic commands. Rejected: modifying `plan-project.md` to add diagram-check logic (wrong abstraction level; diagram is a project concern, not a command concern).

**Automatic, not a prompted checklist.** The agent enforces it by including the task in the breakdown, not by asking Bdon "did you update the diagram?" Rejected: surfacing a pre-spec checklist (friction without reliability; it's easier to skip a checkbox than to skip a task in the queue).

**First task in the slice, not a separate slice.** A separate "update diagram" slice would add planning overhead and potentially create ordering dependencies across projects. Embedding it as the first task in the slice that needs it keeps it local, sequenced correctly, and low-overhead. Rejected: separate diagram-update slice per project (too much ceremony for what's often a targeted change).

**Current project scope for cohesion pass.** Other active projects will reload root-context when they next run plan-project. That's already the correct behavior — forcing a cross-project cohesion pass from here would require knowing what other projects exist and their state, adding fragility. Rejected: cross-project cohesion pass (too coupled; the natural re-entry point already handles it).

**Rule covers all `.root-context/` files.** The diagram is the primary case, but root-context files are by definition shared architecture context. Any of them changing deserves a cohesion pass. Rejected: diagram-only rule (too narrow; creates a maintenance gap as root-context expands).

## Agent decisions

**Project 00004 is in scope.** The design doc for 00004 predates this rule but the slices haven't been written yet. When 00004 slices are generated, the diagram-first rule should apply to whichever slice first modifies state machine behavior. Context: the diagram was created as part of 00004's design; it's effectively "just updated." Alternative: treat 00004 as exempt — would undermine the point of this project on the highest-impact pending work.

**"Confirm no update needed" counts as fulfilling the task.** Rather than skipping the diagram task when nothing changes, the task produces a brief confirmation artifact. This makes intent visible in the task history and prevents the task from being incorrectly marked done before it's run. Alternative: skip the task if diagram is current — silently; harder to audit.
