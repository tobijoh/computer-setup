. .\Prerequisites.ps1
. .\Environment.ps1
. .\Programs.ps1

function Run {
    InstallPrerequisites
    ConfigureEnvironment
    InstallPrograms
    ConfigureDevelopmentTools
    CleanUpDesktop
    RunWindowsUpdate
    AddBoxstarterDoneRestorePoint
    SetGitUser

    Invoke-Reboot
}

function InstallPrerequisites {
    InstallChocolatey
    InstallBoxstarter
    InstallScoop    

    refreshenv
}

function ConfigureEnvironment {
    SetupChocolateyCacheFolder

    Update-ExecutionPolicy Unrestricted

    SetupRestorePoint
    DisableUac
    SetupPowerOptions
    SetupDirectoryOptions
    CleanUpPreInstalledApps
    InstallWindowsSubsystemForLinux
    InstallFonts
}

function CleanUpDesktop {
    Write-Host "Cleaning desktop"
    
    $ThingsToRemove = @(
        "*lnk",
        "desktop.ini"
    )

    foreach ($ThingToRemove in $ThingsToRemove) {
        Get-ChildItem (Join-Path $env:USERPROFILE "Desktop") -Filter $ThingToRemove -Force | ForEach-Object ($_) { Remove-Item $_.FullName -Force }
    }
    
    Write-Host "Desktop cleaned"
}

function AddBoxstarterDoneRestorePoint {
    if (!((Get-ComputerRestorePoint).Description -Like "Boxstarter done")) {
        Checkpoint-Computer -Description "Boxstarter done"
    }
}

Run