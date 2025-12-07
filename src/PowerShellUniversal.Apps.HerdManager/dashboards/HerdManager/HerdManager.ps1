$Navigation = New-UDList -Content {
    New-UDListItem -Label "Home" -Icon (New-UDIcon -Icon Home) -OnClick { Invoke-UDRedirect -Url '/Home' }
    New-UDListItem -Label "🔔 Notifications" -Icon (New-UDIcon -Icon Bell) -OnClick { Invoke-UDRedirect -Url '/notifications' }
    New-UDListItem -Label "Cattle Management" -Icon (New-UDIcon -Icon Cow) -OnClick { Invoke-UDRedirect -Url '/cattle' }
    New-UDListItem -Label "Weight Management" -Icon (New-UDIcon -Icon Weight) -OnClick { Invoke-UDRedirect -Url '/weights' }
    New-UDListItem -Label "Health Records" -Icon (New-UDIcon -Icon Heartbeat) -OnClick { Invoke-UDRedirect -Url '/health' }
    New-UDListItem -Label "Feed Records" -Icon (New-UDIcon -Icon Seedling) -OnClick { Invoke-UDRedirect -Url '/feed-records' }
    New-UDListItem -Label "Rate of Gain" -Icon (New-UDIcon -Icon ChartLine) -OnClick { Invoke-UDRedirect -Url '/rog' }
    New-UDListItem -Label "Animal Report" -Icon (New-UDIcon -Icon FileAlt) -OnClick { Invoke-UDRedirect -Url '/animal-report' }
    New-UDListItem -Label "Reports" -Icon (New-UDIcon -Icon ChartBar) -OnClick { Invoke-UDRedirect -Url '/reports' }
}



$HeaderContent = {
    $dbPath = Join-Path (Get-Module PowerShellUniversal.Apps.HerdManager).ModuleBase -ChildPath 'data\HerdManager.db'
    
    # Notification bell with badge
    New-UDDynamic -Content {
        $overdueQuery = "SELECT COUNT(*) as Count FROM HealthRecords hr INNER JOIN Cattle c ON hr.CattleID = c.CattleID WHERE hr.NextDueDate IS NOT NULL AND hr.NextDueDate < DATE('now') AND c.Status = 'Active'"
        $overdueCount = (Invoke-SqliteQuery -DataSource $dbPath -Query $overdueQuery).Count
        
        if ($overdueCount -gt 0) {
            New-UDBadge -BadgeContent { $overdueCount } -Color error -Content {
                New-UDIconButton -Icon (New-UDIcon -Icon Bell -Size lg) -OnClick { Invoke-UDRedirect -Url '/notifications' }
            }
        }
        else {
            New-UDIconButton -Icon (New-UDIcon -Icon Bell -Size lg) -OnClick { Invoke-UDRedirect -Url '/notifications' }
        }
    } -AutoRefresh -AutoRefreshInterval 300
}.GetNewClosure()

$app = @{
    Title            = '🐄 Herd Manager'
    Pages            = @($homepage, $notifications, $cattleMgmt, $weightMgmt, $healthMgmt, $feedRecords, $rog, $reports, $animalreport)
    Navigation       = $Navigation
    NavigationLayout = 'Temporary'
    HeaderContent    = $HeaderContent
}

New-UDApp @app