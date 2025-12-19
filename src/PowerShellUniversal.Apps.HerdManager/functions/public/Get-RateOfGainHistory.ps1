function Get-RateOfGainHistory {
    <#
    .SYNOPSIS
    Gets historical rate of gain calculations
    
    .DESCRIPTION
    Retrieves saved rate of gain calculations from the database. Can return calculations
    for a specific animal or all animals, limited to the most recent calculations.
    
    .PARAMETER CattleID
    Filter to calculations for a specific animal. If not provided, returns calculations
    for all cattle.
    
    .PARAMETER Limit
    Maximum number of records to return. Default is 50 most recent calculations.
    
    .OUTPUTS
    Rate of gain records with properties:
    TagNumber, Name (CattleName), StartDate, EndDate, StartWeight, EndWeight,
    DaysOnFeed, TotalWeightGain, AverageDailyGain, CalculationDate
    
    .EXAMPLE
    Get-RateOfGainHistory -CattleID 7
    
    Returns up to 50 most recent ROG calculations for cattle ID 7
    
    .EXAMPLE
    Get-RateOfGainHistory -Limit 10
    
    Returns the 10 most recent ROG calculations across all cattle
    
    .EXAMPLE
    Get-RateOfGainHistory -CattleID 12 -Limit 5
    
    Returns the 5 most recent calculations for cattle ID 12
    
    .EXAMPLE
    Get-RateOfGainHistory | Where-Object { $_.AverageDailyGain -gt 2.0 }
    
    Returns all calculations where ADG exceeds 2.0 lbs/day
    
    .NOTES
    Historical calculations are stored when using the Calculate-RateOfGain function.
    Results are ordered by CalculationDate DESC (most recent first).
    #>
    param(
        [int]$CattleID,
        [int]$Limit = 50
    )
    
    if ($CattleID) {
        $query = "SELECT c.TagNumber, c.Name, c.Gender, c.OriginFarm, rog.StartDate, rog.EndDate, rog.StartWeight, rog.EndWeight, rog.TotalWeightGain, rog.DaysBetween, rog.AverageDailyGain, ROUND(rog.AverageDailyGain * 30, 2) AS MonthlyGain, rog.CalculatedDate FROM RateOfGainCalculations rog JOIN Cattle c ON rog.CattleID = c.CattleID WHERE rog.CattleID = $CattleID ORDER BY rog.CalculatedDate DESC LIMIT $Limit"
        Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $query 
    } else {
        $query = "SELECT c.TagNumber, c.Name, c.Gender, c.OriginFarm, rog.StartDate, rog.EndDate, rog.StartWeight, rog.EndWeight, rog.TotalWeightGain, rog.DaysBetween, rog.AverageDailyGain, ROUND(rog.AverageDailyGain * 30, 2) AS MonthlyGain, rog.CalculatedDate FROM RateOfGainCalculations rog JOIN Cattle c ON rog.CattleID = c.CattleID ORDER BY rog.CalculatedDate DESC LIMIT $Limit"
        Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $query 
    }
}





