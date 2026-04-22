# Agent context — command-init-orchestrator

## IMPORTANT — Orchestration change tracking
<!-- installed by init-orchestrator -->

Before making any code, document, or artifact changes in this repository, verify the work
is covered by an active project and slice in `.orchestration/projects/`.

If there is no active project covering the change:
1. Ask the user whether to create a new project (`/plan-project`) or add it as a slice to an existing one.
2. Only proceed without a project if the user explicitly confirms this is a one-off change.

This rule exists to prevent commits from bypassing the planning and review process. Changes
made outside the orchestration system skip spec, breakdown, QA, and signoff — the exact
review gates the system was built to enforce.

---

## Two sets of command files

`.claude/commands/` — local install. Changes here affect only this repo.

`defaults/commands/` — source shipped to users. When someone runs `/init-orchestrator`, these files are copied into their project. Changes here ship to everyone.

If you change `defaults/commands/`, also sync `.claude/commands/` so the change applies locally (enables dogfooding the update immediately).

**Version bumping is required** whenever you modify any file in `defaults/` or `init-orchestrator.md`. Clients compare `version:` fields to decide whether to self-update — a content change with no version bump is invisible to them. Bump patch for fixes, minor for new behaviour, major for breaking changes.

## Diagrams

`docs/diagrams/*.d2` — source of truth. Never edit SVGs directly.

`docs/diagrams/*.svg` — derived artifacts. Regenerate from source:

```bash
d2 docs/diagrams/name.d2 docs/diagrams/name.svg
```

## Keeping docs in sync

When you modify `defaults/commands/` in a way that changes flow, stages, or command names:

1. Update the affected `.d2` files in `docs/diagrams/`
2. Re-render the SVGs
3. Update `README.md` prose if the change affects how the system is described
4. Update `defaults/README.md` as well if any commands, stages, or folder structure have changed

Diagrams that may need updating:
- `lifecycle.d2` — stage transitions, human gates
- `artifacts.d2` — artifacts created at each stage
- Common-patterns gallery (`pause-resume.d2`, `concurrent-projects.d2`, etc.) — if command behaviour changes

---

## Diagram-first enforcement

Any slice whose implementation changes state machine behavior must have "update `state-diagram.md` and any affected `.root-context/` files" as its **first breakdown task**.

**Triggers** (include the diagram task):
- Adding, removing, or changing transitions, states, guards, or key behavioral principles

**Non-triggers** (skip the diagram task):
- Renaming files or variables, docs-only changes, observability additions that don't affect transitions or states

**At spec-write time (plan-project breakdown):** include the diagram-update task as the first step in the breakdown table before any implementation tasks.

**At implementation time:** if the first task in a state-machine-touching slice does not update the diagram, add it before proceeding.

**"No update needed" is not a silent skip.** The diagram-update task must run regardless. If the diagram is already accurate, the task confirms that, records the confirmation, and marks done.

**Cohesion pass:** after any `.root-context/` file is updated during implementation, run a forward cohesion pass over all unimplemented current-project artifacts (design docs, slices, briefs, task files). Scope is current project only — other projects reload root-context on their next `/plan-project` run.

**Ambiguity policy:** when unclear whether a change affects state machine behavior, include the diagram task. False positive beats false negative.
