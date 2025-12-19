function Remove-WeightRecord {
    <#
    .SYNOPSIS
    Deletes a weight record from the database
    
    .DESCRIPTION
    Removes a weight record by its ID
    
    .PARAMETER WeightRecordID
    The ID of the weight record to delete
    
    .EXAMPLE
    Remove-WeightRecord -WeightRecordID 5
    
    Deletes weight record with ID 5
    #>
    param(
        [Parameter(Mandatory)]
        [int]$WeightRecordID
    )
    
    $query = "DELETE FROM WeightRecords WHERE WeightRecordID = $WeightRecordID"
    Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $query
}
