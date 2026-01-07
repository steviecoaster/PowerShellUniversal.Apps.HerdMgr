# Notifications Page - Shows upcoming health events and alerts
$notifications = New-UDPage -Name 'Notifications' -Url '/notifications' -Content {
    
    # Page Header
    New-UDCard -Style (Merge-HerdStyle -BaseStyle $HerdStyles.PageHeader.Hero -CustomStyle @{
        backgroundColor = '#f57c00'
        padding         = '30px'
        backgroundImage = 'linear-gradient(135deg, #f57c00 0%, #ff9800 100%)'
    }) -Content {
        New-UDTypography -Text "🔔 Notifications & Alerts" -Variant h4 -Style $HerdStyles.PageHeader.Title
        New-UDTypography -Text "Stay on top of upcoming health events and important reminders" -Variant body1 -Style $HerdStyles.PageHeader.Subtitle
    }
    
    New-UDDynamic -Id 'notifications-content' -Content {
        
        # Get upcoming health events
        $upcomingEvents = Get-UpcomingHealthEvents
        
        # Get overdue events (NextDueDate in the past)
        $overdueQuery = @"
SELECT 
    hr.HealthRecordID,
    hr.CattleID,
    hr.RecordType,
    hr.Title,
    CAST(hr.NextDueDate AS TEXT) as NextDueDate,
    hr.RecordedBy,
    c.TagNumber,
    c.Name as CattleName
FROM HealthRecords hr
INNER JOIN Cattle c ON hr.CattleID = c.CattleID
WHERE hr.NextDueDate IS NOT NULL 
    AND hr.NextDueDate < DATE('now')
    AND c.Status = 'Active'
ORDER BY hr.NextDueDate ASC
"@
        
    $overdueEvents = Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $overdueQuery
        
        # Get upcoming weight check recommendations (no weight in 45+ days)
        $weightCheckQuery = @"
SELECT 
    c.CattleID,
    c.TagNumber,
    c.Name,
    CAST(MAX(w.WeightDate) AS TEXT) as LastWeightDate,
    CAST(julianday('now') - julianday(MAX(w.WeightDate)) AS INTEGER) as DaysSinceWeight
FROM Cattle c
INNER JOIN WeightRecords w ON c.CattleID = w.CattleID
WHERE c.Status = 'Active'
GROUP BY c.CattleID, c.TagNumber, c.Name
HAVING DaysSinceWeight >= 45
ORDER BY DaysSinceWeight DESC
"@
        
    $weightCheckNeeded = Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $weightCheckQuery
        
        # Summary Cards
        New-UDGrid -Container -Spacing 3 -Content {
            
            # Overdue Events
            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -MediumSize 4 -Content {
                New-UDCard -Style @{
                    borderLeft = "4px solid $(if ($overdueEvents.Count -gt 0) { '#d32f2f' } else { '#2e7d32' })"
                    padding    = '20px'
                    cursor     = 'pointer'
                } -OnClick {
                    Set-UDElement -Id 'notification-filter' -Attributes @{value = 'overdue'}
                } -Content {
                    New-UDTypography -Text "⚠️ Overdue" -Variant h6 -Style @{
                        color        = if ($overdueEvents.Count -gt 0) { '#d32f2f' } else { '#2e7d32' }
                        marginBottom = '10px'
                    }
                    New-UDTypography -Text $overdueEvents.Count -Variant h3 -Style @{
                        fontWeight = 'bold'
                        color      = if ($overdueEvents.Count -gt 0) { '#d32f2f' } else { '#2e7d32' }
                    }
                }
            }
            
            # Upcoming Events
            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -MediumSize 4 -Content {
                New-UDCard -Style @{
                    borderLeft = "4px solid $(if ($upcomingEvents.Count -gt 0) { '#f57c00' } else { '#999' })"
                    padding    = '20px'
                    cursor     = 'pointer'
                } -OnClick {
                    Set-UDElement -Id 'notification-filter' -Attributes @{value = 'upcoming'}
                } -Content {
                    New-UDTypography -Text "📅 Upcoming" -Variant h6 -Style @{
                        color        = if ($upcomingEvents.Count -gt 0) { '#f57c00' } else { '#999' }
                        marginBottom = '10px'
                    }
                    New-UDTypography -Text $upcomingEvents.Count -Variant h3 -Style @{
                        fontWeight = 'bold'
                        color      = if ($upcomingEvents.Count -gt 0) { '#f57c00' } else { '#999' }
                    }
                }
            }
            
            # Weight Check Needed
            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -MediumSize 4 -Content {
                New-UDCard -Style @{
                    borderLeft = "4px solid $(if ($weightCheckNeeded.Count -gt 0) { '#1976d2' } else { '#999' })"
                    padding    = '20px'
                    cursor     = 'pointer'
                } -OnClick {
                    Set-UDElement -Id 'notification-filter' -Attributes @{value = 'weight'}
                } -Content {
                    New-UDTypography -Text "⚖️ Weight Check" -Variant h6 -Style @{
                        color        = if ($weightCheckNeeded.Count -gt 0) { '#1976d2' } else { '#999' }
                        marginBottom = '10px'
                    }
                    New-UDTypography -Text $weightCheckNeeded.Count -Variant h3 -Style @{
                        fontWeight = 'bold'
                        color      = if ($weightCheckNeeded.Count -gt 0) { '#1976d2' } else { '#999' }
                    }
                }
            }
        }
        
        New-UDElement -Tag 'br'
        
        # Overdue Events Section
        if ($overdueEvents.Count -gt 0) {
            New-UDCard -Content {
                New-UDTypography -Text "⚠️ Overdue Health Events" -Variant h5 -Style @{
                    color        = '#d32f2f'
                    marginBottom = '15px'
                    fontWeight   = 'bold'
                }
                
                foreach ($evt in $overdueEvents) {
                    $daysOverdue = ([DateTime]::Now - (ConvertFrom-DateString $evt.NextDueDate)).Days
                    
                    New-UDCard -Style @{
                        marginBottom = '15px'
                        borderLeft   = '4px solid #d32f2f'
                    } -Content {
                        New-UDGrid -Container -Content {
                            New-UDGrid -Item -ExtraSmallSize 12 -MediumSize 8 -Content {
                                New-UDTypography -Text $evt.Title -Variant h6 -Style @{
                                    color      = '#d32f2f'
                                    fontWeight = 'bold'
                                }
                                New-UDTypography -Text "Cattle: $($evt.TagNumber)$(if($evt.CattleName){" - $($evt.CattleName)"})" -Variant body1 -Style @{
                                    marginTop = '5px'
                                }
                                New-UDTypography -Text "Type: $($evt.RecordType)" -Variant body2 -Style @{
                                    opacity   = 0.7
                                    marginTop = '3px'
                                }
                                New-UDTypography -Text "⚠️ $daysOverdue days overdue (Due: $(Format-Date $evt.NextDueDate) )" -Variant body2 -Style @{
                                    color     = '#d32f2f'
                                    marginTop = '5px'
                                    fontWeight = 'bold'
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -MediumSize 4 -Content {
                                New-UDButton -Text "View Cattle" -Variant outlined -Style @{
                                    color       = '#2e7d32'
                                    borderColor = '#2e7d32'
                                    marginRight = '10px'
                                } -OnClick {
                                    Invoke-UDRedirect -Url "/cattle?id=$($evt.CattleID)"
                                }
                                New-UDButton -Text "Add Record" -Variant contained -Style @{
                                    backgroundColor = '#2e7d32'
                                    color           = 'white'
                                } -OnClick {
                                    Invoke-UDRedirect -Url "/health"
                                }
                            }
                        }
                    }
                }
            }
            
            New-UDElement -Tag 'br'
        }
        
        # Upcoming Events Section
        if ($upcomingEvents.Count -gt 0) {
            New-UDCard -Content {
                New-UDTypography -Text "📅 Upcoming Health Events (Next 30 Days)" -Variant h5 -Style @{
                    color        = '#f57c00'
                    marginBottom = '15px'
                    fontWeight   = 'bold'
                }
                
                # Add days until column to the data
                $upcomingEventsWithDays = $upcomingEvents | ForEach-Object {
                    $daysUntil = (ConvertFrom-DateString $_.NextDueDate - [DateTime]::Now).Days
                    $_ | Add-Member -MemberType NoteProperty -Name DaysUntil -Value $daysUntil -PassThru -Force
                }
                
                New-UDTable -Data $upcomingEventsWithDays -Columns @(
                    New-UDTableColumn -Property TagNumber -Title "Tag #" -ShowSort
                    New-UDTableColumn -Property CattleName -Title "Name" -ShowSort -Render {
                        if ($EventData.CattleName) {
                            $EventData.CattleName
                        } else {
                            New-UDElement -Tag 'span' -Attributes @{style = @{color = '#999'; fontStyle = 'italic'}} -Content { 'N/A' }
                        }
                    }
                    New-UDTableColumn -Property RecordType -Title "Type" -ShowSort
                    New-UDTableColumn -Property Title -Title "Title" -ShowSort
                    New-UDTableColumn -Property NextDueDate -Title "Due Date" -ShowSort -Render {
                        $fd = Format-Date $EventData.NextDueDate
                        if ($fd -ne '-') { $fd } else { $EventData.NextDueDate -replace ' \d{2}:\d{2}:\d{2}.*$', '' }
                    }
                    New-UDTableColumn -Property DaysUntil -Title "Days Until" -ShowSort -Render {
                        $daysUntil = $EventData.DaysUntil
                        $color = if ($daysUntil -le 7) { '#f57c00' } elseif ($daysUntil -le 14) { '#ff9800' } else { '#ffb74d' }
                        $weight = if ($daysUntil -le 7) { 'bold' } else { 'normal' }
                        New-UDElement -Tag 'span' -Attributes @{style = @{color = $color; fontWeight = $weight}} -Content { "$daysUntil days" }
                    }
                    New-UDTableColumn -Property HealthRecordID -Title "Actions" -Render {
                        New-UDButton -Text "Details" -Size small -Variant outlined -OnClick {
                                Show-UDModal -Content {
                                $evt = $EventData
                                $daysUntil = (ConvertFrom-DateString $evt.NextDueDate - [DateTime]::Now).Days
                                $urgency = if ($daysUntil -le 7) { 'high' } elseif ($daysUntil -le 14) { 'medium' } else { 'low' }
                                $urgencyColor = switch ($urgency) {
                                    'high' { '#f57c00' }
                                    'medium' { '#ff9800' }
                                    'low' { '#ffb74d' }
                                }
                                
                                New-UDCard -Style @{
                                    borderLeft = "4px solid $urgencyColor"
                                    marginBottom = '20px'
                                } -Content {
                                    New-UDTypography -Text $evt.Title -Variant h5 -Style @{
                                        color = $urgencyColor
                                        fontWeight = 'bold'
                                        marginBottom = '15px'
                                    }
                                    
                                    New-UDElement -Tag 'div' -Content {
                                        New-UDTypography -Text "Cattle Information" -Variant h6 -Style @{
                                            marginTop = '10px'
                                            marginBottom = '10px'
                                            color = '#555'
                                        }
                                        New-UDTypography -Text "Tag Number: $($evt.TagNumber)" -Variant body1
                                        if ($evt.CattleName) {
                                            New-UDTypography -Text "Name: $($evt.CattleName)" -Variant body1
                                        }
                                    }
                                    
                                    New-UDElement -Tag 'div' -Content {
                                        New-UDTypography -Text "Health Event Details" -Variant h6 -Style @{
                                            marginTop = '15px'
                                            marginBottom = '10px'
                                            color = '#555'
                                        }
                                        New-UDTypography -Text "Type: $($evt.RecordType)" -Variant body1
                                        New-UDTypography -Text "Due Date: $(Format-Date $evt.NextDueDate)" -Variant body1
                                        New-UDTypography -Text "Days Until: $daysUntil days" -Variant body1 -Style @{
                                            color = $urgencyColor
                                            fontWeight = 'bold'
                                        }
                                        if ($evt.RecordedBy) {
                                            New-UDTypography -Text "Recorded By: $($evt.RecordedBy)" -Variant body2 -Style @{opacity = 0.7; marginTop = '10px'}
                                        }
                                    }
                                }
                                
                                New-UDElement -Tag 'div' -Attributes @{style = @{textAlign = 'right'; marginTop = '20px'}} -Content {
                                    New-UDButton -Text "View Cattle Profile" -Variant outlined -Style @{
                                        color = '#2e7d32'
                                        borderColor = '#2e7d32'
                                        marginRight = '10px'
                                    } -OnClick {
                                        Hide-UDModal
                                        Invoke-UDRedirect -Url "/cattle?id=$($evt.CattleID)"
                                    }
                                    New-UDButton -Text "Go to Health Records" -Variant contained -Style @{
                                        backgroundColor = '#2e7d32'
                                        color = 'white'
                                    } -OnClick {
                                        Hide-UDModal
                                        Invoke-UDRedirect -Url "/health"
                                    }
                                }
                            } -Header {
                                New-UDTypography -Text "📅 Health Event Details" -Variant h5
                            } -Footer {
                                New-UDButton -Text "Close" -OnClick { Hide-UDModal }
                            } -FullWidth -MaxWidth 'md'
                        }
                    }
                ) -Sort -PageSize 10 -Dense -ShowPagination
            }
            
            New-UDElement -Tag 'br'
        }
        
        # Weight Check Recommendations
        if ($weightCheckNeeded.Count -gt 0) {
            New-UDCard -Content {
                New-UDTypography -Text "⚖️ Weight Check Recommendations" -Variant h5 -Style @{
                    color        = '#1976d2'
                    marginBottom = '15px'
                    fontWeight   = 'bold'
                }
                New-UDTypography -Text "The following cattle haven't been weighed in 45+ days" -Variant body2 -Style @{
                    marginBottom = '15px'
                    opacity      = 0.7
                }
                
                foreach ($animal in $weightCheckNeeded) {
                    New-UDCard -Style @{
                        marginBottom = '15px'
                        borderLeft   = '4px solid #1976d2'
                    } -Content {
                        New-UDGrid -Container -Content {
                            New-UDGrid -Item -ExtraSmallSize 12 -MediumSize 8 -Content {
                                New-UDTypography -Text "$($animal.TagNumber)$(if($animal.Name){" - $($animal.Name)"})" -Variant h6 -Style @{
                                    color      = '#1976d2'
                                    fontWeight = 'bold'
                                }
                                            New-UDTypography -Text "Last weighed: $(Format-Date $animal.LastWeightDate)" -Variant body1 -Style @{
                                    marginTop = '5px'
                                }
                                New-UDTypography -Text "⏱️ $($animal.DaysSinceWeight) days since last weight" -Variant body2 -Style @{
                                    color      = '#1976d2'
                                    marginTop  = '5px'
                                    fontWeight = 'bold'
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -MediumSize 4 -Content {
                                New-UDButton -Text "Add Weight" -Variant contained -Style @{
                                    backgroundColor = '#2e7d32'
                                    color           = 'white'
                                } -OnClick {
                                    Invoke-UDRedirect -Url "/weights"
                                }
                            }
                        }
                    }
                }
            }
        }
        
        # No notifications state
        if ($overdueEvents.Count -eq 0 -and $upcomingEvents.Count -eq 0 -and $weightCheckNeeded.Count -eq 0) {
            New-UDCard -Content {
                New-UDElement -Tag 'div' -Attributes @{style = @{textAlign = 'center'; padding = '40px'}} -Content {
                    New-UDTypography -Text "✅" -Variant h2 -Style @{marginBottom = '20px'}
                    New-UDTypography -Text "All Clear!" -Variant h4 -Style @{
                        marginBottom = '10px'
                        fontWeight   = 'bold'
                    }
                    New-UDTypography -Text "No pending notifications or alerts at this time." -Variant body1 -Style @{
                        opacity = 0.7
                    }
                }
            }
        }
    }
}






