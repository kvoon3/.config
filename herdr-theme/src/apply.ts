import { copyFileSync, existsSync, mkdirSync, readdirSync, statSync, unlinkSync } from "node:fs"
import { join } from "node:path"
import { configPath, writeTheme } from "./config.ts"
import { DATA_HOME, type ThemeEntry } from "./themes.ts"

export interface ApplyResult {
  reloaded: boolean
}

const BACKUP_DIR = join(DATA_HOME, "backups")
const MAX_BACKUPS = 10

/** Snapshot the current config before mutating it. Throttled: at most one backup per minute
 *  so rapid TUI previews don't churn through the retention window. */
function backupConfig(): void {
  const path = configPath()
  if (!existsSync(path)) return
  mkdirSync(BACKUP_DIR, { recursive: true })
  const backups = readdirSync(BACKUP_DIR)
    .filter((f) => f.startsWith("config-"))
    .sort()
  const newest = backups[backups.length - 1]
  if (newest && Date.now() - statSync(join(BACKUP_DIR, newest)).mtimeMs < 60_000) return
  const stamp = new Date().toISOString().replace(/[:.]/g, "-")
  copyFileSync(path, join(BACKUP_DIR, `config-${stamp}.toml`))
  for (const old of backups.slice(0, Math.max(0, backups.length - MAX_BACKUPS + 1))) {
    unlinkSync(join(BACKUP_DIR, old))
  }
}

/**
 * Apply a theme and ask the running herdr server to reload.
 * - custom theme: write name = <base> plus a full [theme.custom] block
 * - builtin theme: write name; [theme.custom] is cleared unless keepCustom is set
 */
export async function applyTheme(
  entry: ThemeEntry,
  opts: { keepCustom?: boolean } = {},
): Promise<ApplyResult> {
  backupConfig()
  if (entry.type === "custom") {
    writeTheme(entry.base ?? "terminal", entry.colors)
  } else {
    writeTheme(entry.name, opts.keepCustom ? "keep" : null)
  }

  try {
    const proc = Bun.spawn(["herdr", "server", "reload-config"], {
      stdout: "ignore",
      stderr: "ignore",
    })
    const code = await proc.exited
    return { reloaded: code === 0 }
  } catch {
    return { reloaded: false }
  }
}

/** Restore a raw config snapshot (theme name + custom tokens), e.g. when the TUI is cancelled. */
export async function restoreTheme(
  name: string,
  custom: Record<string, string> | null,
): Promise<void> {
  writeTheme(name, custom)
  try {
    const proc = Bun.spawn(["herdr", "server", "reload-config"], {
      stdout: "ignore",
      stderr: "ignore",
    })
    await proc.exited
  } catch {
    // Server not running; config is written and applies on next start.
  }
}
