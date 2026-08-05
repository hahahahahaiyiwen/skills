---
name: complete-review-pr
description: Clean up PR review workspace by removing review worktree and review temp artifacts.
---

# Complete Review PR

## When to use
Use after `review-pr` is finished and you want to remove local review artifacts.

## Lightweight preflight
Before running task lifecycle steps, verify orchestration context is loaded:
- If required `ADO_ORCH_*` environment variables for this skill are present, continue and do not run `orchestrator-boot`.
- Run `orchestrator-boot` only when required variables are missing or empty.

## Required input
- Repository key `$repoKey` (for example `DevOpsDeploymentAgents`).
- Reviewed branch `$reviewBranch` (for example `user/<alias>/feature`).
- Workspace root path (default: current repo root parent where `repos/` and `temp/` exist).

## Steps
1. Resolve mapped repository path:
   - `$repoPath = [Environment]::GetEnvironmentVariable("ADO_ORCH_REPO_${repoKey}_PATH")`
   - `cd <workspace-root>`
   - `$repoRoot = Join-Path <workspace-root> $repoPath`
2. Normalize review branch name for filesystem-safe artifact names:
   - `$safeBranch = ($reviewBranch -replace '[^A-Za-z0-9._-]','-')`
3. Compute expected review worktree path:
   - `$reposRoot = (Get-Item (Join-Path <workspace-root> 'repos')).FullName`
   - `$worktreePath = Join-Path $reposRoot ("{0}-review-{1}" -f $repoKey, $safeBranch)`
4. Remove review worktree if it exists:
   - `if (Test-Path $worktreePath) { git -C $repoRoot worktree remove --force $worktreePath }`
   - `git -C $repoRoot worktree prune`
5. Remove review temp artifacts:
   - `$tempDir = Join-Path <workspace-root> 'temp'`
   - `Get-ChildItem -Path $tempDir -Filter ("review-{0}*" -f $safeBranch) -ErrorAction SilentlyContinue | Remove-Item -Force`
6. Verify cleanup:
   - `Test-Path $worktreePath` should be `False`
   - `Get-ChildItem $tempDir -Filter ("review-{0}*" -f $safeBranch)` should return no files

## Guardrails
- Only remove paths matching the exact review worktree naming convention: `${repoKey}-review-${safeBranch}`.
- Only remove temp artifacts matching `review-${safeBranch}*`.
- Do not delete unrelated worktrees or temp files.

## Output
- Repository key and reviewed branch
- Removed worktree path (or "not found")
- Removed temp artifact list (or "none")
- Final cleanup verification status
