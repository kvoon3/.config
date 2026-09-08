# .config

Kevin Kwong's dotfiles for macOS.

## Setup

On a new macOS machine, copy and run:

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/kvoon3/.config/main/install.sh)"
```

To use HTTPS instead of SSH:

```sh
CONFIG_REPO=https://github.com/kvoon3/.config.git sh -c "$(curl -fsSL https://raw.githubusercontent.com/kvoon3/.config/main/install.sh)"
```

For an already-cloned checkout, the core setup is:

```sh
mise install
```

herdr follows macOS appearance natively (`auto_switch` with per-mode
`[theme.custom.light]`/`[theme.custom.dark]` in `herdr/config.toml`).

Kitty uses Input Mono. Install it with Homebrew:

```sh
brew install --cask font-input
```
