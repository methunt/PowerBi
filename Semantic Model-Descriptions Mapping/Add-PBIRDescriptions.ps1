<#
.SYNOPSIS
    Adds or overwrites descriptions on columns and measures in a Power BI PBIR semantic model (TMDL format).

.DESCRIPTION
    Reads a CSV file with columns [Table Name, Field Name, Field Type, Description] and injects
    TMDL documentation comments (///) above the matching column/measure declarations in the
    SemanticModel definition folder. If a description comment already exists it is replaced.
    
    Field Types "Column", "Calculated Column" and "Field Parameter" are treated as TMDL column
    declarations; "Measure" is treated as a TMDL measure declaration.

.PARAMETER SemanticModelPath
    Full path to the .SemanticModel folder (the one that contains the "definition" sub-folder).

.PARAMETER CsvPath
    Full path to the CSV file. Expected columns: Table Name, Field Name, Field Type, Description.

.EXAMPLE
    .\Add-PBIRDescriptions.ps1 `
        -SemanticModelPath "D:\...\MyModel.SemanticModel" `
        -CsvPath "C:\Users\Me\Downloads\descriptions.csv"
#>
param(
    [Parameter(Mandatory)]
    [string]$SemanticModelPath,

    [Parameter(Mandatory)]
    [string]$CsvPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# Validate inputs
# ---------------------------------------------------------------------------
$tablesPath = Join-Path $SemanticModelPath "definition\tables"

if (-not (Test-Path $tablesPath -PathType Container)) {
    Write-Error "Tables folder not found: $tablesPath"
    exit 1
}
if (-not (Test-Path $CsvPath -PathType Leaf)) {
    Write-Error "CSV file not found: $CsvPath"
    exit 1
}

# UTF-8 without BOM writer (matches the existing TMDL file encoding)
$utf8NoBom = New-Object System.Text.UTF8Encoding $false

# ---------------------------------------------------------------------------
# Helper: build a regex pattern that matches a TMDL column/measure declaration
# line for a given field name, regardless of whether the name is quoted or not.
# Declaration lines have exactly one leading tab.
# ---------------------------------------------------------------------------
function Get-DeclPattern {
    param([string]$FieldName, [string]$FieldType)

    $escaped = [regex]::Escape($FieldName)
    $keyword = if ($FieldType -eq 'Measure') { 'measure' } else { 'column' }

    # Match:  \t<keyword> 'FieldName'   (quoted, name contains spaces or special chars)
    #     or  \t<keyword> FieldName     (unquoted)
    # followed by whitespace, "=", or end-of-line
    return "^\t$keyword\s+(?:'$escaped'|$escaped)(\s|=|$)"
}

# ---------------------------------------------------------------------------
# Process CSV
# ---------------------------------------------------------------------------
$csvData  = Import-Csv $CsvPath
$groups   = $csvData | Group-Object -Property 'Table Name'

$totalUpdated  = 0
$totalInserted = 0
$totalMissing  = 0

foreach ($group in $groups) {
    $tableName = $group.Name
    $tmdlPath  = Join-Path $tablesPath "$tableName.tmdl"

    if (-not (Test-Path $tmdlPath -PathType Leaf)) {
        Write-Warning "  [SKIP] TMDL file not found for table '$tableName' - expected: $tmdlPath"
        $totalMissing += $group.Group.Count
        continue
    }

    # Read preserving exact bytes; split on CRLF (TMDL standard)
    $raw   = [System.IO.File]::ReadAllText($tmdlPath, [System.Text.Encoding]::UTF8)
    $lines = [System.Collections.Generic.List[string]]($raw -split "`r`n")

    $fileModified = $false

    foreach ($row in $group.Group) {
        $fieldName  = $row.'Field Name'
        $fieldType  = $row.'Field Type'
        $description = $row.'Description'

        # TMDL uses triple-slash comments (///) for documentation
        # If description has newlines, create multiple /// lines
        $descLines = @()
        if ($description -match "`r`n|`n|`r") {
            # Split on any newline variant and create a /// line for each
            $parts = $description -split "`r`n|`n|`r" | Where-Object { $_.Trim() -ne '' }
            foreach ($part in $parts) {
                $descLines += "`t/// $($part.Trim())"
            }
        }
        else {
            $descLines += "`t/// $description"
        }

        $pattern   = Get-DeclPattern -FieldName $fieldName -FieldType $fieldType
        $declIndex = -1

        for ($i = 0; $i -lt $lines.Count; $i++) {
            if ($lines[$i] -match $pattern) {
                $declIndex = $i
                break
            }
        }

        if ($declIndex -eq -1) {
            Write-Warning "  [NOT FOUND] '$fieldName' ($fieldType) in table '$tableName'"
            $totalMissing++
            continue
        }

        # Check if there are already /// comments immediately before the declaration
        $firstCommentIdx = -1
        $lastCommentIdx = -1
        for ($i = $declIndex - 1; $i -ge 0; $i--) {
            if ($lines[$i] -match '^\t///') {
                $firstCommentIdx = $i
            }
            elseif ($lines[$i].Trim() -ne '') {
                # Hit non-comment, non-blank line - stop
                break
            }
        }

        if ($firstCommentIdx -ge 0) {
            # Find last comment line
            for ($i = $firstCommentIdx; $i -lt $declIndex; $i++) {
                if ($lines[$i] -match '^\t///') {
                    $lastCommentIdx = $i
                }
            }
            # Remove all existing comment lines
            for ($i = $lastCommentIdx; $i -ge $firstCommentIdx; $i--) {
                $lines.RemoveAt($i)
                $declIndex--  # Adjust declaration index
            }
            $totalUpdated++
        }
        else {
            $totalInserted++
        }

        # Insert new comment line(s) before the declaration
        for ($i = $descLines.Count - 1; $i -ge 0; $i--) {
            $lines.Insert($declIndex, $descLines[$i])
        }

        $fileModified = $true
    }

    if ($fileModified) {
        $newContent = $lines -join "`r`n"
        [System.IO.File]::WriteAllText($tmdlPath, $newContent, $utf8NoBom)
        Write-Host "[SAVED] $tableName.tmdl ($($group.Group.Count) field(s) processed)"
    }
}

Write-Host ""
Write-Host "=== Summary ==="
Write-Host "  Descriptions inserted : $totalInserted"
Write-Host "  Descriptions replaced : $totalUpdated"
Write-Host "  Fields not found      : $totalMissing"
