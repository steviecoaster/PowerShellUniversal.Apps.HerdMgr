function Invoke-UniversalSQLiteQuery {
    <#
    .SYNOPSIS
    Execute SQLite queries using the sqlite3 command-line tool
    
    .DESCRIPTION
    A wrapper function that executes SQLite queries using the native sqlite3 CLI.
    This provides cross-platform compatibility without requiring PowerShell modules.
    
    .PARAMETER Path
    Path to the SQLite database file
    
    .PARAMETER Query
    SQL query to execute
    
    .EXAMPLE
    Invoke-UniversalSQLiteQuery -Path "./data/HerdManager.db" -Query "SELECT * FROM Cattle"
    
    .NOTES
    Requires sqlite3 to be installed and available in PATH
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        
        [Parameter(Mandatory)]
        [string]$Query
    )
    
    # Verify sqlite3 is available
    if (-not (Get-Command sqlite3 -ErrorAction SilentlyContinue)) {
    throw "sqlite3 command not found. Please install SQLite."
    }
    
    # Verify database exists
    if (-not (Test-Path $Path)) {
        throw "Database file not found: $Path"
    }
    
    # Resolve full path
    $dbPath = Resolve-Path $Path | Select-Object -ExpandProperty Path
    
    # Use .timeout command for sqlite3 CLI (doesn't return output, just sets connection timeout)
    # This is critical for concurrent access in web apps (5000ms = 5 seconds)
    $timeoutCmd = ".timeout 5000"
    $combinedInput = "$timeoutCmd`n$Query"
    
    # Try JSON output first (best for structured data)
    # Always pass via stdin to ensure .timeout command is processed first
    $output = $combinedInput | sqlite3 $dbPath -json - 2>&1
    
    # Check for errors
    if ($LASTEXITCODE -ne 0) {
        throw "SQLite query failed: $output"
    }
    
    # Parse output
    if ($output) {
        try {
            # Try to parse as JSON
            $result = $output | ConvertFrom-Json
            return $result
        }
        catch {
            # JSON parsing failed, try CSV mode for better compatibility
            $csvOutput = $combinedInput | sqlite3 $dbPath -csv -header - 2>&1
            
            if ($LASTEXITCODE -eq 0 -and $csvOutput) {
                try {
                    # Convert CSV to objects
                    $result = $csvOutput | ConvertFrom-Csv
                    return $result
                }
                catch {
                    # If CSV also fails, return raw output
                    return $csvOutput
                }
            }
            
            # Fallback to raw output
            return $output
        }
    }
    
    return $null
}
