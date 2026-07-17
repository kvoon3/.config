#!/bin/sh
# Register herdr-theme on this machine.
#
#   ~/.config/herdr-theme/scripts/install.sh
#
# Installs deps, compiles a standalone binary, and links it into ~/.local/bin.
# Requires bun (https://bun.sh). Safe to re-run after `git pull`.
set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BIN_DIR="$HOME/.local/bin"

cd "$ROOT"
bun install --frozen-lockfile
bun run build

mkdir -p "$BIN_DIR"
ln -sf "$ROOT/dist/herdr-theme" "$BIN_DIR/herdr-theme"
ln -sf "$ROOT/scripts/herdrx" "$BIN_DIR/herdrx"

echo "herdr-theme installed: $BIN_DIR/herdr-theme -> $ROOT/dist/herdr-theme"
echo "herdrx installed:      $BIN_DIR/herdrx -> $ROOT/scripts/herdrx"

if ! command -v dark-notify >/dev/null 2>&1; then
  echo
  echo "note: dark-notify not found — herdrx auto theme switching will be disabled."
  echo "      install with: mise use -g ubi:cormacrelf/dark-notify"
  echo "      (or: brew install cormacrelf/tap/dark-notify)"
fi
