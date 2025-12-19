function Clear-SystemInfo {
    <#
    .SYNOPSIS
    Removes all rows from the SystemInfo table (resets system settings)

    .DESCRIPTION
    Deletes all rows from the SystemInfo table. Intended for resetting the application
    to an unconfigured state. Use -Force to bypass interactive confirmation when called
    from the UI.

    .PARAMETER Force
    Skip confirmation prompts (use when called from UI buttons)
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [switch]$Force,
        [Parameter()]
        [string]$DatabasePath = $script:DatabasePath
    )

    if (-not $Force) {
        if (-not $PSCmdlet.ShouldProcess('SystemInfo','Clear all rows')) { return }
    }

    try {
    $countRow = Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query "SELECT COUNT(*) AS cnt FROM SystemInfo;"
    if ($countRow -and $countRow.Count -gt 0) { $countInt = [int]$countRow[0].cnt } else { $countInt = 0 }

        if ($countInt -eq 0) {
            Write-Verbose 'SystemInfo table already empty'
            return 0
        }

    Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query "DELETE FROM SystemInfo"

        # Return number of rows removed for verification
        return $countInt
    }
    catch {
        throw $_
    }
}
