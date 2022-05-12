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
    scoop install yarn
    scoop install sudo
    scoop install pwsh
    Write-Host "Installed programs" -Foreground green
}

function ConfigureDevelopmentTools {
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
    Write-Host "Installed VS Code Extensions" -Foreground green

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
    git config --global alias.r "!git fetch; git rebase origin/master -i --autosquash"
    git config --global alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
    git config --global alias.mr "push -u -o merge_request.create -o merge_request.remove_source_branch"

    $GitCloneTarget = "C:\dev"

    if (!(Test-Path $GitCloneTarget)) {
        mkdir $GitCloneTarget
    }
}

# HELPER FUNCTIONS
function Add-ToPowerShellProfile($Find, $Content) {
    if (!( Test-Path $Profile )) { 
        New-Item $Profile -Type File -Force
    } else  {
        $CurrentProfileContent = Get-Content $Profile
    }

    if (!($CurrentProfileContent -Like $Find)) {
        $Content | Add-Content $Profile -Encoding UTF8
    }
}