import { builtinThemes, customThemes, findTheme, matchCustomTheme } from "./themes.ts"
import { readCurrentTheme, readCustomTheme } from "./config.ts"
import { applyTheme } from "./apply.ts"
import { startTui } from "./App.tsx"

const HELP = `herdr-theme — switch the herdr color theme

Usage:
  herdr-theme                 Interactive picker with live preview
  herdr-theme <name>          Switch directly to a theme (built-in or custom)
  herdr-theme --list          List themes (marks the current one)
  herdr-theme --keep-custom   With a built-in theme: keep [theme.custom] overrides
  herdr-theme --help          Show this help

Built-in themes come with full palettes (read from herdr's theme definitions).
Custom themes live in ~/.config/herdr-theme/themes/*.json and are applied as a
base theme plus a complete [theme.custom] block.

Switching to a built-in theme clears [theme.custom] (herdr-theme owns that
block); a backup of config.toml is kept in ~/.config/herdr-theme/backups/.
`

async function main() {
  const args = process.argv.slice(2)
  const keepCustom = args.includes("--keep-custom")
  const positional = args.filter((a) => !a.startsWith("--"))

  if (args.includes("--help") || args.includes("-h")) {
    process.stdout.write(HELP)
    return
  }

  const currentName = readCurrentTheme()
  const currentCustom = matchCustomTheme(readCustomTheme())
  const currentDisplay = currentCustom ?? currentName

  if (args.includes("--list")) {
    for (const group of [builtinThemes(), customThemes()]) {
      if (group.length === 0) continue
      console.log(group[0].type === "builtin" ? "built-in:" : "custom:")
      for (const theme of group) {
        const current = theme.name === currentDisplay
        console.log(`${current ? "❯ " : "  "}${theme.name}${current ? " (current)" : ""}`)
      }
    }
    return
  }

  if (positional.length === 0) {
    startTui()
    return
  }

  const name = positional[0]
  const entry = findTheme(name)
  if (!entry) {
    const names = [...builtinThemes(), ...customThemes()].map((t) => t.name)
    console.error(`unknown theme: ${name}\n\nAvailable themes:\n  ${names.join("\n  ")}`)
    process.exit(1)
  }

  const { reloaded } = await applyTheme(entry, { keepCustom })
  console.log(
    reloaded
      ? `theme switched to ${entry.name}`
      : `theme set to ${entry.name} (server not running; applies on next start)`,
  )
}

await main()
