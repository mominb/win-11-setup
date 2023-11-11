

# Check if Winget is installed
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "Winget is not installed. Please install Winget first."
}
else {
    # Packages to be installed
    $packages = @(
        'Git.Git', 
        'Microsoft.VisualStudioCode',
        'Microsoft.DevHome',
        'Microsoft.WindowsTerminal',
        'Microsoft.PowerShell',
        'JanDeDobbeleer.OhMyPosh',
        'Docker.DockerDesktop'
    )

    foreach ($package in $packages) {
        # Install if not already installed.
        $isInstalled = winget list --id=$package -e
        if ($LASTEXITCODE -ne 0) {
            winget install --id=$package -e
            Write-Host "Installed $package."
        }
        else {
            Write-Host "$package is already installed."
        }
    }
}

$vscodePath = "$env:LOCALAPPDATA\Programs\Microsoft VS Code\"
$currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")

# Check if VS Code is already in the PATH
if ($currentPath -notlike "*$vscodePath*") {
    Write-Host "Adding $vscodePath to User PATH environment variable"
    [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$vscodePath", "User")
}


$email = git config --global --get user.email
$userName = git config --global --get user.name

if ([string]::IsNullOrEmpty($email)) {
    $email = Read-Host "Please enter your github email"
    $userName = Read-Host "Please enter your github name"

    git config --global user.email $email
    git config --global user.name $userName
} 

git config --global credential.helper "$env:ProgramFiles/Git/mingw64/bin/git-credential-manager.exe"

wsl --set-default-version 2
Write-Host "WSL default version has been set to 2"
$distributions = wsl --list --quiet

if ($distributions -notmatch 'Ubuntu') {
    wsl --install -d Ubuntu
}
else {
    Write-Host "Ubuntu is already installed on WSL"
}

$home = $env:USERPROFILE

if (!(Test-Path -Path "$home/github/$userName")) {
    New-Item -ItemType Directory -Path "$home/github/$userName"
}

if (!(Test-Path -Path "$home/github/Win11Debloat")) {
    New-Item -ItemType Directory -Path "$home/github/Win11Debloat"
    git clone https://github.com/Raphire/Win11Debloat.git "$home/github/Win11Debloat"    

    Start-Process -FilePath "cmd.exe" -ArgumentList "/c $home\github\Win11Debloat\Run.bat"
}