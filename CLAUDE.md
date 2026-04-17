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
