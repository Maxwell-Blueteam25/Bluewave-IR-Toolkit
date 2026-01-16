<#
.SYNOPSIS
    Converts a flat CSV IOC list into the Bluewave Sweeper JSON format.
.EXAMPLE
    .\Convert-CsvToIoc.ps1 -CsvPath ".\template.csv" -OutPath ".\campaign_config.json"
#>

param (
    [Parameter(Mandatory=$true)]
    [string]$CsvPath,

    [string]$OutPath = ".\sweeper_config.json",

    [string]$CaseID = "INC-Generated"
)

# 1. Validation
if (-not (Test-Path $CsvPath)) {
    Write-Error "Error: CSV file not found at $CsvPath"
    exit 1
}

$RawData = Import-Csv $CsvPath
$SweepsList = @()

Write-Host "Reading CSV..." -ForegroundColor Cyan


foreach ($Row in $RawData) {
    
    if ([string]::IsNullOrWhiteSpace($Row.Value)) { continue }

   
    $SweepItem = [Ordered]@{
        type   = $Row.Type
        value  = $Row.Value
        action = "report" # Default action
    }

    
    $Constraints = [Ordered]@{}
    $HasConstraints = $false

    
    if (-not [string]::IsNullOrWhiteSpace($Row.Constraint_Path)) {
        $Constraints["path"] = $Row.Constraint_Path
        $HasConstraints = $true
    }

 
    if (-not [string]::IsNullOrWhiteSpace($Row.Constraint_Ext)) {
        $Constraints["extension"] = $Row.Constraint_Ext
        $HasConstraints = $true
    }

    if ($HasConstraints) {
        $SweepItem["constraints"] = $Constraints
    }

    # Add Comments if present
    if (-not [string]::IsNullOrWhiteSpace($Row.Comment)) {
        $SweepItem["comment"] = $Row.Comment
    }

    $SweepsList += $SweepItem
}


$FinalJson = [Ordered]@{
    meta = [Ordered]@{
        case_id      = $CaseID
        generated_by = $env:USERNAME
        generated_at = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        ioc_count    = $SweepsList.Count
    }
    sweeps = $SweepsList
}


try {
    $FinalJson | ConvertTo-Json -Depth 5 | Set-Content -Path $OutPath -Encoding UTF8
    Write-Host "Success! JSON config saved to: $OutPath" -ForegroundColor Green
    Write-Host "Loaded $($SweepsList.Count) indicators." -ForegroundColor Gray
} catch {
    Write-Error "Failed to save JSON file: $_"
}