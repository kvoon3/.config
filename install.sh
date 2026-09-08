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
  echo "mise install failed; some managed tools may be missing."
fi

if ! mise dotfiles apply; then
  echo "mise dotfiles apply failed; symlinked configs (settings.json, pi themes) may be missing."
fi
