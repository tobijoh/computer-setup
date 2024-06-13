Set-PSReadLineOption -PredictionSource History
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# Shows navigable menu of all options when hitting Tab
Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }

Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
Set-PsFzfOption -TabExpansion

$GitPromptSettings.EnableStashStatus = $true

$ProfileDirectory = Split-Path -Path $PROFILE
$ThemePath = Join-Path $ProfileDirectory "Custom" "theme.omp.json"
if (-not (Test-Path $ThemePath)) {
    Invoke-WebRequest -Uri "https://github.com/tobijoh/computer-setup/releases/latest/download/theme.omp.json" -OutFile $ThemePath
}

# Encoding to deal with changes of PowerShell 7.4
[Console]::OutputEncoding = [Text.Encoding]::UTF8
oh-my-posh init pwsh --config $ThemePath | Invoke-Expression

function Set-PoshGitStatus {
    $global:GitStatus = Get-GitStatus
    $env:POSH_GIT_STRING = Write-GitStatus -Status $global:GitStatus
}
    
New-Alias -Name "Set-PoshContext" -Value "Set-PoshGitStatus" -Scope Global -Force
    