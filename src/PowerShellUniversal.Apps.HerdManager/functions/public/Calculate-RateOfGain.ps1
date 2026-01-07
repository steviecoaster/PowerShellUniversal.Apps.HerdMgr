function Measure-RateOfGain {
    <#
    .SYNOPSIS
    Calculates rate of gain between two weight records
    
    .DESCRIPTION
    Computes the Average Daily Gain (ADG) for an animal between two dates by finding
    the closest weight measurements and calculating the rate of weight increase.
    Returns total weight gain, days elapsed, and ADG in lbs/day.
    
    .PARAMETER CattleID
    Database ID of the cattle to analyze (required)
    
    .PARAMETER StartDate
    Beginning date for the calculation period (required).
    Uses the weight record closest to this date.
    
    .PARAMETER EndDate
    Ending date for the calculation period (required).
    Uses the weight record closest to this date.
    
    .OUTPUTS
    PSCustomObject with the following properties:
    - CattleID: ID of the animal
    - StartWeight: Weight at beginning of period (lbs)
    - EndWeight: Weight at end of period (lbs)
    - StartDate: Actual date of start weight measurement
    - EndDate: Actual date of end weight measurement
    - DaysOnFeed: Number of days between measurements
    - TotalWeightGain: Total pounds gained
    - AverageDailyGain: Weight gain per day (lbs/day)
    
    .EXAMPLE
    Measure-RateOfGain -CattleID 5 -StartDate "2025-09-01" -EndDate "2025-12-01"
    
    Calculates 90-day rate of gain for cattle ID 5
    
    .EXAMPLE
    $cattle = Get-AllCattle
    $cattle | ForEach-Object {
        Measure-RateOfGain -CattleID $_.CattleID -StartDate (Get-Date).AddDays(-120) -EndDate (Get-Date)
    }
    
    Calculates 120-day ADG for all active cattle
    
    .NOTES
    Requires at least two weight records for the specified animal within the date range.
    The function finds the closest weight records to the specified dates, so exact matches are not required.
    #>
    param(
        [Parameter(Mandatory)]
        [int]$CattleID,
        
        [Parameter(Mandatory)]
        [DateTime]$StartDate,
        
        [Parameter(Mandatory)]
        [DateTime]$EndDate
    )
    
    # Get the weight records closest to the specified dates
    # If start date is before all records, use the earliest weight
    # If end date is after all records, use the latest weight
    $startDateValue = ConvertTo-SqlValue -Value ($StartDate.ToString('yyyy-MM-dd'))
    $endDateValue = ConvertTo-SqlValue -Value ($EndDate.ToString('yyyy-MM-dd'))
    
    $startQuery = @"
SELECT WeightRecordID, WeightDate, Weight
FROM WeightRecords
WHERE CattleID = $CattleID AND DATE(WeightDate) <= DATE($startDateValue)
ORDER BY WeightDate DESC
LIMIT 1
"@
    
    # Fallback: get earliest weight if no weight found on or before start date
    $earliestQuery = @"
SELECT WeightRecordID, WeightDate, Weight
FROM WeightRecords
WHERE CattleID = $CattleID
ORDER BY WeightDate ASC
LIMIT 1
"@
    
    $endQuery = @"
SELECT WeightRecordID, WeightDate, Weight
FROM WeightRecords
WHERE CattleID = $CattleID AND DATE(WeightDate) <= DATE($endDateValue)
ORDER BY WeightDate DESC
LIMIT 1
"@
    
    # Try to get weight on or before start date
    $startRecord = Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $startQuery 
    
    # If no weight found before/on start date, use the earliest available weight
    if (-not $startRecord) {
        $startRecord = Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $earliestQuery 
        
        if ($startRecord) {
            Write-Verbose "No weight found on or before $(Format-Date $StartDate). Using earliest weight from $(Format-Date $startRecord.WeightDate)"
        }
    }
    
    $endRecord = Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $endQuery 
    
    if (-not $startRecord -or -not $endRecord) {
        Write-Warning "Could not find weight records for the specified date range"
        return $null
    }
    
    # Parse dates from strings
    $startWeightDate = ConvertFrom-DateString $startRecord.WeightDate
    $endWeightDate = ConvertFrom-DateString $endRecord.WeightDate
    
    # Calculate metrics
    $weightGain = $endRecord.Weight - $startRecord.Weight
    $daysBetween = ($endWeightDate - $startWeightDate).Days
    
    if ($daysBetween -le 0) {
        Write-Warning "End date must be after start date"
        return $null
    }
    
    $avgDailyGain = $weightGain / $daysBetween
    
    # Save calculation - prepare values for SQL
    $startWeightRecordId = $startRecord.WeightRecordID
    $endWeightRecordId = $endRecord.WeightRecordID
    $startDateStr = ConvertTo-SqlValue -Value ($startWeightDate.ToString('yyyy-MM-dd HH:mm:ss'))
    $endDateStr = ConvertTo-SqlValue -Value ($endWeightDate.ToString('yyyy-MM-dd HH:mm:ss'))
    $startWeight = $startRecord.Weight
    $endWeight = $endRecord.Weight
    
    $saveQuery = @"
INSERT INTO RateOfGainCalculations 
(CattleID, StartWeightRecordID, EndWeightRecordID, StartDate, EndDate, StartWeight, EndWeight, TotalWeightGain, DaysBetween, AverageDailyGain)
VALUES ($CattleID, $startWeightRecordId, $endWeightRecordId, $startDateStr, $endDateStr, $startWeight, $endWeight, $weightGain, $daysBetween, $avgDailyGain)
"@
    
    Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $saveQuery 
    
    # Return calculation results
    return [PSCustomObject]@{
        CattleID = $CattleID
        StartDate = $startWeightDate
        EndDate = $endWeightDate
        StartWeight = $startRecord.Weight
        EndWeight = $endRecord.Weight
        TotalWeightGain = [Math]::Round($weightGain, 2)
        DaysBetween = $daysBetween
        AverageDailyGain = [Math]::Round($avgDailyGain, 4)
        MonthlyGain = [Math]::Round($avgDailyGain * 30, 2)
    }
}





