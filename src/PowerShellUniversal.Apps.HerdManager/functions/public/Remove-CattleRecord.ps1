function Remove-CattleRecord {
    <#
    .SYNOPSIS
    Removes a cattle record from the database
    
    .DESCRIPTION
    Permanently deletes a cattle record and all associated weight records, health records,
    and rate of gain calculations. This action cannot be undone.
    
    .PARAMETER CattleID
    Database ID of the cattle to remove (required)
    
    .EXAMPLE
    Remove-CattleRecord -CattleID 15
    
    Permanently deletes cattle ID 15 and all associated records
    
    .EXAMPLE
    $cattle = Get-CattleById -CattleID 23
    if ($cattle.Status -eq 'Deceased') {
        Remove-CattleRecord -CattleID 23
    }
    
    Removes a deceased animal from the database
    
    .NOTES
    WARNING: This permanently deletes the record. Consider updating the Status field
    to 'Sold', 'Deceased', or 'Transferred' instead to maintain historical records.
    
    Due to foreign key constraints, all related records (weights, health, ROG calculations)
    are automatically deleted when the cattle record is removed.
    #>
    param(
        [Parameter(Mandatory)]
        [int]$CattleID
    )
    
    $cattleIdValue = ConvertTo-SqlValue -Value $CattleID
    $query = "DELETE FROM Cattle WHERE CattleID = $cattleIdValue"

    try {
        Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $query
        Write-Verbose "Removed cattle record ID $CattleID"
    }
    catch {
        throw $_
    }
}






