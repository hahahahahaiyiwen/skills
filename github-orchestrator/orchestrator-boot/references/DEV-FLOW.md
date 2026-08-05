# Development Workflow

## Skill-First Execution

Use skills as operational checkpoints for the lifecycle below:

1. Boot/context: `orchestrator-boot`
2. Board selection: `board-status`
3. Start work: `claim-issue`
4. Resume work: `continue-issue`
5. Pause/handoff: `handoff-issue`
6. Submit PR: `open-pr`
7. Iterate PR based on reviews: `iterate-pr`
8. Merge/close/cleanup: `complete-issue`

This file describes standards; skills perform deterministic execution.

## Git Flow

```
Issue (GitHub) → Claim → Develop in worktree → Test → PR → Merge to main → Deploy
```

---

## Full Development Cycle

### 1. Select Task from Board
- Use skill: `board-status`

### 2. Claim Issue
- Use skill: `claim-issue`

### 3. Develop
- Start from worktree prepared by `claim-issue` or `continue-issue`

### 4. Handoff & Continue (Optional)
- Save context with `handoff-issue`
- Resume with `continue-issue`

### 5. Submit PR
- Use skill: `open-pr`

### 6. Review & Address PR Comments
- Use skill: `iterate-pr`

### 7. Complete
- Use skill: `complete-issue`

---

## Branch Notes

| Branch | Purpose |
|------|------|
| `main` | Stable version |
| `dev` | Integration testing (optional) |
| `feature/<number>-*` | Feature development |
| `fix/<number>-*` | Bug fixes |

---

## Commit Convention

Format: `<type>: <description>`

| Type | Description |
|------|------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation |
| `refactor` | Refactor |
| `test` | Test |
| `chore` | Misc |

Examples:
- `feat: add user authentication`
- `fix: resolve race condition in queue`
- `refactor: extract message parser`

---

## Deployment (Optional)

If you have automated deployment (e.g., webhook, CI/CD), describe it here:

```
Trigger: push to main
Flow: pull → install → build → restart
Verification: check deployment logs
```

If there is no automated deployment, remove this section.
