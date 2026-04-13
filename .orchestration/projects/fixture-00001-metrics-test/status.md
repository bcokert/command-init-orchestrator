stage: done
project_id: fixture-00001-metrics-test
worktree_path: .orchestration/worktrees/fixture-00001-metrics-test
branch: project/fixture-00001-metrics-test
next_action: project complete
transitions:
  - stage: design_in_progress
    timestamp: 2026-03-01T09:00:00+00:00
    note: project created
  - stage: design_review
    timestamp: 2026-03-01T09:45:00+00:00
    note: design interview complete
  - stage: slicing_in_progress
    timestamp: 2026-03-01T10:00:00+00:00
    note: slicing started
  - stage: slicing_review
    timestamp: 2026-03-01T10:20:00+00:00
    note: 2 slices created
  - stage: spec_in_progress
    timestamp: 2026-03-01T10:30:00+00:00
    note: spec started
  - stage: spec_review
    timestamp: 2026-03-01T11:00:00+00:00
    note: spec written for slice 01
  - stage: breakdown_in_progress
    timestamp: 2026-03-01T11:05:00+00:00
    note: breakdown started
  - stage: tasks_ready
    timestamp: 2026-03-01T11:15:00+00:00
    note: 2 tasks created for slice 01
  - stage: worktree_created
    timestamp: 2026-03-01T11:20:00+00:00
    note: worktree created at .orchestration/worktrees/fixture-00001-metrics-test
  - stage: implementing
    note: task execution started
    # timestamp missing — simulates interrupted write (crash between stage change and status.md update)
  - stage: signoff_review
    timestamp: 2026-03-01T14:30:00+00:00
    note: QA passed — 2 checks, 0 manual
  - stage: implementing
    timestamp: 2026-03-02T09:00:00+00:00
    note: task execution started — slice 02
  - stage: signoff_review
    timestamp: 2026-03-02T13:00:00+00:00
    note: QA passed — 2 checks, 0 manual (1 failure fixed during QA)
  - stage: feedback_pending
    timestamp: 2026-03-02T13:30:00+00:00
    note: 1 feedback slice added
  - stage: spec_in_progress
    timestamp: 2026-03-02T13:45:00+00:00
    note: spec started for slice 02.1
  - stage: tasks_ready
    timestamp: 2026-03-02T14:00:00+00:00
    note: 1 task created for slice 02.1
  - stage: implementing
    timestamp: 2026-03-02T14:05:00+00:00
    note: task execution started — slice 02.1
  - stage: signoff_review
    timestamp: 2026-03-02T15:30:00+00:00
    note: QA passed — 1 check, 0 manual
  - stage: done
    timestamp: 2026-03-02T15:45:00+00:00
    note: slice 02.1 approved — worktree removed, archived to done/2026-03/fixture-00001-metrics-test
