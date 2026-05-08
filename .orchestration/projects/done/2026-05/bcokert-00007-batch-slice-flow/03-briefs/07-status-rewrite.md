# Brief 07 — /status rewrite

**Type:** Task (AI agent)
**Date:** 2026-05-06

## 1. Intent

`/status` (170 lines) duplicates the multi-project scan logic, has two separate count-format definitions, restates the date-format rule per render block, and keeps two parallel tables (state abbreviations, next-action commands). Rewrite using the shared next-actions reader, merge the tables, dedupe formatting rules. ~27% shrinkage. No user-visible behavior change.

## 2. Observable outcomes

```
Given /status before this slice
When the user runs it
Then output is visually identical to before
```

```
Given /status before this slice
When the file is counted
Then ≤ ~125 lines (from 170)
```

```
Given /status before this slice
When a reader looks for state-to-command mapping
Then a single merged table (state | abbrev | emoji | command) holds it
```

```
Given /status after this slice
When the date-format rule is searched
Then it appears once, not per render block
```

## 3. Constraints

**Must:**
- Phase 2 multi-project scan replaced with next-actions.md reader call.
- Sort tiebreak (most-recent first; project-ID descending) preserved via reader.
- Single merged state/abbrev/emoji/command table.
- Single date-format rule sentence.
- Cut legacy `reviewed` and `specced` rows.
- Trim Behavior rules.
- Mirror to `.claude/commands/status.md`. Bump version (minor).

**Must not:**
- Change visible output for the user.
- Remove any state value from the table — every active state has a row.

**Preferences:**
- Keep emoji/abbrev short and visually scannable.

**Escalation triggers:**
- If the merged table loses readability vs. two separate tables, ask before splitting back.

## 4. Done definition

- `defaults/commands/status.md` line count ≤ 125.
- `.claude/commands/status.md` matches defaults.
- One state table; one count-format definition; one date-format rule.
- Visual diff: `/status` output before/after this slice is identical.

## 5. Breakdown

| # | Step | Deliverable | Done signal |
|---|------|-------------|-------------|
| 1 | Phase 2 rewrite | next-actions.md reader call; sort + active-project filter from reader | Phase 2 ≤ ~10 lines |
| 2 | Merge state tables | Single table state \| abbrev \| emoji \| command; legacy aliases dropped | One table; complete states |
| 3 | Dedupe count + date format | Single Counts format definition; date rule hoisted to one line | grep returns one match each |
| 4 | Behavior rules trim + mirror + version bump + size verify | Trim; mirror; ≤ 125 lines | All checks pass |
