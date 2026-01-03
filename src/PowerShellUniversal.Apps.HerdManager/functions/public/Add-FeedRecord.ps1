function Add-FeedRecord {
    <#
    .SYNOPSIS
    Adds a daily feed record for the herd
    
    .DESCRIPTION
    Records daily feed consumption for the entire herd operation.
    Supports both legacy column-based ingredients and new dynamic recipe-based ingredients.
    Only one feed record can exist per day.
    
    .PARAMETER FeedDate
    Date of the feeding record (required)
    
    .PARAMETER IngredientAmounts
    Hashtable of ingredient names and amounts (supports dynamic recipes)
    Example: @{ 'Corn Silage' = 5000; 'High Moisture Corn' = 3000 }
    
    .PARAMETER HaylagePounds
    Pounds of haylage fed (legacy parameter, optional, defaults to 0)
    
    .PARAMETER SilagePounds
    Pounds of silage fed (legacy parameter, optional, defaults to 0)
    
    .PARAMETER HighMoistureCornPounds
    Pounds of high moisture corn fed (legacy parameter, optional, defaults to 0)
    
    .PARAMETER TotalPounds
    Total pounds of feed consumed (optional)
    If not provided, will be calculated from ingredient amounts
    
    .PARAMETER Notes
    Additional notes about the feeding (optional)
    
    .PARAMETER RecordedBy
    Name of person recording the feed data (optional)
    
    .OUTPUTS
    None
    
    .EXAMPLE
    Add-FeedRecord -FeedDate (Get-Date) -IngredientAmounts @{ 'Corn Silage' = 5000; 'Supplement' = 200 } -RecordedBy "Ranch Manager"
    
    Records today's feed using dynamic recipe ingredients
    
    .EXAMPLE
    Add-FeedRecord -FeedDate (Get-Date) -HaylagePounds 5000 -SilagePounds 8000 -HighMoistureCornPounds 3000 -RecordedBy "Ranch Manager"
    
    Records today's feed using legacy parameters (backward compatible)
    
    .NOTES
    Only one feed record is allowed per day. Attempting to add a duplicate will result in an error.
    New records should use -IngredientAmounts for flexibility with recipe changes.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [DateTime]$FeedDate,
        
        [Parameter()]
        [hashtable]$IngredientAmounts,
        
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
        if ($IngredientAmounts) {
            # Sum from dynamic ingredients
            $TotalPounds = ($IngredientAmounts.Values | Measure-Object -Sum).Sum
        }
        else {
            # Sum from legacy parameters
            $TotalPounds = $HaylagePounds + $SilagePounds + $HighMoistureCornPounds
        }
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
    
    # Convert ingredient amounts to JSON if provided
    $ingredientAmountsValue = 'NULL'
    if ($IngredientAmounts) {
        $jsonString = $IngredientAmounts | ConvertTo-Json -Compress
        $ingredientAmountsValue = ConvertTo-SqlValue -Value $jsonString
        Write-Verbose "IngredientAmounts JSON: $jsonString"
        Write-Verbose "IngredientAmounts SQL Value: $ingredientAmountsValue"
    }

    $query = "INSERT INTO FeedRecords (FeedDate, HaylagePounds, SilagePounds, HighMoistureCornPounds, TotalPounds, IngredientAmounts, Notes, RecordedBy, CreatedDate) VALUES ($feedDateValue, $haylageValue, $silageValue, $cornValue, $totalValue, $ingredientAmountsValue, $notesValue, $recordedByValue, $createdDateValue)"

    Write-Verbose "SQL Query: $query"
    
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






