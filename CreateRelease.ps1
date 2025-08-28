param(
    [string]$InputFile = ".\HardwareInfo.ps1",
    [string]$OutputFile = ".\HardwareInfo.exe",
    [string]$IconFile = ".\icon.ico"
)

<#
.SYNOPSIS
    Erstellt eine EXE aus einem PowerShell-Skript mit optionalem Icon.
#>

if (-not (Get-Command Invoke-PS2EXE -ErrorAction SilentlyContinue)) {
    Write-Error "Invoke-PS2EXE ist nicht verfügbar. Bitte installiere das PS2EXE-Modul."
    Write-Host "Installiere es mit:"
    Write-Host "    Install-Module -Name PS2EXE -Scope CurrentUser"
    exit 1
}

if (-not (Test-Path $InputFile)) {
    Write-Error "Die Eingabedatei '$InputFile' existiert nicht."
    exit 1
}

if (-not (Test-Path $IconFile)) {
    Write-Warning "Icon-Datei '$IconFile' nicht gefunden. Es wird kein Icon verwendet."
    $IconFile = $null
}

try {
    Invoke-PS2EXE `
        -InputFile   $InputFile `
        -OutputFile  $OutputFile `
        -IconFile    $IconFile `
        -NoConsole
} catch {
    Write-Error "Fehler beim Erstellen der EXE: $_"
    exit 1
}