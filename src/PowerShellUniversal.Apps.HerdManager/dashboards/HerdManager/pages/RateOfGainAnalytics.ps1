$rogAnalytics = New-UDPage -Name 'ROG Analytics' -Url '/rog-analytics' -Content {
    
    # Page Header
    New-UDCard -Style (Merge-HerdStyle -BaseStyle $HerdStyles.PageHeader.Hero -CustomStyle @{
        backgroundColor = '#1976d2'
        padding         = '30px'
        backgroundImage = 'linear-gradient(135deg, #1976d2 0%, #42a5f5 100%)'
    }) -Content {
        New-UDTypography -Text "📈 Advanced Rate of Gain Analytics" -Variant h4 -Style $HerdStyles.PageHeader.Title
        New-UDTypography -Text "Comprehensive ADG analysis across groups, date ranges, and locations with statistical insights." -Variant body1 -Style $HerdStyles.PageHeader.Subtitle
    }
    
    # Analysis Configuration Card
    New-UDCard -Style $HerdStyles.Card.Elevated -Content {
        New-UDTypography -Text "🔧 Analysis Configuration" -Variant h5 -Style $HerdStyles.Typography.SectionTitle
        
        New-UDGrid -Container -Spacing 3 -Content {
            # Group By Selection
            New-UDGrid -Item -ExtraSmallSize 12 -MediumSize 6 -LargeSize 4 -Content {
                New-UDTypography -Text "Group By" -Variant body2 -Style @{ fontWeight = 'bold'; marginBottom = '8px' }
                New-UDSelect -Id 'group-by-select' -Option {
                    New-UDSelectOption -Name "Location" -Value "Location"
                    New-UDSelectOption -Name "Breed" -Value "Breed"
                    New-UDSelectOption -Name "Gender" -Value "Gender"
                    New-UDSelectOption -Name "Origin Farm" -Value "OriginFarm"
                    New-UDSelectOption -Name "Individual Animals" -Value "Individual"
                } -DefaultValue "Location" -FullWidth
            }
            
            # Date Range Type
            New-UDGrid -Item -ExtraSmallSize 12 -MediumSize 6 -LargeSize 4 -Content {
                New-UDTypography -Text "Date Range" -Variant body2 -Style @{ fontWeight = 'bold'; marginBottom = '8px' }
                New-UDSelect -Id 'date-range-type' -Option {
                    New-UDSelectOption -Name "Last 30 Days" -Value "30"
                    New-UDSelectOption -Name "Last 60 Days" -Value "60"
                    New-UDSelectOption -Name "Last 90 Days" -Value "90"
                    New-UDSelectOption -Name "Last 120 Days" -Value "120"
                    New-UDSelectOption -Name "Custom Range" -Value "custom"
                } -DefaultValue "90" -FullWidth -OnChange {
                    $rangeType = (Get-UDElement -Id 'date-range-type').value
                    if ($rangeType -eq 'custom') {
                        Show-UDElement -Id 'custom-date-range'
                    } else {
                        Hide-UDElement -Id 'custom-date-range'
                    }
                }
            }
            
            # Status Filter
            New-UDGrid -Item -ExtraSmallSize 12 -MediumSize 6 -LargeSize 4 -Content {
                New-UDTypography -Text "Status Filter" -Variant body2 -Style @{ fontWeight = 'bold'; marginBottom = '8px' }
                New-UDSelect -Id 'status-filter' -Option {
                    New-UDSelectOption -Name "Active Only" -Value "Active"
                    New-UDSelectOption -Name "All Status" -Value "All"
                } -DefaultValue "Active" -FullWidth
            }
        }
        
        # Custom Date Range (hidden by default)
        New-UDElement -Id 'custom-date-range' -Tag 'div' -Attributes @{ style = @{ display = 'none'; marginTop = '20px' }} -Content {
            New-UDGrid -Container -Spacing 3 -Content {
                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                    New-UDDatePicker -Id 'custom-start-date' -Label 'Start Date' -Value ((Get-Date).AddDays(-90).ToString('yyyy-MM-dd'))
                }
                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                    New-UDDatePicker -Id 'custom-end-date' -Label 'End Date' -Value ((Get-Date).ToString('yyyy-MM-dd'))
                }
            }
        }
        
        New-UDElement -Tag 'br'
        
        # Action Buttons
        New-UDGrid -Container -Spacing 2 -Content {
            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -MediumSize 4 -Content {
                New-UDButton -Text "Run Analysis" -Icon (New-UDIcon -Icon ChartLine) -Variant contained -FullWidth -Style $HerdStyles.Button.Primary -OnClick {
                    Sync-UDElement -Id 'rog-analytics-results'
                }
            }
            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -MediumSize 4 -Content {
                New-UDButton -Text "Export Results" -Icon (New-UDIcon -Icon Download) -Variant outlined -FullWidth -Style $HerdStyles.Button.Secondary -OnClick {
                    Show-UDToast -Message "Export functionality coming soon!" -MessageColor blue
                }
            }
        }
    }
    
    # Results Section
    New-UDDynamic -Id 'rog-analytics-results' -Content {
        $groupBy = (Get-UDElement -Id 'group-by-select').value
        
        # If no group selected yet, show welcome message
        if (-not $groupBy) {
            New-UDCard -Style $HerdStyles.Card.Default -Content {
                New-UDTypography -Text "👋 Welcome to ROG Analytics" -Variant h5 -Style @{ marginBottom = '20px'; textAlign = 'center' }
                New-UDTypography -Text "Configure your analysis settings above and click 'Run Analysis' to get started." -Variant body1 -Style @{ textAlign = 'center'; opacity = '0.8'; marginBottom = '30px' }
                
                New-UDGrid -Container -Spacing 2 -Content {
                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -MediumSize 3 -Content {
                        New-UDCard -Style $HerdStyles.StatCard.Default -Content {
                            New-UDElement -Tag 'div' -Attributes @{ style = @{ textAlign = 'center' }} -Content {
                                New-UDIcon -Icon ChartLine -Size '3x' -Style @{ color = '#4CAF50'; marginBottom = '10px' }
                                New-UDTypography -Text "Group Analysis" -Variant body2 -Style @{ fontWeight = 'bold' }
                                New-UDTypography -Text "Compare by location, breed, gender, or farm" -Variant caption -Style @{ opacity = '0.7' }
                            }
                        }
                    }
                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -MediumSize 3 -Content {
                        New-UDCard -Style $HerdStyles.StatCard.Default -Content {
                            New-UDElement -Tag 'div' -Attributes @{ style = @{ textAlign = 'center' }} -Content {
                                New-UDIcon -Icon ChartBar -Size '3x' -Style @{ color = '#2196F3'; marginBottom = '10px' }
                                New-UDTypography -Text "Visual Charts" -Variant body2 -Style @{ fontWeight = 'bold' }
                                New-UDTypography -Text "Interactive bar charts and histograms" -Variant caption -Style @{ opacity = '0.7' }
                            }
                        }
                    }
                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -MediumSize 3 -Content {
                        New-UDCard -Style $HerdStyles.StatCard.Default -Content {
                            New-UDElement -Tag 'div' -Attributes @{ style = @{ textAlign = 'center' }} -Content {
                                New-UDIcon -Icon Calculator -Size '3x' -Style @{ color = '#FF9800'; marginBottom = '10px' }
                                New-UDTypography -Text "Statistics" -Variant body2 -Style @{ fontWeight = 'bold' }
                                New-UDTypography -Text "Average, median, min, max ADG values" -Variant caption -Style @{ opacity = '0.7' }
                            }
                        }
                    }
                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -MediumSize 3 -Content {
                        New-UDCard -Style $HerdStyles.StatCard.Default -Content {
                            New-UDElement -Tag 'div' -Attributes @{ style = @{ textAlign = 'center' }} -Content {
                                New-UDIcon -Icon Trophy -Size '3x' -Style @{ color = '#9C27B0'; marginBottom = '10px' }
                                New-UDTypography -Text "Top Performers" -Variant body2 -Style @{ fontWeight = 'bold' }
                                New-UDTypography -Text "See best and worst gaining animals" -Variant caption -Style @{ opacity = '0.7' }
                            }
                        }
                    }
                }
            }
            return
        }
        
        $groupBy = (Get-UDElement -Id 'group-by-select').value
        $dateRangeType = (Get-UDElement -Id 'date-range-type').value
        $statusFilter = (Get-UDElement -Id 'status-filter').value
        
        
        # Determine date range
        if ($dateRangeType -eq 'custom') {
            $startDateValue = (Get-UDElement -Id 'custom-start-date').value
            $endDateValue = (Get-UDElement -Id 'custom-end-date').value
            try {
                $startDate = ConvertFrom-DateString $startDateValue
                $endDate = ConvertFrom-DateString $endDateValue
            } catch {
                New-UDAlert -Severity error -Text "Invalid custom date range"
                return
            }
        } else {
            $endDate = Get-Date
            $startDate = $endDate.AddDays(-[int]$dateRangeType)
        }
        
        
        $cattle = if ($statusFilter -eq 'Active') {
            Get-AllCattle -Status 'Active'
        } else {
            Get-AllCattle
        }
        
        if (-not $cattle -or $cattle.Count -eq 0) {
            New-UDAlert -Severity warning -Text "No cattle found matching the filter criteria."
            return
        }
        
        # Fetch ALL weight records at once for better performance
        $allWeights = Get-AllWeightRecords
        $weightsByCattle = $allWeights | Group-Object -Property CattleID -AsHashTable
        
        # Calculate ROG for each animal using in-memory data
        $rogResults = @()
        $total = $cattle.Count
        
        foreach ($animal in $cattle) {
            try {
                $animalWeights = $weightsByCattle[$animal.CattleID]
                if (-not $animalWeights -or $animalWeights.Count -lt 2) {
                    continue
                }
                
                # Filter weights within date range and sort
                $weightsInRange = $animalWeights | 
                    Where-Object { 
                        $weightDate = [DateTime]$_.WeightDate
                        $weightDate -ge $startDate -and $weightDate -le $endDate 
                    } | 
                    Sort-Object WeightDate
                
                if ($weightsInRange.Count -lt 2) {
                    continue
                }
                
                # Get first and last weight in range
                $firstWeight = $weightsInRange[0]
                $lastWeight = $weightsInRange[-1]
                
                $startWeightDate = [DateTime]$firstWeight.WeightDate
                $endWeightDate = [DateTime]$lastWeight.WeightDate
                $daysBetween = ($endWeightDate - $startWeightDate).TotalDays
                
                if ($daysBetween -le 0) {
                    continue
                }
                
                $totalGain = [double]$lastWeight.Weight - [double]$firstWeight.Weight
                $adg = [Math]::Round($totalGain / $daysBetween, 2)
                
                $rogResults += [PSCustomObject]@{
                    CattleID = $animal.CattleID
                    TagNumber = $animal.TagNumber
                    Name = $animal.Name
                    Breed = $animal.Breed
                    Gender = $animal.Gender
                    Location = $animal.Location
                    OriginFarm = $animal.OriginFarm
                    StartWeight = [Math]::Round([double]$firstWeight.Weight, 1)
                    EndWeight = [Math]::Round([double]$lastWeight.Weight, 1)
                    TotalGain = [Math]::Round($totalGain, 1)
                    DaysOnFeed = [int]$daysBetween
                    ADG = $adg
                    MonthlyGain = [Math]::Round($adg * 30, 1)
                }
            } catch {
                Write-Verbose "Could not calculate ROG for $($animal.TagNumber): $_"
            }
        }
        
        if ($rogResults.Count -eq 0) {
            New-UDAlert -Severity info -Text "No rate of gain data available for the selected criteria. Animals need at least 2 weight records in the date range."
            return
        }
        
        # Group the results based on selection
        $groupedResults = if ($groupBy -eq 'Individual') {
            $rogResults | Group-Object -Property TagNumber | ForEach-Object {
                $group = $_.Group[0]
                [PSCustomObject]@{
                    GroupName = "$($group.TagNumber)$(if($group.Name){" - $($group.Name)"})"
                    Count = 1
                    AvgADG = $group.ADG
                    MedianADG = $group.ADG
                    MinADG = $group.ADG
                    MaxADG = $group.ADG
                    TotalGain = $group.TotalGain
                    AvgStartWeight = $group.StartWeight
                    AvgEndWeight = $group.EndWeight
                    Animals = @($group)
                }
            }
        } else {
            $rogResults | Group-Object -Property $groupBy | ForEach-Object {
                $groupName = if ($_.Name) { $_.Name } else { "(Not Specified)" }
                $adgValues = $_.Group.ADG | Sort-Object
                $median = if ($adgValues.Count % 2 -eq 0) {
                    ($adgValues[$adgValues.Count/2 - 1] + $adgValues[$adgValues.Count/2]) / 2
                } else {
                    $adgValues[[Math]::Floor($adgValues.Count/2)]
                }
                
                [PSCustomObject]@{
                    GroupName = $groupName
                    Count = $_.Group.Count
                    AvgADG = [Math]::Round(($_.Group.ADG | Measure-Object -Average).Average, 4)
                    MedianADG = [Math]::Round($median, 4)
                    MinADG = [Math]::Round(($_.Group.ADG | Measure-Object -Minimum).Minimum, 4)
                    MaxADG = [Math]::Round(($_.Group.ADG | Measure-Object -Maximum).Maximum, 4)
                    TotalGain = [Math]::Round(($_.Group.TotalGain | Measure-Object -Sum).Sum, 2)
                    AvgStartWeight = [Math]::Round(($_.Group.StartWeight | Measure-Object -Average).Average, 2)
                    AvgEndWeight = [Math]::Round(($_.Group.EndWeight | Measure-Object -Average).Average, 2)
                    Animals = $_.Group
                }
            }
        }
        
        # Summary Statistics Card
        New-UDCard -Style $HerdStyles.Card.Default -Content {
            New-UDTypography -Text "📊 Summary Statistics" -Variant h6 -Style @{ marginBottom = '20px'; fontWeight = 'bold' }
            
            $overallAvgADG = [Math]::Round(($rogResults.ADG | Measure-Object -Average).Average, 4)
            $overallMedianADG = [Math]::Round((($rogResults.ADG | Sort-Object)[[Math]::Floor($rogResults.Count/2)]), 4)
            $totalAnimals = $rogResults.Count
            $dateRangeText = "$(Format-Date $startDate) to $(Format-Date $endDate)"
            
            New-UDGrid -Container -Spacing 2 -Content {
                New-UDGrid -Item -ExtraSmallSize 6 -SmallSize 4 -MediumSize 3 -Content {
                    New-UDCard -Style $HerdStyles.StatCard.Success -Content {
                        New-UDTypography -Text "Overall Avg ADG" -Variant body2 -Style @{ opacity = '0.8' }
                        New-UDTypography -Text "$overallAvgADG lbs/day" -Variant h5 -Style @{ fontWeight = 'bold'; marginTop = '8px' }
                    }
                }
                New-UDGrid -Item -ExtraSmallSize 6 -SmallSize 4 -MediumSize 3 -Content {
                    New-UDCard -Style $HerdStyles.StatCard.Default -Content {
                        New-UDTypography -Text "Median ADG" -Variant body2 -Style @{ opacity = '0.8' }
                        New-UDTypography -Text "$overallMedianADG lbs/day" -Variant h5 -Style @{ fontWeight = 'bold'; marginTop = '8px' }
                    }
                }
                New-UDGrid -Item -ExtraSmallSize 6 -SmallSize 4 -MediumSize 3 -Content {
                    New-UDCard -Style $HerdStyles.StatCard.Default -Content {
                        New-UDTypography -Text "Animals Analyzed" -Variant body2 -Style @{ opacity = '0.8' }
                        New-UDTypography -Text "$totalAnimals" -Variant h5 -Style @{ fontWeight = 'bold'; marginTop = '8px' }
                    }
                }
                New-UDGrid -Item -ExtraSmallSize 6 -SmallSize 12 -MediumSize 3 -Content {
                    New-UDCard -Style $HerdStyles.StatCard.Default -Content {
                        New-UDTypography -Text "Date Range" -Variant body2 -Style @{ opacity = '0.8' }
                        New-UDTypography -Text "$dateRangeText" -Variant body2 -Style @{ fontWeight = 'bold'; marginTop = '8px'; fontSize = '12px' }
                    }
                }
            }
        }
        
        # Group Comparison Chart
        New-UDCard -Style $HerdStyles.Card.Default -Content {
            New-UDTypography -Text "📊 Group Comparison - Average ADG" -Variant h6 -Style @{ marginBottom = '20px'; fontWeight = 'bold' }
            
            $chartData = $groupedResults | Sort-Object -Property AvgADG -Descending | Select-Object -First 15
            
            $dataset = New-UDChartJSDataset -DataProperty 'AvgADG' -Label 'Average ADG (lbs/day)' -BackgroundColor '#4CAF50'
            
            New-UDElement -Tag 'div' -Attributes @{ style = @{ height = '300px' } } -Content {
                New-UDChartJS -Type 'bar' -Data $chartData -Dataset $dataset -LabelProperty 'GroupName' -Options @{
                    maintainAspectRatio = $false
                    scales = @{
                        y = @{
                            beginAtZero = $true
                        }
                    }
                    plugins = @{
                        legend = @{
                            display = $false
                        }
                    }
                }
            }
        }
        
        # Detailed Group Results Table
        New-UDCard -Style $HerdStyles.Card.Default -Content {
            New-UDTypography -Text "📋 Detailed Group Analysis" -Variant h6 -Style @{ marginBottom = '20px'; fontWeight = 'bold' }
            
            New-UDTable -Data $groupedResults -Columns @(
                New-UDTableColumn -Property GroupName -Title "$groupBy" -Sort
                New-UDTableColumn -Property Count -Title "Animals" -Sort
                New-UDTableColumn -Property AvgADG -Title "Avg ADG" -Sort -Render {
                    New-UDTypography -Text "$($EventData.AvgADG)" -Style @{
                        fontWeight = 'bold'
                        color = if ($EventData.AvgADG -gt 3.0) { '#4caf50' } elseif ($EventData.AvgADG -gt 2.0) { '#ff9800' } else { '#f44336' }
                    }
                }
                New-UDTableColumn -Property TotalGain -Title "Total Gain" -Sort
            ) -Sort -Dense -ShowPagination -PageSize 10
        }
        
        # Performance Distribution Card
        New-UDCard -Style $HerdStyles.Card.Default -Content {
            New-UDTypography -Text "📊 ADG Distribution" -Variant h6 -Style @{ marginBottom = '20px'; fontWeight = 'bold' }
            
            # Create histogram data
            $bins = @(
                @{ label = '< 1.0'; min = 0; max = 1.0; count = 0 }
                @{ label = '1.0-1.5'; min = 1.0; max = 1.5; count = 0 }
                @{ label = '1.5-2.0'; min = 1.5; max = 2.0; count = 0 }
                @{ label = '2.0-2.5'; min = 2.0; max = 2.5; count = 0 }
                @{ label = '2.5-3.0'; min = 2.5; max = 3.0; count = 0 }
                @{ label = '3.0-3.5'; min = 3.0; max = 3.5; count = 0 }
                @{ label = '3.5-4.0'; min = 3.5; max = 4.0; count = 0 }
                @{ label = '> 4.0'; min = 4.0; max = 999; count = 0 }
            )
            
            foreach ($result in $rogResults) {
                foreach ($bin in $bins) {
                    if ($result.ADG -ge $bin.min -and $result.ADG -lt $bin.max) {
                        $bin.count++
                        break
                    }
                }
            }
            
            $dataset = New-UDChartJSDataset -DataProperty 'count' -Label 'Number of Animals' -BackgroundColor '#2196F3'
            
            New-UDElement -Tag 'div' -Attributes @{ style = @{ height = '250px' } } -Content {
                New-UDChartJS -Type 'bar' -Data $bins -Dataset $dataset -LabelProperty 'label' -Options @{
                    maintainAspectRatio = $false
                    scales = @{
                        y = @{
                            beginAtZero = $true
                        }
                    }
                    plugins = @{
                        legend = @{
                            display = $false
                        }
                    }
                }
            }
        }
        
        # Top & Bottom Performers
        New-UDGrid -Container -Spacing 2 -Content {
            # Top Performers
            New-UDGrid -Item -ExtraSmallSize 12 -MediumSize 6 -Content {
                New-UDCard -Style $HerdStyles.Card.Accent -Content {
                    New-UDTypography -Text "🏆 Top 5 Performers" -Variant h6 -Style @{ marginBottom = '15px'; fontWeight = 'bold' }
                    
                    $topPerformers = $rogResults | Sort-Object -Property ADG -Descending | Select-Object -First 5
                    
                    New-UDTable -Data $topPerformers -Columns @(
                        New-UDTableColumn -Property TagNumber -Title "Tag"
                        New-UDTableColumn -Property Name -Title "Name"
                        New-UDTableColumn -Property ADG -Title "ADG" -Render {
                            New-UDTypography -Text "$($EventData.ADG) lbs/day" -Style @{ fontWeight = 'bold'; color = '#4caf50' }
                        }
                        New-UDTableColumn -Property TotalGain -Title "Total Gain"
                    ) -Dense -ShowPagination:$false
                }
            }
            
            # Bottom Performers
            New-UDGrid -Item -ExtraSmallSize 12 -MediumSize 6 -Content {
                New-UDCard -Style $HerdStyles.Card.Default -Content {
                    New-UDTypography -Text "⚠️ Bottom 5 Performers" -Variant h6 -Style @{ marginBottom = '15px'; fontWeight = 'bold' }
                    
                    $bottomPerformers = $rogResults | Sort-Object -Property ADG | Select-Object -First 5
                    
                    New-UDTable -Data $bottomPerformers -Columns @(
                        New-UDTableColumn -Property TagNumber -Title "Tag"
                        New-UDTableColumn -Property Name -Title "Name"
                        New-UDTableColumn -Property ADG -Title "ADG" -Render {
                            New-UDTypography -Text "$($EventData.ADG) lbs/day" -Style @{ fontWeight = 'bold'; color = '#f44336' }
                        }
                        New-UDTableColumn -Property TotalGain -Title "Total Gain"
                    ) -Dense -ShowPagination:$false
                }
            }
        }
        
    } -LoadingComponent {
        New-UDCard -Style $HerdStyles.Card.Default -Content {
            New-UDTypography -Text "⏳ Analyzing herd data..." -Variant h6 -Style @{ marginBottom = '20px'; textAlign = 'center' }
            New-UDSkeleton -Variant rect -Height 400
        }
    }
    
}
