---
type: brief
slice: 05
project: bcokert-00003-remove-worktree-replace-task-queuing
date: 2026-04-18
---

# Delegation brief — slice 05: model/effort metadata on tasks and phases

**Type:** Task (AI agent)
**Date:** 2026-04-18

---

### 1. Intent

Currently every phase of the orchestrator runs at the session's default model and effort level — there's no way to specify per-task or per-phase requirements. This slice adds `model` and `effort` metadata fields to task files and annotates the two phases that need elevated capability: the design interview (plan-project) and QA.

The design interview shapes everything downstream — wrong decisions here are expensive. QA must catch what implementation missed — a missed failure is worse than a slow pass. Both get `model: opus, effort: max`. Everything else defaults to `model: sonnet, effort: default`.

The mechanism for how `model`/`effort` get *applied* is intentionally left loose — the spec surfaces these values to the executing agent when presenting each task. Actual model-switching or subagent spawning is future work.

---

### 2. Observable outcomes

**Happy path — task file format:**
```
Given a project that completes plan-project breakdown
When task files are generated
Then each task file has model and effort fields in its frontmatter,
  with values sonnet and default respectively
```

**Happy path — plan-project annotation:**
```
Given defaults/commands/plan-project.md
Then Phase 2 (interview) header or preamble includes "model: opus, effort: max"
```

**Happy path — QA annotation:**
```
Given .orchestration/support/qa.md
Then it includes "model: opus, effort: max" in its header or Phase 0 preamble
```

**Happy path — implement surfaces model/effort:**
```
Given a task file with model: opus, effort: max
When /implement presents the task kickoff
Then it includes the model and effort values in the task presentation
```

**Edge — old task files without model/effort:**
```
Given a task file with no model or effort fields
When /implement presents it
Then it treats missing fields as sonnet/default and proceeds normally
```

---

### 3. Constraints

**Must:**
- Add `model` and `effort` to the task file frontmatter template in `defaults/commands/plan-project.md` Phase 7 (breakdown). Default values: `model: sonnet`, `effort: default`.
- In plan-project Phase 2 (interview), add a preamble or annotation indicating `model: opus, effort: max`. A comment or header note is sufficient — this is metadata for the agent reading the command, not runtime enforcement.
- In `.orchestration/support/qa.md`, add `model: opus, effort: max` annotation to the frontmatter or Phase 0 preamble.
- In `defaults/commands/implement.md` Phase 2 (task execution), include the task's `model` and `effort` values when presenting the kickoff for each task. If the fields are absent: default to `sonnet`/`default`.
- Bump `defaults/commands/plan-project.md` version: 2.2.1 → 2.3.0 (new fields in task format).
- Bump `defaults/commands/implement.md` version: already 2.3.0 after slice 03 — bump to 2.4.0.
- Sync `.claude/commands/plan-project.md` and `.claude/commands/implement.md` from defaults after editing.
- Do not commit anything.

**Must not:**
- Add any runtime model-switching logic, API calls, or subagent spawning. This is metadata surfacing only.
- Change the `agent_type` derivation logic in plan-project.
- Modify the QA verification or reporting logic — only annotate the phase.

**Preferences:**
- Annotation style: a brief note at the top of the relevant phase (e.g. `<!-- model: opus, effort: max -->`  or a plain text line like `> Model: opus · Effort: max`) — whatever reads naturally in the command file's format.

**Escalation triggers:**
- If the plan-project task file template is in a code block that would be broken by adding fields — restructure the template cleanly rather than cramming fields in awkwardly. Flag if the change would affect any other part of the command.

---

### 4. Done definition

- Task file template in `defaults/commands/plan-project.md` includes `model: sonnet` and `effort: default` fields.
- Phase 2 of plan-project has a visible `model: opus, effort: max` annotation.
- `.orchestration/support/qa.md` has a visible `model: opus, effort: max` annotation.
- `defaults/commands/implement.md` task kickoff includes model/effort from the task file.
- Both `.claude/commands/` files are synced.

**Test vectors:**
```
grep "model:" defaults/commands/plan-project.md
→ matches at least: model: sonnet (in template) and model: opus (in phase annotation)

grep "model:" .orchestration/support/qa.md
→ at least one match

grep "model\|effort" defaults/commands/implement.md
→ matches in task kickoff section

diff defaults/commands/plan-project.md .claude/commands/plan-project.md
→ no output

diff defaults/commands/implement.md .claude/commands/implement.md
→ no output
```

---

### 5. Breakdown

| # | Step | Deliverable | Done signal |
|---|------|-------------|-------------|
| 1 | Edit `defaults/commands/plan-project.md` | Task file template has `model`/`effort` fields; Phase 2 annotated with opus/max; version 2.3.0 | `grep "model:" defaults/commands/plan-project.md` → matches template + annotation |
| 2 | Edit `.orchestration/support/qa.md` | `model: opus, effort: max` annotation added to header or Phase 0 | `grep "model:" .orchestration/support/qa.md` → one match |
| 3 | Edit `defaults/commands/implement.md` | Task kickoff surfaces model/effort; missing fields default to sonnet/default; version 2.4.0 | `grep "model\|effort" defaults/commands/implement.md` → matches in kickoff section |
| 4 | Sync `.claude/commands/` | Both plan-project.md and implement.md copied from defaults | Both diff commands → no output |
