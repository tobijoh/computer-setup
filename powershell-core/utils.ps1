$DevFolder = "C:\dev"

function Open-Dev {
    Set-Location $DevFolder
}

function Open-DevRandom {
    Set-Location "$DevFolder\Random"
}

function Open-NVimConfig {
    code "$env:LOCALAPPDATA\nvim\init.vim"
}

function Open-Solution {
    [CmdletBinding()]
    param(
        [string] $Solution,

        [ValidateSet("rider", "vs22", "code")]
        [string] $Ide
    )

    $RiderWorkingDirectory = Join-Path $env:LOCALAPPDATA "JetBrains" "Installations" "Rider233" "bin"
    $RiderExecutable = Join-Path $RiderWorkingDirectory "rider64.exe"

    $Vs22WorkingDirectory = Join-Path $env:ProgramFiles "Microsoft Visual Studio" "2022" "Professional" "Common7" "IDE"
    $Vs22Executable = Join-Path $Vs22WorkingDirectory "devenv.exe" 
    
    if (!$Solution) {
        $Solution = Get-ChildItem -Filter "*.sln" -Recurse | Select-Object -First 1
    }

    if (!$Solution) {
        $Solution = Get-ChildItem -Filter "*.csproj" -Recurse | Select-Object -First 1
    }

    if (-not $Ide) {
        if (Test-Path $RiderWorkingDirectory) {
            Write-Host "No IDE specified, defaulting to Rider." -ForegroundColor Yellow
            $Ide = "rider"
        }
        elseif (Test-Path $Vs22WorkingDirectory) {
            Write-Host "No IDE specified, defaulting to Visual Studio 2022." -ForegroundColor Yellow
            $Ide = "vs22"
        }
        else {
            Write-Host "No IDE specified, defaulting to Visual Studio Code." -ForegroundColor Yellow
            $Ide = "code"
        }
    }

    if ($Ide -eq "rider") {
        Start-Process $RiderExecutable -WorkingDirectory $RiderWorkingDirectory -ArgumentList $Solution
    }
    elseif ($Ide -eq "vs22") {
        Start-Process $Vs22Executable -WorkingDirectory $Vs22WorkingDirectory -ArgumentList $Solution
    }
    elseif ($Ide -eq "code") {
        $SolutionDirectory = Split-Path -Path $Solution -Parent
        Start-Process code -ArgumentList $SolutionDirectory -NoNewWindow
    }
}

function Remove-DockerImage {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Image
    )

    $Containers = docker container ls
    $Container = $Containers -split "`r`n" | Where-Object { $_ -like "*$Image*" }

    if ($Container) {
        $ContainerId = ($Container -split '\s+')[0]
        $ContainerName = ($Container -split '\s+')[1]

        docker container stop $ContainerId
        docker container rm $ContainerId

        Write-Host "Successfully removed container $ContainerName"c -ForegroundColor Green
    }
    else {
        Write-Host "No container found" -ForegroundColor Green
    }

    $Images = docker image ls
    $Image = $Images -split "`r`n" | Where-Object { $_ -like "*$Image*" }

    if ($Image) {
        $ImageId = ($Image -split '\s+')[2]
        $ImageName = ($Image -split '\s+')[0]

        docker image rm $ImageId

        Write-Host "Sucessfully removed image $ImageName" -ForegroundColor Green
    }
    else {
        Write-Host "No image found" -ForegroundColor Green
    }
}

function Open-ProfileFolder {
    Set-Location (Split-Path -Path $PROFILE)
}

function Open-ProfileUtils {
    $Path = Join-Path (Split-Path -Path $PROFILE) "Custom" "utils.ps1"
    code $Path
}

function Open-ProfileAliases {
    $Path = Join-Path (Split-Path -Path $PROFILE) "Custom" "aliases.ps1"
    code $Path
}

function Test-RenovateConfig {
    param (
        [Parameter(Mandatory = $true)]
        [string] $Path
    )

    if (Get-Command docker -ErrorAction SilentlyContinue) {
        & docker run -v $Path`:/usr/src/app/renovate.json -it renovate/renovate renovate-config-validator
    }
    else {
        Write-Host "Docker is not installed" -ForegroundColor Red
    }
}