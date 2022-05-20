function InstallPrograms {
    Write-Host "Installing programs using choco or scoop"
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
    scoop install yarn
    scoop install sudo
    scoop install pwsh
    Write-Host "Installed programs" -Foreground green
}

function ConfigureDevelopmentTools {
    ConfigurePowershell
    ConfigureGit
    ConfigureVsCode
    ConfigureWindowsTerminal

    $GitCloneTarget = "C:\dev"

    if (!(Test-Path $GitCloneTarget)) {
        mkdir $GitCloneTarget
    }
}

function ConfigurePowershell {
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    Install-Module -Name z -RequiredVersion 1.1.10 -AllowClobber
    Install-Module psreadline -Force

    Add-ToPowerShellProfile -Find "*Set-PSReadLineOption*" -Content @("
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    Import-Module posh-git
    Set-Alias g git
    ")
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
    git config --global alias.oops "commit --amend --no-edit"
    git config --global alias.a "add --patch"
    git config --global alias.please "push --force-with-lease"
    git config --global alias.navigate "!git add . && git commit -m 'WIP-mob' --allow-empty --no-verify && git push -u --no-verify"
    git config --global alias.drive "!git pull --rebase && git log -1 --stat && git reset HEAD^ && git push --force-with-lease"
    git config --global pull.rebase true
    git config --global alias.r "!git fetch; git rebase origin/$(git main) -i --autosquash"
    git config --global alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
    git config --global alias.mr "push -u -o merge_request.create -o merge_request.remove_source_branch"
    git config --global alias.dotnetformat "!git rebase --interactive --exec \"dotnet format ./src && git commit -a --allow-empty --fixup=HEAD\" --strategy-option=theirs origin/$(git main)"
    git config --global alias.main "!git symbolic-ref refs/remotes/origin/HEAD | cut -d'/' -f4"
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
