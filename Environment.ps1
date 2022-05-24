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

    if ($GitUserName -and $GitEmail) {
        git config --global user.name "$GitUserName"
        git config --global user.email "$GitEmail"
    }
}

function InstallFonts {
    Write-Host "Installing fonts" -ForegroundColor Magenta

    $UserInstalledFontsDirectory = "$env:USERPROFILE\AppData\Local\Microsoft\Windows\Fonts"
    $FontsTempDirectory = ".\fonts"
    $FontsObject = (New-Object -ComObject Shell.Application).Namespace(0x14)

    $FontUrls = @('https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf',
        'https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf',
        'https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf',
        'https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf')

    New-Item -ItemType Directory -Force -Path $FontsTempDirectory > $null

    Push-Location $FontsTempDirectory

    foreach ($FontUrl in $FontUrls) {
        $FontName = $FontUrl.Split('/')[-1]
        Invoke-WebRequest -Uri $FontUrl -OutFile ".\$FontName"
    }

    foreach ($FontObject in (Get-ChildItem -Path $Source -Include '*.ttf', '*.ttc', '*.otf' -Recurse)) {
        $FontName = $FontObject.Name
        $FontPath = Join-Path $UserInstalledFontsDirectory $FontName
    
        if (Test-Path -Path $FontPath) {
            Write-Host "Font $FontName already installed, skipping..."
        }
        else {
            Write-Host "Installing font: $FontName"
            $FontsObject.CopyHere($FontObject.FullName)
        }
    }

    Pop-Location

    Remove-Item -Path $FontsTempDirectory -Force -Recurse
}

function DisableUac {
    $UacRegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    New-ItemProperty -Path $UacRegistryPath -Name 'ConsentPromptBehaviorAdmin' -Value 0 -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $UacRegistryPath -Name 'ConsentPromptBehaviorUser' -Value 3 -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $UacRegistryPath -Name 'EnableInstallerDetection' -Value 1 -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $UacRegistryPath -Name 'EnableLUA' -Value 1 -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $UacRegistryPath -Name 'EnableVirtualization' -Value 1 -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $UacRegistryPath -Name 'PromptOnSecureDesktop' -Value 0 -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $UacRegistryPath -Name 'ValidateAdminCodeSignatures' -Value 0 -PropertyType DWORD -Force | Out-Null
}

function AddWindowsSecurityExceptions {
    $PathExclusions = @(
        "C:\Windows\Microsoft.NET",
        "C:\Windows\assembly",
        (Join-Path $env:USERPROFILE "AppData\Local\Microsoft\VisualStudio"),
        (Join-Path $env:USERPROFILE ".nuget\packages"),
        "C:\ProgramData\Microsoft\VisualStudio\Packages",
        "C:\Program Files (x86)\MSBuild",
        "C:\Program Files (x86)\Microsoft Visual Studio",
        "C:\Program Files (x86)\Microsoft SDKs",
        "C:\Program Files\Microsoft VS Code",
        (Join-Path $env:USERPROFILE "AppData\Roaming\npm-cache"),
        [Environment]::GetEnvironmentVariable("WIN10_DEV_BOX_PROJECT_BASE_DIRECTORY", "User")
    )

    $ProcessExclusions = @(
        "rider64.exe",
        "devenv.exe",
        "dotnet.exe",
        "msbuild.exe",
        "node.exe",
        "node.js",
        "perfwatson2.exe",
        "ServiceHub.Host.Node.x86.exe",
        "vbcscompiler.exe"
    )

    foreach ($Exclusion in $PathExclusions) {
        Write-Host "Adding Path Exclusion: " $Exclusion
        Add-MpPreference -ExclusionPath $Exclusion
    }

    foreach ($Exclusion in $ProcessExclusions) {
        Write-Host "Adding Process Exclusion: " $Exclusion
        Add-MpPreference -ExclusionProcess $Exclusion
    }

    Write-Host ""
    Write-Host "These exclusions are now added to Windows Security:"

    $WindowsSecurityPreferences = Get-MpPreference
    $WindowsSecurityPreferences.ExclusionPath
    $WindowsSecurityPreferences.ExclusionProcess
}

RestoreClassicContextMenuInWindows11 {
    Write-Host "Restoring old Windows 10 context menu in Windows 11"

    $ContextMenuRegistryPath = "HKCU:\SOFTWARE\Classes\CLSID"
    $ContextMenuRegistryKey = "{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}"

    New-Item -Path $ContextMenuRegistryPath -Name $ContextMenuRegistryKey
    New-ItemProperty -Path (Join-Path $ContextMenuRegistryPath $ContextMenuRegistryKey) -Name "InprocServer32" -Value ""

    Write-Host "Context menu restored, rebooting to make the change apply"

    Invoke-Reboot
}