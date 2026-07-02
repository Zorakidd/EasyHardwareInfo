param(
    [string]$OutputFile = "$env:USERPROFILE\Desktop\Hardware-info.txt"
)

# Eine Hilfsfunktion ersetzt 6x denselben try/catch-Block
function Add-Section {
    param(
        [System.Text.StringBuilder]$Sb,
        [string]$Title,
        [scriptblock]$Query
    )
    [void]$Sb.AppendLine().AppendLine("===== $Title =====")
    try {
        $out = & $Query | Format-List | Out-String
        [void]$Sb.Append($out.TrimEnd()).AppendLine()
    }
    catch {
        [void]$Sb.AppendLine("Fehler beim Abrufen der ${Title}-Informationen: $_")
    }
}

$sb = [System.Text.StringBuilder]::new(8192)
[void]$sb.AppendLine("Hardware-Informationen erstellt am: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")

# Eine CIM-Session statt 5 separater Verbindungen
$cim = New-CimSession

Add-Section $sb 'GPU' {
    Get-CimInstance -CimSession $cim Win32_VideoController -ErrorAction Stop |
    Select-Object Name, AdapterCompatibility, DriverVersion, VideoProcessor
}
Add-Section $sb 'Prozessor' {
    Get-CimInstance -CimSession $cim Win32_Processor -ErrorAction Stop |
    Select-Object Name, Manufacturer, MaxClockSpeed, NumberOfCores, NumberOfLogicalProcessors
}
Add-Section $sb 'Mainboard' {
    Get-CimInstance -CimSession $cim Win32_BaseBoard -ErrorAction Stop |
    Select-Object Manufacturer, Product, SerialNumber, Version
}
Add-Section $sb 'BIOS' {
    Get-CimInstance -CimSession $cim Win32_BIOS -ErrorAction Stop |
    Select-Object Manufacturer, SMBIOSBIOSVersion, ReleaseDate, SerialNumber, Version
}
Add-Section $sb 'Arbeitsspeicher (RAM)' {
    Get-CimInstance -CimSession $cim Win32_PhysicalMemory -ErrorAction Stop |
    Select-Object Manufacturer, PartNumber, SerialNumber, Speed,
    @{Name = 'Capacity(GB)'; Expression = { [math]::Round($_.Capacity / 1GB, 2) } }
}
Add-Section $sb 'Festplatten' {
    # Reuse the shared CIM session instead of letting Get-PhysicalDisk open its own implicit connection
    Get-PhysicalDisk -CimSession $cim -ErrorAction Stop |
    Select-Object FriendlyName, MediaType,
    @{Name = 'Size(GB)'; Expression = { [math]::Round($_.Size / 1GB, 2) } }
}

Remove-CimSession $cim

[void]$sb.AppendLine().AppendLine(
    'Für Gehäuse, Netzteil (PSU) und CPU-Kühler ist eine manuelle Sichtprüfung notwendig.'
)

# Genau EIN Schreibvorgang, UTF-8 mit BOM (Umlaute in Notepad korrekt)
[System.IO.File]::WriteAllText(
    $OutputFile,
    $sb.ToString(),
    [System.Text.UTF8Encoding]::new($true)
)

Write-Host "Fertig! Alle Infos wurden gespeichert in: $OutputFile" -ForegroundColor Green