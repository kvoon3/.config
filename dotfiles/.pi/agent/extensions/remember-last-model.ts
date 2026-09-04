import { readFileSync, writeFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const settingsPath = join(
  process.env.PI_CODING_AGENT_DIR ?? join(homedir(), ".pi", "agent"),
  "settings.json",
);

export default function rememberLastModel(pi: ExtensionAPI): void {
  pi.on("model_select", (event, ctx) => {
    if (ctx.mode !== "tui" || event.source === "restore") return;

    try {
      const settings = JSON.parse(readFileSync(settingsPath, "utf8")) as Record<string, unknown>;
      settings.defaultProvider = event.model.provider;
      settings.defaultModel = event.model.id;
      writeFileSync(settingsPath, `${JSON.stringify(settings, null, 2)}\n`);
    } catch (error) {
      ctx.ui.notify(
        `Could not save last model: ${error instanceof Error ? error.message : String(error)}`,
        "error",
      );
    }
  });
}
