---
name: handoff-issue
description: Save structured task handoff to GitHub issue comment for cross-session continuation.
---

# Handoff Issue

## When to use
Use before ending session when issue is not complete.

## Lightweight preflight
Before running issue lifecycle steps, verify orchestration context is loaded:
- If `CORE.md` and `DEV-FLOW.md` guidance is already present in the active context, continue.
- If either is missing or uncertain, run `orchestrator-boot` first, then continue.

## Working directory routing
- Run `git status`, `git log`, and `git push` from the active issue worktree:
  - `repos/<repo>-<feature>`

## Steps
1. Ensure latest local commits are pushed to task branch.
2. Collect state:
   - Completed work
   - In-progress work
   - Next steps
   - Notes/risks
   - Branch and commit SHA
3. Post a `## HANDOFF` comment using the standard structure, summarizing the current state and next steps for the issue.
   - `gh issue comment <number> -R <org>/<repo> --body $body`

## Output
- Confirmation of handoff comment posted with summary of current state and next steps.

## Guardrails

## Issue Comment Template
```markdown
## HANDOFF

### Current Status
- Done: xxx
- In progress: yyy

### Branch
`feature/42-user-auth` @ <commit-sha>

### Next Steps
1. Complete zzz
2. Test aaa

### Notes
- bbb needs special handling
```
