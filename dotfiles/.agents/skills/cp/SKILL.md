---
name: cp
description: Commit current changes and safely push them. Use when explicitly invoked to create a Conventional Commit and push it upstream.
argument-hint: "[commit context]"
disable-model-invocation: true
---

Read and follow `../c/SKILL.md`, treating any arguments as commit context.

After a successful commit, fetch the configured upstream. If it has commits absent locally, ask whether to rebase and wait for confirmation before rebasing or pushing. Otherwise, push the commit.

Never force-push. If no upstream is configured or the push is unsafe, explain why.
