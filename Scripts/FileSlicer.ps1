# Version 1.2 will add "$_.UpdateReasons -like "*Dele*" -and [datetime]$_.UpdateTimeStamp -ge $time"

<#
.SYNOPSIS
    Parses MFT, $J (USN Journal), and Prefetch artifacts for file and executable analysis.

.DESCRIPTION
    This script allows the user to import MFT, $J, or Prefetch files and perform various analyses, 
    such as:
      - Listing top executables
      - Showing all executables
      - Top file extensions
      - File creations, deletions, renames (Journal only)
      - Searching for specific strings or files
    Results can be exported to CSV.

.PARAMETER artifactchoice
    Select the artifact type: 1 = MFT, 2 = $J, 3 = Prefetch.

.PARAMETER analysisChoice
    Select the analysis to perform: 1–7 as described in the menu.

.EXAMPLE
    .\ArtifactParser.ps1
    Runs the script and prompts for artifact type and analysis options.

.NOTES
    Created by Maxwell Skinner for forensic artifact analysis.
#>

Write-Host @"
╔═══════════════════════════════════════════════════════════════════════════════╗
║                                                                               ║
║    ███████╗██╗██╗     ███████╗    ███████╗██╗     ██╗ ██████╗███████╗██████╗  ║
║    ██╔════╝██║██║     ██╔════╝    ██╔════╝██║     ██║██╔════╝██╔════╝██╔══██╗ ║
║    █████╗  ██║██║     █████╗      ███████╗██║     ██║██║     █████╗  ██████╔╝ ║
║    ██╔══╝  ██║██║     ██╔══╝      ╚════██║██║     ██║██║     ██╔══╝  ██╔══██╗ ║
║    ██║     ██║███████╗███████╗    ███████║███████╗██║╚██████╗███████╗██║  ██║ ║
║    ╚═╝     ╚═╝╚══════╝╚══════╝    ╚══════╝╚══════╝╚═╝ ╚═════╝╚══════╝╚═╝  ╚═╝ ║
║                                                                               ║
║              ▓▓▓▓▓  Forensic Artifact Analysis Tool  ▓▓▓▓▓                   ║
║                        Created by Maxwell Skinner                            ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

Write-Host ""
Write-Host "    ═══════════════════════════════════════════════════════" -ForegroundColor DarkCyan
Write-Host "      Slice through digital artifacts with precision!" -ForegroundColor Yellow
Write-Host "    ═══════════════════════════════════════════════════════" -ForegroundColor DarkCyan
Write-Host ""

Write-Host "Select Artifact to Parse: " -ForegroundColor Cyan
Write-Host "1. `$MFT (.csv)' " -ForegroundColor Cyan
Write-Host "2. `$J (.csv)' " -ForegroundColor Cyan
Write-Host "3. Prefetch (.txt) " -ForegroundColor Cyan

$artifactchoice = Read-Host "Select Options 1-3"

switch ($artifactchoice){
    1 { $filePath = (Read-Host "Enter MFT CSV Path").Trim('"') ; $artifactType = "MFT" }
    2 { $filePath = (Read-Host "Enter J CSV Path").Trim('"') ; $artifactType = "Journal" }
    3 { $filePath = Read-Host "Enter Prefetch file Path (.txt)"; $artifactType = "Prefetch" }
    default { Write-Host "Invalid Choice. Exiting." ; exit }
}

# Import data depending on type

if ( $artifactType -eq "Prefetch") {
    $data = Get-Content -Path $filePath
} else {
    $data = Import-Csv -Path $filePath
}

# Menu
# Menu
Write-Host "Select analysis option:"
Write-Host "1. Top executables"
Write-Host "2. All executables"
Write-Host "3. Top file extensions"
Write-Host "4. File creations"
Write-Host "5. File deletions"
Write-Host "6. File renames"
Write-Host "7. Hunt for string/file"
$analysisChoice = Read-Host "Enter choice (1-7)"

switch($analysisChoice){
    1 { #Top Executables 
        if ($artifactType -eq "Prefetch") {
           $results = $data | Select-String -Pattern "Executable Name" | Group-Object | Sort-Object Count -Descending | Select-Object Count, Name
        } elseif ($artifactType -eq "MFT") {
           $results = $data | Where-Object { $_.Extension -ieq ".exe" } | Group-Object FileName | Sort-Object Count -Descending
        } elseif ($artifactType -eq "Journal") {
            $results = $data | Where-Object { $_.Extension -ieq ".exe" } | Group-Object Name | Sort-Object Count -Descending | Select-Object Count, Name
        }
    $results    
    $export = Read-Host "Do you want to export results to CSV? (y/n)"
        if ($export -eq "y") {
            $outPath = Read-Host "Enter output file path (e.g., results.csv)"
            $results | Export-Csv -Path $outPath -NoTypeInformation -Encoding UTF8
            Write-Host "Results exported to $outPath" -ForegroundColor Green
        }        
    }   
    2 { #All Exe's
        if ($artifactType -eq "Prefetch") {
         $results = $data | Select-String -Pattern "Executable Name" | Sort-Object -Unique
        } elseif ($artifactType -eq "MFT") {
           $results = $data  | Where-Object { $_.Extension -ieq ".exe" } | Select-Object FileName, ParentPath, Created0x10 | Format-List
        } elseif ($artifactType -eq "Journal"){
           $results = $data | Where-Object { $_.Extension -ieq ".exe" } | Select-Object Name, "UpdateTimestamp"
        }
    $results
    $export = Read-Host "Do you want to export results to CSV? (y/n)"
        if ($export -eq "y") {
            $outPath = Read-Host "Enter output file path (e.g., results.csv)"
            $results | Export-Csv -Path $outPath -NoTypeInformation -Encoding UTF8
            Write-Host "Results exported to $outPath" -ForegroundColor Green
        }     
    }
    3 { #Top File Extensions
        if ($artifactType -eq "Prefetch") {
           $results = $data | Select-String -Pattern "Executable Name" | Group-Object | Sort-Object Count -Descending
        } elseif ($artifactType -eq "MFT") {
           $results = $data  | Group-Object Extension | Sort-Object Count -Descending | Select-Object Count, Name -First 20
        } elseif ($artifactType -eq "Journal"){
            $results = $data | Group-Object Extension | Sort-Object Count -Descending | Select-Object Count, Name -First 20
        }    
    $results
    $export = Read-Host "Do you want to export results to CSV? (y/n)"
        if ($export -eq "y") {
            $outPath = Read-Host "Enter output file path (e.g., results.csv)"
            $results | Export-Csv -Path $outPath -NoTypeInformation -Encoding UTF8
            Write-Host "Results exported to $outPath" -ForegroundColor Green
        }         
    }

    4 { # File Creations
        if ($artifactType -eq "Prefetch") {
           Write-Host "This Option is only available for $J" -ForegroundColor Red ; return
        } elseif ($artifactType -eq "MFT") {
            Write-Host "This Option is only available for $J" -ForegroundColor Red ; return
        } elseif ($artifactType -eq "Journal"){
          $results = $data | Where-Object { $_.UpdateReasons -eq "FileCreate" } | Select-Object Name, UpdateTimestamp, UpdateReasons | Format-List
        }    
    $results
    $export = Read-Host "Do you want to export results to CSV? (y/n)"
        if ($export -eq "y") {
            $outPath = Read-Host "Enter output file path (e.g., results.csv)"
            $results | Export-Csv -Path $outPath -NoTypeInformation -Encoding UTF8
            Write-Host "Results exported to $outPath" -ForegroundColor Green
        }         
    } 

    5 { # File Deletions
        if ($artifactType -eq "Prefetch") {
           Write-Host "This Option is only available for $J" -ForegroundColor Red ; return
        } elseif ($artifactType -eq "MFT") {
            Write-Host "This Option is only available for $J" -ForegroundColor Red ; return
        } elseif ($artifactType -eq "Journal"){
         $results = $data | Where-Object { $_.UpdateReasons -like "*Dele*" } | Select-Object Name, UpdateTimestamp, UpdateReasons | Format-List
        }    
    $results
    $export = Read-Host "Do you want to export results to CSV? (y/n)"
        if ($export -eq "y") {
            $outPath = Read-Host "Enter output file path (e.g., results.csv)"
            $results | Export-Csv -Path $outPath -NoTypeInformation -Encoding UTF8
            Write-Host "Results exported to $outPath" -ForegroundColor Green
        }         
    } 
    
    6 { # File Renames
        if ($artifactType -eq "Prefetch") {
           Write-Host "This Option is only available for $J" -ForegroundColor Red ; return
        } elseif ($artifactType -eq "MFT") {
            Write-Host "This Option is only available for $J" -ForegroundColor Red ; return
        } elseif ($artifactType -eq "Journal"){
         $results = $data | Where-Object { $_.UpdateReasons -like "*Rename*" } | Select-Object Name, UpdateTimestamp, UpdateReasons | Format-List
        }    
    $results
    $export = Read-Host "Do you want to export results to CSV? (y/n)"
        if ($export -eq "y") {
            $outPath = Read-Host "Enter output file path (e.g., results.csv)"
            $results | Export-Csv -Path $outPath -NoTypeInformation -Encoding UTF8
            Write-Host "Results exported to $outPath" -ForegroundColor Green
        }        
    } 

    7 { # Search For String
        $string = Read-Host "Enter a String"
        if ($artifactType -eq "Prefetch") {
         $results = $data | Select-String -Pattern $string
        } elseif ($artifactType -eq "MFT") {
         $results = $data | Where-Object { $_.FileName -like "*$string*" }
        } elseif ($artifactType -eq "Journal"){
        $results = $data | Where-Object { $_.Name -like "*$string*" } 
        }    
    $results
    $export = Read-Host "Do you want to export results to CSV? (y/n)"
        if ($export -eq "y") {
            $outPath = Read-Host "Enter output file path (e.g., results.csv)"
            $results | Export-Csv -Path $outPath -NoTypeInformation -Encoding UTF8
            Write-Host "Results exported to $outPath" -ForegroundColor Green
        }     
    } 

}