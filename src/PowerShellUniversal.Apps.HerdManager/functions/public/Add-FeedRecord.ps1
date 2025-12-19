function Add-FeedRecord {
    <#
    .SYNOPSIS
    Adds a daily feed record for the herd
    
    .DESCRIPTION
    Records daily feed consumption for the entire herd operation.
    Tracks different feed types (haylage, silage, high moisture corn) and total pounds fed.
    Only one feed record can exist per day.
    
    .PARAMETER FeedDate
    Date of the feeding record (required)
    
    .PARAMETER HaylagePounds
    Pounds of haylage fed (optional, defaults to 0)
    
    .PARAMETER SilagePounds
    Pounds of silage fed (optional, defaults to 0)
    
    .PARAMETER HighMoistureCornPounds
    Pounds of high moisture corn fed (optional, defaults to 0)
    
    .PARAMETER TotalPounds
    Total pounds of feed consumed (required)
    If not provided, will be calculated from individual feed types
    
    .PARAMETER Notes
    Additional notes about the feeding (optional)
    
    .PARAMETER RecordedBy
    Name of person recording the feed data (optional)
    
    .OUTPUTS
    None
    
    .EXAMPLE
    Add-FeedRecord -FeedDate (Get-Date) -HaylagePounds 5000 -SilagePounds 8000 -HighMoistureCornPounds 3000 -TotalPounds 16000 -RecordedBy "Ranch Manager"
    
    Records today's feed consumption with breakdown by feed type
    
    .EXAMPLE
    Add-FeedRecord -FeedDate "2024-12-01" -TotalPounds 15500 -Notes "Reduced feed due to weather"
    
    Records a simple total feed amount without breakdown
    
    .EXAMPLE
    Add-FeedRecord -FeedDate (Get-Date) -HaylagePounds 4500 -SilagePounds 7200 -RecordedBy "John Smith"
    
    Records feed with automatic total calculation (11,700 lbs)
    
    .NOTES
    Only one feed record is allowed per day. Attempting to add a duplicate will result in an error.
    If TotalPounds is not provided, it will be calculated from the sum of individual feed types.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [DateTime]$FeedDate,
        
        [Parameter()]
        [decimal]$HaylagePounds = 0,
        
        [Parameter()]
        [decimal]$SilagePounds = 0,
        
        [Parameter()]
        [decimal]$HighMoistureCornPounds = 0,
        
        [Parameter()]
        [decimal]$TotalPounds,
        
        [Parameter()]
        [string]$Notes,
        
        [Parameter()]
        [ValidateSet('Brandon','Jerry','Stephanie')]
        [string]$RecordedBy
    )
    
    # Calculate total if not provided
    if (-not $PSBoundParameters.ContainsKey('TotalPounds')) {
        $TotalPounds = $HaylagePounds + $SilagePounds + $HighMoistureCornPounds
    }
    
    # Validate that total is greater than zero
    if ($TotalPounds -le 0) {
        throw "TotalPounds must be greater than zero"
    }
    
    # Convert values to SQL-safe representations
    $feedDateValue = ConvertTo-SqlValue -Value $FeedDate
    $haylageValue = ConvertTo-SqlValue -Value $HaylagePounds
    $silageValue = ConvertTo-SqlValue -Value $SilagePounds
    $cornValue = ConvertTo-SqlValue -Value $HighMoistureCornPounds
    $totalValue = ConvertTo-SqlValue -Value $TotalPounds
    $notesValue = ConvertTo-SqlValue -Value $Notes
    $recordedByValue = ConvertTo-SqlValue -Value $RecordedBy
    $createdDateValue = ConvertTo-SqlValue -Value (Get-Date)

    $query = "INSERT INTO FeedRecords (FeedDate, HaylagePounds, SilagePounds, HighMoistureCornPounds, TotalPounds, Notes, RecordedBy, CreatedDate) VALUES ($feedDateValue, $haylageValue, $silageValue, $cornValue, $totalValue, $notesValue, $recordedByValue, $createdDateValue)"

    try {
    Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $query
    Write-Verbose "Feed record added for $(Format-Date $FeedDate)"
    }
    catch {
        if ($_.Exception.Message -like "*UNIQUE constraint failed*") {
            throw "A feed record already exists for $(Format-Date $FeedDate). Use Update-FeedRecord to modify existing records."
        }
        else {
            throw $_
        }
    }
}






