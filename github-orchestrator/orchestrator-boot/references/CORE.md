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

## GitHub Is the Single Source of Truth

All task management, context handoff, and progress tracking are done on GitHub:

| Information | Location |
|------|------|
| Task definition | Issue body |
| Task status | Project Board status |
| Work progress | Issue comments ((`## CLAIM`, `## PROGRESS`, `## CONTINUE`)) |
| Handoff document | Issue comment (`## HANDOFF`) |
| Completion record | Issue closing comment (`## COMPLETE`) |

---

## Branch Ownership Mechanism

A branch is a task ownership marker.

### Naming Convention

```
feature/<issue-number>-<short-name>
fix/<issue-number>-<short-name>
```

Example: `feature/42-user-auth`

### Ownership Rules

| State | Meaning |
|------|------|
| Branch exists + Issue In Progress | Someone is actively developing |
| Branch exists + Issue Todo | Someone started before; can be picked up |
| No branch + Issue Todo | Not started; can be claimed |
| PR merged + Issue Done | Completed |

### Handoff/Pickup Flow

To pick up a task that already has a branch:

1. Read Issue body + comments for full context
2. Pull the branch into a local worktree
3. Leave an Issue comment: `Taking over development, continuing from <commit-sha>`
4. Continue development

---

## Issue Lifecycle

```
Create Issue → Add to Project Board (Todo)
    ↓
Claim → Set status to In Progress → Create branch → Leave `## CLAIM` comment
    ↓
In development → Leave `## PROGRESS` comments for key progress
    ↓
Session interrupted → Leave `## HANDOFF` comment → Push branch
    ↓
Take over → Pull branch → Read `## HANDOFF` → Leave `## CONTINUE` comment
    ↓
Complete → PR → Merge → Issue auto-closes -> Leave `## COMPLETE` comment → Done
```

---

## Issue Comment Standards

Policy-level requirements:
- **`## CLAIM` comment** required when claiming task.
- **`## PROGRESS` comments** recommended for major decisions/blockers.
- **`## HANDOFF` comment** required when pausing unfinished work.
- **`## CONTINUE` comment** required when resuming unfinished work.
- **`## COMPLETE` comment** required after merge.

Operational **Issue Comment Template** are owned by skills:
- `## CLAIM` template: `claim-issue`
- `## HANDOFF` template: `handoff-issue`
- `## CONTINUE` template: `continue-issue`
- `## COMPLETE` template: `complete-issue`
- `## PROGRESS` template: `open-pr`, `iterate-pr`

---

## Context Management

The agent context window is limited. Large tasks will span multiple sessions; the HANDOFF mechanism ensures zero information loss across sessions.

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
git worktree add ../repos/<repo>-<feature> -b feature/<number>-<name> main

# Take over existing branch
cd repos/<repo>
git fetch origin feature/<number>-<name>
git worktree add ../repos/<repo>-<feature> feature/<number>-<name>

# Cleanup
git worktree remove ../repos/<repo>-<feature>
```

Reasons:
- Main repo may contain other uncommitted changes
- Parallel tasks do not interfere with each other
- Keep the main repo clean

---

## Scope Control

Each task can define writable scope in the Issue body or a separate config:

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

- Put large content (code, analysis reports) in files or Issue comments, not chat
- Reference file paths instead of copying full content
- Protect context window usage
