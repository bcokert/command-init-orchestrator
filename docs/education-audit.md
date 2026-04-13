# Education audit

Audit of all 4 command files: every stage-transition output, gate message, and error message checked for "what to do next" guidance.

**Summary:** 22 checks, 3 gaps found and fixed.

## Results

| Command | Location | Output type | Has "what next"? | Fix applied |
|---------|----------|-------------|------------------|-------------|
| /design | Phase 0: no in-progress projects | no-op guidance | yes — "run /design to continue" | — |
| /design | Phase 0: wrong-command routing (all rows) | error | yes — each names the right command | — |
| /design | Phase 4: design_review gate | stage transition | yes — "run /design to continue to slicing" | — |
| /design | Phase 5: slicing_review gate | stage transition | yes — "run /design to continue to spec" | — |
| /design | Phase 5: draft slice blocking | stop | yes — "set status: reviewed, run /design" | — |
| /design | Phase 6: spec_review gate | stage transition | yes — "run /design to continue to breakdown" | — |
| /design | Phase 6: signoff_review blocking | stop | yes — "run /review first" | — |
| /design | Phase 7: tasks_ready gate | stage transition | yes — "run /implement to start implementation" | — |
| /implement | Phase 0: no ready projects, none implementing | stop | yes — "run /design to start one" | — |
| /implement | Phase 0: no ready projects, some implementing | stop | yes — "Pass a project ID to resume one of the above" | — |
| /implement | Phase 0: wrong-command routing (all rows) | error | yes — each names the right command | — |
| /implement | Phase 1: worktree creation failure | error | yes — project stays at tasks_ready, implied re-run | — |
| /implement | Phase 1: worktree directory missing on resume | error | yes — "run git worktree prune, then re-run /implement" | — |
| /implement | Phase 3: blocked dependency | stop | no | Added: "Fix the task's depends_on field or complete the prerequisite task, then re-run /implement" |
| /implement | Phase 4: QA passed, signoff_review | stage transition | yes — "run /review to approve or provide feedback" | — |
| /review | Phase 0: no signoff_review projects | stop | no | Added: "Run /implement to execute tasks, or /design to start a new project" |
| /review | Phase 0: wrong-command routing (all rows) | error | yes — each names the right command | — |
| /review | Phase 1: merge conflict | stop | yes — "resolve manually then re-run /review" | — |
| /review | Phase 1: dirty worktree before removal | stop | no | Added: "check what's uncommitted with `git status` in the worktree, then re-run /review" |
| /review | Phase 1: archive collision | stop | yes — "resolve manually before re-running /review" | — |
| /review | Phase 2: feedback recorded | output | yes — "Run /design to review and spec the next slice" | — |
| /status | All outputs | informational | yes — review reminders name the right command; "no active projects" says "run /design" | — |

## Notes

- The `/implement` dependency-blocked message was technically implied (re-run after fixing) but not stated. Made explicit.
- The `/review` "no projects awaiting signoff" case is less common but still needs guidance — user may not know whether to run `/implement` or `/design`.
- The dirty worktree warning was actionable but didn't say how to investigate — added `git status` suggestion.
