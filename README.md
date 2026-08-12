# .config

Kevin Kwong's dotfiles for macOS.

## Setup

On a new macOS machine, copy and run:

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/kvoon3/.config/main/install.sh)"
```

To use HTTPS instead of SSH:

```sh
CONFIG_REPO=https://github.com/kvoon3/.config.git sh -c "$(curl -fsSL https://raw.githubusercontent.com/kvoon3/.config/main/install.sh)"
```

For an already-cloned checkout, the core setup is:

```sh
mise install
mise exec -- ~/.config/herdr-theme/scripts/install.sh
```

Use `herdrx` instead of `herdr` — it follows macOS appearance, applying the
light/dark theme pair from `herdr-theme/config.json` (edit via `herdr-theme`).

This setup uses mise for managed tools. `mise install` may fail to install
`dark-notify` if GitHub API rate limits unauthenticated requests; Homebrew is
only used as a fallback for that case:

```sh
brew install cormacrelf/tap/dark-notify
```

Kitty uses Input Mono. Install it with Homebrew:

```sh
brew install --cask font-input
```

## Windows notes (WezTerm + Git Bash)

Two one-time steps:

1. **UTF-8 system codepage** — fixes GBK mojibake in piped PowerShell/cmd output
   (pi tool results, copied error text). Run as Administrator, then **reboot**:

   ```powershell
   Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Nls\CodePage' -Name ACP -Value 65001
   Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Nls\CodePage' -Name OEMCP -Value 65001
   ```

   Equivalent GUI: 设置 → 时间和语言 → 语言和区域 → 管理语言设置 → 更改系统区域设置
   → 勾选 "Beta: 使用 Unicode UTF-8 提供全球语言支持"。

   Revert (e.g. legacy apps like Xshell misbehave):

   ```powershell
   Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Nls\CodePage' -Name ACP -Value 936
   Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Nls\CodePage' -Name OEMCP -Value 936
   ```

2. **Nerd Font** — `wezterm/wezterm.lua` uses `MesloLGM Nerd Font Mono`; without it
   WezTerm falls back and TUI icons render wrong. Install any Nerd Font from
   https://www.nerdfonts.com/font-downloads (Meslo LG M recommended), or use the
   GUI: 设置 → 个性化 → 字体 → 拖入下载的 .ttf 文件。
