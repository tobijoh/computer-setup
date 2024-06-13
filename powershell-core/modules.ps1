Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

if (-not (Get-Module -Name Microsoft.PowerShell.PSResourceGet)) {
    Install-Module -Name Microsoft.PowerShell.PSResourceGet -AllowPrerelease
}

$ModulesHashTable = @{
    'posh-git'   = ''
    'PSFzF'      = ''
    'z'          = '1.1.10'
    'PSReadLine' = ''
}

foreach ($Module in $ModulesHashTable.GetEnumerator()) {
    if (-not (Get-PSResource -Name $Module.Name -ErrorAction SilentlyContinue)) {
        if (-not $Module.Value) {
            Install-PSResource -Name $Module.Name -Repository PSGallery -Scope CurrentUser
        }
        else {
            Install-PSResource -Name $Module.Name -Version $Module.Value -Repository PSGallery -Scope CurrentUser
        }
    }
}