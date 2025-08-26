param(
    [string]$OutputFile = "$env:USERPROFILE\Desktop\Hardware-info.txt"
)

$outFile = $OutputFile

# Falls Datei schon existiert: löschen
if (Test-Path $outFile) { Remove-Item $outFile }

# Zeitstempel hinzufügen
"Hardware-Informationen erstellt am: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Out-File $outFile

# --- GPU ---
"`n===== GPU =====" | Out-File $outFile -Append
try {
    Get-CimInstance Win32_VideoController -ErrorAction Stop |
        Select-Object Name, AdapterCompatibility, DriverVersion, VideoProcessor |
        Format-List | Out-File $outFile -Append
} catch {
    "`nFehler beim Abrufen der GPU-Informationen: $_" | Out-File $outFile -Append
}

# --- Prozessor ---
"`n===== Prozessor =====" | Out-File $outFile -Append
try {
    Get-CimInstance Win32_Processor -ErrorAction Stop |
        Select-Object Name, Manufacturer, MaxClockSpeed, NumberOfCores, NumberOfLogicalProcessors |
        Format-List | Out-File $outFile -Append
} catch {
    "`nFehler beim Abrufen der Prozessor-Informationen: $_" | Out-File $outFile -Append
}

# --- Mainboard ---
"`n===== Mainboard =====" | Out-File $outFile -Append
try {
    Get-CimInstance Win32_BaseBoard -ErrorAction Stop |
        Select-Object Manufacturer, Product, SerialNumber, Version |
        Format-List | Out-File $outFile -Append
} catch {
    "`nFehler beim Abrufen der Mainboard-Informationen: $_" | Out-File $outFile -Append
}

# --- BIOS ---
"`n===== BIOS =====" | Out-File $outFile -Append
try {
    Get-CimInstance Win32_BIOS -ErrorAction Stop |
        Select-Object Manufacturer, SMBIOSBIOSVersion, ReleaseDate, SerialNumber, Version |
        Format-List | Out-File $outFile -Append
} catch {
    "`nFehler beim Abrufen der BIOS-Informationen: $_" | Out-File $outFile -Append
}

# --- RAM ---
"`n===== Arbeitsspeicher (RAM) =====" | Out-File $outFile -Append
try {
    Get-CimInstance Win32_PhysicalMemory -ErrorAction Stop |
        Select-Object Manufacturer, PartNumber, SerialNumber, Speed,
        @{Name="Capacity(GB)";Expression={[math]::Round($_.Capacity/1GB,2)}} |
        Format-List | Out-File $outFile -Append
} catch {
    "`nFehler beim Abrufen der RAM-Informationen: $_" | Out-File $outFile -Append
}

# --- Festplatten ---
"`n===== Festplatten =====" | Out-File $outFile -Append
try {
    Get-PhysicalDisk -ErrorAction Stop |
        Select-Object FriendlyName, MediaType,
        @{Name="Size(GB)";Expression={[math]::Round($_.Size/1GB,2)}} |
        Format-List | Out-File $outFile -Append
} catch {
    "`nFehler beim Abrufen der Festplatten-Informationen: $_" | Out-File $outFile -Append
}

# Hinweis
"`nFür Gehäuse, Netzteil (PSU) und CPU-Kühler ist eine manuelle Sichtprüfung notwendig." | Out-File $outFile -Append

Write-Host "Fertig! Alle Infos wurden gespeichert in: $outFile" -ForegroundColor Green
