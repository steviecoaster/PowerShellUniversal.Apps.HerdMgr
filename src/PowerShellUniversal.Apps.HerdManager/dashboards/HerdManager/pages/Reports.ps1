$reports = New-UDPage -Name 'Reports' -Url '/reports' -Content {
    
    # Page Header
    New-UDCard -Style @{
        backgroundColor = '#2e7d32'
        color           = 'white'
        padding         = '30px'
        marginBottom    = '30px'
        borderRadius    = '8px'
        backgroundImage = 'linear-gradient(135deg, #2e7d32 0%, #66bb6a 100%)'
        boxShadow       = '0 4px 6px rgba(0,0,0,0.1)'
    } -Content {
        New-UDTypography -Text "📊 Herd Reports & Analytics" -Variant h4 -Style @{
            fontWeight   = 'bold'
            marginBottom = '10px'
        }
        New-UDTypography -Text "Comprehensive insights into your herd's performance, health, and finances" -Variant body1 -Style @{
            opacity = '0.9'
        }
    }
    
    # Report Selector Tabs
    New-UDTabs -Tabs {
        
        # Tab 1: Herd Overview Dashboard
        New-UDTab -Text "Herd Overview" -Icon (New-UDIcon -Icon ChartPie) -Content {
            New-UDDynamic -Content {
                
                # Get all cattle data
                $allCattle = Get-AllCattle
                $activeCattle = $allCattle | Where-Object { $_.Status -eq 'Active' }
                
                # Basic Stats Cards
                New-UDGrid -Container -Spacing 3 -Content {
                    
                    # Total Active Cattle
                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -MediumSize 3 -Content {
                        New-UDCard -Style @{
                            backgroundColor = '#e8f5e9'
                            borderLeft      = '4px solid #2e7d32'
                            padding         = '20px'
                        } -Content {
                            New-UDTypography -Text "🐄 Active Cattle" -Variant h6 -Style @{color = '#2e7d32'; marginBottom = '10px'}
                            New-UDTypography -Text $activeCattle.Count -Variant h3 -Style @{fontWeight = 'bold'; color = '#2e7d32'}
                        }
                    }
                    
                    # Steers
                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -MediumSize 3 -Content {
                        $steers = ($activeCattle | Where-Object { $_.Gender -eq 'Steer' }).Count
                        New-UDCard -Style @{
                            backgroundColor = '#e3f2fd'
                            borderLeft      = '4px solid #1976d2'
                            padding         = '20px'
                        } -Content {
                            New-UDTypography -Text "🐂 Steers" -Variant h6 -Style @{color = '#1976d2'; marginBottom = '10px'}
                            New-UDTypography -Text $steers -Variant h3 -Style @{fontWeight = 'bold'; color = '#1976d2'}
                        }
                    }
                    
                    # Heifers
                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -MediumSize 3 -Content {
                        $heifers = ($activeCattle | Where-Object { $_.Gender -eq 'Heifer' }).Count
                        New-UDCard -Style @{
                            backgroundColor = '#fce4ec'
                            borderLeft      = '4px solid #c2185b'
                            padding         = '20px'
                        } -Content {
                            New-UDTypography -Text "🐮 Heifers" -Variant h6 -Style @{color = '#c2185b'; marginBottom = '10px'}
                            New-UDTypography -Text $heifers -Variant h3 -Style @{fontWeight = 'bold'; color = '#c2185b'}
                        }
                    }
                    
                    # Average Weight
                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -MediumSize 3 -Content {
                        $avgWeight = ($activeCattle | Where-Object { $_.LatestWeight } | Measure-Object -Property LatestWeight -Average).Average
                        New-UDCard -Style @{
                            backgroundColor = '#fff3e0'
                            borderLeft      = '4px solid #f57c00'
                            padding         = '20px'
                        } -Content {
                            New-UDTypography -Text "⚖️ Avg Weight" -Variant h6 -Style @{color = '#f57c00'; marginBottom = '10px'}
                            New-UDTypography -Text "$([Math]::Round($avgWeight, 0)) lbs" -Variant h3 -Style @{fontWeight = 'bold'; color = '#f57c00'}
                        }
                    }
                }
                
                New-UDElement -Tag 'br'
                
                # Charts Row
                New-UDGrid -Container -Spacing 3 -Content {
                    
                    # Status Breakdown
                    New-UDGrid -Item -ExtraSmallSize 12 -MediumSize 6 -Content {
                        New-UDCard -Content {
                            New-UDTypography -Text "Cattle by Status" -Variant h6 -Style @{marginBottom = '15px'; color = '#2e7d32'}
                            
                            New-UDElement -Tag 'div' -Attributes @{style = @{maxHeight = '300px'}} -Content {
                                $statusGroups = $allCattle | Group-Object -Property Status
                                $statusData = $statusGroups | ForEach-Object {
                                    [PSCustomObject]@{
                                        Status = $_.Name
                                        Count  = $_.Count
                                    }
                                }
                                
                                New-UDChartJS -Type doughnut -Data $statusData -DataProperty Count -LabelProperty Status -Options @{
                                    maintainAspectRatio = $false
                                    plugins = @{
                                        legend = @{
                                            position = 'bottom'
                                        }
                                    }
                                } -BackgroundColor @('#2e7d32', '#1976d2', '#d32f2f', '#f57c00')
                            }
                        }
                    }
                    
                    # Origin Farm Breakdown
                    New-UDGrid -Item -ExtraSmallSize 12 -MediumSize 6 -Content {
                        New-UDCard -Content {
                            New-UDTypography -Text "Cattle by Origin Farm" -Variant h6 -Style @{marginBottom = '15px'; color = '#2e7d32'}
                            
                            New-UDElement -Tag 'div' -Attributes @{style = @{maxHeight = '300px'}} -Content {
                                $farmGroups = $activeCattle | Group-Object -Property OriginFarm
                                $farmData = $farmGroups | ForEach-Object {
                                    [PSCustomObject]@{
                                        Farm  = $_.Name
                                        Count = $_.Count
                                    }
                                } | Sort-Object -Property Count -Descending
                                
                                New-UDChartJS -Type bar -Data $farmData -DataProperty Count -LabelProperty Farm -Options @{
                                    maintainAspectRatio = $false
                                    indexAxis = 'y'
                                    scales = @{
                                        x = @{
                                            beginAtZero = $true
                                        }
                                    }
                                } -BackgroundColor @('#2e7d32')
                            }
                        }
                    }
                }
            }
        }
        
        # Tab 2: Rate of Gain Summary
        New-UDTab -Text "Rate of Gain" -Icon (New-UDIcon -Icon ChartLine) -Content {
            New-UDDynamic -Content {
                
                $rogQuery = @"
SELECT 
    c.CattleID,
    c.TagNumber,
    c.Name,
    c.OriginFarm,
    c.Gender,
    rog.AverageDailyGain,
    CAST(rog.StartDate AS TEXT) as StartDate,
    CAST(rog.EndDate AS TEXT) as EndDate,
    rog.TotalWeightGain,
    rog.DaysBetween
FROM RateOfGainCalculations rog
INNER JOIN Cattle c ON rog.CattleID = c.CattleID
WHERE c.Status = 'Active'
ORDER BY rog.EndDate DESC
"@
                
                $rogData = Invoke-SqliteQuery -DataSource $script:DatabasePath -Query $rogQuery -As PSObject
                
                if ($rogData -and $rogData.Count -gt 0) {
                    
                    # Summary Stats
                    $avgADG = ($rogData | Measure-Object -Property AverageDailyGain -Average).Average
                    $maxADG = ($rogData | Measure-Object -Property AverageDailyGain -Maximum).Maximum
                    $minADG = ($rogData | Measure-Object -Property AverageDailyGain -Minimum).Minimum
                    
                    New-UDGrid -Container -Spacing 3 -Content {
                        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 4 -Content {
                            New-UDCard -Style @{
                                backgroundColor = '#e8f5e9'
                                borderLeft      = '4px solid #2e7d32'
                                padding         = '20px'
                            } -Content {
                                New-UDTypography -Text "Average ADG" -Variant h6 -Style @{color = '#2e7d32'; marginBottom = '10px'}
                                New-UDTypography -Text "$([Math]::Round($avgADG, 2)) lbs/day" -Variant h4 -Style @{fontWeight = 'bold'; color = '#2e7d32'}
                            }
                        }
                        
                        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 4 -Content {
                            New-UDCard -Style @{
                                backgroundColor = '#e3f2fd'
                                borderLeft      = '4px solid #1976d2'
                                padding         = '20px'
                            } -Content {
                                New-UDTypography -Text "Top Performer" -Variant h6 -Style @{color = '#1976d2'; marginBottom = '10px'}
                                New-UDTypography -Text "$([Math]::Round($maxADG, 2)) lbs/day" -Variant h4 -Style @{fontWeight = 'bold'; color = '#1976d2'}
                            }
                        }
                        
                        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 4 -Content {
                            New-UDCard -Style @{
                                backgroundColor = '#fff3e0'
                                borderLeft      = '4px solid #f57c00'
                                padding         = '20px'
                            } -Content {
                                New-UDTypography -Text "Needs Attention" -Variant h6 -Style @{color = '#f57c00'; marginBottom = '10px'}
                                New-UDTypography -Text "$([Math]::Round($minADG, 2)) lbs/day" -Variant h4 -Style @{fontWeight = 'bold'; color = '#f57c00'}
                            }
                        }
                    }
                    
                    New-UDElement -Tag 'br'
                    
                    # Performance by Gender
                    New-UDGrid -Container -Spacing 3 -Content {
                        New-UDGrid -Item -ExtraSmallSize 12 -MediumSize 6 -Content {
                            New-UDCard -Content {
                                New-UDTypography -Text "ADG Comparison by Gender" -Variant h6 -Style @{marginBottom = '15px'; color = '#2e7d32'}
                                
                                New-UDElement -Tag 'div' -Attributes @{style = @{maxHeight = '250px'}} -Content {
                                    $genderADG = $rogData | Group-Object -Property Gender | ForEach-Object {
                                        [PSCustomObject]@{
                                            Gender = $_.Name
                                            AvgADG = [Math]::Round(($_.Group | Measure-Object -Property AverageDailyGain -Average).Average, 2)
                                        }
                                    }
                                    
                                    New-UDChartJS -Type bar -Data $genderADG -DataProperty AvgADG -LabelProperty Gender -Options @{
                                        maintainAspectRatio = $false
                                        scales = @{
                                            y = @{
                                                beginAtZero = $true
                                                title = @{
                                                    display = $true
                                                    text = 'Average Daily Gain (lbs/day)'
                                                }
                                            }
                                        }
                                    } -BackgroundColor @('#1976d2', '#c2185b')
                                }
                            }
                        }
                        
                        # Performance by Origin Farm
                        New-UDGrid -Item -ExtraSmallSize 12 -MediumSize 6 -Content {
                            New-UDCard -Content {
                                New-UDTypography -Text "ADG by Origin Farm" -Variant h6 -Style @{marginBottom = '15px'; color = '#2e7d32'}
                                
                                New-UDElement -Tag 'div' -Attributes @{style = @{maxHeight = '250px'}} -Content {
                                    $farmADG = $rogData | Group-Object -Property OriginFarm | ForEach-Object {
                                        [PSCustomObject]@{
                                            Farm   = $_.Name
                                            AvgADG = [Math]::Round(($_.Group | Measure-Object -Property AverageDailyGain -Average).Average, 2)
                                        }
                                    } | Sort-Object -Property AvgADG -Descending
                                    
                                    New-UDChartJS -Type bar -Data $farmADG -DataProperty AvgADG -LabelProperty Farm -Options @{
                                        maintainAspectRatio = $false
                                        indexAxis = 'y'
                                        scales = @{
                                            x = @{
                                                beginAtZero = $true
                                                title = @{
                                                    display = $true
                                                    text = 'Average Daily Gain (lbs/day)'
                                                }
                                            }
                                        }
                                    } -BackgroundColor @('#2e7d32')
                                }
                            }
                        }
                    }
                    
                    New-UDElement -Tag 'br'
                    
                    # Top and Bottom Performers Table
                    New-UDCard -Content {
                        New-UDTypography -Text "Individual Performance" -Variant h6 -Style @{marginBottom = '15px'; color = '#2e7d32'}
                        
                        $sortedRog = $rogData | Sort-Object -Property AverageDailyGain -Descending | Select-Object -First 20
                        
                        $columns = @(
                            New-UDTableColumn -Property TagNumber -Title "Tag #"
                            New-UDTableColumn -Property Name -Title "Name" -Render {
                                if ($EventData.Name) { $EventData.Name } else { '-' }
                            }
                            New-UDTableColumn -Property Gender -Title "Gender"
                            New-UDTableColumn -Property OriginFarm -Title "Origin"
                            New-UDTableColumn -Property AverageDailyGain -Title "ADG (lbs/day)" -Render {
                                $adg = [Math]::Round($EventData.AverageDailyGain, 2)
                                $color = if ($adg -gt $avgADG) { '#2e7d32' } else { '#f57c00' }
                                New-UDTypography -Text $adg -Style @{fontWeight = 'bold'; color = $color}
                            }
                            New-UDTableColumn -Property TotalWeightGain -Title "Total Gain (lbs)" -Render {
                                [Math]::Round($EventData.TotalWeightGain, 1)
                            }
                            New-UDTableColumn -Property DaysBetween -Title "Days"
                        )
                        
                        New-UDTable -Data $sortedRog -Columns $columns -Dense -ShowSort -ShowPagination -PageSize 10
                    }
                    
                } else {
                    New-UDAlert -Severity info -Text "No rate of gain calculations available yet. Add weight records and calculate ADG to see performance data."
                }
            }
        }
        
        # Tab 3: Health Summary
        New-UDTab -Text "Health Summary" -Icon (New-UDIcon -Icon Heartbeat) -Content {
            New-UDDynamic -Content {
                
                $healthRecords = Get-HealthRecords
                
                if ($healthRecords -and $healthRecords.Count -gt 0) {
                    
                    # Summary Stats
                    $totalRecords = $healthRecords.Count
                    $totalCost = ($healthRecords | Where-Object { $_.Cost } | Measure-Object -Property Cost -Sum).Sum
                    $vaccinations = ($healthRecords | Where-Object { $_.RecordType -eq 'Vaccination' }).Count
                    $treatments = ($healthRecords | Where-Object { $_.RecordType -eq 'Treatment' }).Count
                    
                    New-UDGrid -Container -Spacing 3 -Content {
                        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -MediumSize 3 -Content {
                            New-UDCard -Style @{
                                backgroundColor = '#e8f5e9'
                                borderLeft      = '4px solid #2e7d32'
                                padding         = '20px'
                            } -Content {
                                New-UDTypography -Text "Total Records" -Variant h6 -Style @{color = '#2e7d32'; marginBottom = '10px'}
                                New-UDTypography -Text $totalRecords -Variant h3 -Style @{fontWeight = 'bold'; color = '#2e7d32'}
                            }
                        }
                        
                        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -MediumSize 3 -Content {
                            New-UDCard -Style @{
                                backgroundColor = '#e3f2fd'
                                borderLeft      = '4px solid #1976d2'
                                padding         = '20px'
                            } -Content {
                                New-UDTypography -Text "💉 Vaccinations" -Variant h6 -Style @{color = '#1976d2'; marginBottom = '10px'}
                                New-UDTypography -Text $vaccinations -Variant h3 -Style @{fontWeight = 'bold'; color = '#1976d2'}
                            }
                        }
                        
                        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -MediumSize 3 -Content {
                            New-UDCard -Style @{
                                backgroundColor = '#fce4ec'
                                borderLeft      = '4px solid #c2185b'
                                padding         = '20px'
                            } -Content {
                                New-UDTypography -Text "🏥 Treatments" -Variant h6 -Style @{color = '#c2185b'; marginBottom = '10px'}
                                New-UDTypography -Text $treatments -Variant h3 -Style @{fontWeight = 'bold'; color = '#c2185b'}
                            }
                        }
                        
                        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -MediumSize 3 -Content {
                            New-UDCard -Style @{
                                backgroundColor = '#fff3e0'
                                borderLeft      = '4px solid #f57c00'
                                padding         = '20px'
                            } -Content {
                                New-UDTypography -Text "💰 Total Cost" -Variant h6 -Style @{color = '#f57c00'; marginBottom = '10px'}
                                New-UDTypography -Text "`$$([Math]::Round($totalCost, 2))" -Variant h3 -Style @{fontWeight = 'bold'; color = '#f57c00'}
                            }
                        }
                    }
                    
                    New-UDElement -Tag 'br'
                    
                    # Charts
                    New-UDGrid -Container -Spacing 3 -Content {
                        # Record Type Distribution
                        New-UDGrid -Item -ExtraSmallSize 12 -MediumSize 6 -Content {
                            New-UDCard -Content {
                                New-UDTypography -Text "Health Records by Type" -Variant h6 -Style @{marginBottom = '15px'; color = '#2e7d32'}
                                
                                New-UDElement -Tag 'div' -Attributes @{style = @{maxHeight = '300px'}} -Content {
                                    $typeGroups = $healthRecords | Group-Object -Property RecordType
                                    $typeData = $typeGroups | ForEach-Object {
                                        [PSCustomObject]@{
                                            Type  = $_.Name
                                            Count = $_.Count
                                        }
                                    }
                                    
                                    New-UDChartJS -Type doughnut -Data $typeData -DataProperty Count -LabelProperty Type -Options @{
                                        maintainAspectRatio = $false
                                        plugins = @{
                                            legend = @{
                                                position = 'bottom'
                                            }
                                        }
                                    } -BackgroundColor @('#2e7d32', '#1976d2', '#f57c00', '#7b1fa2', '#666')
                                }
                            }
                        }
                        
                        # Cost by Type
                        New-UDGrid -Item -ExtraSmallSize 12 -MediumSize 6 -Content {
                            New-UDCard -Content {
                                New-UDTypography -Text "Health Costs by Type" -Variant h6 -Style @{marginBottom = '15px'; color = '#2e7d32'}
                                
                                New-UDElement -Tag 'div' -Attributes @{style = @{maxHeight = '250px'}} -Content {
                                    $costByType = $healthRecords | Where-Object { $_.Cost } | Group-Object -Property RecordType | ForEach-Object {
                                        [PSCustomObject]@{
                                            Type       = $_.Name
                                            TotalCost = [Math]::Round(($_.Group | Measure-Object -Property Cost -Sum).Sum, 2)
                                        }
                                    } | Sort-Object -Property TotalCost -Descending
                                    
                                    New-UDChartJS -Type bar -Data $costByType -DataProperty TotalCost -LabelProperty Type -Options @{
                                        maintainAspectRatio = $false
                                        scales = @{
                                            y = @{
                                                beginAtZero = $true
                                                title = @{
                                                    display = $true
                                                    text = 'Total Cost ($)'
                                                }
                                            }
                                        }
                                    } -BackgroundColor @('#f57c00')
                                }
                            }
                        }
                    }
                    
                    New-UDElement -Tag 'br'
                    
                    # Animals with Most Health Events
                    New-UDCard -Content {
                        New-UDTypography -Text "Cattle Health Activity" -Variant h6 -Style @{marginBottom = '15px'; color = '#2e7d32'}
                        
                        $cattleHealth = $healthRecords | Group-Object -Property CattleID | ForEach-Object {
                            $records = $_.Group
                            [PSCustomObject]@{
                                TagNumber   = $records[0].TagNumber
                                Name        = $records[0].CattleName
                                RecordCount = $_.Count
                                TotalCost   = [Math]::Round(($records | Where-Object { $_.Cost } | Measure-Object -Property Cost -Sum).Sum, 2)
                            }
                        } | Sort-Object -Property RecordCount -Descending | Select-Object -First 10
                        
                        $columns = @(
                            New-UDTableColumn -Property TagNumber -Title "Tag #"
                            New-UDTableColumn -Property Name -Title "Name" -Render {
                                if ($EventData.Name) { $EventData.Name } else { '-' }
                            }
                            New-UDTableColumn -Property RecordCount -Title "Health Events"
                            New-UDTableColumn -Property TotalCost -Title "Total Cost" -Render {
                                if ($EventData.TotalCost -gt 0) { "`$$($EventData.TotalCost)" } else { '-' }
                            }
                        )
                        
                        New-UDTable -Data $cattleHealth -Columns $columns -Dense
                    }
                    
                } else {
                    New-UDAlert -Severity info -Text "No health records available yet. Add health records to see health analytics."
                }
            }
        }
        
        # Tab 4: Cost Analysis
        New-UDTab -Text "Cost Analysis" -Icon (New-UDIcon -Icon DollarSign) -Content {
            New-UDDynamic -Content {
                
                $healthRecords = Get-HealthRecords
                $healthCosts = $healthRecords | Where-Object { $_.Cost }
                
                if ($healthCosts -and $healthCosts.Count -gt 0) {
                    
                    $totalHealthCost = ($healthCosts | Measure-Object -Property Cost -Sum).Sum
                    $avgCostPerEvent = ($healthCosts | Measure-Object -Property Cost -Average).Average
                    $activeCattle = (Get-AllCattle | Where-Object { $_.Status -eq 'Active' }).Count
                    $costPerHead = if ($activeCattle -gt 0) { $totalHealthCost / $activeCattle } else { 0 }
                    
                    New-UDGrid -Container -Spacing 3 -Content {
                        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -MediumSize 3 -Content {
                            New-UDCard -Style @{
                                backgroundColor = '#fff3e0'
                                borderLeft      = '4px solid #f57c00'
                                padding         = '20px'
                            } -Content {
                                New-UDTypography -Text "Total Health Costs" -Variant h6 -Style @{color = '#f57c00'; marginBottom = '10px'}
                                New-UDTypography -Text "`$$([Math]::Round($totalHealthCost, 2))" -Variant h3 -Style @{fontWeight = 'bold'; color = '#f57c00'}
                            }
                        }
                        
                        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -MediumSize 3 -Content {
                            New-UDCard -Style @{
                                backgroundColor = '#e3f2fd'
                                borderLeft      = '4px solid #1976d2'
                                padding         = '20px'
                            } -Content {
                                New-UDTypography -Text "Avg Cost Per Event" -Variant h6 -Style @{color = '#1976d2'; marginBottom = '10px'}
                                New-UDTypography -Text "`$$([Math]::Round($avgCostPerEvent, 2))" -Variant h3 -Style @{fontWeight = 'bold'; color = '#1976d2'}
                            }
                        }
                        
                        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -MediumSize 3 -Content {
                            New-UDCard -Style @{
                                backgroundColor = '#e8f5e9'
                                borderLeft      = '4px solid #2e7d32'
                                padding         = '20px'
                            } -Content {
                                New-UDTypography -Text "Cost Per Head" -Variant h6 -Style @{color = '#2e7d32'; marginBottom = '10px'}
                                New-UDTypography -Text "`$$([Math]::Round($costPerHead, 2))" -Variant h3 -Style @{fontWeight = 'bold'; color = '#2e7d32'}
                            }
                        }
                        
                        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -MediumSize 3 -Content {
                            New-UDCard -Style @{
                                backgroundColor = '#fce4ec'
                                borderLeft      = '4px solid #c2185b'
                                padding         = '20px'
                            } -Content {
                                New-UDTypography -Text "Active Cattle" -Variant h6 -Style @{color = '#c2185b'; marginBottom = '10px'}
                                New-UDTypography -Text $activeCattle -Variant h3 -Style @{fontWeight = 'bold'; color = '#c2185b'}
                            }
                        }
                    }
                    
                    New-UDElement -Tag 'br'
                    
                    # Cost Breakdown
                    New-UDCard -Content {
                        New-UDTypography -Text "Most Expensive Health Events" -Variant h6 -Style @{marginBottom = '15px'; color = '#2e7d32'}
                        
                        $expensiveEvents = $healthCosts | Sort-Object -Property Cost -Descending | Select-Object -First 10
                        
                        $columns = @(
                            New-UDTableColumn -Property TagNumber -Title "Tag #"
                            New-UDTableColumn -Property CattleName -Title "Name" -Render {
                                if ($EventData.CattleName) { $EventData.CattleName } else { '-' }
                            }
                            New-UDTableColumn -Property RecordDate -Title "Date" -Render {
                                ([DateTime]$EventData.RecordDate).ToString('MM/dd/yyyy')
                            }
                            New-UDTableColumn -Property RecordType -Title "Type"
                            New-UDTableColumn -Property Title -Title "Title"
                            New-UDTableColumn -Property Cost -Title "Cost" -Render {
                                New-UDTypography -Text "`$$($EventData.Cost)" -Style @{fontWeight = 'bold'; color = '#f57c00'}
                            }
                        )
                        
                        New-UDTable -Data $expensiveEvents -Columns $columns -Dense -ShowSort
                    }
                    
                } else {
                    New-UDAlert -Severity info -Text "No cost data available yet. Add health records with cost information to see financial analytics."
                }
            }
        }
    }
}
