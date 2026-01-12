function Run-Persistence {
    param (
        [string]$LogPath,

        [string]$BaselinePath,

        [string]$JsonOutputPath
    )

    $log = @()
    $structuredLog = @()

    $log += "==== Windows Persistence Mechanism Check ===="

    # 1. Registry Run Keys
    $log += "`n[+] Checking Registry Run Keys..."
    $runKeys = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
    )

    foreach ($key in $runKeys) {
        if (Test-Path $key) {
            Get-ItemProperty -Path $key | ForEach-Object {
                $_.PSObject.Properties | Where-Object {
                    $_.Name -notin @("PSPath", "PSParentPath", "PSChildName", "PSDrive", "PSProvider")
                } | ForEach-Object {
                    $line = "$($key)\$($_.Name) -> $($_.Value)"
                    $log += $line
                    $structuredLog += [pscustomobject]@{
                        Category = "RegistryRunKey"
                        Path     = "$($key)\$($_.Name)"
                        Value    = "$($_.Value)"
                    }
                }
            }
        }
    }

    # 2. Startup Folder Shortcuts
    $log += "`n[+] Checking Startup Folder Shortcuts..."
    $startupPaths = @(
        "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup",
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"
    )

    foreach ($path in $startupPaths) {
        if (Test-Path $path) {
            Get-ChildItem -Path $path -Filter *.lnk | ForEach-Object {
                $line = "Startup Shortcut: $($_.FullName)"
                $log += $line
                $structuredLog += [pscustomobject]@{
                    Category = "StartupShortcut"
                    Path     = "$($_.FullName)"
                    Value    = ""
                }
            }
        }
    }

    # 3. Scheduled Tasks (excluding Microsoft)
    $log += "`n[+] Checking Scheduled Tasks..."
    Get-ScheduledTask | Where-Object { $_.TaskPath -notlike "\Microsoft*" } | ForEach-Object {
        $line = "Task: $($_.TaskName) | Path: $($_.TaskPath)"
        $log += $line
        $structuredLog += [pscustomobject]@{
            Category = "ScheduledTask"
            Path     = $($_.TaskPath)
            Value    = $($_.TaskName)
        }
    }

    # 4. Auto-start Services (non-Microsoft)
    $log += "`n[+] Checking Auto-Start Services (non-Microsoft)..."
    Get-WmiObject -Class Win32_Service | Where-Object {
        $_.StartMode -eq "Auto" -and $_.State -eq "Running" -and $_.PathName -notlike "*Microsoft*"
    } | ForEach-Object {
        $line = "Service: $($_.Name) ($($_.DisplayName)) -> $($_.PathName)"
        $log += $line
        $structuredLog += [pscustomobject]@{
            Category = "Service"
            Path     = $($_.Name)
            Value    = "$($_.DisplayName) -> $($_.PathName)"
        }
    }

    $log += "`n[DONE] Check Complete."

    # Sort for consistency
    $log = $log | Sort-Object

    # Output to file
    $log | Out-File -FilePath $LogPath -Encoding UTF8
    Write-Host "`n[+] Log saved to: $LogPath" -ForegroundColor Cyan

    # Optional: Output to JSON
    if ($JsonOutputPath) {
        $structuredLog | ConvertTo-Json -Depth 5 | Out-File -FilePath $JsonOutputPath -Encoding UTF8
        Write-Host "[+] Structured JSON saved to: $JsonOutputPath" -ForegroundColor Cyan
    }

    # Optional: Compare to baseline
    if ($BaselinePath -and (Test-Path $BaselinePath)) {
        Write-Host "`n[~] Comparing current results to baseline..." -ForegroundColor Magenta
        $baseline = Get-Content $BaselinePath
        $current  = Get-Content $LogPath

        $differences = Compare-Object -ReferenceObject $baseline -DifferenceObject $current

        if ($differences) {
            Write-Host "`n[!] Differences from baseline detected:" -ForegroundColor Red
            $differences | ForEach-Object {
                Write-Host "$($_.SideIndicator) $($_.InputObject)" -ForegroundColor Yellow
            }
        } else {
            Write-Host "`n[+] No differences from baseline." -ForegroundColor Green
        }
    }

    # Show log in console
    Write-Host "`n===== Current Persistence Check Output =====" -ForegroundColor White
    $log | ForEach-Object { Write-Host $_ -ForegroundColor Yellow }
}

## Example Usage:
# Run-Persistence -LogPath "C:\Logs\persistence_check.txt" `
 #               -BaselinePath "C:\Logs\baseline.txt" `
   #             -JsonOutputPath "C:\Logs\persistence_check.json"
