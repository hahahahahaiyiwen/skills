---
name: orchestrator-boot
description: Bootstrap project mapping or load core orchestration context before task execution.
---

# Orchestrator Boot

## Source of truth and governance
- GitHub is the single source of truth for task state and cross-session continuity:
  - Task definition: Issue body
  - Progress/handoff: Issue comments (`## HANDOFF`)
  - Task state: Project Board
  - Ownership: task branch naming
- Governance and workflow standards are loaded from `references/CORE.md` and `references/DEV-FLOW.md`.

## When to use
Use at session start in either mode:
- Bootstrap mode: initialize `references/RESOURCE-MAP.yml` when mapping is missing.
- Execution mode: load core context before selecting or continuing work.

## Inputs
- `references/CORE.md`
- `references/DEV-FLOW.md`
- `references/RESOURCE-MAP.yml`

## Steps
1. Read the three required reference files above.
2. Check `references/RESOURCE-MAP.yml` completeness.
3. If mapping is missing or placeholder-only:
   - Ask user for org, board, repo map, and infrastructure basics.
   - Update `references/RESOURCE-MAP.yml`.
   - Output bootstrap summary and stop.
4. If mapping is ready:
   - Read `organization.name` and `organization.project_board.number`.
   - Load operational routing from `references/CORE.md` and `references/DEV-FLOW.md`.
   - Run `gh project item-list <NUMBER> --owner <ORG> --format json`.
   - Summarize board lanes: Todo, In Progress, Done.
   - Present lifecycle skills loaded for execution:
     - `board-status`, `claim-issue`, `continue-issue`, `handoff-issue`, `open-pr`, `iterate-pr`, `complete-issue`
   - Present available issues for user to claim. Ask user to choose an issue to work on.

## Output
- Bootstrap mode: completed mapping summary.
- Execution mode: current board snapshot, loaded lifecycle skills, and next action options.
