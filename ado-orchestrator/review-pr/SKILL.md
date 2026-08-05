---
name: review-pr
description: Ask for repo and branch, create a review worktree, diff vs target branch, and start review.
---

# Review PR

## When to use
Use when you want to review a branch against the repository target branch without opening or depending on a PR first.

## Lightweight preflight
Before running task lifecycle steps, verify orchestration context is loaded:
- If required `ADO_ORCH_*` environment variables for this skill are present, continue and do not run `orchestrator-boot`.
- Run `orchestrator-boot` only when required variables are missing or empty.

## Required input
- Organization URL `$Env:ADO_ORCH_ORG_URL`.
- Project name `$Env:ADO_ORCH_PROJECT`.
- Repository key `$repoKey` for the repository to review.
- Branch to review `$reviewBranch` (for example `user/<username>/feature`).
- Workspace root path (default: current directory that contains `repos/` and `temp/`).

## Steps
1. Ask user for `$repoKey` and `$reviewBranch`.
2. Resolve and validate repository mapping:
   - `$workspaceRoot = (Get-Location).Path`
   - `$repoPath = [Environment]::GetEnvironmentVariable("ADO_ORCH_REPO_${repoKey}_PATH")`
   - `$targetBranch = [Environment]::GetEnvironmentVariable("ADO_ORCH_REPO_${repoKey}_TARGET_BRANCH")`
   - `if ([string]::IsNullOrWhiteSpace($repoPath) -or [string]::IsNullOrWhiteSpace($targetBranch)) { throw "Missing repository map for $repoKey" }`
   - `$repoRoot = (Resolve-Path (Join-Path $workspaceRoot $repoPath)).Path`
3. Normalize branch name and resolve review paths:
   - `$safeBranch = ($reviewBranch -replace '[^A-Za-z0-9._-]','-')`
   - `$reposRoot = (Resolve-Path (Join-Path $workspaceRoot 'repos')).Path`
   - `$tempDir = Join-Path $workspaceRoot 'temp'`
   - `if (-not (Test-Path $tempDir)) { New-Item -ItemType Directory -Path $tempDir | Out-Null }`
   - `$worktreePath = Join-Path $reposRoot ("{0}-review-{1}" -f $repoKey, $safeBranch)`
4. Fetch and validate remote branches before review:
   - `git -C $repoRoot fetch --quiet origin $targetBranch $reviewBranch`
   - `git -C $repoRoot show-ref --verify --quiet "refs/remotes/origin/$targetBranch"`
   - `if ($LASTEXITCODE -ne 0) { throw "Target branch not found: origin/$targetBranch" }`
   - `git -C $repoRoot show-ref --verify --quiet "refs/remotes/origin/$reviewBranch"`
   - `if ($LASTEXITCODE -ne 0) { throw "Review branch not found: origin/$reviewBranch" }`
5. Create review worktree (checked out branch for file-by-file inspection):
   - `if (Test-Path $worktreePath) { git -C $repoRoot worktree remove --force $worktreePath }`
   - `git -C $repoRoot worktree add --quiet $worktreePath "origin/$reviewBranch"`
6. Generate review context by diffing review branch against target branch:
   - `git -C $repoRoot --no-pager log --oneline --left-right --cherry-pick "origin/$targetBranch...origin/$reviewBranch"`
   - `git -C $repoRoot --no-pager diff --name-status --find-renames "origin/$targetBranch...origin/$reviewBranch"`
   - `git -C $repoRoot --no-pager diff --stat "origin/$targetBranch...origin/$reviewBranch"`
   - `git -C $repoRoot --no-pager diff "origin/$targetBranch...origin/$reviewBranch" *> (Join-Path $tempDir ("review-{0}.diff" -f $safeBranch))`
7. Start review from the dedicated worktree:
   - `cd $worktreePath`
   - Review diff one file at a time.
   - Reference review guidance under "assets" if available.
   - Report detailed findings with severity and exact file/line references.

## Guardrails
- Do not switch branches in the main repo directory; perform review from the dedicated worktree.
- Do not mutate remote branches during review.
- Keep orchestration context authoritative for repo path and target branch selection.
- Use `${repoKey}-review-${safeBranch}` naming for the worktree to stay compatible with `complete-review-pr`.
- Use sanitized `$safeBranch` for all filesystem artifact names.

## Output
- Review summary with overall assessment, list of changed files, and specific comments on code quality, correctness, and style.
- Review worktree path and generated diff artifact path.
