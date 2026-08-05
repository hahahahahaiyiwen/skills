---
name: complete-issue
description: Complete work item lifecycle by completing PR, syncing main, and cleaning task worktree.
---

# Complete Issue
## When to use
Use after PR is approved and ready to merge.

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
- Project name `$Env:ADO_ORCH_PROJECT`.

## Steps
1. Complete PR:
   - `az repos pr update --id <pr-id> --status completed --delete-source-branch true --organization $env:ADO_ORCH_ORG_URL --project $env:ADO_ORCH_PROJECT`
2. Sync local main:
   - `cd ([Environment]::GetEnvironmentVariable("ADO_ORCH_REPO_${repoKey}_PATH"))`
   - `git pull --ff-only`
3. Remove task worktree:
   - `git worktree remove ../repos/${repoKey}-${branch}`
4. Delete local branch if still present.
5. Post a `## COMPLETE` comment using the standard structure, summarizing the completion and verification.
   - Use the universal Work Item Comment API convention from `orchestrator-boot/references/CORE.md`.
   - Use `az devops invoke --area wit --resource comments --api-version 7.1-preview` with JSON `--in-file` payload, then verify latest comment.

## Output
- Completed PR number
- Work item final status
- Cleanup confirmation

## Work Item Comment Template
```powershell
$body = @'
## COMPLETE
PR #<pr-id> completed.
### Change Summary
- Added ...
- Modified ...
### Verification
- [x] Tests passed
- [x] Build passed
'@
```
