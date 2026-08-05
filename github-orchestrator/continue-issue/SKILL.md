---
name: continue-issue
description: Resume an in-progress GitHub issue by restoring branch, worktree, and handoff context.
---

# Continue Issue

## When to use
Use when the user says `continue #N` or wants to resume existing work.

## Lightweight preflight
Before running issue lifecycle steps, verify orchestration context is loaded:
- If `CORE.md` and `DEV-FLOW.md` guidance is already present in the active context, continue.
- If either is missing or uncertain, run `orchestrator-boot` first, then continue.

## Steps
1. Read issue + comments:
   - `gh issue view <number> -R <org>/<repo> --json title,body,comments,assignees,labels`
2. Find latest `## HANDOFF` comment.
3. Locate existing branch:
   - `cd repos/<repo>`
   - `git branch -a | grep "feature/<number>"`
4. Fetch and attach worktree:
   - `git fetch origin <branch>`
   - `git worktree add ../<repo>-<feature> <branch>`
5. Post a `## CONTINUE` comment using the standard structure, summarizing the restored context and next steps.
   - `gh issue comment <number> -R <org>/<repo> --body $body`
6. Route to worktree and continue development.
   - `cd ../<repo>-<feature>`
## Guardrails
- If no branch exists, stop and recommend using `claim-issue`.
- If branch diverges, report exact state and ask user whether to rebase or continue.

## Output
- Issue title
- Branch name
- Worktree path
- Summary of progress and next steps

## Issue Comment Template
```markdown
## CONTINUE
Resuming work on this issue.
### Restored Context
- Done: xxx
- In progress: yyy
### Branch
`feature/42-user-auth` @ <commit-sha>
### Next Steps
1. Complete zzz
2. Test aaa
```
