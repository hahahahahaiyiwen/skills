---
name: handoff-issue
description: Save structured task handoff to Azure DevOps work item comment for cross-session continuation.
---

# Handoff Issue

## When to use
Use before ending session when the work item is not complete.

## Lightweight preflight
Before running task lifecycle steps, verify orchestration context is loaded:
- If required `ADO_ORCH_*` environment variables for this skill are present, continue and do not run `orchestrator-boot`.
- Run `orchestrator-boot` only when required variables are missing or empty.

## Required input
- Work item ID.
- PR ID.
- Repository key `$repoKey`.
- Working branch name `$branch`.
- Organization URL `$Env:ADO_ORCH_ORG_URL`.
- Project name `$Env:ADO_ORCH_PROJECT`

## Working directory routing
- Run `git status`, `git log`, and `git push` from the active issue worktree:
  - `repos/$repoKey-$branch`

## Steps
1. Ensure latest local commits are pushed to task branch.
2. Collect state:
  - Completed work
  - In-progress work
  - Next steps
  - Notes/risks
  - Branch and commit SHA
3. Post a `## HANDOFF` comment using the standard structure, summarizing the current state and next steps for the work item.
  - Use the universal Work Item Comment API convention from `orchestrator-boot/references/CORE.md`.
  - Use `az devops invoke --area wit --resource comments --api-version 7.1-preview` with JSON `--in-file` payload, then verify latest comment.

## Output
- Confirmation of handoff comment posted with summary of current state and next steps.

## Work Item Comment Template
```powershell
$body = @'
## HANDOFF
### Current Status
- Done: xxx
- In progress: yyy
### Branch
`42-user-auth`
### Next Steps
1. Complete zzz
2. Test aaa
### Notes
- bbb needs special handling
'@
```
