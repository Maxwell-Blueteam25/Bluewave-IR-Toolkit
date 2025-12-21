param(
    [Parameter(Mandatory=$True)]
    [string]$StorageContainerUrl,

    [Parameter(Mandatory=$True)]
    [string]$SasToken
)

$ErrorActionPreference = "Stop"
$ToolsPath = "$PSScriptRoot\Tools"
$Hostname = $env:COMPUTERNAME
$TimeStamp = Get-Date -Format "yyyyMMdd-HHmm"
$WorkDir = "C:\Bluewave_IR_$Hostname"

$MagnetExe = "$ToolsPath\Magnet\MRCv120.exe"
$KapeExe = "$ToolsPath\Kape\kape.exe"
$AzCopyExe = "$ToolsPath\AzCopy\azcopy.exe"
$VeloExe = Get-ChildItem -Path "$ToolsPath\Velociraptor\*.exe" | Select-Object -First 1

if (-not (Test-Path $MagnetExe)) { Write-Error "File not found: $MagnetExe"; exit }
if (-not (Test-Path $KapeExe)) { Write-Error "File not found: $KapeExe"; exit }
if (-not (Test-Path $AzCopyExe)) { Write-Error "File not found: $AzCopyExe"; exit }
if (-not $VeloExe) { Write-Error "No Velociraptor Collector executable found in $ToolsPath\Velociraptor"; exit }

New-Item -Path $WorkDir -ItemType Directory -Force | Out-Null
New-Item -Path "$WorkDir\Parsed" -ItemType Directory -Force | Out-Null

Write-Host "[+] Starting RAM Collection..." -ForegroundColor Cyan
Start-Process -FilePath $MagnetExe -ArgumentList "/accepteula /go /silent /d:""$WorkDir\Memory""" -Wait

Write-Host "[+] Starting Velociraptor ($($VeloExe.Name))..." -ForegroundColor Cyan
Start-Process -FilePath $VeloExe.FullName -Wait

Move-Item "$PSScriptRoot\Collection*.zip" "$WorkDir\Velociraptor_$Hostname.zip" -ErrorAction SilentlyContinue
Move-Item "$ToolsPath\Velociraptor\Collection*.zip" "$WorkDir\Velociraptor_$Hostname.zip" -ErrorAction SilentlyContinue

Write-Host "[+] Running KAPE 'Live' Modules..." -ForegroundColor Cyan
& $KapeExe `
    --msource C: `
    --mdest "$WorkDir\Parsed" `
    --module PowerShell_Process_Cmdline,Windows_Net_Start `
    --mflush --tflush

Write-Host "[+] Uploading Evidence Folder to Azure..." -ForegroundColor Green
$DestURL = "$StorageContainerUrl/$Hostname`_$TimeStamp`?$SasToken"

& $AzCopyExe copy "$WorkDir" "$DestURL" --recursive

Write-Host "[+] Cleaning up local files..." -ForegroundColor Yellow
Remove-Item $WorkDir -Recurse -Force
Write-Host "[+] Done. Evidence Secure." -ForegroundColor Green
