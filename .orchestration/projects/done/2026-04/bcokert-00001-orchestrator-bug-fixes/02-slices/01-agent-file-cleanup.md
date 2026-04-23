---
type: slice
slice: 01
order: 01
project: orchestrator-bug-fixes
design: .orchestration/projects/bcokert-00001-orchestrator-bug-fixes/01-design/design-01.md
status: done
status_updated_at: "2026-04-23T00:00:00-07:00"
---

# Slice 01 — Agent file cleanup

**Goal:** Fix all 5 remaining agent files to reference current paths. Remove lead.md from defaults and local installs. Update init-orchestrator.md to match.

## Happy path

- All 5 agent files in `defaults/agents/` and `.claude/agents/` reference only paths that exist in the current layout (`.orchestration/projects/`, `.orchestration/support/`, task/brief paths under the project directory).
- `lead.md` is absent from `defaults/agents/` and `.claude/agents/`.
- `init-orchestrator.md` no longer lists `lead.md` in its agent install list.
- `standards.md` no longer references `.orchestration/root-context/lessons/`.
- Version numbers bumped on every modified agent file (patch bump minimum; minor if behavior changed).
- `.claude/agents/` stays in sync with `defaults/agents/` — same files, same content.

## Edge cases

- Old installs already have `lead.md` in their `.claude/agents/`. This slice doesn't touch them. Document the gap: users must re-run `/init-orchestrator` to get the updated set; the init's old-file detection covers commands only, not agents.
- If an agent file references a path that no longer exists and no obvious replacement exists, flag it explicitly rather than guessing. Don't invent a path that doesn't exist yet.
- `init-orchestrator.md` installs agents by copying files from `defaults/agents/` — removing `lead.md` from `defaults/` is sufficient; no other install-list change is required if the init loops over the directory rather than a hardcoded list. Verify before assuming.
- Version bump applies to each modified file independently — don't bump files that weren't changed.
