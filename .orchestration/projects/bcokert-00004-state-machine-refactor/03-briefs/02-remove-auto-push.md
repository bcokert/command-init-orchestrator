**Type:** Task (AI agent)
**Date:** 2026-04-21

---

### 1. Intent

Every command file that calls `git push` does so automatically, without operator control. Push has external effects: it updates the remote and triggers CI. The operator should decide when this happens. This slice removes all automatic `git push` calls from `plan-project.md`, `implement.md`, and `review.md` in `defaults/commands/`. No behavioral logic changes — just push removal and description updates.

Target files: `defaults/commands/plan-project.md`, `defaults/commands/implement.md`, `defaults/commands/review.md`. Do not touch `.claude/commands/` (local install, updated separately via `/init-orchestrator`).

---

### 2. Observable outcomes

```
Given plan-project.md with git push lines in Phase 5, 6, and 7 On entry sections
When the push removal is applied
Then no git push appears anywhere in plan-project.md
```

```
Given review.md with git push in the approve path and archive path
When the push removal is applied
Then no git push appears anywhere in review.md
```

```
Given implement.md
When checked for git push
Then none exist (already clean — confirm and move on)
```

```
Given plan-project.md description frontmatter reading "Commits and pushes at each human approval gate"
When the update is applied
Then it reads "Commits at each human approval gate"
```

---

### 3. Constraints

**Must:**
- Remove every `git push` line from plan-project.md (Phases 5, 6, 7 entry blocks and Phase 7 after-breakdown block).
- Remove every `git push` line from review.md (approve path and archive path).
- Update plan-project.md description in frontmatter: remove "and pushes".
- Remove any prose referencing "pushed to remote" in gate messages or status outputs.
- Bump versions: plan-project `2.4.0 → 2.5.0`, review `1.3.0 → 1.4.0`.
- If implement.md has no push (verify first), confirm and do not modify its version.

**Must not:**
- Remove any `git add` or `git commit` lines — only push.
- Touch any file outside `defaults/commands/`.
- Touch `.claude/commands/`.

**Escalation triggers:**
- If a `git push` line appears in an unexpected context (e.g., inside a conditional that implies it's intentional non-automatic behavior): stop and report before removing.

---

### 4. Done definition

- Read plan-project.md: zero occurrences of `git push`. Version is `2.5.0`. Description does not mention "pushes".
- Read review.md: zero occurrences of `git push`. Version is `1.4.0`.
- Read implement.md: zero occurrences of `git push` (pre-existing). Version unchanged.
- No changes to any other file.

---

### 5. Breakdown

| # | Step | Deliverable | Done signal |
|---|------|-------------|-------------|
| 1 | Remove git push from plan-project.md and update description | All push lines removed; frontmatter description updated; version `2.5.0` | Read file: no `git push`, version `2.5.0`, description clean |
| 2 | Remove git push from review.md | All push lines removed; version `1.4.0` | Read file: no `git push`, version `1.4.0` |
| 3 | Confirm implement.md is clean | No push lines found; no version change needed | Read file: no `git push`; version unchanged |
