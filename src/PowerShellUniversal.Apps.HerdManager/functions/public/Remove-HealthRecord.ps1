function Remove-HealthRecord {
    <#
    .SYNOPSIS
    Removes a health record
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
