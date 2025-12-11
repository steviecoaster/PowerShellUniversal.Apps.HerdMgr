function Get-WeightHistory {
    <#
    .SYNOPSIS
    Gets weight history for a specific animal
    
    .DESCRIPTION
    Retrieves all weight measurements for an animal ordered by date (most recent first).
    Weight history is used to track growth patterns and calculate rate of gain.
    
    .PARAMETER CattleID
    Database ID of the cattle whose weight history to retrieve (required)
    
    .OUTPUTS
    Array of weight records with properties:
    WeightRecordID, WeightDate, Weight, WeightUnit, MeasurementMethod,
    RecordedBy, Notes
    
    .EXAMPLE
    Get-WeightHistory -CattleID 7
    
    Returns all weight records for cattle ID 7, newest first
    
    .EXAMPLE
    $weights = Get-WeightHistory -CattleID 12
    $latestWeight = $weights[0]
    Write-Host "Current weight: $($latestWeight.Weight) $($latestWeight.WeightUnit)"
    
    Gets weight history and displays the most recent weight
    
    .EXAMPLE
    Get-WeightHistory -CattleID 5 | Select-Object WeightDate, Weight | Format-Table
    
    Displays weight history in table format
    
    .NOTES
    Results are ordered by WeightDate DESC, so the most recent weight is first in the array.
    #>
    param(
        [Parameter(Mandatory)]
        [int]$CattleID
    )
    
    $query = @"
SELECT WeightRecordID, WeightDate, Weight, WeightUnit, MeasurementMethod, RecordedBy, Notes
FROM WeightRecords
WHERE CattleID = @CattleID
ORDER BY WeightDate DESC
"@
    
    Invoke-SqliteQuery -DataSource $script:DatabasePath -Query $query -SqlParameters @{CattleID = $CattleID} -As PSObject
}