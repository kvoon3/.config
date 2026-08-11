/**
 * Compile herdr-theme to a standalone binary at dist/herdr-theme.
 * Usage: bun run build
 *
 * The binary reads themes/ and data/ from DATA_HOME (~/.config/herdr-theme,
 * override with HERDR_THEME_HOME) at runtime, so keep the repo checkout there.
 */
import solidPlugin from "@opentui/solid/bun-plugin"

const OUT = `dist/herdr-theme${process.platform === "win32" ? ".exe" : ""}`

const result = await Bun.build({
  entrypoints: ["src/index.tsx"],
  target: "bun",
  plugins: [solidPlugin],
  compile: {
    outfile: OUT,
  },
})

if (!result.success) {
  for (const log of result.logs) console.error(log)
  process.exit(1)
}
console.log(`built ${OUT}`)
