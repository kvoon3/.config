import { readFileSync, writeFileSync, existsSync } from "node:fs"
import { homedir } from "node:os"
import { join } from "node:path"
import { THEME_TOKENS, type ThemeColors } from "./themes.ts"

export function configPath(): string {
  return process.env.HERDR_CONFIG_PATH ?? join(homedir(), ".config", "herdr", "config.toml")
}

const SECTION_RE = /^\s*\[([^\]]+)\]/
const NAME_RE = /^(\s*)name\s*=.*$/
const KV_RE = /^\s*([A-Za-z0-9_]+)\s*=\s*"([^"]*)"\s*$/

function sectionName(line: string): string | null {
  const m = SECTION_RE.exec(line)
  return m ? m[1].trim() : null
}

/** Find the line range [start, end) of a TOML section by exact name. */
function findSection(lines: string[], name: string): { start: number; end: number } | null {
  for (let i = 0; i < lines.length; i++) {
    if (sectionName(lines[i]) === name) {
      let end = lines.length
      for (let j = i + 1; j < lines.length; j++) {
        if (sectionName(lines[j]) !== null) {
          end = j
          break
        }
      }
      return { start: i, end }
    }
  }
  return null
}

function readLines(): string[] {
  const path = configPath()
  if (!existsSync(path)) return []
  return readFileSync(path, "utf8").split("\n")
}

export function readCurrentTheme(): string | null {
  const lines = readLines()
  const theme = findSection(lines, "theme")
  if (!theme) return null
  for (let i = theme.start + 1; i < theme.end; i++) {
    const m = /^\s*name\s*=\s*"([^"]*)"/.exec(lines[i])
    if (m) return m[1]
  }
  return null
}

export function readCustomTheme(): ThemeColors | null {
  const lines = readLines()
  const custom = findSection(lines, "theme.custom")
  if (!custom) return null
  const colors: ThemeColors = {}
  for (let i = custom.start + 1; i < custom.end; i++) {
    const m = KV_RE.exec(lines[i])
    if (m) colors[m[1]] = m[2]
  }
  return colors
}

/**
 * Rewrite the theme in one pass, preserving every unrelated line.
 * - `custom === "keep"`: leave [theme.custom] as is
 * - `custom === null`: remove [theme.custom]
 * - otherwise: replace [theme.custom] with exactly these colors (canonical token order)
 */
export function writeTheme(name: string, custom: ThemeColors | null | "keep"): void {
  const path = configPath()
  const text = existsSync(path) ? readFileSync(path, "utf8") : ""
  const lines = text.split("\n")

  // 1. [theme.custom]
  const customSection = findSection(lines, "theme.custom")
  if (custom !== "keep" && customSection) {
    lines.splice(customSection.start, customSection.end - customSection.start)
  }
  if (custom !== "keep" && custom !== null) {
    const ordered = THEME_TOKENS.filter((t) => custom[t] !== undefined)
    const extra = Object.keys(custom).filter((k) => !THEME_TOKENS.includes(k))
    const block = [
      "[theme.custom]",
      ...[...ordered, ...extra].map((k) => `${k} = "${custom[k]}"`),
    ]
    const theme = findSection(lines, "theme")
    const at = theme ? theme.end : lines.length
    const blockWithPadding = [
      ...(at > 0 && lines[at - 1] !== "" ? [""] : []),
      ...block,
      ...(at < lines.length && lines[at] !== "" ? [""] : []),
    ]
    lines.splice(at, 0, ...blockWithPadding)
  }

  // 2. [theme] name
  const theme = findSection(lines, "theme")
  if (theme) {
    for (let i = theme.start + 1; i < theme.end; i++) {
      const m = NAME_RE.exec(lines[i])
      if (m) {
        lines[i] = `${m[1]}name = "${name}"`
        writeFileSync(path, lines.join("\n"))
        return
      }
    }
    lines.splice(theme.start + 1, 0, `name = "${name}"`)
    writeFileSync(path, lines.join("\n"))
    return
  }
  const out = lines.join("\n")
  const base = out.endsWith("\n") || out === "" ? out : out + "\n"
  writeFileSync(path, base + (base === "" ? "" : "\n") + `[theme]\nname = "${name}"\n`)
}
