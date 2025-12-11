function Remove-HealthRecord {
    <#
    .SYNOPSIS
    Removes a health record
    
    .DESCRIPTION
    Permanently deletes a health record from the database. This action cannot be undone.
    
    .PARAMETER HealthRecordID
    Database ID of the health record to remove (required)
    
    .EXAMPLE
    Remove-HealthRecord -HealthRecordID 45
    
    Permanently deletes health record ID 45
    
    .EXAMPLE
    $oldRecords = Get-HealthRecords | Where-Object { $_.RecordDate -lt (Get-Date).AddYears(-5) }
    $oldRecords | ForEach-Object { Remove-HealthRecord -HealthRecordID $_.HealthRecordID }
    
    Removes all health records older than 5 years
    
    .NOTES
    WARNING: This permanently deletes the record and cannot be undone.
    Consider whether historical health data should be preserved for record-keeping.
    #>
    param(
        [Parameter(Mandatory)]
        [int]
        $HealthRecordID
    )
    
    $query = "DELETE FROM HealthRecords WHERE HealthRecordID = @HealthRecordID"
    
    Invoke-SqliteQuery -DataSource $script:DatabasePath -Query $query -SqlParameters @{
        HealthRecordID = $HealthRecordID
    }
}
