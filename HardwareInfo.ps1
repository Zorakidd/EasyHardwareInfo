<#
.SYNOPSIS
    Collects key hardware information (GPU, CPU, motherboard, BIOS, RAM, storage)
    and writes a human-readable report to a text file.
#>
param(
    [string]$OutputFile = "$env:USERPROFILE\Desktop\Hardware-info.txt"
)

# A helper function replaces the same try/catch block that would otherwise be repeated for every section
function Add-ReportSection {
    param(
        [System.Text.StringBuilder]$ReportBuilder,
        [string]$Title,
        [scriptblock]$DataQuery
    )
    [void]$ReportBuilder.AppendLine().AppendLine("===== $Title =====")
    try {
        # Run the query, format it as a list, and capture the result as plain text for the report
        $sectionOutput = & $DataQuery | Format-List | Out-String
        [void]$ReportBuilder.Append($sectionOutput.TrimEnd()).AppendLine()
    }
    catch {
        # A single failing section (e.g. missing driver info) should not abort the whole report
        $errorMessage = "Error retrieving $Title information: $_"
        [void]$ReportBuilder.AppendLine($errorMessage)
        Write-Warning $errorMessage
    }
}

if ([string]::IsNullOrWhiteSpace($OutputFile)) {
    Write-Error "-OutputFile cannot be empty. Provide a valid file path, e.g. -OutputFile 'C:\Reports\Hardware-info.txt'."
    exit 1
}

# This tool depends on WMI/CIM and the Storage module, both of which are Windows-only
if ($PSVersionTable.PSVersion.Major -ge 6 -and -not $IsWindows) {
    Write-Error "EasyHardwareInfo only works on Windows, because it relies on WMI/CIM and the Storage module."
    exit 1
}

# Make sure the target folder for the report exists (or can be created) before doing any work
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
    $cimSession = New-CimSession -ErrorAction Stop
}
catch {
    Write-Error "Could not open a CIM/WMI session on this computer: $_`nMake sure the 'Windows Management Instrumentation' service is running and try again."
    exit 1
}

try {
    $reportBuilder = [System.Text.StringBuilder]::new(8192)
    [void]$reportBuilder.AppendLine("Hardware information generated on: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")

    Add-ReportSection $reportBuilder 'GPU' {
        Get-CimInstance -CimSession $cimSession Win32_VideoController -ErrorAction Stop |
        Select-Object Name, AdapterCompatibility, DriverVersion, VideoProcessor
    }
    Add-ReportSection $reportBuilder 'Processor' {
        Get-CimInstance -CimSession $cimSession Win32_Processor -ErrorAction Stop |
        Select-Object Name, Manufacturer, MaxClockSpeed, NumberOfCores, NumberOfLogicalProcessors
    }
    Add-ReportSection $reportBuilder 'Motherboard' {
        Get-CimInstance -CimSession $cimSession Win32_BaseBoard -ErrorAction Stop |
        Select-Object Manufacturer, Product, SerialNumber, Version
    }
    Add-ReportSection $reportBuilder 'BIOS' {
        Get-CimInstance -CimSession $cimSession Win32_BIOS -ErrorAction Stop |
        Select-Object Manufacturer, SMBIOSBIOSVersion, ReleaseDate, SerialNumber, Version
    }
    Add-ReportSection $reportBuilder 'Memory (RAM)' {
        Get-CimInstance -CimSession $cimSession Win32_PhysicalMemory -ErrorAction Stop |
        Select-Object Manufacturer, PartNumber, SerialNumber, Speed,
        @{Name = 'Capacity(GB)'; Expression = { [math]::Round($_.Capacity / 1GB, 2) } }
    }
    Add-ReportSection $reportBuilder 'Storage' {
        # Reuse the shared CIM session instead of letting Get-PhysicalDisk open its own implicit connection
        Get-PhysicalDisk -CimSession $cimSession -ErrorAction Stop |
        Select-Object FriendlyName, MediaType,
        @{Name = 'Size(GB)'; Expression = { [math]::Round($_.Size / 1GB, 2) } }
    }

    [void]$reportBuilder.AppendLine().AppendLine(
        'Case, power supply (PSU), and CPU cooler require a manual visual inspection.'
    )
}
finally {
    # Always release the CIM session, even if something above throws unexpectedly
    Remove-CimSession $cimSession -ErrorAction SilentlyContinue
}

try {
    # Exactly one write operation, UTF-8 with BOM (so special characters display correctly in Notepad)
    [System.IO.File]::WriteAllText(
        $OutputFile,
        $reportBuilder.ToString(),
        [System.Text.UTF8Encoding]::new($true)
    )
}
catch {
    Write-Error "Could not save the report to '$OutputFile': $_`nCheck that the path is valid, that you have write permission, and that the file is not open in another program."
    exit 1
}

Write-Host "Done! All information has been saved to: $OutputFile" -ForegroundColor Green
