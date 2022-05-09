Write-Host "Please enter the following:"
Write-Host ""
    
Read-HostAndSaveToEnv -Description "Git user name (eg. John Doe)" -EnvironmentKey WIN10_DEV_BOX_GIT_USER_NAME
Read-HostAndSaveToEnv -Description "Git email (eg. john.doe@example.com)" -EnvironmentKey WIN10_DEV_BOX_GIT_EMAIL