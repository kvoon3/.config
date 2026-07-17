import { applyForMode, type Mode } from "./auto.ts"

/**
 * Long-running watcher: stream appearance changes from dark-notify and apply
 * the configured theme per mode. dark-notify prints the current mode as soon
 * as it starts, which doubles as the initial sync.
 *
 * Runs until killed (herdrx kills it when herdr exits).
 */
export async function watch(): Promise<void> {
  const bin = Bun.which("dark-notify")
  if (!bin) {
    console.error(
      "herdr-theme watch: dark-notify not found — auto theme switching disabled.\n" +
        "  install with: mise use -g ubi:cormacrelf/dark-notify\n" +
        "  (or: brew install cormacrelf/tap/dark-notify)",
    )
    process.exit(1)
  }

  const proc = Bun.spawn([bin], { stdout: "pipe", stderr: "inherit" })
  const shutdown = (code: number) => {
    try {
      proc.kill()
    } catch {
      // Child already gone.
    }
    process.exit(code)
  }
  process.on("SIGTERM", () => shutdown(0))
  process.on("SIGINT", () => shutdown(130))

  console.log("herdr-theme watch: following system appearance")

  const decoder = new TextDecoder()
  let pending = ""
  for await (const chunk of proc.stdout) {
    pending += decoder.decode(chunk, { stream: true })
    const lines = pending.split("\n")
    pending = lines.pop() ?? ""
    for (const line of lines) {
      const mode = line.trim()
      if (mode === "light" || mode === "dark") {
        await applyForMode(mode as Mode)
      }
    }
  }

  const code = await proc.exited
  console.error(`herdr-theme watch: dark-notify exited (${code})`)
  process.exit(code ?? 0)
}
