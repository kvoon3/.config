import { applyForMode, type Mode } from "./auto.ts"

/**
 * Long-running watcher: stream appearance changes from dark-notify and apply
 * the configured theme per mode. dark-notify prints the current mode as soon
 * as it starts, which doubles as the initial sync.
 *
 * Runs until killed (herdrx kills it when herdr exits).
 */
// Windows: subscribe to RegistryKeyChangeEvent (RegNotifyChangeKeyValue under the
// hood) on the Personalize key — fires when the appearance setting changes, no
// polling. Same "light"/"dark" line protocol as dark-notify, so the streaming
// below is shared. Wait-Event -Timeout 10 doubles as a slow fallback poll and a
// parent-death check so a fast herdrx cleanup can't orphan it.
// HKEY_USERS + SID is used because HKEY_CURRENT_USER resolves to the WMI service's
// account, not the logged-in user's.
const WIN_POLL = "$sid=[System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value; $p='HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize'; $q=\"SELECT * FROM RegistryKeyChangeEvent WHERE Hive='HKEY_USERS' AND KeyPath='$sid\\\\Software\\\\Microsoft\\\\Windows\\\\CurrentVersion\\\\Themes\\\\Personalize'\"; Register-CimIndicationEvent -Query $q -SourceIdentifier theme -ErrorVariable evErr -ErrorAction SilentlyContinue; if($evErr){ [Console]::Error.WriteLine('herdr-theme watch: registry event subscription failed, falling back to 10s polling') }; $v=(Get-ItemProperty $p).AppsUseLightTheme; $m=if($v -eq 0){'dark'}else{'light'}; $m; $prev=$m; while($true){ Wait-Event -SourceIdentifier theme -Timeout 10 | Out-Null; Remove-Event -SourceIdentifier theme -ErrorAction SilentlyContinue; $v=(Get-ItemProperty $p).AppsUseLightTheme; $m=if($v -eq 0){'dark'}else{'light'}; if($m -ne $prev){ $m; $prev=$m }; $par=(Get-CimInstance Win32_Process -Filter \"ProcessId=$PID\").ParentProcessId; if(-not (Get-Process -Id $par -ErrorAction SilentlyContinue)){ break } }"

function appearanceCmd(): string[] {
  if (process.platform === "win32") {
    return ["powershell", "-NoProfile", "-Command", WIN_POLL]
  }
  const bin = Bun.which("dark-notify")
  if (!bin) {
    console.error(
      "herdr-theme watch: dark-notify not found — auto theme switching disabled.\n" +
        "  install with: mise use -g ubi:cormacrelf/dark-notify\n" +
        "  (or: brew install cormacrelf/tap/dark-notify)",
    )
    process.exit(1)
  }
  return [bin]
}

export async function watch(): Promise<void> {
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

  const proc = Bun.spawn(appearanceCmd(), { stdout: "pipe", stderr: "inherit" })

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
