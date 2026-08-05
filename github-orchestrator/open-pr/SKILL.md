---
name: open-pr
description: Create or update pull request for an issue branch and record linkage in the issue thread.
---

# Open PR

## When to use
Use after implementation and verification pass in the task worktree.

## Lightweight preflight
Before running issue lifecycle steps, verify orchestration context is loaded:
- If `CORE.md` and `DEV-FLOW.md` guidance is already present in the active context, continue.
- If either is missing or uncertain, run `orchestrator-boot` first, then continue.

## Steps
1. Run project checks/tests in worktree.
2. Push latest branch:
   - `cd repos/<repo>-<feature>`
   - `git push -u origin <branch>`
3. Create PR:
   - `gh pr create --base main --head <branch> --body "Closes #<number>"`
4. Post a `## PROGRESS` comment using the standard structure, summarizing the PR creation and next steps.
   - `gh issue comment <number> -R <org>/<repo> --body $body`
5. Monitor review comments and respond with code updates as needed.

## Guardrails
- Do not run branch-specific git operations from main branch `repos/<repo>`.
- Do not open PR with failing required checks unless user explicitly allows.
- Keep PR scoped to issue acceptance criteria.

## Output
- PR URL
- Verification summary
- Pending review actions (if any)

## Issue Comment Template
```markdown
## PROGRESS

PR opened: <pr-url>
Scope: <summary>
Next: waiting for review
```
