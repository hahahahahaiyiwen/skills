---
name: iterate-pr
description: Create or update pull request for an issue branch and record linkage in the issue thread.
---

# Iterate PR

## When to use
Process review comments before merge:

## Lightweight preflight
Before running issue lifecycle steps, verify orchestration context is loaded:
- If `CORE.md` and `DEV-FLOW.md` guidance is already present in the active context, continue.
- If either is missing or uncertain, run `orchestrator-boot` first, then continue.

## Steps
1. Read PR review comments.
  - Top-level discussion: `gh pr view <pr-number> -R <org>/<repo> --json comments --jq '.comments[] | {author: .author.login, body: .body, id: .id}'`
  - Inline review comments: `gh api repos/<org>/<repo>/pulls/<pr-number>/comments --paginate --jq '.[] | {author: .user.login, path: .path, line: .line, body: .body, id: .id, url: .html_url}'`
  - (Optional) Thread state (resolved/outdated): `gh api graphql -f query='query($owner:String!, $repo:String!, $number:Int!){ repository(owner:$owner,name:$repo){ pullRequest(number:$number){ reviewThreads(first:100){ nodes { isResolved isOutdated comments(first:20){ nodes { databaseId body author { login } url } } } } } } }' -F owner=<org> -F repo=<repo> -F number=<pr-number>`
2. If you do not agree, resolve with a concise reason.
  - Reply to the specific review comment: `gh api -X POST repos/<org>/<repo>/pulls/<pr-number>/comments/<comment-id>/replies -f body='<comment-author>: I think we should not address this because <reason>'`
3. If you agree, make code changes, push, and then resolve the comment by replying how you address it.
  - `cd repos/<repo>-<feature>`
  - Make code changes to address the comment.
  - `git add . && git commit -m "fix: address PR review comments"`
  - `git push`
  - Reply to the specific review comment: `gh api -X POST repos/<org>/<repo>/pulls/<pr-number>/comments/<comment-id>/replies -f body='<comment-author>: I have made the changes to address your comment. Please take another look.'`
  - PowerShell note: when using hashtable/array indexing in CLI args, use subexpression expansion (for example: `-f body="$($replies[$id])"`).
4. Post a `## PROGRESS` comment using the standard structure, summarizing the comments and PR update.
  - `gh issue comment <number> -R <org>/<repo> --body $body`

## Output
- PR URL
- Verification summary

## Issue Comment Template
```markdown
## PROGRESS

PR updated to address review comments.
Scope: <summary>
Next: waiting for review
```
