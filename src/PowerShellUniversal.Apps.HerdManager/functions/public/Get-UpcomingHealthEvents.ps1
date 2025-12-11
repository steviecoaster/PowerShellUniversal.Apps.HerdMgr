function Get-UpcomingHealthEvents {
    <#
    .SYNOPSIS
    Gets upcoming health events (vaccinations, follow-ups) that are due
    
    .DESCRIPTION
    Retrieves health records that have upcoming due dates within a specified time window.
    Useful for scheduling and ensuring animals receive timely follow-up care.
    
    .PARAMETER DaysAhead
    Number of days into the future to check for upcoming events. Default is 30 days.
    
    .OUTPUTS
    Health event records with properties:
    HealthRecordID, CattleID, TagNumber, CattleName, RecordType, Title,
    OriginalDate, NextDueDate, DaysUntilDue
    
    .EXAMPLE
    Get-UpcomingHealthEvents
    
    Returns all health events due in the next 30 days
    
    .EXAMPLE
    Get-UpcomingHealthEvents -DaysAhead 7
    
    Returns health events due in the next week
    
    .EXAMPLE
    Get-UpcomingHealthEvents -DaysAhead 60 | Where-Object { $_.RecordType -eq 'Vaccination' }
    
    Returns upcoming vaccinations due in the next 60 days
    
    .EXAMPLE
    $upcoming = Get-UpcomingHealthEvents -DaysAhead 14
    $upcoming | Sort-Object DaysUntilDue | Format-Table TagNumber, CattleName, Title, DaysUntilDue
    
    Displays upcoming events for the next 2 weeks, sorted by urgency
    
    .NOTES
    Only returns records where NextDueDate is set and falls within the specified timeframe.
    Results include DaysUntilDue for easy prioritization of care tasks.
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
