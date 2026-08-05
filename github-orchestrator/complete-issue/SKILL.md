---
name: complete-issue
description: Complete issue lifecycle by merging PR, syncing main, and cleaning task worktree.
---

# Complete Issue
## When to use
Use after PR is approved and ready to merge.

## Lightweight preflight
Before running issue lifecycle steps, verify orchestration context is loaded:
- If `CORE.md` and `DEV-FLOW.md` guidance is already present in the active context, continue.
- If either is missing or uncertain, run `orchestrator-boot` first, then continue.

## Steps
1. Merge PR:
   - `gh pr merge <pr-number> --merge --delete-branch`
2. Confirm issue closed by `Closes #<number>`.
3. Sync local main:
   - `cd repos/<repo>`
   - `git pull --ff-only`
4. Remove task worktree:
   - `git worktree remove ../<repo>-<feature>`
5. Delete local branch if still present.
6. Post a `## COMPLETE` comment using the standard structure, summarizing the completion and verification.
   - `gh issue comment <number> -R <org>/<repo> --body $body`

## Output
- Merged PR number
- Issue final status
- Cleanup confirmation

## Guardrails

## Issue Comment Template
```markdown
## COMPLETE

PR #<pr-number> merged.

### Change Summary
- Added ...
- Modified ...

### Verification
- [x] Tests passed
- [x] Build passed
```
