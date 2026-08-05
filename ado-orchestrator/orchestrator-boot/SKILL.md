---
name: orchestrator-boot
description: Bootstrap project mapping or load core orchestration context before task execution.
---

# Orchestrator Boot

## Source of truth and governance
- Azure DevOps Board is the single source of truth for task state and cross-session continuity:
  - Task definition: Work Item fields/description
  - Progress/handoff: Work Item comments (`## HANDOFF`)
  - Task state: Azure Boards column/state
  - Ownership: task branch naming
- Governance and workflow standards are loaded from `references/CORE.md` and `references/DEV-FLOW.md`.

## When to use
Use at session start in either when bootstraping the orchestration context for the first time or when required environment variables are missing. Do not run if context is already loaded.

## Inputs
- `references/CORE.md`
- `references/DEV-FLOW.md`
- `references/RESOURCE-MAP.yml`
- `scripts/Initialize-OrchestrationRepos.ps1`
- `scripts/Load-ResourceMapEnv.ps1`

## Steps
1. Read `references/CORE.md` and `references/DEV-FLOW.md`.
2. Check `references/RESOURCE-MAP.yml` completeness.
3. If mapping is missing or placeholder-only:
   - Ask user for org URL, project, board/team, repo map, and infrastructure basics.
   - Update `references/RESOURCE-MAP.yml`.
   - Initialize mapped repositories (idempotent; clones missing repo paths using each repo `target_branch`) by running:
     - `. .\.github\skills\orchestrator-boot\scripts\Initialize-OrchestrationRepos.ps1`
4. Load map values into environment variables for this session by running script:
   - `. .\.github\skills\orchestrator-boot\scripts\Load-ResourceMapEnv.ps1`
5. Run `az boards query --wiql "Select [System.Id],[System.Title],[System.State],[System.TeamProject],[System.AssignedTo],[System.AreaPath] From WorkItems Where [System.TeamProject] = '$env:ADO_ORCH_PROJECT' And [System.AssignedTo] = '$env:ADO_ORCH_BOARD_ASSIGNED_TO' And [System.AreaPath] Under '$env:ADO_ORCH_BOARD_AREA' Order By [System.ChangedDate] Desc" --organization $env:ADO_ORCH_ORG_URL --project $env:ADO_ORCH_PROJECT`.
   - Summarize board lanes: Todo, Active, Done.
   - Present lifecycle skills loaded for execution:
     - `board-status`, `claim-issue`, `continue-issue`, `handoff-issue`, `open-pr`, `iterate-pr`, `complete-issue`
   - Present available work items for user to claim. Ask user to choose a work item to work on.

## Output
- Current board snapshot, loaded lifecycle skills, and next action options.
