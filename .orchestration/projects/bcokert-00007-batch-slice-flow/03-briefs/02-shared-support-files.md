# Brief 02 — shared support files

**Type:** Task (AI agent)
**Date:** 2026-05-06

## 1. Intent

Three new shared support files give later slices the helpers they need to deduplicate logic: `next-actions.md` (queue/state reader), `status-write.md` (frontmatter helper), `bdonize.md` (voice block). They also need to be installed by `/init-orchestrator` so downstream repos pick them up.

## 2. Observable outcomes

```
Given .orchestration/support/ before this slice
When a reader looks for next-actions.md / status-write.md / bdonize.md
Then all three exist with documented input/output contracts
```

```
Given a downstream repo running /init-orchestrator after this slice
When the install loop runs
Then the three new files install at .orchestration/support/{next-actions,status-write,bdonize}.md
```

```
Given a command needs to enumerate active projects
When it reads next-actions.md's contract
Then it sees a tuple shape (project_id, artifact_kind, artifact_id, status, status_updated_at, next_actions) with artifact_kind ∈ {project_root, design, slice} and next_actions as a list of legal verbs
```

## 3. Constraints

**Must:**
- next-actions.md excludes `done/` from its scan.
- status-write.md is frontmatter-only — no logging side effects, no iterations.md write.
- bdonize.md content matches what slice/spec/plan-project currently restate verbatim.
- All three files start at `version: 1.0.0`.
- init-orchestrator.md install loop lists them under support files.

**Must not:**
- Add behavior beyond what the contract states.
- Make commands consume the new files in this slice — that's slices 04-08.
- Use "Bdon" or "human" in the new files; vocabulary is "user".

**Preferences:**
- Tuple shape names: SliceNextActions, DesignNextActions, ProjectNextActions (or similar) — Go-struct portable for 00006.

**Escalation triggers:**
- If existing bdonize blocks differ between slice/spec/plan-project, surface the diff before consolidating — pick the most complete version, not a merge of contradictions.

## 4. Done definition

- Three new files exist at `defaults/commands/{next-actions,status-write,bdonize}.md`.
- A grep of `defaults/commands/{next-actions,status-write,bdonize}.md` for "Bdon" returns no matches.
- A re-run of `/init-orchestrator` against a fresh checkout installs the files at `.orchestration/support/{next-actions,status-write,bdonize}.md`.
- next-actions.md contract specifies exclusion of `done/` and the artifact_kind enum.
- status-write.md contract specifies frontmatter-only writes.

## 5. Breakdown

| # | Step | Deliverable | Done signal |
|---|------|-------------|-------------|
| 1 | Write next-actions.md | Contract: input none, output tuples (project_id, artifact_kind, artifact_id, status, status_updated_at, next_actions); excludes done/ | File exists with versioned frontmatter |
| 2 | Write status-write.md | Contract: inputs (project_id, slice_NN, new_status); writes status + status_updated_at; warn-and-continue on missing | File exists; frontmatter-only stated |
| 3 | Write bdonize.md | Voice block extracted from slice.md/spec.md/plan-project.md verbatim consolidation | File exists; content matches sources |
| 4 | Update init-orchestrator.md | Add three new files to support-file install loop; bump version | Install loop references all three |
| 5 | Verify install | Sandbox /init-orchestrator dry-run; confirm files land at .orchestration/support/ | All three files installed |
