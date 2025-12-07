function Get-RateOfGainHistory {
    <#
    .SYNOPSIS
    Gets historical rate of gain calculations
    #>
    param(
        [int]$CattleID,
        [int]$Limit = 50
    )
    
    if ($CattleID) {
        $query = @"
SELECT 
    c.TagNumber,
    c.Name,
    CAST(rog.StartDate AS TEXT) as StartDate,
    CAST(rog.EndDate AS TEXT) as EndDate,
    rog.StartWeight,
    rog.EndWeight,
    rog.TotalWeightGain,
    rog.DaysBetween,
    rog.AverageDailyGain,
    ROUND(rog.AverageDailyGain * 30, 2) AS MonthlyGain,
    CAST(rog.CalculatedDate AS TEXT) as CalculatedDate
FROM RateOfGainCalculations rog
JOIN Cattle c ON rog.CattleID = c.CattleID
WHERE rog.CattleID = @CattleID
ORDER BY rog.CalculatedDate DESC
LIMIT @Limit
"@
        Invoke-SqliteQuery -DataSource $script:DatabasePath -Query $query -SqlParameters @{
            CattleID = $CattleID
            Limit = $Limit
        } -As PSObject
    } else {
        $query = "SELECT * FROM RecentRateOfGain LIMIT @Limit"
        Invoke-SqliteQuery -DataSource $script:DatabasePath -Query $query -SqlParameters @{
            Limit = $Limit
        } -As PSObject
    }
}