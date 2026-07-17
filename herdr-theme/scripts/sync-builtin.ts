/**
 * Regenerate data/builtin-themes.json from herdr's source (src/app/state.rs).
 * Usage: bun run sync
 */
import { writeFileSync } from "node:fs"
import { join } from "node:path"

const STATE_RS_URL =
  "https://raw.githubusercontent.com/ogulcancelik/herdr/master/src/app/state.rs"

const TOKENS = [
  "accent", "panel_bg", "surface0", "surface1", "surface_dim", "overlay0", "overlay1",
  "text", "subtext0", "mauve", "green", "yellow", "red", "blue", "teal", "peach",
]

function toHex(r: string, g: string, b: string): string {
  return (
    "#" +
    [r, g, b].map((n) => Number(n).toString(16).padStart(2, "0")).join("")
  )
}

const source = await (await fetch(STATE_RS_URL)).text()

// 1. Parse Palette constructors: `pub fn tokyo_night() -> Self { ... }`
const constructors = new Map<string, Record<string, string>>()
const ctorRe = /pub fn (\w+)\(\) -> Self \{\s*Self \{([\s\S]*?)\}\s*\}/g
for (const m of source.matchAll(ctorRe)) {
  const [, fnName, body] = m
  const colors: Record<string, string> = {}
  for (const field of body.matchAll(/(\w+):\s*Color::Rgb\((\d+),\s*(\d+),\s*(\d+)\)/g)) {
    colors[field[1]] = toHex(field[2], field[3], field[4])
  }
  for (const field of body.matchAll(/(\w+):\s*Color::(\w+)/g)) {
    if (!(field[1] in colors)) colors[field[1]] = field[2].toLowerCase()
  }
  constructors.set(fnName, colors)
}

// 2. Map theme names to constructors via `from_name` arms (first alias wins).
const themes: Record<string, Record<string, string>> = {}
const armRe = /"([^"]+)"(?:\s*\|\s*"[^"]+")*\s*=>\s*Some\(Self::(\w+)\(\)\)/g
for (const m of source.matchAll(armRe)) {
  const [, name, fnName] = m
  const colors = constructors.get(fnName)
  if (colors && !themes[name]) themes[name] = colors
}

for (const [name, colors] of Object.entries(themes)) {
  const missing = TOKENS.filter((t) => !(t in colors))
  if (missing.length > 0) {
    throw new Error(`theme ${name}: missing tokens after parse: ${missing.join(", ")}`)
  }
}

const out = {
  source: "https://github.com/ogulcancelik/herdr/blob/master/src/app/state.rs",
  syncedAt: new Date().toISOString().slice(0, 10),
  tokens: TOKENS,
  themes,
}
const target = join(import.meta.dir, "..", "data", "builtin-themes.json")
writeFileSync(target, JSON.stringify(out, null, 2) + "\n")
console.log(`wrote ${Object.keys(themes).length} themes to ${target}`)
