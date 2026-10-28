# Agent Guidance

This is a personal dotfiles repository rooted at `~/.config`.

## Rules

- **Deny-by-default**: `.gitignore` ignores everything except explicitly whitelisted paths. Currently tracked: `dotfiles/`, `ghostty/`, `git/`, `herdr/`, `karabiner/`, `kitty/`, `lazygit/`, `mise/`, `notes/`, `wezterm/`.
- **Do not add new top-level folders without user approval.** If asked to add one, update `.gitignore` to whitelist it.
- **Never commit secrets or machine-local state**: logs, sockets, session files, credentials, backups, etc.
- **Keep changes minimal**: this repo is for stable config, not experiments.
- **Try mise first for installations**: check whether mise can manage the requested software and use it when supported before choosing another installer.
- For `herdr/`, exclude: `*.log`, `*.sock*`, `session.json`, `session-history.json`, `session-snapshots/`, `release-notes.json`, `.plugins.lock`, `plugins/`.
- For `dotfiles/`, exclude: `.secrets.zsh`, `.secrets.bash`, `.agents/.skill-lock.json`, `.agents/skills/terminal-browser`, `.agents/skills/ego-browser`.
- For `mise/`, track the shared `config.toml`, the per-platform files `config.macos.toml` / `config.windows.toml`, and `miserc.toml` (it enables `auto_env`, which is what loads the platform files); exclude `*.local.toml` (machine-local overrides).
- For `kitty/`, exclude backup files (`*.bak`).
- For `lazygit/`, track only `config.yml`; lazygit's `state.yml` and logs stay machine-local. `~/Library/Application Support/lazygit/config.yml` is a symlink to it.
- For `karabiner/`, exclude `automatic_backups/`.
- `windows/` holds no tracked files; it stays whitelisted only for the machine-local `.secrets.bash` that `dotfiles/.bashrc.win` sources.
- For `git/`, exclude: `config.local` (identity/SSH/proxy/credentials), `kvoon9` (work identity), `gitk` (UI geometry). Nested `.git` is not tracked.
