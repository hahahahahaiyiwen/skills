---
name: board-status
description: Show current GitHub Project Board task status grouped by workflow lane.
---

# Board Status

## When to use
Use when the user asks what is available or what is currently in progress.

## Steps
1. Read org and board number from `skills/orchestrator-boot/references/RESOURCE-MAP.yml`.
2. Run:
   - `gh project item-list <NUMBER> --owner <ORG> --format json`
3. Group items by status lane.
4. Return concise list with:
   - Issue number
   - Title
   - Repository
   - Lane

## Output
- Actionable view of available tasks to claim or continue
