# .config

Personal configuration files (dotfiles) for macOS.

## Included

- `kitty/` — terminal emulator config and themes
- `herdr/` — terminal multiplexer config
- `karabiner/` — keyboard remapping config

## Design

This repo uses a deny-by-default `.gitignore`: everything is ignored unless explicitly whitelisted. Only the three folders above are tracked.

## Setup

Clone and symlink configs as needed, or copy directly into `~/.config`.

```bash
git clone https://github.com/kvoon3/.config.git
```
