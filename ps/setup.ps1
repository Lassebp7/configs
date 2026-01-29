Write-Host "--- Starting Winget Bulk Install ---" -ForegroundColor Cyan
winget import -i .\apps.json --accept-package-agreements --accept-source-agreements

Write-Host "--- Configuring Starship & Profiles ---" -ForegroundColor Cyan

$ProfileDir = [System.IO.Path]::GetDirectoryName($PROFILE)
if (!(Test-Path $ProfileDir)) {
    New-Item -ItemType Directory -Path $ProfileDir -Force
}

Copy-Item -Path ".\Microsoft.PowerShell_profile.ps1" -Destination $PROFILE -Force

starship preset nerd-font-symbols -o "$HOME\.config\starship.toml"

Write-Host "--- Setup Complete! Restart PowerShell to see changes. ---" -ForegroundColor Green