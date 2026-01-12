<#
.SYNOPSIS
    Generates a recursive ASCII visualization of the Windows process tree.

.DESCRIPTION
    Retrieves active processes via WMI/CIM. Constructs an adjacency list and recursively visualizes the hierarchy. 
    Can target the entire system or a specific root process.

.PARAMETER ProcessId
    Optional. The specific Process ID (PID) to visualize. 
    If omitted, the script identifies and displays all root processes (processes with no active parent).

.EXAMPLE
    .\Get-ProcessTree.ps1
    Displays the full system process tree.

.EXAMPLE
    .\Get-ProcessTree.ps1 -ProcessId 4550
    Displays the tree starting strictly from Process ID 4550.
#>

param(
    [int]$ProcessId
)

$allProcs = Get-CimInstance Win32_Process | Select-Object ProcessId, ParentProcessId, Name
$childrenTable = @{}
$nameTable = @{}

foreach ($process in $allProcs) {
    $id = [int]$process.ProcessId
    $parentId = [int]$process.ParentProcessId
    
    $nameTable[$id] = $process.Name

    if (-not $childrenTable.ContainsKey($parentId)) {
        $childrenTable[$parentId] = [System.Collections.ArrayList]::new()
    }
    [void]$childrenTable[$parentId].Add($process)
}

function Show-ProcessTree {
    param(
        [int]$Id,
        [hashtable]$ChildrenMap,
        [hashtable]$NameMap,
        [int]$Level = 0
    )

    $indent = "|-- " * $Level
    $name = $NameMap[$Id]
    
    if ([string]::IsNullOrEmpty($name)) { $name = "Unknown/Exited" }
    
    Write-Output "$indent$name ($Id)"

    if ($ChildrenMap.ContainsKey($Id)) {
        foreach ($child in $ChildrenMap[$Id]) {
            Show-ProcessTree -Id $child.ProcessId -ChildrenMap $ChildrenMap -NameMap $NameMap -Level ($Level + 1)
        }
    }
}

if ($ProcessId -and $nameTable.ContainsKey($ProcessId)) {
    Show-ProcessTree -Id $ProcessId -ChildrenMap $childrenTable -NameMap $nameTable
}
elseif ($ProcessId) {
    Write-Warning "Process ID $ProcessId not found."
}
else {
    $roots = $allProcs | Where-Object { 
        $checkId = [int]$_.ParentProcessId
        -not $nameTable.ContainsKey($checkId) 
    }

    foreach ($root in $roots) {
        Show-ProcessTree -Id $root.ProcessId -ChildrenMap $childrenTable -NameMap $nameTable
    }
}