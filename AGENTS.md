# Agent Guidance

This is a personal dotfiles repository rooted at `~/.config`.

## Rules

- **Deny-by-default**: `.gitignore` ignores everything except explicitly whitelisted paths. Currently tracked: `dotfiles/`, `ghostty/`, `git/`, `herdr/`, `karabiner/`, `kitty/`, `lazygit/`, `mise/`, `rex/`, `wezterm/`.
- `notes/` is deliberately untracked: it holds this machine's deep-dive write-ups, not portable config.
- **Do not add new top-level folders without user approval.** If asked to add one, update `.gitignore` to whitelist it.
- **Never commit secrets or machine-local state**: logs, sockets, session files, credentials, backups, etc.
- **Keep changes minimal**: this repo is for stable config, not experiments.
- **Try mise first for installations**: check whether mise can manage the requested software and use it when supported before choosing another installer.
- For `herdr/`, exclude: `*.log`, `*.sock*`, `session.json`, `session-history.json`, `session-snapshots/`, `release-notes.json`, `.plugins.lock`, `plugins/`.
- For `dotfiles/`, exclude: `.secrets.zsh`, `.secrets.bash`, `.agents/.skill-lock.json`, `.agents/skills/terminal-browser`, `.agents/skills/ego-browser`, `.pi/agent/models.json`, `.pi/agent/settings.json`. The last two are written by pi on each machine (`baseUrl`, `deviceId`, catalog, extension versions) and cannot hold one correct value for every host.
- For `mise/`, track the shared `config.toml`, the per-platform files `config.macos.toml` / `config.windows.toml`, and `miserc.toml` (it enables `auto_env`, which is what loads the platform files); exclude `*.local.toml` (machine-local overrides).
- For `kitty/`, exclude backup files (`*.bak`).
- For `lazygit/`, track only `config.yml`; lazygit's `state.yml` and logs stay machine-local. `~/Library/Application Support/lazygit/config.yml` is a symlink to it.
- For `karabiner/`, exclude `automatic_backups/`.
- `windows/` holds no tracked files; it stays whitelisted only for the machine-local `.secrets.bash` that `dotfiles/.bashrc.win` sources.
- For `git/`, exclude: `config.local` (identity/SSH/proxy/credentials), `kvoon9` (work identity), `gitk` (UI geometry). Nested `.git` is not tracked.

## WezTerm: repo file is the single source of truth, via a Windows shim

WezTerm runs as a **Windows** process (`wezterm-gui`), not in WSL, so it can only load files it can
resolve on the Windows filesystem. Current wiring:

- `~/.config/wezterm/wezterm.lua` (tracked in this repo) is the **single source of truth**. Edit here.
- `C:\Users\a1176\.wezterm.lua` is a **~50-line shim**: it does `pcall(dofile, repo_path)` over
  `\\wsl.localhost\Ubuntu-24.04\home\kvoon\.config\wezterm\wezterm.lua` and returns the result. Do not put
  config in the shim — edits there are ignored whenever the repo file is reachable.
- Backup of the original pre-shim config: `C:\Users\a1176\.wezterm.lua.bak`.

Why a shim and not a directory symlink: `New-Item -ItemType SymbolicLink` for `C:\Users\a1176\.config\wezterm`
fails with *"Administrator privilege required for this operation"*. Symlinks (`mklink /D` too) need admin or
Developer Mode; junctions (`-ItemType Junction`) work unprivileged but cannot target a UNC path. If Developer
Mode is ever enabled, the symlink variant documented in the shim's header comment is the cleaner setup.

- The shim has a **fallback branch** for when WSL is down and the UNC path is unreachable: a minimal inline
  config whose most important line is `front_end = 'WebGpu'`. Default OpenGL renders a **blank window** on
  this AMD machine, so a config that fails to load *without* that line looks like a broken terminal, not a
  missing config.
- Windows home is `C:\Users\a1176`; WSL home is `/home/kvoon`. Separate filesystems: `/mnt/c/Users/a1176`
  ≡ `C:\Users\a1176`, but `~/.config` is **not** `%USERPROFILE%\.config`. Unifying the usernames would not
  bridge them — the axes are different (filesystem, not name). Don't rename the Windows profile for this.
- `font_size` is in points. It was `18.0` — grossly large on the 1920x1080/100%-scale display; now `14.0`.
  `Ctrl`+`-` / `Ctrl`+`=` adjusts live if you want to preview a value before writing it.

## Windows-side shells from WSL: `pwsh`, not `powershell.exe`

Windows-side commands run in PowerShell 7 — `pwsh.exe` (on the Windows PATH) resolves from WSL by
name. `powershell.exe` is 5.1: UTF-16LE + BOM output by default (the profile moves `Out-File`/`Set-Content`/`Add-Content` to UTF-8), no `??` / `-Parallel`, slower — and `NetSecurity` ships
in both, so nothing is gained by staying. Not via mise (WSL would get the Linux build, no Windows-only
modules). Firewall changes need elevation: spawn `Start-Process pwsh -Verb RunAs` and have the child write
its result to a file, since the UAC prompt is answered on the Windows desktop. From a WSL shell use the
`psh` helper (`psh51` only to reproduce what 5.1-based tooling sees). Details: `notes/windows.md`.

## PowerShell: repo file is the source, Windows side is a shim

`dotfiles/powershell/profile.ps1` is the single source of truth. `%USERPROFILE%\Documents\PowerShell\profile.ps1`
(pwsh 7) and `%USERPROFILE%\Documents\WindowsPowerShell\profile.ps1` (5.1) are copies of
`dotfiles/powershell/profile.shim.ps1`, which reads the repo file as text and `Invoke-Expression`s it.
Dot-sourcing is not an option: `ExecutionPolicy RemoteSigned` refuses to run an unsigned *script file*
over UNC ("is not digitally signed"), while evaluating text needs no policy change and no `Unblock-File`.
Edit the repo file; re-copy the shim only when the shim itself changes.

- Non-interactive shells get agent semantics: `$PSNativeCommandUseErrorActionPreference` (7.3+), plain
  UTF-8 output, no progress bars, **no aliases**. The prompt, PSReadLine and shortcuts live behind
  `Initialize-InteractiveProfile`. Keep that split — an alias that shadows a cmdlet silently breaks agents.
- Tool availability comes from `%LOCALAPPDATA%\mise\shims` appended to the **user** PATH in the registry,
  not from `mise activate` (which prepends one path per installed tool). Append only: the shims must stay
  behind `C:\Windows\System32` so they cannot shadow system binaries.
- `psh` (PowerShell 7) and `psh51` (Windows PowerShell 5.1) in `dotfiles/functions.sh` run a Windows
  PowerShell command from WSL: native cwd, strict exit codes via `PSH_STRICT`/`WSLENV`.

Details, measured startup cost, and the Windows-Terminal probe for the interactive branch: `notes/windows.md`.

## Verifying GUI rendering from WSL

Windows GUI processes are invisible to WSLg screenshot tools (`grim`, `scrot`, `xwd`, `import` are absent
and would not capture them anyway). Use PowerShell interop:

1. Validate a config change **without touching the live one**:
   `wezterm.exe --config-file <path> show-keys`. It loads the config headlessly, prints the key table, and
   surfaces Lua errors — cheap smoke test, and it proves the file is reachable (works for UNC paths).
2. Launch an isolated instance for a real render test:
   `wezterm.exe --config-file <path> start --always-new-process --class pi-verify`. `--always-new-process`
   matters: without it the new window is served by the already-running GUI, which uses its own loaded config.
3. Capture that specific window: diff `Get-Process wezterm-gui` before/after to get the new pid, then
   `SetWindowPos(hwnd, HWND_TOPMOST, …)` + `CopyFromScreen` over `GetWindowRect`. `SetForegroundWindow` alone
   is unreliable — the window ends up behind others and you screenshot the wrong app. Remember to drop the
   window off topmost afterwards, and to `Stop-Process` the test pid so you don't pile up GUIs.
4. `SetProcessDPIAware()` first, or captures come back scaled/cropped. Save the PNG under
   `C:\Users\a1176\AppData\Local\Temp\` and read it from WSL at `/mnt/c/Users/a1176/AppData/Local/Temp/…png`.
   Recreate helper scripts under Temp when needed; do not add them to this repo.

Reference: `GetWindowRect` reported `1416x1100` on a `1920x1080` screen, which also shows the WezTerm window
is taller than the display — worth flagging when judging whether text "looks too big" vs. the window being
oversized.
