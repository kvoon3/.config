# Loads the repo profile. Copied verbatim to both CurrentUserAllHosts profiles:
#   %USERPROFILE%\Documents\PowerShell\profile.ps1        (pwsh 7+)
#   %USERPROFILE%\Documents\WindowsPowerShell\profile.ps1 (Windows PowerShell 5.1)
#
# Read as text and Invoke-Expression'd instead of dot-sourced: RemoteSigned
# treats a UNC path as the untrusted zone and refuses to run an unsigned script
# file from it, while evaluating text needs no policy change. The repo profile
# must therefore not rely on $PSScriptRoot.

$repoProfile = '\\wsl.localhost\Ubuntu-24.04\home\kvoon\.config\dotfiles\powershell\profile.ps1'

$code = $null
try { $code = Get-Content -LiteralPath $repoProfile -Raw -ErrorAction Stop } catch { }

if ($code) {
    Invoke-Expression $code
    return
}

# WSL is down or the repo moved. Keep the shell usable with the one setting that
# matters: UTF-8 output. Tools come from the persistent user PATH, not from here.
$utf8 = New-Object System.Text.UTF8Encoding $false
try { [Console]::OutputEncoding = $utf8 } catch { }
$OutputEncoding = $utf8

if (-not [Console]::IsOutputRedirected) {
    Write-Host '[profile] repo profile unreachable; using fallback' -ForegroundColor DarkYellow
}
