function Get-FeedTonnageReport {
    <#
    .SYNOPSIS
    Generates feed tonnage reports by ingredient over time
    
    .DESCRIPTION
    Analyzes feed consumption and generates tonnage reports per ingredient.
    Can break down by month or provide totals for a date range.
    Supports both legacy column-based and new JSON-based feed records.
    
    .PARAMETER StartDate
    Start date for the report range
    
    .PARAMETER EndDate
    End date for the report range (defaults to today)
    
    .PARAMETER GroupByMonth
    Break down results by month
    
    .PARAMETER IngredientName
    Filter to specific ingredient (optional)
    
    .EXAMPLE
    Get-FeedTonnageReport -StartDate "2025-01-01" -EndDate "2025-12-31"
    
    Gets annual tonnage for all ingredients
    
    .EXAMPLE
    Get-FeedTonnageReport -StartDate "2025-01-01" -GroupByMonth
    
    Gets monthly breakdown from start date to present
    
    .EXAMPLE
    Get-FeedTonnageReport -StartDate "2025-01-01" -IngredientName "Corn Silage" -GroupByMonth
    
    Gets monthly tonnage for corn silage only
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [DateTime]$StartDate,
        
        [Parameter()]
        [DateTime]$EndDate = (Get-Date),
        
        [Parameter()]
        [switch]$GroupByMonth,
        
        [Parameter()]
        [string]$IngredientName
    )
    
    $startDateValue = ConvertTo-SqlValue -Value $StartDate
    $endDateValue = ConvertTo-SqlValue -Value $EndDate
    
    # Get all feed records in range
    $query = @"
SELECT FeedRecordID, FeedDate, 
       HaylagePounds, SilagePounds, HighMoistureCornPounds,
       IngredientAmounts, TotalPounds
FROM FeedRecords
WHERE FeedDate BETWEEN $startDateValue AND $endDateValue
ORDER BY FeedDate
"@
    
    $records = Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $query
    
    if (-not $records) {
        Write-Verbose "No feed records found in date range"
        $null
    }
    
    # Get active recipe ingredients for reference
    $recipe = Get-FeedRecipe -Active -IncludeIngredients
    
    # Build tonnage data
    $tonnageData = @{}
    
    foreach ($record in $records) {
        $periodKey = if ($GroupByMonth) {
            ([DateTime]$record.FeedDate).ToString('yyyy-MM')
        }
        else {
            'Total'
        }
        
        if (-not $tonnageData.ContainsKey($periodKey)) {
            $tonnageData[$periodKey] = @{}
        }
        
        # Parse ingredients from JSON if available, otherwise use legacy columns
        if ($record.IngredientAmounts) {
            try {
                $ingredients = $record.IngredientAmounts | ConvertFrom-Json
                foreach ($ing in $ingredients.PSObject.Properties) {
                    $ingName = $ing.Name
                    $amount = [decimal]$ing.Value
                    
                    if (-not $IngredientName -or $ingName -eq $IngredientName) {
                        if (-not $tonnageData[$periodKey].ContainsKey($ingName)) {
                            $tonnageData[$periodKey][$ingName] = 0
                        }
                        $tonnageData[$periodKey][$ingName] += $amount
                    }
                }
            }
            catch {
                Write-Warning "Failed to parse IngredientAmounts for record $($record.FeedRecordID)"
            }
        }
        else {
            # Legacy columns mapping
            $legacyMapping = @{
                'Haylage'            = $record.HaylagePounds
                'Corn Silage'        = $record.SilagePounds
                'High Moisture Corn' = $record.HighMoistureCornPounds
            }
            
            foreach ($legacyIng in $legacyMapping.GetEnumerator()) {
                $ingName = $legacyIng.Key
                $amount = [decimal]$legacyIng.Value
                
                if ($amount -gt 0 -and (-not $IngredientName -or $ingName -eq $IngredientName)) {
                    if (-not $tonnageData[$periodKey].ContainsKey($ingName)) {
                        $tonnageData[$periodKey][$ingName] = 0
                    }
                    $tonnageData[$periodKey][$ingName] += $amount
                }
            }
        }
    }
    
    # Convert to output objects
    $results = @()
    
    foreach ($period in ($tonnageData.Keys | Sort-Object)) {
        foreach ($ingredient in ($tonnageData[$period].Keys | Sort-Object)) {
            $pounds = $tonnageData[$period][$ingredient]
            $tons = [Math]::Round($pounds / 2000, 2)
            
            $result = [PSCustomObject]@{
                Period      = $period
                Ingredient  = $ingredient
                TotalPounds = $pounds
                TotalTons   = $tons
            }
            
            # Add month name if grouping by month
            if ($GroupByMonth -and $period -ne 'Total') {
                $monthDate = [DateTime]::ParseExact($period, 'yyyy-MM', $null)
                $result | Add-Member -MemberType NoteProperty -Name MonthName -Value $monthDate.ToString('MMMM yyyy')
            }
            
            $results += $result
        }
    }
    
    $results
}
