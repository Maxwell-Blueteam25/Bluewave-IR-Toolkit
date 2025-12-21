# Bluewave-IR-Toolkit
High-velocity DFIR 'Smash &amp; Grab' pipeline. Automates RAM/Artifact collection (Velociraptor/Magnet) and lightweight live triage (KAPE), streamlining evidence directly to Azure Storage for remote analysis.
**Current Version:** 1.0.0
**Author:** Maxwell Skinner (Bluewave Cyberdefense)

## Overview
The Bluewave IR Toolkit is a lightweight, "Smash & Grab" Incident Response pipeline designed for high-velocity forensic collection. It prioritizes **Time-To-Evidence** by automating the capture of RAM and Disk Artifacts and streaming them directly to an Azure "Clean Room" for analysis.

This tool avoids the common pitfall of "Heavy Parsing" on the victim endpoint. It performs a minimal "Live Triage" locally and offloads heavy processing to the cloud.

### The Pipeline
1. **Capture RAM** (Magnet RAM Capture / DumpIt)
2. **Collect Artifacts** (Velociraptor Offline Collector)
3. **Live Triage** (KAPE - Safe Modules Only)
4. **Exfiltrate** (AzCopy Recursive Stream to Azure Blob)

---

## ⚠️ "Bring Your Own Tools" (BYOT)
To comply with licensing restrictions (Kroll, Magnet, Microsoft), this repository **does not** contain the executable binaries. You must populate the `Tools/` directory with your own licensed copies.

### 1. Tools/Velociraptor/
Generate a standalone "Offline Collector" using the official Docker image.
**Recommended Artifacts for Scope:**
* `Windows.KapeFiles.Targets` (Config: SansTriage or KapeTriage)
* `Windows.EventLogs.EvtxHunter`
* `Windows.EventLogs.Evtx`
* `Windows.System.DNSCache`
* `Windows.Sysinternals.Autoruns`
* `Windows.System.Services`

### 2. Tools/Kape/
Download KAPE from Kroll.
* **Purpose:** Runs "Safe" Live Triage modules (non-locking).
* **Modules Used:** `Hayabusa`, `PowerShell_Process_Cmdline`, `Windows_Net_Start`.

### 3. Tools/Magnet/
Download Magnet RAM Capture (Free Tool).
* **Purpose:** Volatile memory acquisition.

### 4. Tools/AzCopy/
Download `azcopy.exe` (v10) from Microsoft.
* **Purpose:** High-speed, recursive upload to Azure Blob Storage.

---

## Usage

1. **Prepare the Toolkit:**
   Place the required executables in their respective folders in `Tools/`.

2. **Generate SAS Token:**
   Create an Azure Container SAS Token with `Write` and `Create` permissions.

3. **Run on Endpoint (Admin):**
   ```
   .\Start-Collection.ps1 -SasToken "?sv=2022-11-02&ss=b&srt=sco..." .\Start-Collection.ps1 `
     -StorageContainerUrl "https://myclient.blob.core.windows.net/evidence-container" `
     -SasToken "?sv=2022-11-02&ss=b&srt=sco..."
   ```
   
