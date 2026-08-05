---
name: iterate-pr
description: Update pull request from review feedback and record progress in the work item thread.
---

# Iterate PR

## When to use
Process review comments before merge.

## Lightweight preflight
Before running task lifecycle steps, verify orchestration context is loaded:
- If required `ADO_ORCH_*` environment variables for this skill are present, continue and do not run `orchestrator-boot`.
- Run `orchestrator-boot` only when required variables are missing or empty.

## Required input
- Work item ID.
- PR ID.
- Organization URL `$Env:ADO_ORCH_ORG_URL`.
- Project name `$Env:ADO_ORCH_PROJECT`

## Steps
1. Read PR review context.
  - PR summary/status: `az repos pr show --id <pr-id> --organization $env:ADO_ORCH_ORG_URL --project $env:ADO_ORCH_PROJECT`
  - Reviewer state: `az repos pr reviewer list --id <pr-id> --organization $env:ADO_ORCH_ORG_URL --project $env:ADO_ORCH_PROJECT`
  - Thread/comments (advanced): use Azure DevOps PR discussion UI when deeper thread inspection is needed.
2. If you do not agree with a comment, reply with concise technical rationale in the PR thread.
3. If you agree, make code changes, push, and reply in the PR thread with what changed.
  - `git add . && git commit -m "fix: address PR review comments"`
  - `git push`
4. Post a `## PROGRESS` comment using the standard structure, summarizing the updates and next action.
  - Use the universal Work Item Comment API convention from `orchestrator-boot/references/CORE.md`.
  - Use `az devops invoke --area wit --resource comments --api-version 7.1-preview` with JSON `--in-file` payload, then verify latest comment.
## Output
- PR URL
- Verification summary

## Work Item Comment Template
```powershell
$body = @'
## PROGRESS
PR updated to address review comments.
Scope: <summary>
Next: waiting for review
'@
```
