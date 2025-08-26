param(
    [string]$InputFile = ".\HardwareInfo.ps1",
    [string]$OutputFile = ".\HardwareInfo.exe",
    [string]$IconFile = ".\icon.ico"
)

if (-not (Get-Command Invoke-PS2EXE -ErrorAction SilentlyContinue)) {
    Write-Error "Invoke-PS2EXE is not available. Please install the PS2EXE module."
    Write-Host "You can install it by running:"
    Write-Host "    Install-Module -Name PS2EXE -Scope CurrentUser"
    exit 1
}

if (-not (Test-Path $InputFile)) {
    Write-Error "Input file '$InputFile' does not exist."
    exit 1
}

Invoke-PS2EXE `
    -InputFile   $InputFile `
    -OutputFile  $OutputFile `
    -IconFile    $IconFile `
    -NoConsole