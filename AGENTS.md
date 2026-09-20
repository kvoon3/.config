# Agent Guidance

This is a personal dotfiles repository rooted at `~/.config`.

## Rules

- **Deny-by-default**: `.gitignore` ignores everything except explicitly whitelisted paths. Currently tracked: `dotfiles/`, `ghostty/`, `git/`, `herdr/`, `karabiner/`, `kitty/`, `mise/`, `notes/`, `wezterm/`.
- **Do not add new top-level folders without user approval.** If asked to add one, update `.gitignore` to whitelist it.
- **Never commit secrets or machine-local state**: logs, sockets, session files, credentials, backups, etc.
- **Keep changes minimal**: this repo is for stable config, not experiments.
- For `herdr/`, exclude: `*.log`, `*.sock`, `session.json`, `session-history.json`, `release-notes.json`, `.plugins.lock`, `plugins/`.
- For `dotfiles/`, exclude: `.secrets.zsh`, `.secrets.bash`, `.agents/.skill-lock.json`, `.agents/skills/terminal-browser`.
- For `mise/`, track everything (currently just `config.toml`, the global tool manifest).
- For `kitty/`, exclude backup files (`*.bak`).
- For `karabiner/`, exclude `automatic_backups/`.
- `windows/` holds no tracked files; it stays whitelisted only for the machine-local `.secrets.bash` that `dotfiles/.bashrc.win` sources.
- For `git/`, exclude: `config.local` (identity/SSH/proxy/credentials), `kvoon9` (work identity), `gitk` (UI geometry). Nested `.git` is not tracked.
