# PowerShell profile. Loaded as text by the machine-local shim, so both
# Windows PowerShell 5.1 and pwsh 7+ parse this same file: no `?:`, no `??`,
# no `$PSStyle` outside a version guard.

$Interactive = -not [Console]::IsOutputRedirected -and -not [Console]::IsInputRedirected

$utf8 = New-Object System.Text.UTF8Encoding $false
try { [Console]::OutputEncoding = $utf8 } catch { }
try { [Console]::InputEncoding = $utf8 } catch { }
$OutputEncoding = $utf8

if ($PSVersionTable.PSVersion -ge [version]'7.3') {
    $PSNativeCommandArgumentPassing = 'Standard'
    $PSNativeCommandUseErrorActionPreference = $true
}

if ($PSVersionTable.PSVersion.Major -lt 6) {
    # 5.1 writes UTF-16LE by default; these three cmdlets get UTF-8 instead.
    $PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
    $PSDefaultParameterValues['Set-Content:Encoding'] = 'utf8'
    $PSDefaultParameterValues['Add-Content:Encoding'] = 'utf8'
}

# mise shims, appended: a shim that shares a name with a system binary must not
# shadow it. Not `mise activate`, which prepends one path per installed tool.
$miseShims = Join-Path $env:LOCALAPPDATA 'mise\shims'
if ((Test-Path -LiteralPath $miseShims) -and ($env:PATH -split ';') -notcontains $miseShims) {
    $env:PATH = "$env:PATH;$miseShims"
}

# WSL interop starts the process in the Linux cwd. Outside /mnt that is a UNC
# path, which child processes cannot use, so fall back to the Windows home.
try {
    $startDir = $PWD.ProviderPath
    if ($startDir -like '\\wsl.localhost\*' -or $startDir -like '\\wsl$\*') {
        [Environment]::CurrentDirectory = $env:USERPROFILE
        Set-Location -LiteralPath $env:USERPROFILE
        if ($Interactive) {
            Write-Host "[profile] cwd under WSL ($startDir); using $env:USERPROFILE" -ForegroundColor DarkYellow
        }
    }
} catch { }

if (-not $Interactive) {
    $ProgressPreference = 'SilentlyContinue'
    if (-not $env:NO_COLOR) { $env:NO_COLOR = '1' }
    if ($PSVersionTable.PSVersion -ge [version]'7.2') { $PSStyle.OutputRendering = 'PlainText' }
    # Opt-in strict mode (set by psh/psh51): a failed command must not exit 0.
    if ($env:PSH_STRICT) { $ErrorActionPreference = 'Stop' }
}

# A function rather than a top-level block: the shim runs this file through
# Invoke-Expression, where a bare `return` would end the caller's scope.
function Initialize-InteractiveProfile {

    if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
        oh-my-posh init pwsh | Invoke-Expression
    }

    $psrl = Get-Module -ListAvailable PSReadLine |
        Sort-Object Version -Descending | Select-Object -First 1
    if ($psrl) {
        Import-Module PSReadLine -ErrorAction SilentlyContinue
        try {
            Set-PSReadLineOption -EditMode Windows -BellStyle None `
                -HistoryNoDuplicates -MaximumHistoryCount 10000
            Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
            Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
            Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
        } catch { }
        if ($psrl.Version -ge [version]'2.1.0') {
            try {
                Set-PSReadLineOption -PredictionSource History -PredictionViewStyle ListView
            } catch { }
        }
    }

    function global:ll { Get-ChildItem -Force @args }
    function global:la { Get-ChildItem @args }
    function global:.. { Set-Location .. }
    function global:... { Set-Location ..\.. }

    function global:which {
        param([Parameter(ValueFromRemainingArguments = $true)][string[]] $Name)
        foreach ($n in $Name) {
            $c = Get-Command $n -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($c) { $c.Source } else { "which: $n not found" }
        }
    }

    function global:gs { git status @args }
    function global:gd { git diff @args }
    function global:gll { git log --graph --all --pretty=format:'%C(magenta)%h %C(white) %an  %ar%C(blue)  %D%n%s%n' @args }
    function global:cc { claude --dangerously-skip-permissions @args }
    function global:ss { Get-Content -Raw package.json | ConvertFrom-Json | Select-Object -ExpandProperty scripts }

    if (Get-Command lazygit -ErrorAction SilentlyContinue) {
        Set-Alias -Name lg -Value lazygit -Scope Global -Option AllScope
    }
}

if ($Interactive) { Initialize-InteractiveProfile }
