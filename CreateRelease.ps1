param(
    [string]$InputFile = ".\HardwareInfo.ps1",
    [string]$OutputFile = ".\HardwareInfo.exe",
    [string]$IconFile = ".\icon.ico"
)

<#
.SYNOPSIS
    Creates an EXE from a PowerShell script with an optional icon.
#>

if ([string]::IsNullOrWhiteSpace($InputFile) -or [string]::IsNullOrWhiteSpace($OutputFile)) {
    Write-Error "-InputFile and -OutputFile cannot be empty."
    exit 1
}

if (-not (Get-Command Invoke-PS2EXE -ErrorAction SilentlyContinue)) {
    Write-Error "Invoke-PS2EXE is not available. Please install the PS2EXE module."
    Write-Host "Install it with:"
    Write-Host "    Install-Module -Name PS2EXE -Scope CurrentUser"
    exit 1
}

if (-not (Test-Path $InputFile)) {
    Write-Error "The input file '$InputFile' does not exist."
    exit 1
}

if ([string]::IsNullOrWhiteSpace($IconFile) -or -not (Test-Path $IconFile)) {
    Write-Warning "Icon file '$IconFile' not found. No icon will be used."
    $IconFile = $null
}

# Make sure the target folder for the EXE exists before handing off to PS2EXE
try {
    $outputDirectory = Split-Path -Path $OutputFile -Parent
    if ($outputDirectory -and -not (Test-Path -Path $outputDirectory)) {
        New-Item -Path $outputDirectory -ItemType Directory -Force -ErrorAction Stop | Out-Null
    }
}
catch {
    Write-Error "The output path '$OutputFile' is invalid or its folder could not be created: $_"
    exit 1
}

try {
    Invoke-PS2EXE `
        -InputFile   $InputFile `
        -OutputFile  $OutputFile `
        -IconFile    $IconFile `
        -NoConsole
} catch {
    Write-Error "Error creating the EXE: $_"
    exit 1
}

if (-not (Test-Path $OutputFile)) {
    Write-Error "PS2EXE did not report an error, but '$OutputFile' was not created. Check the PS2EXE output above for details."
    exit 1
}

Write-Host "Done! EXE created at: $OutputFile" -ForegroundColor Green
