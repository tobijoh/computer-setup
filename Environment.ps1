function SetupChocolateyCacheFolder {
    $ChocolateyCacheFolder = "C:\choco-temp"

    if (!(Test-Path $ChocolateyCacheFolder)) {
        mkdir $ChocolateyCacheFolder
    }

    choco config set cacheLocation "$ChocolateyCacheFolder"
}

function SetupRestorePoint {
    Enable-ComputerRestore -Drive "C:\"
    vssadmin list shadowstorage
    vssadmin resize shadowstorage /on=C: /for=C: /maxsize=10%
    Set-ItemProperty "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\SystemRestore" -Name SystemRestorePointCreationFrequency -Value 5
    if (!((Get-ComputerRestorePoint).Description -Like "Clean Install")) {
        Checkpoint-Computer -Description "Clean Install"
    }
}

function SetupPowerOptions {
    Write-Host "Setting up power options"
    Powercfg /Change monitor-timeout-ac 20
    Powercfg /Change standby-timeout-ac 0
    Powercfg -setacvalueindex scheme_current sub_buttons pbuttonaction 0
    Write-Host "Completed power options" -Foreground green
}

function SetupDirectoryOptions {
    # Show hidden files, Show protected OS files, Show file extensions
    Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowProtectedOSFiles -EnableShowFileExtensions
    Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ShowTaskViewButton -Value 0 -Type DWord -Force
    Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ShowCortanaButton -Value 0 -Type DWord -Force
    Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search -Name SearchBoxTaskbarMode -Value 0 -Type DWord -Force
}

function CleanUpPreInstalledApps {
    # Remove all $AppNames String array from taskbar Pin location
    $ComObj = (New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}')
    $AppNames = "Microsoft Edge|stor|mai|support"
    #use the match to limit the apps removed from start tiles
    $ComObjItem = $ComObj.Items() | Where-Object { $_.Name -match $AppNames }
    foreach ($Obj in $ComObjItem) {
        Write-Host "$("Checking " + $Obj.name)" -ForegroundColor Cyan
        foreach ($Verb in $Obj.Verbs()) {
            Write-Host "$("Verb: " + $Verb.name)" -ForegroundColor white
            if (($Verb.name -match 'Un.*pin from Start')) {
                Write-Host "$("Ok " + $Obj.name + " contains " + $Verb.name)" -ForegroundColor Red
                try {
                    $Verb.DoIt()
                }
                catch {}
            }
            if (($Verb.name -match 'Un.*pin from tas&kbar') -And ($Obj.name -match $AppNames)) {
                Write-Host "$("Ok " + $Obj.name + " contains " + $Verb.name)" -ForegroundColor Red
                try {
                    $Verb.DoIt()
                }
                catch {}
            }
        }
    }

    Write-Host "Remove pre-installed apps"
    # Microsoft junk
    Get-AppxPackage Microsoft.*3D* | Remove-AppxPackage
    Get-AppxPackage Microsoft.*advertising* | Remove-AppxPackage
    Get-AppxPackage Microsoft.Bing* | Remove-AppxPackage
    Get-AppxPackage Microsoft.CommsPhone | Remove-AppxPackage
    Get-AppxPackage Microsoft.Getstarted | Remove-AppxPackage
    Get-AppxPackage Microsoft.Messaging | Remove-AppxPackage
    Get-AppxPackage Microsoft.MicrosoftOfficeHub | Remove-AppxPackage
    Get-AppxPackage Microsoft.MicrosoftStickyNotes | Remove-AppxPackage
    Get-AppxPackage Microsoft.Office.OneNote | Remove-AppxPackage
    Get-AppxPackage Microsoft.Office.Sway | Remove-AppxPackage
    Get-AppxPackage Microsoft.OneConnect | Remove-AppxPackage
    Get-AppxPackage Microsoft.People | Remove-AppxPackage
    Get-AppxPackage Microsoft.SkypeApp | Remove-AppxPackage
    Get-AppxPackage Microsoft.Wallet | Remove-AppxPackage
    Get-AppxPackage Microsoft.Windows.Photos | Remove-AppxPackage
    Get-AppxPackage Microsoft.WindowsAlarms | Remove-AppxPackage
    Get-AppxPackage Microsoft.WindowsFeedbackHub | Remove-AppxPackage
    Get-AppxPackage Microsoft.WindowsMaps | Remove-AppxPackage
    Get-AppxPackage Microsoft.WindowsPhone | Remove-AppxPackage
    Get-AppxPackage Microsoft.WindowsSoundRecorder | Remove-AppxPackage
    Get-AppxPackage microsoft.windowscommunicationsapps | Remove-AppxPackage
    Get-AppxPackage Microsoft.Zune* | Remove-AppxPackage
    Get-AppxPackage Microsoft.ScreenSketch | Remove-AppxPackage
    Get-AppxPackage Microsoft.YourPhone | Remove-AppxPackage

    # Misc
    Get-AppxPackage *Autodesk* | Remove-AppxPackage
    Get-AppxPackage *Spotify* | Remove-AppxPackage

    # Junk games
    Get-AppxPackage king.com.* | Remove-AppxPackage
    Get-AppxPackage *disney* | Remove-AppxPackage
    Get-AppxPackage *MarchofEmpires* | Remove-AppxPackage
    Get-AppxPackage *Solitaire* | Remove-AppxPackage
    Write-Host "Removed pre-installed apps"
}

function InstallWindowsSubsystemForLinux {
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
    Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
    refreshenv
    wsl --set-default-version 2
    wsl --update
    if (!((wsl --list --all) -Like "*Ubuntu*")) {
        wsl --install --distribution Ubuntu
    }
}

function RunWindowsUpdate {
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    Install-Module -Name PSWindowsUpdate -Repository PSGallery
    Add-WUServiceManager -ServiceID 7971f918-a847-4430-9279-4a52d1efe18d -AddServiceFlag 7
    Get-WindowsUpdate
    Install-WindowsUpdate
}

function SetGitUser {
    $GitUserName = [Environment]::GetEnvironmentVariable("WIN10_DEV_BOX_GIT_USER_NAME", "User")
    $GitEmail = [Environment]::GetEnvironmentVariable("WIN10_DEV_BOX_GIT_EMAIL", "User")

    if($GitUserName -and $GitEmail) {
        git config --global user.name "$GitUserName"
        git config --global user.email "$GitEmail"
    }
}