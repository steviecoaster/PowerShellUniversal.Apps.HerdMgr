function Get-AllWeightRecords {
    <#
    .SYNOPSIS
    Gets all weight records with cattle information
    
    .DESCRIPTION
    Retrieves all weight records from the database joined with cattle information,
    ordered by most recent first.
    
    .EXAMPLE
    Get-AllWeightRecords
    
    Returns all weight records with cattle details
    
    .EXAMPLE
    Get-AllWeightRecords | Where-Object { $_.Weight -gt 800 }
    
    Returns all weight records over 800 lbs
    #>
    param()
    
    $query = "SELECT wr.WeightRecordID, wr.CattleID, c.TagNumber, c.Name as CattleName, wr.Weight, wr.WeightUnit, wr.WeightDate, wr.MeasurementMethod, wr.Notes, wr.RecordedBy, wr.CreatedDate FROM WeightRecords wr INNER JOIN Cattle c ON wr.CattleID = c.CattleID ORDER BY wr.WeightDate DESC, wr.CreatedDate DESC"
    
    Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $query
}
