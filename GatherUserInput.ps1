function Run {
    Write-Host "Please enter the following:"
    Write-Host ""
        
    Read-HostAndSaveToEnv -Description "Git user name (eg. John Doe)" -EnvironmentKey WIN10_DEV_BOX_GIT_USER_NAME
    Read-HostAndSaveToEnv -Description "Git email (eg. john.doe@example.com)" -EnvironmentKey WIN10_DEV_BOX_GIT_EMAIL
    Read-HostAndSaveToEnv -Description "Base directory for projects" -EnvironmentKey WIN10_DEV_BOX_PROJECT_BASE_DIRECTORY
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