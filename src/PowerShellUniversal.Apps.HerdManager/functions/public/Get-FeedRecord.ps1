function Get-FeedRecord {
    <#
    .SYNOPSIS
    Retrieves feed records from the database
    
    .DESCRIPTION
    Gets daily feed consumption records for the herd.
    Can retrieve records by ID, date, date range, or all records.
    
    .PARAMETER FeedRecordID
    Specific feed record ID to retrieve
    
    .PARAMETER FeedDate
    Retrieve feed record for a specific date
    
    .PARAMETER StartDate
    Start date for date range query (use with EndDate)
    
    .PARAMETER EndDate
    End date for date range query (use with StartDate)
    
    .PARAMETER DaysBack
    Get feed records for the last N days (e.g., -DaysBack 30 for last 30 days)
    
    .PARAMETER All
    Retrieve all feed records (ordered by date descending)
    
    .OUTPUTS
    Array of feed record objects with properties:
    FeedRecordID, FeedDate, HaylagePounds, SilagePounds, HighMoistureCornPounds,
    TotalPounds, Notes, RecordedBy, CreatedDate
    
    .EXAMPLE
    Get-FeedRecord -FeedRecordID 15
    
    Gets a specific feed record by ID
    
    .EXAMPLE
    Get-FeedRecord -FeedDate "2024-12-01"
    
    Gets the feed record for December 1st, 2024
    
    .EXAMPLE
    Get-FeedRecord -StartDate "2024-11-01" -EndDate "2024-11-30"
    
    Gets all feed records for November 2024
    
    .EXAMPLE
    Get-FeedRecord -DaysBack 7
    
    Gets feed records for the last 7 days
    
    .EXAMPLE
    Get-FeedRecord -All | Select-Object -First 10
    
    Gets the 10 most recent feed records
    
    .NOTES
    Records are returned in descending date order (most recent first) by default.
    #>
    [CmdletBinding(DefaultParameterSetName = 'All')]
    param(
        [Parameter(ParameterSetName = 'ById', Mandatory)]
        [int]$FeedRecordID,
        
        [Parameter(ParameterSetName = 'ByDate', Mandatory)]
        [DateTime]$FeedDate,
        
        [Parameter(ParameterSetName = 'ByDateRange', Mandatory)]
        [DateTime]$StartDate,
        
        [Parameter(ParameterSetName = 'ByDateRange', Mandatory)]
        [DateTime]$EndDate,
        
        [Parameter(ParameterSetName = 'ByDaysBack', Mandatory)]
        [int]$DaysBack,
        
        [Parameter(ParameterSetName = 'All')]
        [switch]$All
    )
    
    switch ($PSCmdlet.ParameterSetName) {
        'ById' {
            $query = @"
SELECT FeedRecordID, FeedDate, HaylagePounds, SilagePounds, HighMoistureCornPounds, 
       TotalPounds, Notes, RecordedBy, CreatedDate
FROM FeedRecords
WHERE FeedRecordID = $FeedRecordID
"@
        }
        
        'ByDate' {
            $feedDateValue = ConvertTo-SqlValue -Value ($FeedDate.ToString('yyyy-MM-dd'))
            $query = @"
SELECT FeedRecordID, FeedDate, HaylagePounds, SilagePounds, HighMoistureCornPounds, 
       TotalPounds, Notes, RecordedBy, CreatedDate
FROM FeedRecords
WHERE DATE(FeedDate) = DATE($feedDateValue)
"@
        }
        
        'ByDateRange' {
            $startDateValue = ConvertTo-SqlValue -Value ($StartDate.ToString('yyyy-MM-dd'))
            $endDateValue = ConvertTo-SqlValue -Value ($EndDate.ToString('yyyy-MM-dd'))
            $query = @"
SELECT FeedRecordID, FeedDate, HaylagePounds, SilagePounds, HighMoistureCornPounds, 
       TotalPounds, Notes, RecordedBy, CreatedDate
FROM FeedRecords
WHERE DATE(FeedDate) BETWEEN DATE($startDateValue) AND DATE($endDateValue)
ORDER BY FeedDate DESC
"@
        }
        
        'ByDaysBack' {
            $cutoffDate = (Get-Date).AddDays(-$DaysBack)
            $cutoffDateValue = ConvertTo-SqlValue -Value ($cutoffDate.ToString('yyyy-MM-dd'))
            $query = @"
SELECT FeedRecordID, FeedDate, HaylagePounds, SilagePounds, HighMoistureCornPounds, 
       TotalPounds, Notes, RecordedBy, CreatedDate
FROM FeedRecords
WHERE DATE(FeedDate) >= DATE($cutoffDateValue)
ORDER BY FeedDate DESC
"@
        }
        
        'All' {
            $query = @"
SELECT FeedRecordID, FeedDate, HaylagePounds, SilagePounds, HighMoistureCornPounds, 
       TotalPounds, Notes, RecordedBy, CreatedDate
FROM FeedRecords
ORDER BY FeedDate DESC
"@
        }
    }
    
    $results = Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $query
    
    if ($results) {
        return $results
    }
    else {
        Write-Verbose "No feed records found matching the specified criteria"
        return $null
    }
}






