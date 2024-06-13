$Aliases = @{
    g                   = 'git'
    os                  = 'Open-Solution'
    op                  = 'Open-Profile'
    nconf               = 'Open-NVimConfig'
    dev                 = 'Open-Dev'
    devrand             = 'Open-DevRandom'
    opf                 = 'Open-ProfileFolder'
    opu                 = 'Open-ProfileUtils'
    opa                 = 'Open-ProfileAliases'
    'validate-renovate' = 'Test-RenovateConfig'
}

$Aliases.GetEnumerator() | ForEach-Object {
    Set-Alias $_.Key $_.Value
}

function Show-CustomAliases {
    $AllAliases = Get-Alias | Select-Object -ExpandProperty Name

    foreach ($Alias in $AllAliases) {
        if ($Aliases.ContainsKey($Alias)) {
            Write-Output "$Alias -> $($Aliases[$Alias])"
        }
    }
}

Set-Alias aliases Show-CustomAliases