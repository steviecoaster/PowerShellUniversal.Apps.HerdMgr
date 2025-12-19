function Get-NotificationCount {
    [CmdletBinding()]
    Param()

    begin {
        $moduleBase = (Get-Module PowerShellUniversal.Apps.HerdManager).ModuleBase
        $dbPath = Join-Path $moduleBase 'data' 'HerdManager.db'
    }
    
    end {
        
        $overdueQuery = "SELECT COUNT(*) as Count FROM HealthRecords hr INNER JOIN Cattle c ON hr.CattleID = c.CattleID WHERE hr.NextDueDate IS NOT NULL AND hr.NextDueDate < DATE('now') AND c.Status = 'Active'"
        $overdueCount = (Invoke-UniversalSQLiteQuery -Path $dbPath -Query $overdueQuery).Count

        return $overdueCount
    }
}