---
name: claim-issue
description: Claim a GitHub issue, create task branch/worktree, and post start comment.
---

# Claim Issue

## When to use
Use when starting a Todo task.

## Lightweight preflight
Before running issue lifecycle steps, verify orchestration context is loaded:
- If `CORE.md` and `DEV-FLOW.md` guidance is already present in the active context, continue.
- If either is missing or uncertain, run `orchestrator-boot` first, then continue.

## Required input
- Issue number
- Target repository key from `RESOURCE-MAP.yml` `repos` section

## Steps
1. Read issue details:
   - `gh issue view <number> -R <org>/<repo> --json title,body,comments`
2. Create branch name:
   - `feature/<number>-<short-name>` unless task is a bugfix, then `fix/<number>-<short-name>`.
3. Route to main repository path and create worktree:
   - `cd repos/<repo>`
   - `git fetch origin`
   - `git worktree add ../<repo>-<feature> -b <branch> main`
4. Post a `## CLAIM` comment using the standard structure, summarizing the claim and next steps.
   - `gh issue comment <number> -R <org>/<repo> --body $body`
5. Route to new worktree and install dependencies:
   - `cd ../<repo>-<feature>`
   - Install dependencies (based on project tech stack):
     - `pnpm install` / `go mod download` / `cargo fetch` / `pip install -r requirements.txt`
6. Begin development on the issue task in the new worktree.

## Guardrails
- Do not claim if another active owner is clearly working unless user requests takeover.
- Keep all implementation work inside the new worktree.

## Output
- Issue title
- Branch name
- Worktree path
- Next development step

## Issue Comment Template
```markdown
## CLAIM
Claiming this issue and starting work.
### Issue
`#<number>` - <issue-title>
### Branch
`<branch>` @ <commit-sha>
### Next Steps
1. Implement xxx
```
