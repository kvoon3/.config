import { builtinThemes, customThemes, findTheme } from "./themes.ts"
import { applyTheme } from "./apply.ts"
import { readSettings } from "./auto.ts"
import { watch } from "./watch.ts"
import { startTui } from "./App.tsx"

const HELP = `herdr-theme — switch the herdr color theme

Usage:
  herdr-theme                 Interactive picker: configure the light/dark pair
  herdr-theme <name>          Switch directly to a theme (built-in or custom)
  herdr-theme watch           Follow macOS appearance (used by herdrx; needs
                              dark-notify: mise use -g ubi:cormacrelf/dark-notify)
  herdr-theme --list          List themes (marks the configured light/dark pair)
  herdr-theme --keep-custom   With a built-in theme: keep [theme.custom] overrides
  herdr-theme --help          Show this help

Auto switching: configure a light and a dark theme in the picker (or in
~/.config/herdr-theme/config.json) and start herdr via herdrx — the watcher
applies the matching theme whenever macOS changes appearance. Unset one of the
pair (enter on a set theme in the picker) to turn auto switching off.

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

  if (positional[0] === "watch") {
    await watch()
    return
  }

  if (args.includes("--list")) {
    const settings = readSettings()
    for (const group of [builtinThemes(), customThemes()]) {
      if (group.length === 0) continue
      console.log(group[0].type === "builtin" ? "built-in:" : "custom:")
      for (const theme of group) {
        const tags = [
          theme.name === settings.lightTheme ? "light" : "",
          theme.name === settings.darkTheme ? "dark" : "",
        ]
          .filter(Boolean)
          .join(", ")
        console.log(`  ${theme.name}${tags ? ` (${tags})` : ""}`)
      }
    }
    return
  }

  if (positional.length === 0) {
    await startTui()
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
