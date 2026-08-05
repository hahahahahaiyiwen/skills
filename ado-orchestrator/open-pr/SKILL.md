---
name: open-pr
description: Create or update pull request for a task branch and record linkage in the work item thread.
---

# Open PR

## When to use
Use after implementation and verification pass in the task worktree.

## Lightweight preflight
Before running task lifecycle steps, verify orchestration context is loaded:
- If required `ADO_ORCH_*` environment variables for this skill are present, continue and do not run `orchestrator-boot`.
- Run `orchestrator-boot` only when required variables are missing or empty.

## Required input
- Work item ID.
- PR ID.
- Working branch name `$branch`.
- Organization URL `$Env:ADO_ORCH_ORG_URL`.
- Project name `$Env:ADO_ORCH_PROJECT`

## Steps
1. Run project checks/tests in worktree.
2. Push latest branch:
   - `git push -u origin $branch`
3. Create PR:
   - `az repos pr create --source-branch $branch --target-branch ([Environment]::GetEnvironmentVariable("ADO_ORCH_REPO_${repoKey}_TARGET_BRANCH")) --title "<title>" --description "Related work item: #<id>" --work-items <id> --organization $env:ADO_ORCH_ORG_URL --project $env:ADO_ORCH_PROJECT`
4. Post a `## PROGRESS` comment using the standard structure, summarizing the PR creation and next steps.
   - Use the universal Work Item Comment API convention from `orchestrator-boot/references/CORE.md`.
   - Use `az devops invoke --area wit --resource comments --api-version 7.1-preview` with JSON `--in-file` payload, then verify latest comment.
5. Monitor review comments and respond with code updates as needed.

## Guardrails
- Do not run branch-specific git operations from the main repository worktree.
- Do not open PR with failing required checks unless user explicitly allows.
- Keep PR scoped to work item acceptance criteria.

## Output
- PR URL
- Verification summary
- Pending review actions (if any)

## Work Item Comment Template
```powershell
$body = @'
## PROGRESS
PR opened: <pr-url>
Scope: <summary>
Next: waiting for review
'@
```
