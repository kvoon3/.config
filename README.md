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
mise exec -- ~/.config/herdr-theme/scripts/install.sh
```

Use `herdrx` instead of `herdr` — it follows macOS appearance, applying the
light/dark theme pair from `herdr-theme/config.json` (edit via `herdr-theme`).

This setup uses mise for managed tools. `mise install` may fail to install
`dark-notify` if GitHub API rate limits unauthenticated requests; Homebrew is
only used as a fallback for that case:

```sh
brew install cormacrelf/tap/dark-notify
```
