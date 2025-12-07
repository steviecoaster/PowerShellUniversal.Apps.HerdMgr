function Get-WeightHistory {
    <#
    .SYNOPSIS
    Gets weight history for a specific animal
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