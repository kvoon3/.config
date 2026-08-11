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

BIN="$ROOT/dist/herdr-theme"
LINK="herdr-theme"
case "$(uname -s)" in MINGW*) BIN="$BIN.exe"; LINK="$LINK.exe" ;; esac

mkdir -p "$BIN_DIR"
ln -sf "$BIN" "$BIN_DIR/$LINK"

case "$(uname -s)" in
  MINGW*|MSYS*)
    # On Windows the default shell is PowerShell, which won't run extensionless
    # POSIX scripts, and the POSIX herdrx is unreliable here (WSL-stub `bash`
    # on PATH, MSYS kill races that orphan the watcher). Ship a native
    # PowerShell herdrx and DON'T install the POSIX script — Git Bash would
    # resolve `herdrx` to it ahead of herdrx.cmd and hit the same races.
    cat >"$BIN_DIR/herdrx.ps1" <<'EOF'
# herdrx for Windows — PowerShell equivalent of the POSIX herdrx:
# start the appearance watcher, run herdr, stop the watcher when herdr exits.
param([Parameter(ValueFromRemainingArguments = $true)][string[]]$herdrArgs)

$ErrorActionPreference = 'Stop'
$logDir = Join-Path $env:USERPROFILE '.config\herdr-theme'
New-Item -ItemType Directory -Force $logDir | Out-Null
$log = Join-Path $logDir 'watch.log'

$code = 1
$watcher = $null
try {
  $watcher = Start-Process -FilePath 'herdr-theme' -ArgumentList 'watch' `
    -WindowStyle Hidden -RedirectStandardOutput $log `
    -RedirectStandardError (Join-Path $logDir 'watch.err.log') -PassThru
  & herdr @herdrArgs
  $code = $LASTEXITCODE
} finally {
  if ($watcher -and -not $watcher.HasExited) { Stop-Process -Id $watcher.Id -Force }
}
exit $code
EOF
    cat >"$BIN_DIR/herdrx.cmd" <<'EOF'
@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0herdrx.ps1" %*
EOF
    # Git Bash (MSYS) can't resolve .cmd/.ps1 from PATH — provide a sh entry
    # that just forwards to the native PowerShell herdrx (no kill logic here,
    # so no orphan risk).
    cat >"$BIN_DIR/herdrx" <<'EOF'
#!/bin/sh
# Git Bash entry: forward to the native PowerShell herdrx.
exec powershell -NoProfile -ExecutionPolicy Bypass -File "$(dirname "$0")/herdrx.ps1" "$@"
EOF
    chmod +x "$BIN_DIR/herdrx"
  ;;
  *)
    ln -sf "$ROOT/scripts/herdrx" "$BIN_DIR/herdrx"
  ;;
esac

echo "herdr-theme installed: $BIN_DIR/$LINK -> $BIN"
case "$(uname -s)" in
  MINGW*|MSYS*)
    echo "herdrx installed:      $BIN_DIR/herdrx.cmd -> herdrx.ps1 (PowerShell)" ;;
  *)
    echo "herdrx installed:      $BIN_DIR/herdrx -> $ROOT/scripts/herdrx" ;;
esac
[ -f "$BIN_DIR/herdrx.cmd" ] && echo "herdrx.cmd installed:  $BIN_DIR/herdrx.cmd (PowerShell shim)"

case "$(uname -s)" in
  MINGW*) : ;;
  *) if ! command -v dark-notify >/dev/null 2>&1; then
       echo
       echo "note: dark-notify not found — herdrx auto theme switching will be disabled."
       echo "      install with: mise use -g ubi:cormacrelf/dark-notify"
       echo "      (or: brew install cormacrelf/tap/dark-notify)"
     fi ;;
esac
