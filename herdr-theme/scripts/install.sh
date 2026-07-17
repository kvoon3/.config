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

echo "herdr-theme installed: $BIN_DIR/herdr-theme -> $ROOT/dist/herdr-theme"
