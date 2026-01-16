# Bluewave Sweeper

A portable, agentless IOC scanner for Windows. It sweeps endpoints for specific file names, hashes, registry keys, and processes defined in a JSON profile.

The logic is derived from the "Collector" methodology outlined in _Incident Response & Computer Forensics_ (Mandia/Prosise) and RedLine. It implements that concept using native PowerShell to automate the search for specific artifacts across a fleet without requiring an EDR agent.

## Repository Structure

| **File**                  | **Description**                                                                                                     |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| `BluewaveSweeper.ps1`     | **PowerShell 7 (Core)** engine. Uses multithreading for faster file hashing.                                        |
| `BluewaveSweeper_5.1.ps1` | **PowerShell 5.1 (Legacy)** engine. Serial execution. Compatible with default Windows installations (Server 2012+). |
| `Convert-CsvToIoc.ps1`    | Helper script. Converts the CSV template into the JSON format required by the sweeper.                              |
| `sweeper_config.json`     | **Sample** configuration file. **You must generate your own using the converter.**                                  |
| `sweeper-schema.json`     | JSON schema used to validate the config file before execution.                                                      |
| `template.csv`            | Input template for defining IOCs.                                                                                   |

## Supported Indicators

The engine supports five logic modules:

1. **file_name**: Scans for specific filenames.
    
2. **file_hash**: Scans for SHA256 hashes. Supports path constraints to limit scope.
    
3. **registry_key**: Checks for the existence of specific keys.
    
4. **registry_value**: Checks for specific values (data) within a key.
    
5. **process_name**: Checks for running processes and captures PIDs.
    

## Workflow

### 1. Define IOCs

Populate `template.csv` with the target indicators.

- **Type**: `file_name`, `file_hash`, `registry_key`, `registry_value`, `process_name`.
    
- **Value**: The indicator (e.g., `mimikatz.exe`, `A1B2...`).
    
- **Constraint_Path**: (Optional) Restricts the search scope (e.g., `C:\Users\`).
    
    - `file_name`: Defaults to `C:\` recursively if blank.
        
    - `file_hash`: Defaults to `C:\Users\` recursively if blank.
        

### 2. Generate Configuration

Run the converter to transform the CSV into a validated JSON profile.

PowerShell

```
.\Convert-CsvToIoc.ps1 -CsvPath ".\template.csv" -OutPath ".\sweeper_config.json"
```

### 3. Deploy and Sweep

Copy the script (`.ps1`) and the config (`.json`) to the target machine.

#### Mode: Local (Default)

Saves the JSON report to the script's directory.

PowerShell

```
.\BluewaveSweeper.ps1 -InputJson ".\sweeper_config.json" -ReportMode Local
```

#### Mode: SMB (Network Share)

Saves the report locally, then copies it to a specified share.

PowerShell

```
.\BluewaveSweeper.ps1 -InputJson ".\sweeper_config.json" -ReportMode SMB -SMBPath "\\Server\EvidenceShare"
```

#### Mode: Cloud (Azure Blob)

Saves the report locally, then uploads it via REST API (PUT) to an Azure Blob Container using a SAS URL.

PowerShell

```
.\BluewaveSweeper.ps1 -InputJson ".\sweeper_config.json" -ReportMode Cloud -SasURL "https://<storage>.blob.core.windows.net/<container>?<sastoken>"
```

## Output Format

Reports are generated as JSON files: `Report_<HOSTNAME>_<TIMESTAMP>.json`.

**Sample Output:**

JSON

```
[
  {
    "Hostname": "DESKTOP-MAX",
    "Timestamp": "2026-01-16 16:00:00",
    "Type": "process_name",
    "Value": "svchost.exe",
    "Status": "DIRTY",
    "Details": "Count: 12 | PIDs: 1044, 2300, 4055"
  }
]
```

## Requirements

**BluewaveSweeper.ps1**

- PowerShell 7.0 or higher
    
- Windows 10/11, Server 2016+
    

**BluewaveSweeper_5.1.ps1**

- PowerShell 5.1 (Default on Windows)
    
- .NET Framework 4.5+ (Required for TLS 1.2 support during Cloud uploads)
