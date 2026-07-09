# Agent Guidance

This is a personal dotfiles repository rooted at `~/.config`.

## Rules

- **Deny-by-default**: `.gitignore` ignores everything except explicitly whitelisted paths. Currently only `kitty/`, `herdr/`, `karabiner/`, and `ghostty/` are tracked.
- **Do not add new top-level folders without user approval.** If asked to add one, update `.gitignore` to whitelist it.
- **Never commit secrets or machine-local state**: logs, sockets, session files, credentials, backups, etc.
- **Keep changes minimal**: this repo is for stable config, not experiments.
- For `herdr/`, exclude: `*.log`, `*.sock`, `session.json`, `release-notes.json`.
- For `kitty/`, exclude backup files (`*.bak`).
