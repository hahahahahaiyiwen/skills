---
name: claim-issue
description: Claim an Azure DevOps work item, create task branch/worktree, and post start comment.
---

# Claim Issue

## When to use
Use when starting a Todo task.

## Lightweight preflight
Before running task lifecycle steps, verify orchestration context is loaded:
- If `CORE.md` and `DEV-FLOW.md` guidance is already present in the active context, continue.
- If either is missing or uncertain, run `orchestrator-boot` first, then continue.

## Required inputs
- Work item ID.
- Organization URL `$Env:ADO_ORCH_ORG_URL`.
- Project name `$Env:ADO_ORCH_PROJECT`.
- All repository keys from `$Env:ADO_ORCH_REPO_KEYS`.

## Steps
1. Read work item details:
   - `az boards work-item show --id <id> --organization $env:ADO_ORCH_ORG_URL`
2. Determine the repository for the work item based on area path or other metadata, and set respository key `$repoKey`.
3. Create branch name `$branch` as work item id:
   - `<id>`
4. Route to main repository path and create worktree:
   - `cd ([Environment]::GetEnvironmentVariable("ADO_ORCH_REPO_${repoKey}_PATH"))`
   - `git fetch origin`
   - `git worktree add ../$repoKey-$branch -b "$branch" $Env:ADO_ORCH_REPO_DevOpsDeploymentAgents_TARGET_BRANCH`
5. Post a `## CLAIM` comment using the standard structure, summarizing the claim and next steps.
   - Use the universal Work Item Comment API convention from `orchestrator-boot/references/CORE.md`.
   - Use `az devops invoke --area wit --resource comments --api-version 7.1-preview` with JSON `--in-file` payload, then verify latest comment.
6. Route to new worktree:
   - `cd ../$repoKey-$branch`
7. Restore any necessary dependencies or perform setup steps to prepare for development.
   - `msbuild /t:restore` or `dotnet restore` or similar as needed.
8. Begin development on the task in the new worktree.

## Guardrails
- Do not claim if another active owner is clearly working unless user requests takeover.
- Keep all implementation work inside the new worktree.

## Output
- Work item title
- Branch name
- Worktree path
- Next development step

## Work Item Comment Template
```powershell
$body = @'
## CLAIM
Claiming this work item and starting work.
### Work Item
`#<id>` - <work-item-title>
### Branch
`<branch>`
### Next Steps
1. Implement xxx
'@
```
