#!/bin/sh
# Bootstrap this dotfiles checkout on a new macOS machine.
set -e

CONFIG_REPO="${CONFIG_REPO:-git@github.com:kvoon3/.config.git}"

if ! command -v mise >/dev/null 2>&1; then
  curl https://mise.run/zsh | sh
  export PATH="$HOME/.local/bin:$PATH"
fi

if [ -d "$HOME/.config/.git" ]; then
  git -C "$HOME/.config" pull --ff-only
else
  git clone "$CONFIG_REPO" "$HOME/.config"
fi

cd "$HOME/.config"
if ! mise install; then
  echo "mise install failed; continuing so dark-notify can use the Homebrew fallback if needed."
fi

if ! mise dotfiles apply; then
  echo "mise dotfiles apply failed; symlinked configs (settings.json, pi themes) may be missing."
fi

if ! command -v dark-notify >/dev/null 2>&1; then
  if command -v brew >/dev/null 2>&1; then
    brew install cormacrelf/tap/dark-notify
  else
    echo "dark-notify is missing; install it after GitHub rate limits clear, or install Homebrew and run:"
    echo "  brew install cormacrelf/tap/dark-notify"
  fi
fi

mise exec -- "$HOME/.config/herdr-theme/scripts/install.sh"

command -v herdrx
command -v herdr-theme
command -v dark-notify
herdr-theme --list
