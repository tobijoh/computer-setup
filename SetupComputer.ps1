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
    SetupPowerOptions
    SetupDirectoryOptions
    CleanUpPreInstalledApps
    InstallWindowsSubsystemForLinux
}

function CleanUpDesktop {
    Write-Host "Cleaning desktop"
    Remove-Item C:\Users\*\Desktop\*lnk
    Remove-Item C:\Users\*\Desktop\desktop.ini -Force
    Write-Host "Desktop cleaned"
}

function AddBoxstarterDoneRestorePoint {
    if  (!((Get-ComputerRestorePoint).Description -Like "Boxstarter done")) {
        Checkpoint-Computer -Description "Boxstarter done"
    }
}

# HELPER FUNCTIONS
function Read-HostAndSaveToEnv($Description, $EnvironmentKey) {
    $CurrentValue = [Environment]::GetEnvironmentVariable($EnvironmentKey, "User")
    Write-Host $Description -ForegroundColor green
    if ($CurrentValue) {
        Write-Host "Simply press ENTER to preserve current value (" -NoNewline
        Write-Host $CurrentValue  -NoNewline -ForegroundColor blue
        Write-Host ")"
    }
    Write-Host "> " -NoNewline
    $NewValue = Read-Host
    if ($NewValue -ne "") {
        [Environment]::SetEnvironmentVariable($EnvironmentKey, $NewValue, "User")
    }
    Write-Host ""
}

Run