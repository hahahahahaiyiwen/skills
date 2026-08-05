---
name: continue-issue
description: Resume an in-progress Azure DevOps work item by restoring branch, worktree, and handoff context.
---

# Continue Issue

## When to use
Use when the user says `continue #N` or wants to resume existing work.

## Lightweight preflight
Before running task lifecycle steps, verify orchestration context is loaded:
- If required `ADO_ORCH_*` environment variables for this skill are present, continue and do not run `orchestrator-boot`.
- Run `orchestrator-boot` only when required variables are missing or empty.

## Required input
- Work item ID.
- Organization URL `$Env:ADO_ORCH_ORG_URL`.
- Project name `$Env:ADO_ORCH_PROJECT`.

## Steps
1. Read work item + comments:
   - `az boards work-item show --id <id> --organization $env:ADO_ORCH_ORG_URL`
   - `az devops invoke --area wit --resource comments --route-parameters project=$Env:ADO_ORCH_PROJECT workItemId=<id> --query-parameters '$top=200' --api-version 7.1-preview`
2. Find latest `## HANDOFF` comment.
3. Resolve repository path and locate existing branch:
   - `$repoKey = "<REPO_KEY>"`
   - `cd ([Environment]::GetEnvironmentVariable("ADO_ORCH_REPO_${repoKey}_PATH"))`
   - `git fetch origin`
   - `git branch -a | Select-String "<id>"`
   - `$branch = (matched branch name)`
4. Fetch and attach worktree:
   - `git fetch origin "$branch"`
   - `git worktree add ../$repoKey-$branch -b "$branch"`
5. Post a `## CONTINUE` comment using the standard structure, summarizing the restored context and next steps.
   - Use the universal Work Item Comment API convention from `orchestrator-boot/references/CORE.md`.
   - Use `az devops invoke --area wit --resource comments --api-version 7.1-preview` with JSON `--in-file` payload, then verify latest comment.
6. Route to worktree and continue development.
   - `cd ../$repoKey-$branch`

## Guardrails
- If no branch exists, stop and recommend using `claim-issue`.
- If branch diverges, report exact state and ask user whether to rebase or continue.

## Output
- Work item title
- Branch name
- Worktree id
- Worktree path
- Summary of progress and next steps

## Work Item Comment Template
```powershell
$body = @'
## CONTINUE
Resuming work on this item.
### Restored Context
- Done: xxx
- In progress: yyy
### Branch
`42-user-auth`
### Next Steps
1. Complete zzz
2. Test aaa
'@
```
