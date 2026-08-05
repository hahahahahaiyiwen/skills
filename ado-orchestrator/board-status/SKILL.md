---
name: board-status
description: Show current Azure DevOps Board task status grouped by workflow lane.
---

# Board Status

## When to use
Use when the user asks what is available or what is currently in progress.

## Lightweight preflight
Before running task lifecycle steps, verify orchestration context is loaded:
- If `CORE.md` and `DEV-FLOW.md` guidance is already present in the active context, continue.
- If either is missing or uncertain, run `orchestrator-boot` first, then continue.

## Steps
1. Run:
   - `az boards query --wiql "Select [System.Id],[System.Title],[System.State],[System.TeamProject],[System.AssignedTo],[System.AreaPath] From WorkItems Where [System.TeamProject] = '$env:ADO_ORCH_PROJECT' And [System.AssignedTo] = '$env:ADO_ORCH_BOARD_ASSIGNED_TO' And [System.AreaPath] Under '$env:ADO_ORCH_BOARD_AREA' Order By [System.ChangedDate] Desc" --organization $env:ADO_ORCH_ORG_URL --project $env:ADO_ORCH_PROJECT`
2. Group items by status lane.
3. Return concise list with:
   - Work Item ID
   - Title
   - Assigned To
   - Lane

## Output
- Actionable view of available tasks to claim or continue
