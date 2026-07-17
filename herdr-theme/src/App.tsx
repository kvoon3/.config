import { render, useKeyboard, useRenderer } from "@opentui/solid"
import { createSignal, For } from "solid-js"
import { builtinThemes, customThemes, type ThemeEntry } from "./themes.ts"
import { applyTheme } from "./apply.ts"
import {
  autoEnabled,
  currentMode,
  readSettings,
  writeSettings,
  type Mode,
  type Settings,
} from "./auto.ts"

const SWATCH_TOKENS = ["accent", "green", "yellow", "red", "blue", "mauve", "teal", "peach"]
const NAME_WIDTH = 18

function swatches(theme: ThemeEntry): { char: string; color: string }[] {
  return SWATCH_TOKENS.map((token) => {
    const color = theme.colors[token]
    if (!color || color === "reset") return { char: " ", color: "" }
    return { char: "■", color }
  })
}

type Row = { kind: "header"; label: string } | { kind: "theme"; theme: ThemeEntry; index: number }

function slotOf(settings: Settings, mode: Mode): string | null {
  return mode === "light" ? settings.lightTheme : settings.darkTheme
}

export function App(props: { initialTab: Mode }) {
  const renderer = useRenderer()
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

  const [tab, setTab] = createSignal<Mode>(props.initialTab)
  const [settings, setSettings] = createSignal<Settings>(readSettings())
  const [selected, setSelected] = createSignal(0)
  const [status, setStatus] = createSignal("")

  function cursorToSlot(mode: Mode) {
    const name = slotOf(settings(), mode)
    setSelected(Math.max(0, entries.findIndex((t) => t.name === name)))
  }
  cursorToSlot(props.initialTab)

  function switchTab(next: Mode) {
    if (next === tab()) return
    setTab(next)
    cursorToSlot(next)
  }

  /** enter: set the highlighted theme as this tab's slot (applied immediately only
   *  when the tab matches the live system mode); pressing enter on the theme
   *  already in the slot unsets it. */
  async function commit() {
    const entry = entries[selected()]
    const next = { ...settings() }
    const key = tab() === "light" ? "lightTheme" : "darkTheme"
    if (next[key] === entry.name) {
      if (!slotOf(next, tab() === "light" ? "dark" : "light")) {
        setStatus(`cannot unset ${entry.name}: it is the last configured theme`)
        return
      }
      next[key] = null
      writeSettings(next)
      setSettings(next)
      setStatus(`${tab()}: unset ${entry.name}`)
      return
    }
    next[key] = entry.name
    writeSettings(next)
    setSettings(next)
    // Apply immediately only when this tab matches the live system mode;
    // configuring the other mode's theme must not flip the UI right now.
    if ((await currentMode()) !== tab()) {
      setStatus(`${tab()} → ${entry.name} (saved; applies when system goes ${tab()})`)
      return
    }
    const { reloaded } = await applyTheme(entry)
    setStatus(
      reloaded
        ? `${tab()} → ${entry.name} (applied)`
        : `${tab()} → ${entry.name} (written; server not running)`,
    )
  }

  useKeyboard((key) => {
    const i = selected()
    if (key.name === "left" || key.name === "h") {
      switchTab("light")
    } else if (key.name === "right" || key.name === "l" || key.name === "tab" || key.raw === "\t") {
      switchTab(tab() === "light" ? "dark" : "light")
    } else if (key.name === "up" || key.name === "k") {
      setSelected((i - 1 + entries.length) % entries.length)
    } else if (key.name === "down" || key.name === "j") {
      setSelected((i + 1) % entries.length)
    } else if (key.name === "return" || key.name === "enter") {
      void commit()
    } else if (key.name === "escape" || key.name === "q" || (key.ctrl && key.name === "c")) {
      renderer.destroy()
    }
  })

  function tabLabel(mode: Mode) {
    const active = tab() === mode
    const name = slotOf(settings(), mode)
    return (
      <text fg={active ? "#9ece6a" : "#666666"}>
        {active ? "❯ " : "  "}
        <strong>{mode}</strong>
        {name ? `: ${name}` : ""}
      </text>
    )
  }

  return (
    <box flexDirection="column" padding={1}>
      <box flexDirection="row" gap={3}>
        {tabLabel("light")}
        {tabLabel("dark")}
        <text fg="#666666">{autoEnabled(settings()) ? "auto on" : "auto off"}</text>
      </box>
      <For each={rows}>
        {(row) => {
          if (row.kind === "header") {
            return <text fg="#666666">{row.label}</text>
          }
          const { theme, index } = row
          const isSlot = () => theme.name === slotOf(settings(), tab())
          return (
            <text fg={index === selected() ? "#9ece6a" : isSlot() ? "#7aa2f7" : "#cccccc"}>
              {index === selected() ? "❯ " : "  "}
              {theme.name.padEnd(NAME_WIDTH)}
              {isSlot() ? "(set) " : "      "}
              <For each={swatches(theme)}>
                {/* span props only honor `style` (fg/bg) — a direct `fg` prop is dropped by @opentui/solid */}
                {(s) => <span style={{ fg: s.color || undefined } as {}}>{s.char}</span>}
              </For>
            </text>
          )
        }}
      </For>
      <text fg="#888888">{status() || " "}</text>
      <text fg="#666666">←/→/tab switch · ↑/↓ or j/k select · enter set/unset · esc/q quit</text>
    </box>
  )
}

export async function startTui() {
  const initialTab = await currentMode()
  render(() => <App initialTab={initialTab} />, { exitOnCtrlC: false })
}
