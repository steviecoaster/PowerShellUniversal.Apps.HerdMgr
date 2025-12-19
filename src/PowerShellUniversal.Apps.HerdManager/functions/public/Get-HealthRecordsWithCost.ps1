function Get-HealthRecordsWithCost {
    <#
    .SYNOPSIS
    Gets health records that have associated costs for a specific cattle
    
    .DESCRIPTION
    Retrieves health records from the database filtered by cattle ID and where
    a cost is recorded. Used primarily for invoice generation.
    
    .PARAMETER CattleID
    The ID of the cattle to get health records for
    
    .EXAMPLE
    Get-HealthRecordsWithCost -CattleID 1
    
    Returns all health records with costs for cattle ID 1
    
    .NOTES
    Only returns records where Cost > 0
    #>
    param(
        [Parameter(Mandatory)]
        [int]$CattleID
    )
    
    $query = "SELECT RecordDate, RecordType, Title, Description, Cost FROM HealthRecords WHERE CattleID = $CattleID AND Cost > 0 ORDER BY RecordDate"
    
    Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $query
}
