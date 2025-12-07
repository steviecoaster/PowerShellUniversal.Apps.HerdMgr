function Calculate-RateOfGain {
    <#
    .SYNOPSIS
    Calculates rate of gain between two weight records
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
    $startQuery = @"
SELECT WeightRecordID, WeightDate, Weight
FROM WeightRecords
WHERE CattleID = @CattleID AND DATE(WeightDate) <= DATE(@StartDate)
ORDER BY WeightDate DESC
LIMIT 1
"@
    
    $endQuery = @"
SELECT WeightRecordID, WeightDate, Weight
FROM WeightRecords
WHERE CattleID = @CattleID AND DATE(WeightDate) <= DATE(@EndDate)
ORDER BY WeightDate DESC
LIMIT 1
"@
    
    $startRecord = Invoke-SqliteQuery -DataSource $script:DatabasePath -Query $startQuery -SqlParameters @{
        CattleID = $CattleID
        StartDate = $StartDate
    } -As PSObject
    
    $endRecord = Invoke-SqliteQuery -DataSource $script:DatabasePath -Query $endQuery -SqlParameters @{
        CattleID = $CattleID
        EndDate = $EndDate
    } -As PSObject
    
    if (-not $startRecord -or -not $endRecord) {
        Write-Warning "Could not find weight records for the specified date range"
        return $null
    }
    
    # Parse dates from strings
    $startWeightDate = [DateTime]::Parse($startRecord.WeightDate)
    $endWeightDate = [DateTime]::Parse($endRecord.WeightDate)
    
    # Calculate metrics
    $weightGain = $endRecord.Weight - $startRecord.Weight
    $daysBetween = ($endWeightDate - $startWeightDate).Days
    
    if ($daysBetween -le 0) {
        Write-Warning "End date must be after start date"
        return $null
    }
    
    $avgDailyGain = $weightGain / $daysBetween
    
    # Save calculation
    $saveQuery = @"
INSERT INTO RateOfGainCalculations 
(CattleID, StartWeightRecordID, EndWeightRecordID, StartDate, EndDate, StartWeight, EndWeight, TotalWeightGain, DaysBetween, AverageDailyGain)
VALUES (@CattleID, @StartWeightRecordID, @EndWeightRecordID, @StartDate, @EndDate, @StartWeight, @EndWeight, @TotalWeightGain, @DaysBetween, @AverageDailyGain)
"@
    
    Invoke-SqliteQuery -DataSource $script:DatabasePath -Query $saveQuery -SqlParameters @{
        CattleID = $CattleID
        StartWeightRecordID = $startRecord.WeightRecordID
        EndWeightRecordID = $endRecord.WeightRecordID
        StartDate = $startWeightDate.ToString('MM/dd/yyyy HH:mm:ss')
        EndDate = $endWeightDate.ToString('MM/dd/yyyy HH:mm:ss')
        StartWeight = $startRecord.Weight
        EndWeight = $endRecord.Weight
        TotalWeightGain = $weightGain
        DaysBetween = $daysBetween
        AverageDailyGain = $avgDailyGain
    }
    
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