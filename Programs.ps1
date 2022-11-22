function InstallPrograms {
    Write-Host "Installing programs using choco or scoop"
    choco install 7zip.install -y
    choco install git -y
    choco install poshgit -y
    choco install microsoft-edge -y
    choco install googlechrome -y
    choco install firefox -y
    choco install vscode -y
    choco install nvm -y
    choco install slack -y
    choco install microsoft-windows-terminal -y
    choco install firacode -y
    choco install dotnetcore -y
    choco install jetbrains-rider -y
    choco install ssms -y
    choco install docker-desktop -y
    choco install dotnetcore-sdk -y
    choco install spotify -y
    choco install ditto --pre -y
    choco install postman -y
    choco install foxitreader -y
    choco install miktex -y --force
    choco install strawberryperl -y
    choco install linqpad -y
    scoop install yarn
    scoop install sudo
    scoop install pwsh
    Write-Host "Installed programs" -Foreground green
}

function ConfigureDevelopmentTools {
    ConfigurePowershell
    ConfigureGit
    CreateSshKey
    ConfigureVsCode
    ConfigureWindowsTerminal
    InstallMicrosoftEdgeExtensions
    SetMicrosoftEdgeStartPage
    ConfigureLaTeX

    $GitCloneTarget = [Environment]::GetEnvironmentVariable("WIN10_DEV_BOX_PROJECT_BASE_DIRECTORY", "User")

    if (!(Test-Path $GitCloneTarget)) {
        mkdir $GitCloneTarget
    }
}

function ConfigurePowershell {
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    Install-Module -Name z -RequiredVersion 1.1.10 -AllowClobber
    Install-Module psreadline -Force

    Add-ToPowerShellProfile -Find "*Set-PSReadLineOption*" -Content @('
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

    # Shows navigable menu of all options when hitting Tab
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
    
    Import-Module posh-git
    Set-Alias g git    

    $GitPromptSettings.EnableStashStatus = $true
    ')
}

function ConfigureGit {
    git config --global push.default current
    git config --global core.editor "code --wait"
    git config --global merge.tool vscode
    git config --global mergetool.vscode.cmd 'code --wait $MERGED'
    git config --global mergetool.keepBackup false
    git config --global diff.tool vscode
    git config --global difftool.vscode.cmd 'code --wait --diff $LOCAL $REMOTE'
    git config --global alias.co "checkout"
    git config --global alias.cob "checkout -b"
    git config --global alias.oops "commit --amend --no-edit"
    git config --global alias.a "add --patch"
    git config --global alias.please "push --force-with-lease"
    git config --global alias.navigate "!git add . && git commit -m 'WIP-mob' --allow-empty --no-verify && git push -u --no-verify"
    git config --global alias.drive "!git pull --rebase && git log -1 --stat && git reset HEAD^ && git push --force-with-lease"
    git config --global pull.rebase true
    git config --global alias.r '!git fetch; git rebase origin/$(git main) -i --autosquash'
    git config --global alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
    git config --global alias.mr "push -u -o merge_request.create -o merge_request.remove_source_branch"
    git config --global alias.dotnetformat "!git rebase --interactive --exec 'dotnet format ./src && git commit -a --allow-empty --fixup=HEAD' --strategy-option=theirs origin/`$(git main)"
    git config --global alias.main "!git symbolic-ref refs/remotes/origin/HEAD | cut -d'/' -f4"
    git config --global alias.cge "config --global -e"
    git config --global alias.pt "push origin --tags"
}

function ConfigureVsCode {
    # Install extensions

    Write-Host "Installing VS Code extensions"
    code --install-extension dbaeumer.vscode-eslint
    code --install-extension esbenp.prettier-vscode
    code --install-extension formulahendry.auto-rename-tag
    code --install-extension kavod-io.vscode-jest-test-adapter
    code --install-extension ms-vsliveshare.vsliveshare
    code --install-extension msjsdiag.debugger-for-chrome
    code --install-extension PKief.material-icon-theme
    code --install-extension runningcoder.react-snippets
    code --install-extension shd101wyy.markdown-preview-enhanced
    code --install-extension James-Yu.latex-workshop
    code --install-extension tecosaur.latex-utilities
    Write-Host "Installed VS Code Extensions" -Foreground Green
    
    # Configure desired settings

    Write-Host "Configuring VS Code settings"
    $VsCodeSourceSettingsPath = "https://github.com/tobijoh/computer-setup/releases/latest/download/vscode.settings.json"
    $VsCodeDestinationSettingsPath = "$env:APPDATA\Code\User\settings.json"

    Invoke-WebRequest -Uri $VsCodeSourceSettingsPath -OutFile $VsCodeDestinationSettingsPath
    Write-Host "VS Code settings configured" -Foreground Green
}

function ConfigureWindowsTerminal {
    Write-Host "Configuring Windows Terminal settings"
    $WindowsTerminalSourceSettingsPath = "https://github.com/tobijoh/computer-setup/releases/latest/download/windows-terminal.settings.json"
    $WindowsTerminalDestinationSettingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    
    Invoke-WebRequest -Uri $WindowsTerminalSourceSettingsPath -OutFile $WindowsTerminalDestinationSettingsPath
    Write-Host "Windows Terminal settings configured" -Foreground Green
}

function ConfigureLaTeX {
    $ThingsToAddToPath = @(
        "C:\Program Files\MiKTeX\miktex\bin\x64",
        "C:\Strawberry\c\bin",
        "C:\Strawberry\perl\site\bin",
        "C:\Strawberry\perl\bin"
    )

    foreach ($ThingToAddToPath in $ThingsToAddToPath) {
        [Environment]::SetEnvironmentVariable("PATH", $env:PATH + ";$ThingToAddToPath", [EnvironmentVariableTarget]::User)
    }
}

function CreateSshKey {
    Write-Host "Creating an SSH key"

    $Email = [Environment]::GetEnvironmentVariable("WIN10_DEV_BOX_GIT_EMAIL", "User")
    $SshPath = Join-Path $env:USERPROFILE ".ssh" "id_ed25519"

    & ssh-keygen -t ed25519 -C "$Email" -f "$SshPath" -N "''"

    Write-Host "SSH key successfully created"
}

function InstallMicrosoftEdgeExtensions {    
    Write-Host "Installing Microsoft Edge extensions" -ForegroundColor Magenta
    
    $ExtensionRegistryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Edge\ExtensionInstallForcelist"
    
    if (!(Test-Path $ExtensionRegistryPath)) {
        New-Item $ExtensionRegistryPath -Force
    }
    
    # Then add the new extensions (if not already installed)
    $ExtensionList = @{
        "dneaehbmnbhcippjikoajpoabadpodje" = "Old Reddit Redirect"
        "fmkadmapgofadopljbjfkapdkoienihi" = "React Developer Tools"
        "lmhkpmbekcpmknklioeibfkpmmfibljd" = "Redux DevTools"
        "mnjggcdmjocbbbhaepdhchncahnbgone" = "SponsorBlock for YouTube"
        "dhdgffkkebhmkfjojejmpbldmpobfkfo" = "TamperMonkey"
        "cjpalhdlnbpafiamejdnhcphjbkeiagm" = "uBlock Origin"
    }
    
    foreach ($Extension in $ExtensionList.GetEnumerator()) {
        $ExistingExtensions = Get-RegistryKeyPropertiesAndValues -Path $ExtensionRegistryPath
        $ExtensionNumber = $null -eq $ExistingExtensions ? 1 : $ExistingExtensions[-1].Property + 1
        
        $ExtensionId = "$($Extension.Name);https://clients2.google.com/service/update2/crx"
    
        if ($ExistingExtensions | Where-Object { $_.Value -eq $ExtensionId }) {
            Write-Host "$($Extension.Value) is already installed, skipping..."
        }
        else {
            Write-Host "Installing $($Extension.Value)..."
            $ExtensionRegistryKey = $ExtensionNumber
            New-ItemProperty -Path $ExtensionRegistryPath -PropertyType String -Name $ExtensionRegistryKey -Value $ExtensionId | Out-Null
            Write-Host "Done!"
        }
    }
    
    Write-Host "Extensions installed" -ForegroundColor Green
}

function SetMicrosoftEdgeStartPage {
    Write-Host "Setting Microsoft Edge start page..." -ForegroundColor Magenta

    $StartPageUrl = 'https://google.com'
    $EdgeRegistryKey = "HKCU:\Software\Policies\Microsoft\Edge"

    if ( -Not (Test-Path $EdgeRegistryKey)) {
        New-Item -Path $EdgeRegistryKey | Out-Null
    }

    Set-ItemProperty -Path $EdgeRegistryKey -Name "RestoreOnStartup" -Value 4 -Type "DWORD"

    $EdgeStartupUrlRegistryKey = "$EdgeRegistryKey\RestoreOnStartupURLs"
    if (-Not (Test-Path $EdgeStartupUrlRegistryKey)) {
        New-Item -Path $EdgeStartupUrlRegistryKey | Out-Null
    }

    Set-ItemProperty -Path $EdgeStartupUrlRegistryKey -Name '1' -Value $StartPageUrl

    Write-Host "Done!" -Foreground Green
}

# HELPER FUNCTIONS
function Add-ToPowerShellProfile($Find, $Content) {
    if (!( Test-Path $Profile )) { 
        New-Item $Profile -Type File -Force
    }
    else {
        $CurrentProfileContent = Get-Content $Profile
    }

    if (!($CurrentProfileContent -Like $Find)) {
        $Content | Add-Content $Profile -Encoding UTF8
    }
}

function Get-RegistryKeyPropertiesAndValues {
    Param(
        [Parameter(Mandatory = $true)]
        [string]$Path)

    Push-Location
    Set-Location -Path $Path
    Get-Item . |
    Select-Object -ExpandProperty Property |
    ForEach-Object {
        New-Object PSObject -Property @{"Property" = $_;
            "Value"                                = (Get-ItemProperty -Path . -Name $_).$_
        } }
    Pop-Location
}