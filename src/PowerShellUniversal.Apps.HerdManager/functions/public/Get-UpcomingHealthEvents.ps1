function Get-UpcomingHealthEvents {
    <#
    .SYNOPSIS
    Gets upcoming health events (vaccinations, follow-ups) that are due
    #>
    param(
        [int]$DaysAhead = 30
    )
    
    $query = @"
SELECT 
    hr.HealthRecordID,
    hr.CattleID,
    c.TagNumber,
    c.Name as CattleName,
    hr.RecordType,
    hr.Title,
    hr.RecordDate as OriginalDate,
    hr.NextDueDate,
    CAST((JULIANDAY(hr.NextDueDate) - JULIANDAY('now')) AS INTEGER) as DaysUntilDue
FROM HealthRecords hr
INNER JOIN Cattle c ON hr.CattleID = c.CattleID
WHERE hr.NextDueDate IS NOT NULL
  AND c.Status = 'Active'
  AND hr.NextDueDate >= DATE('now')
  AND hr.NextDueDate <= DATE('now', '+' || @DaysAhead || ' days')
ORDER BY hr.NextDueDate ASC
"@
    
    Invoke-SqliteQuery -DataSource $script:DatabasePath -Query $query -SqlParameters @{
        DaysAhead = $DaysAhead
    } -As PSObject
}
