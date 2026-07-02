# 🖥️ EasyHardwareInfo

A small Windows tool that shows you your PC's hardware information at the push of a button — fast, lightweight, and no installation required.

It reads your GPU, CPU, motherboard, BIOS, RAM, and storage details via Windows Management Instrumentation (WMI) and saves them to a plain text report, so you always have a quick overview of what's inside your system (handy for support requests, upgrades, or just curiosity).

---

## 📥 Download

[![Download here](https://img.shields.io/badge/⬇️_Download-here-blue?style=for-the-badge)](https://github.com/Zorakidd/EasyHardwareInfo/releases/download/v1.0/HardwareInfo.exe)

Or grab the latest release from the [Releases page](https://github.com/Zorakidd/EasyHardwareInfo/releases).

---

## 🚀 Usage

1. Download `HardwareInfo.exe`.
2. Run the file (no installation needed).
3. A report is generated and saved to your Desktop as `Hardware-info.txt`, containing your GPU, CPU, motherboard, BIOS, RAM, and storage details.

### Example

Running the tool with no arguments:

```
HardwareInfo.exe
```

produces `Hardware-info.txt` on your Desktop, with content similar to:

```
Hardware information generated on: 2026-07-02 14:30:00

===== GPU =====

Name                 : NVIDIA GeForce RTX 4070 Laptop GPU
AdapterCompatibility : NVIDIA
DriverVersion        : 32.0.16.1047
VideoProcessor       : NVIDIA GeForce RTX 4070 Laptop GPU

===== Processor =====

Name                      : 13th Gen Intel(R) Core(TM) i9-13900H
Manufacturer              : GenuineIntel
MaxClockSpeed             : 2600
NumberOfCores             : 14
NumberOfLogicalProcessors : 20

...
```

To save the report to a custom location instead, run the underlying PowerShell script directly with the `-OutputFile` parameter:

```powershell
.\HardwareInfo.ps1 -OutputFile "C:\Reports\my-pc-info.txt"
```

> **Note:** case, power supply (PSU), and CPU cooler cannot be detected via software and require a manual visual inspection.

---

## ✅ Requirements

- Windows 10 or Windows 11 (uses WMI/CIM and the built-in Storage module, so it is Windows-only).
- No installation and no administrator rights required.