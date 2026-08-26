---
name: c
description: Commit current changes using Conventional Commits. Use when explicitly invoked to create a focused git commit.
argument-hint: "[commit context]"
disable-model-invocation: true
---

Inspect `git status` and the diff. Treat any arguments as commit context. Stage only relevant changes, then create one focused Conventional Commit: `type(scope): subject` (or `type: subject`).

Do not include secrets, generated files, or unrelated changes. Do not amend or change Git configuration. If no safe commit is possible, explain why.
