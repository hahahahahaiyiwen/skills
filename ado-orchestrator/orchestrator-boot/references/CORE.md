# Work Protocol

## Skill Routing

Operational actions should be executed via skills instead of free-form command flow:

- Boot and context load: `orchestrator-boot`
- Board query: `board-status`
- Claim task: `claim-issue`
- Resume task: `continue-issue`
- Save interruption context: `handoff-issue`
- PR creation/update: `open-pr`
- PR review iteration: `iterate-pr`
- Merge and cleanup: `complete-issue`

`CORE.md` defines governance; skills define executable procedures.

## Azure DevOps Is the Single Source of Truth

All task management, context handoff, and progress tracking are done on Azure DevOps:

| Information | Location |
|------|------|
| Task definition | Work Item description |
| Task status | Azure Boards state/column |
| Work progress | Work Item comments (`## CLAIM`, `## PROGRESS`, `## CONTINUE`) |
| Handoff document | Work Item comment (`## HANDOFF`) |
| Completion record | Work Item comment (`## COMPLETE`) |

---

## Branch Ownership Mechanism

A branch is a task ownership marker.

### Naming Convention

```
<work-item-id>-<short-name>
```

Example: `42-user-auth`

### Ownership Rules

| State | Meaning |
|------|------|
| Branch exists + Work Item Active | Someone is actively developing |
| Branch exists + Work Item Todo | Someone started before; can be picked up |
| No branch + Work Item Todo | Not started; can be claimed |
| PR completed + Work Item Done | Completed |

### Handoff/Pickup Flow

To pick up a task that already has a branch:

1. Read Work Item description + comments for full context
2. Pull the branch into a local worktree
3. Leave a Work Item comment: `Taking over development, continuing from <commit-sha>`
4. Continue development

---

## Work Item Lifecycle

```
Create Work Item → Add to Board (Todo)
    ↓
Claim → Set state to Active → Create branch → Leave `## CLAIM` comment
    ↓
In development → Leave `## PROGRESS` comments for key progress
    ↓
Session interrupted → Leave `## HANDOFF` comment → Push branch
    ↓
Take over → Pull branch → Read `## HANDOFF` → Leave `## CONTINUE` comment
    ↓
Complete → PR → Merge → Set Work Item Done → Leave `## COMPLETE` comment
```

---

## Work Item Comment Standards

Policy-level requirements:
- **`## CLAIM` comment** required when claiming task.
- **`## PROGRESS` comments** recommended for major decisions/blockers.
- **`## HANDOFF` comment** required when pausing unfinished work.
- **`## CONTINUE` comment** required when resuming unfinished work.
- **`## COMPLETE` comment** required after merge.

Operational **Work Item Comment Templates** are owned by skills:
- `## CLAIM` template: `claim-issue`
- `## HANDOFF` template: `handoff-issue`
- `## CONTINUE` template: `continue-issue`
- `## COMPLETE` template: `complete-issue`
- `## PROGRESS` template: `open-pr`, `iterate-pr`

### Universal Comment API Convention (Required)

All lifecycle skills must use one shared execution pattern for Work Item comments.

- Use WIT Comments API via `az devops invoke` for **all** lifecycle comments (`## CLAIM`, `## PROGRESS`, `## HANDOFF`, `## CONTINUE`, `## COMPLETE`).
- Pin comment API version to `7.1-preview` for both read and write.
- Do not use `az boards work-item update --discussion` for lifecycle multiline comments.
- Always send comment body with JSON `--in-file` payload (`{ "text": $body }`).
- Always read back latest comment after write and verify expected heading exists.

```powershell
$commentApiVersion = '7.1-preview'
$commentBodyPath = Join-Path $env:TEMP "wi-$id-comment.json"
@{ text = $body } | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $commentBodyPath -Encoding utf8

# create comment
az devops invoke --area wit --resource comments `
  --route-parameters project=$Env:ADO_ORCH_PROJECT workItemId=$id `
  --http-method POST --api-version $commentApiVersion --in-file $commentBodyPath

# read latest comment for verification
az devops invoke --area wit --resource comments `
  --route-parameters project=$Env:ADO_ORCH_PROJECT workItemId=$id `
  --query-parameters '$top=1' --api-version $commentApiVersion

Remove-Item -LiteralPath $commentBodyPath -Force
```

---

## Context Management

The agent context window is limited. Large tasks will span multiple sessions; the HANDOFF mechanism ensures minimal information loss across sessions.

### Proactive Save (Recommended)

When the conversation becomes long and approaches context limits, ask user to use `handoff-issue` to save context.

### Recovery After Compress

If context has been auto-compressed, information may be lost:

1. Return to the state before compress
2. Execute the handoff-issue skill in the restored full context
3. Start a new session and resume by executing continue-issue skill

`## HANDOFF` is a structured handoff document (done / in progress / next steps / notes), with much higher information density than residual compressed context.

---

## Worktree Usage

**Use `git worktree` for feature development** instead of switching branches in the main repo:

```bash
# Create worktree
cd repos/<repo>
git worktree add ../repos/<repo>-<branch> -b <number>-<name> dev

# Take over existing branch
cd repos/<repo>
git fetch origin <number>-<name>
git worktree add ../repos/<repo>-<branch> <number>-<name>

# Cleanup
git worktree remove ../repos/<repo>-<branch>
```

Reasons:
- Main repo may contain other uncommitted changes
- Parallel tasks do not interfere with each other
- Keep the main repo clean

---

## Scope Control

Each task can define writable scope in the Work Item description or a separate config:

```yaml
write:
  - src/auth/
  - src/middleware/

forbidden:
  - .env
```

- **Only modify** paths allowed in `write`
- If outside scope, ask the user before changing anything
- Paths in `forbidden` must never be written

---

## Before Committing Code

1. Run checks in the worktree directory (e.g., `pnpm check` / `go vet` / `cargo test`)
2. Ensure feature completeness; do not commit partial work
3. Follow commit message conventions (see DEV-FLOW.md)

---

## File Communication Principles

- Put large content (code, analysis reports) in files or Work Item comments, not chat
- Reference file paths instead of copying full content
- Protect context window usage
