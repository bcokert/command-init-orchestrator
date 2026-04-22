**Type:** Task (AI agent)
**Date:** 2026-04-21

---

### 1. Intent

No record exists of what questions were asked, what decisions were made, or why the system is in its current state. Questions, iteration history, and key decisions live only in the agent's session context — lost when the session ends. This slice adds an `observability/` directory to each project, populated automatically during `plan-project` runs. Three files: a running question log, an iteration replay log, and a decision log.

Only `defaults/commands/plan-project.md` changes. Version `2.7.0 → 2.8.0`.

---

### 2. Observable outcomes

```
Given a new project being created by plan-project
When the project directory is initialized
Then observability/questions.md, observability/iterations.md, observability/decisions.md are created with empty template headers
```

```
Given plan-project running interviewQuestions()
When questions are asked
Then they are appended to observability/questions.md with a timestamp and open/answered status
```

```
Given plan-project completing a planIteration pass
When the pass ends
Then a timestamped entry is appended to observability/iterations.md: current state, what changed, why
```

```
Given plan-project making a key decision via updatePlanningContext
When the decision is recorded
Then it is appended to observability/decisions.md with reasoning and rejected alternatives
```

```
Given an existing project without observability/ (old project)
When plan-project runs on it
Then observability/ is created with empty template files; no error
```

```
Given observability/ files deleted mid-project
When plan-project runs
Then files are recreated as empty templates; project state is unaffected
```

---

### 3. Constraints

**Must:**
- Add observability/ directory creation to project setup in Phase 0 Step 4. Write three files with empty template headers (see template format below).
- Add question logging to the interview / Phase 2 section: each batch of questions asked must be appended to questions.md with timestamp and initial `open` status; answers update those entries to `answered`.
- Add iteration logging to planIteration: append to iterations.md at the end of each pass.
- Add decision logging to wherever key decisions are made (design doc resolved-decisions sections, major routing choices): append to decisions.md.
- Add crash recovery: if plan-project detects observability/ is missing mid-project, recreate empty templates and continue.
- Bump version: `2.7.0 → 2.8.0`.

**Must not:**
- Block project operation on observability failures. If a write to an observability file fails, log a warning and continue — observability is never load-bearing.
- Touch any file outside `defaults/commands/plan-project.md`.

**Template format:**
```markdown
# Questions log
<!-- Format: ## YYYY-MM-DD HH:MM — [open|answered] Question text -->
```
```markdown
# Iteration log
<!-- Format: ## YYYY-MM-DD HH:MM — [state] What changed. Why. -->
```
```markdown
# Decision log
<!-- Format: ## YYYY-MM-DD HH:MM — Decision. Why. Rejected: alternatives. -->
```

**Escalation triggers:**
- If existing plan-project structure has no clear place for "key decisions" (no updatePlanningContext section): note where decisions are currently recorded and add logging there; report what you found.

---

### 4. Done definition

- Read plan-project.md: Step 4 project creation includes `mkdir observability/` and writes three template files.
- Read plan-project.md: Phase 2 interview section references questions.md for question logging.
- Read plan-project.md: planIteration or equivalent section appends to iterations.md.
- Read plan-project.md: key decision points reference decisions.md.
- Read plan-project.md: crash recovery section (or missing-files note) covers observability/ recreation.
- Version reads `2.8.0`.

---

### 5. Breakdown

| # | Step | Deliverable | Done signal |
|---|------|-------------|-------------|
| 1 | Add observability/ creation to project setup + crash recovery | Step 4 creates dir + 3 template files; missing-files note added | Read file: Step 4 has mkdir observability/ and 3 Write calls; crash recovery note present |
| 2 | Add question logging to Phase 2 interview | Questions appended to questions.md on ask; answers update status | Read file: Phase 2 references questions.md with append logic |
| 3 | Add iteration + decision logging | planIteration appends to iterations.md; decisions appended to decisions.md | Read file: both append operations present in relevant sections |
| 4 | Version bump and coherence pass | Version `2.8.0`; no contradictions | Frontmatter reads `2.8.0` |
