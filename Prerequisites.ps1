function InstallChocolatey {
    if (Check-Command -cmdname 'choco') {
        Write-Host "Choco is already installed, skip installation."
    }
    else {
        Write-Host "Installing Chocolatey first..."
        Write-Host "------------------------------------"
        Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        Write-Host "Installed Chocolatey" -ForegroundColor Green
    }
}

function InstallBoxstarter {
    if (Check-Command -cmdname 'Install-BoxstarterPackage') {
        Write-Host "Boxstarter is already installed, skip installation."
    }
    else {
        Write-Host "Installing Boxstarter..."
        Write-Host "------------------------------------"
        . { Invoke-WebRequest -useb https://boxstarter.org/bootstrapper.ps1 } | Invoke-Expression; Get-Boxstarter -Force
        Write-Host "Installed Boxstarter" -ForegroundColor Green
    }
}

function InstallScoop {
    if (Check-Command -cmdname 'scoop') {
        Write-Host "scoop is already installed, skip installation."
    }
    else {
        Write-Host "Installing scoop..."
        Write-Host "------------------------------------"
        Invoke-WebRequest -Uri https://get.scoop.sh -OutFile '.\install-scoop.ps1'
        Invoke-Expression '.\install-scoop.ps1 -RunAsAdmin'
        Remove-Item -Path install-scoop.ps1
        Write-Host "Installed scoop" -ForegroundColor Green
    }
}

# HELPER FUNCTIONS
function Check-Command($cmdname) {
    return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
}