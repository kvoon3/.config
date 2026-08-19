---
name: battery
description: >
  Run battery CLI commands on Apple Silicon Macs. Use this when the user asks about battery status, battery percentage, battery health, time remaining, charging state, setting a charge limit, maintaining battery at a certain level, stopping battery maintenance, calibrating the battery, charging to a target, discharging to a target, checking battery logs, updating the battery tool, or reinstalling/uninstalling the battery utility. Triggers include any mention of "battery" in the context of their Mac — status, charge, limit, maintain, calibrate, discharge, logs, update, install.
---

# Battery

Run the `battery` CLI utility on Apple Silicon Macs. This tool manages the SMC (System Management Controller) to control battery charging behavior.

## Commands

### Status
```bash
battery status
```
Shows current battery percentage, voltage, time remaining, and whether maintenance is active.

### Maintain
```bash
battery maintain 80           # maintain at 80%
battery maintain 70-80        # maintain between 70-80%
battery maintain stop         # stop maintenance
```
Reboot-persistent battery level maintenance. Keeps battery within a target range when plugged in.

### Charging
```bash
battery charging on           # allow charging
battery charging off          # stop charging
```
Manually enable/disable charging.

### Adapter
```bash
battery adapter on            # allow adapter power
battery adapter off           # block adapter power (discharges even when plugged in)
```

### Charge / Discharge
```bash
battery charge 90             # charge up to 90%, then stop
battery discharge 80          # discharge down to 80%, then stop
```
One-time charge/discharge to a target. Maintenance is restored after completion.

### Calibrate
```bash
battery calibrate
```
Discharges to ~15%, recharges to 100%, holds for 1 hour. Maintenance restored after.

### Logs
```bash
battery logs                  # show recent logs
battery logs 100              # show last 100 lines
```

### Maintenance
```bash
battery update                # update to latest version
battery reinstall             # reinstall the CLI
battery uninstall             # remove everything
```

## How to handle user requests

When the user asks something about their battery, map their intent to a command and run it directly with `bash`. Show the output as-is — it's already human-readable. If the intent is ambiguous, ask a short clarifying question before running.

**Examples of user phrasing → command:**

| User says | Run |
|---|---|
| "What's my battery at?" / "battery status" / "how's the battery?" | `battery status` |
| "Keep battery at 80%" / "set charge limit to 80" / "limit battery to 80" | `battery maintain 80` |
| "Stop maintaining" / "remove battery limit" / "let it charge fully" | `battery maintain stop` |
| "Charge to 90%" / "fill battery to 90" | `battery charge 90` |
| "Discharge to 50%" / "drain to 50" | `battery discharge 50` |
| "Calibrate battery" | `battery calibrate` |
| "Show battery logs" / "what's been happening with my battery?" | `battery logs` |
| "Update battery tool" | `battery update` |
| "Uninstall battery tool" | `battery uninstall` |
| "Stop charging" / "pause charging" | `battery charging off` |
| "Start charging" / "resume charging" | `battery charging on` |
