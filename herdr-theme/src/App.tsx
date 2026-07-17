import { render, useKeyboard, useRenderer } from "@opentui/solid"
import { createSignal, For, onCleanup } from "solid-js"
import { builtinThemes, customThemes, matchCustomTheme, type ThemeEntry } from "./themes.ts"
import { readCurrentTheme, readCustomTheme } from "./config.ts"
import { applyTheme, restoreTheme } from "./apply.ts"

const PREVIEW_DEBOUNCE_MS = 150
const SWATCH_TOKENS = ["accent", "green", "yellow", "red", "blue", "mauve", "teal", "peach"]
const NAME_WIDTH = 18

function swatches(theme: ThemeEntry): { char: string; color: string }[] {
  return SWATCH_TOKENS.map((token) => {
    const color = theme.colors[token]
    if (!color || color === "reset") return { char: " ", color: "" }
    return { char: "■", color }
  })
}

export function App() {
  const renderer = useRenderer()
  type Row = { kind: "header"; label: string } | { kind: "theme"; theme: ThemeEntry; index: number }
  const rows: Row[] = []
  let index = 0
  for (const group of [
    { label: "built-in:", themes: builtinThemes() },
    { label: "custom:", themes: customThemes() },
  ]) {
    if (group.themes.length === 0) continue
    rows.push({ kind: "header", label: group.label })
    for (const theme of group.themes) rows.push({ kind: "theme", theme, index: index++ })
  }
  const entries = rows.flatMap((r) => (r.kind === "theme" ? [r.theme] : []))

  const originalName = readCurrentTheme()
  const originalCustom = readCustomTheme()
  const currentDisplay = matchCustomTheme(originalCustom) ?? originalName

  const startIndex = Math.max(
    0,
    entries.findIndex((t) => t.name === currentDisplay),
  )
  const [selected, setSelected] = createSignal(startIndex)
  const [status, setStatus] = createSignal("")

  let timer: ReturnType<typeof setTimeout> | undefined
  onCleanup(() => timer && clearTimeout(timer))

  function preview(index: number) {
    if (timer) clearTimeout(timer)
    timer = setTimeout(async () => {
      const entry = entries[index]
      const { reloaded } = await applyTheme(entry)
      setStatus(
        reloaded ? `previewing: ${entry.name}` : `written: ${entry.name} (server not running)`,
      )
    }, PREVIEW_DEBOUNCE_MS)
  }

  async function restoreAndExit() {
    if (timer) clearTimeout(timer)
    if (originalName) {
      await restoreTheme(originalName, originalCustom)
    }
    renderer.destroy()
  }

  useKeyboard((key) => {
    const i = selected()
    if (key.name === "up" || key.name === "k") {
      const next = (i - 1 + entries.length) % entries.length
      setSelected(next)
      preview(next)
    } else if (key.name === "down" || key.name === "j") {
      const next = (i + 1) % entries.length
      setSelected(next)
      preview(next)
    } else if (key.name === "return" || key.name === "enter") {
      if (timer) clearTimeout(timer)
      renderer.destroy()
    } else if (key.name === "escape" || key.name === "q" || (key.ctrl && key.name === "c")) {
      void restoreAndExit()
    }
  })

  return (
    <box flexDirection="column" padding={1}>
      <text fg="#7aa2f7">
        <strong>herdr-theme</strong>
      </text>
      <For each={rows}>
        {(row) => {
          if (row.kind === "header") {
            return <text fg="#666666">{row.label}</text>
          }
          const { theme, index } = row
          return (
            <text
              fg={
                index === selected()
                  ? "#9ece6a"
                  : theme.name === currentDisplay
                    ? "#7aa2f7"
                    : "#cccccc"
              }
            >
              {index === selected() ? "❯ " : "  "}
              {theme.name.padEnd(NAME_WIDTH)}
              {theme.name === currentDisplay ? "(current) " : "           "}
              <For each={swatches(theme)}>{(s) => <span fg={s.color || undefined}>{s.char}</span>}</For>
            </text>
          )
        }}
      </For>
      <text fg="#888888">{status() || " "}</text>
      <text fg="#666666">↑/↓ or j/k preview · enter keep · esc/q restore</text>
    </box>
  )
}

export function startTui() {
  render(() => <App />, { exitOnCtrlC: false })
}
