function Get-SystemInfo {
    <#
    .SYNOPSIS
    Retrieves the system-level configuration row (single row) from the database.

    .DESCRIPTION
    Returns a PSCustomObject with the system configuration values if present, otherwise $null.

    .EXAMPLE
    Get-SystemInfo
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [String]
        $DbPath = $script:DatabasePath
    )

    $query = "SELECT * FROM SystemInfo LIMIT 1"
    $result = Invoke-UniversalSQLiteQuery -Path $DbPath -Query $query

    return $result
}
