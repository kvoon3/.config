import { readdirSync, readFileSync } from "node:fs"
import { homedir } from "node:os"
import { join } from "node:path"

/**
 * Where themes and backups live. Fixed to the dotfiles location so the compiled
 * binary and `bun run` behave identically; override for testing.
 */
export const DATA_HOME =
  process.env.HERDR_THEME_HOME ?? join(homedir(), ".config", "herdr-theme")

interface BuiltinData {
  tokens: string[]
  themes: Record<string, ThemeColors>
}

function loadBuiltinData(): BuiltinData {
  const path = join(DATA_HOME, "data", "builtin-themes.json")
  try {
    return JSON.parse(readFileSync(path, "utf8"))
  } catch {
    throw new Error(`cannot read ${path} — run \`bun run sync\` in the herdr-theme repo first`)
  }
}

const builtinData = loadBuiltinData()

/** The 16 color tokens herdr understands in [theme.custom]. */
export const THEME_TOKENS = builtinData.tokens

export type ThemeColors = Record<string, string>

export interface ThemeEntry {
  name: string
  type: "builtin" | "custom"
  /** Custom themes only: the built-in base written to [theme] name. */
  base?: string
  colors: ThemeColors
}

export function builtinThemes(): ThemeEntry[] {
  return Object.entries(builtinData.themes).map(([name, colors]) => ({
    name,
    type: "builtin" as const,
    colors: colors as ThemeColors,
  }))
}

export function customThemes(): ThemeEntry[] {
  const dir = join(DATA_HOME, "themes")
  let files: string[]
  try {
    files = readdirSync(dir).filter((f) => f.endsWith(".json"))
  } catch {
    return []
  }
  const themes: ThemeEntry[] = []
  for (const file of files.sort()) {
    try {
      const raw = JSON.parse(readFileSync(join(dir, file), "utf8"))
      themes.push({
        name: raw.name ?? file.replace(/\.json$/, ""),
        type: "custom",
        base: raw.base ?? "terminal",
        colors: raw.colors ?? {},
      })
    } catch {
      // Skip malformed theme files.
    }
  }
  return themes
}

export function allThemes(): ThemeEntry[] {
  return [...builtinThemes(), ...customThemes()]
}

export function findTheme(name: string): ThemeEntry | undefined {
  return allThemes().find((t) => t.name === name)
}

/**
 * Identify the active custom theme from [theme.custom]: every token in the config
 * must match the theme's colors, with a minimum of 4 tokens to avoid false positives
 * from small hand-made tweaks. Extra/missing tokens in the config are fine.
 */
export function matchCustomTheme(custom: ThemeColors | null): string | null {
  if (!custom) return null
  const entries = Object.entries(custom)
  if (entries.length < 4) return null
  for (const theme of customThemes()) {
    if (entries.every(([k, v]) => theme.colors[k] === v)) return theme.name
  }
  return null
}
