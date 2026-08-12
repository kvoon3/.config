# Windows setup notes (WezTerm + Git Bash)

Two one-time steps:

## 1. UTF-8 system codepage

Fixes GBK mojibake in piped PowerShell/cmd output (pi tool results, copied error
text). Run as Administrator, then **reboot**:

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

## 2. Nerd Font

`wezterm/wezterm.lua` uses `MesloLGM Nerd Font Mono`; without it WezTerm falls
back and TUI icons render wrong. Install any Nerd Font from
https://www.nerdfonts.com/font-downloads (Meslo LG M recommended), or use the
GUI: 设置 → 个性化 → 字体 → 拖入下载的 .ttf 文件。
