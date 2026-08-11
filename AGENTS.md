# Agent Guidance

This is a personal dotfiles repository rooted at `~/.config`.

## Rules

- **Deny-by-default**: `.gitignore` ignores everything except explicitly whitelisted paths. Currently only `kitty/`, `herdr/`, `herdr-theme/`, `karabiner/`, `ghostty/`, `git/`, and `mise/` are tracked.
- **Do not add new top-level folders without user approval.** If asked to add one, update `.gitignore` to whitelist it.
- **Never commit secrets or machine-local state**: logs, sockets, session files, credentials, backups, etc.
- **Keep changes minimal**: this repo is for stable config, not experiments.
- For `herdr/`, exclude: `*.log`, `*.sock`, `session.json`, `release-notes.json`.
- For `herdr-theme/` (Bun + OpenTUI/Solid TUI behind the global `herdr-theme` and `herdrx` commands), exclude: `node_modules/`, `dist/`, `backups/`, `watch.log`, `watch.err.log`. Its own `config.json` (light/dark theme pair) is tracked.
- For `mise/`, track everything (currently just `config.toml`, the global tool manifest).
- For `kitty/`, exclude backup files (`*.bak`).
- For `git/`, exclude: `config.local` (identity/SSH/proxy/credentials), `kvoon9` (work identity), `gitk` (UI geometry). Nested `.git` is not tracked.
