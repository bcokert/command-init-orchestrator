# Brief 09 — init-orchestrator consolidated gate + delete defaults/config.yaml

**Type:** Task (AI agent)
**Date:** 2026-05-06

## 1. Intent

`/init-orchestrator` currently has three near-identical install loops (commands / support / agents) and prompts per file on version mismatch — up to 12 prompts on a re-run. The design's batch principle says one consolidated gate. `defaults/config.yaml` is also a confirmed orphan that references commands that don't exist; deleting it removes a stale artifact.

## 2. Observable outcomes

```
Given /init-orchestrator before this slice
When the user re-runs on a downstream repo with N drifted files
Then one prompt fires: "{N} files would update — accept all / review per-file / skip"
```

```
Given the user picks "accept all"
When the install proceeds
Then all updates apply with a one-line summary; no further prompts
```

```
Given the user picks "review per-file"
When the install proceeds
Then today's per-file prompt flow runs as fallback (regression-tested behavior)
```

```
Given the user picks "skip"
When the install completes
Then the install is untouched; the report lists which files would have updated
```

```
Given defaults/ before this slice
When grep searches for config.yaml references
Then none in any command, agent, or support file (orphan confirmed)
```

```
Given defaults/ after this slice
When ls defaults/config.yaml runs
Then file does not exist
```

## 3. Constraints

**Must:**
- Audit defaults/config.yaml references project-wide before deletion.
- Collapse three install loops into one parameterized loop driven by a file-class table.
- Implement consolidated gate with three options (accept all / review per-file / skip).
- "review per-file" branch must function exactly as today's flow.
- "skip" must report would-have-updated paths.
- Annotate "old 7-command files" detection list to clarify path/class distinction.
- Bump init-orchestrator.md version (minor).

**Must not:**
- Change UX for fresh checkout (no gate; just install).
- Lose the version-bump prompt logic — only consolidate it.
- Break a downstream repo on first re-run after this slice ships.

**Preferences:**
- Default to "accept all" on a plain "yes" response.

**Escalation triggers:**
- If config.yaml has any non-trivial references, stop deletion and surface for review.

## 4. Done definition

- One consolidated update gate visible in init-orchestrator.md.
- Three install loops collapse to one.
- defaults/config.yaml does not exist; no remaining references.
- "skip" branch reports would-have-updated paths.
- "review per-file" branch passes a manual regression check (3 files of different states: missing / same / drifted).

## 5. Breakdown

| # | Step | Deliverable | Done signal |
|---|------|-------------|-------------|
| 1 | Audit + delete defaults/config.yaml | Zero references; file deleted | grep + ls confirm |
| 2 | Collapse install loops | Single parameterized loop with file-class table | One loop, three classes |
| 3 | Consolidated update gate | Three-option prompt: accept all / review per-file / skip | Gate visible |
| 4 | "review per-file" fallback + "skip" reporting | Each branch works per spec | Manual regression on 3 file states |
| 5 | Annotate "old 7-command files" detection list + version bump | Path/class note added; version bumped | Comment present |
