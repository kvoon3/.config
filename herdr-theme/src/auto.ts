import { readFileSync, writeFileSync } from "node:fs"
import { join } from "node:path"
import { DATA_HOME, findTheme } from "./themes.ts"
import { applyTheme } from "./apply.ts"

export type Mode = "light" | "dark"

/**
 * herdr-theme's own settings: the light/dark theme pair. Auto-switching is a
 * derived state — it is on exactly when both slots are set; unsetting one slot
 * is how you turn it off.
 */
export interface Settings {
  lightTheme: string | null
  darkTheme: string | null
}

export function settingsPath(): string {
  return join(DATA_HOME, "config.json")
}

export function readSettings(): Settings {
  try {
    const raw = JSON.parse(readFileSync(settingsPath(), "utf8"))
    return {
      lightTheme: typeof raw.lightTheme === "string" ? raw.lightTheme : null,
      darkTheme: typeof raw.darkTheme === "string" ? raw.darkTheme : null,
    }
  } catch {
    return { lightTheme: null, darkTheme: null }
  }
}

export function writeSettings(settings: Settings): void {
  writeFileSync(settingsPath(), JSON.stringify(settings, null, 2) + "\n")
}

export function autoEnabled(settings: Settings): boolean {
  return settings.lightTheme !== null && settings.darkTheme !== null
}

/** Current macOS appearance. `AppleInterfaceStyle` only exists in dark mode. */
export async function currentMode(): Promise<Mode> {
  try {
    const proc = Bun.spawn(["defaults", "read", "-g", "AppleInterfaceStyle"], {
      stdout: "pipe",
      stderr: "ignore",
    })
    const out = await new Response(proc.stdout).text()
    await proc.exited
    return out.trim().toLowerCase().startsWith("dark") ? "dark" : "light"
  } catch {
    return "light"
  }
}

/**
 * Apply the theme configured for `mode` (if any). Settings are re-read on every
 * call so edits made while the watcher is running take effect immediately.
 */
export async function applyForMode(mode: Mode): Promise<boolean> {
  const settings = readSettings()
  const name = mode === "dark" ? settings.darkTheme : settings.lightTheme
  if (!name) return false
  const entry = findTheme(name)
  if (!entry) {
    console.error(`watch: theme "${name}" configured for ${mode} mode not found`)
    return false
  }
  await applyTheme(entry)
  console.log(`watch: applied ${name} (${mode} mode)`)
  return true
}
