$animalreport = New-UDPage -Name "Animal Report" -Icon (New-UDIcon -Icon FileAlt) -Content {
    
    # Print-friendly CSS
    New-UDElement -Tag 'style' -Content {
        @"
        @media print {
            .MuiAppBar-root, nav, button, .no-print {
                display: none !important;
            }
            .MuiCard-root {
                box-shadow: none !important;
                border: 1px solid #ddd !important;
                page-break-inside: avoid;
            }
            body {
                font-size: 12pt;
            }
        }
"@
    }
    
    New-UDCard -Style $HerdStyles.Card.Elevated -Content {
        New-UDTypography -Text "🐂 Comprehensive Animal Report" -Variant h4 -Style $HerdStyles.Typography.PageTitle
        
        New-UDTypography -Text "Select an animal to generate a detailed performance and health report." -Variant body1 -Style @{
            marginBottom = '20px'
            color = '#666'
        }
        
        # Animal Selector
        New-UDGrid -Container -Spacing 2 -Content {
            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 8 -MediumSize 6 -Content {
                New-UDDynamic -Id 'animal-select-dynamic' -Content {
                    New-UDSelect -Id 'report-animal-select' -Label "Select Animal" -Option {
                        $cattle = Get-AllCattle -Status 'Active'
                        foreach ($animal in $cattle) {
                            $displayText = if ($animal.Name) {
                                "$($animal.TagNumber) - $($animal.Name)"
                            } else {
                                $animal.TagNumber
                            }
                            New-UDSelectOption -Name $displayText -Value $animal.CattleID
                        }
                    } -OnChange {
                        Sync-UDElement -Id 'animal-report-content'
                    } -FullWidth
                } -LoadingComponent {
                    New-UDSkeleton -Variant text -Height 56
                }
            }
            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 4 -MediumSize 3 -Content {
                New-UDButton -Text "Print Report" -Icon (New-UDIcon -Icon Print) -Variant outlined -OnClick {
                    Invoke-UDJavaScript -JavaScript "window.print();"
                } -FullWidth -Style @{
                    height = '56px'
                }
            }
        }
    }
    
    # Report Content Area
    New-UDDynamic -Id 'animal-report-content' -Content {
        try {
            $cattleId = (Get-UDElement -Id 'report-animal-select').value
            
            if (-not $cattleId) {
                New-UDPaper -Style @{padding = '40px'; textAlign = 'center'} -Content {
                    New-UDTypography -Text "👆 Select an animal above to view their comprehensive report" -Variant h6 -Style @{color = '#999'}
                }
                return
            }
            
            # Get animal data
            $animal = Get-CattleById -CattleID $cattleId
            
            if (-not $animal) {
                New-UDPaper -Style @{padding = '40px'; textAlign = 'center'; borderLeft = '4px solid #d32f2f'} -Content {
                    New-UDTypography -Text "❌ Animal not found" -Variant h6 -Style @{color = '#d32f2f'}
                }
                return
            }
            
            # Calculate age if birth date available
            $age = if ($animal.BirthDate) {
                try {
                    $birthDate = ConvertFrom-DateString $animal.BirthDate
                    $ageInDays = ([DateTime]::Now - $birthDate).Days
                    if ($ageInDays -lt 30) {
                        "$ageInDays days"
                    } elseif ($ageInDays -lt 365) {
                        "$([Math]::Floor($ageInDays / 30)) months"
                    } else {
                        $years = [Math]::Floor($ageInDays / 365)
                        $months = [Math]::Floor(($ageInDays % 365) / 30)
                        "$years years, $months months"
                    }
                } catch {
                    "Unknown"
                }
            } else {
                "Unknown"
            }
            
            # Get weight history
            $weightHistory = Get-WeightHistory -CattleID $cattleId
            
            # Get ROG history
            $rogHistory = Get-RateOfGainHistory -CattleID $cattleId -Limit 100
            
            # Get health records
            $healthRecords = Get-HealthRecords -CattleID $cattleId
            
            # Calculate summary stats
            $currentWeight = if ($weightHistory -and $weightHistory.Count -gt 0) {
                ($weightHistory | Sort-Object WeightDate -Descending | Select-Object -First 1).Weight
            } else {
                $null
            }
            
            $startingWeight = if ($weightHistory -and $weightHistory.Count -gt 0) {
                ($weightHistory | Sort-Object WeightDate | Select-Object -First 1).Weight
            } else {
                $null
            }
            
            $totalGain = if ($currentWeight -and $startingWeight) {
                [Math]::Round($currentWeight - $startingWeight, 2)
            } else {
                $null
            }
            
            $avgADG = if ($rogHistory -and $rogHistory.Count -gt 0) {
                [Math]::Round(($rogHistory | Measure-Object -Property AverageDailyGain -Average).Average, 4)
            } else {
                $null
            }
            
            $daysInHerd = if ($animal.PurchaseDate) {
                try {
                    $purchaseDate = ConvertFrom-DateString $animal.PurchaseDate
                    ([DateTime]::Now - $purchaseDate).Days
                } catch {
                    $null
                }
            } elseif ($animal.BirthDate) {
                try {
                    $birthDate = ConvertFrom-DateString $animal.BirthDate
                    ([DateTime]::Now - $birthDate).Days
                } catch {
                    $null
                }
            } else {
                $null
            }
            
            # ============ ANIMAL PROFILE SECTION ============
            New-UDCard -Style @{
                marginBottom = '25px'
                borderRadius = '8px'
                boxShadow = '0 2px 8px rgba(0,0,0,0.1)'
                borderLeft = '5px solid #2e7d32'
            } -Content {
                New-UDTypography -Text "📋 Animal Profile" -Variant h5 -Style @{
                    color = '#2e7d32'
                    fontWeight = 'bold'
                    marginBottom = '20px'
                }
                
                New-UDGrid -Container -Spacing 3 -Content {
                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -MediumSize 3 -Content {
                        New-UDPaper -Style @{padding = '15px'} -Content {
                            New-UDTypography -Text "Tag Number" -Variant body2 -Style @{marginBottom = '5px'; opacity = 0.7}
                            New-UDTypography -Text $animal.TagNumber -Variant h6 -Style @{fontWeight = 'bold'; color = '#2e7d32'}
                        }
                    }
                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -MediumSize 3 -Content {
                        New-UDPaper -Style @{padding = '15px'} -Content {
                            New-UDTypography -Text "Name" -Variant body2 -Style @{marginBottom = '5px'; opacity = 0.7}
                            New-UDTypography -Text $(if ($animal.Name) { $animal.Name } else { 'N/A' }) -Variant h6 -Style @{fontWeight = 'bold'}
                        }
                    }
                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -MediumSize 3 -Content {
                        New-UDPaper -Style @{padding = '15px'} -Content {
                            New-UDTypography -Text "Breed" -Variant body2 -Style @{marginBottom = '5px'; opacity = 0.7}
                            New-UDTypography -Text $(if ($animal.Breed) { $animal.Breed } else { 'N/A' }) -Variant h6 -Style @{fontWeight = 'bold'}
                        }
                    }
                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -MediumSize 3 -Content {
                        New-UDPaper -Style @{padding = '15px'} -Content {
                            New-UDTypography -Text "Gender" -Variant body2 -Style @{marginBottom = '5px'; opacity = 0.7}
                            New-UDTypography -Text $(if ($animal.Gender) { $animal.Gender } else { 'N/A' }) -Variant h6 -Style @{fontWeight = 'bold'}
                        }
                    }
                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -MediumSize 3 -Content {
                        New-UDPaper -Style @{padding = '15px'} -Content {
                            New-UDTypography -Text "Age" -Variant body2 -Style @{marginBottom = '5px'; opacity = 0.7}
                            New-UDTypography -Text $age -Variant h6 -Style @{fontWeight = 'bold'}
                        }
                    }
                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -MediumSize 3 -Content {
                        New-UDPaper -Style @{padding = '15px'} -Content {
                            New-UDTypography -Text "Origin Farm" -Variant body2 -Style @{marginBottom = '5px'; opacity = 0.7}
                            New-UDTypography -Text $(if ($animal.OriginFarm) { $animal.OriginFarm } else { 'N/A' }) -Variant h6 -Style @{fontWeight = 'bold'}
                        }
                    }
                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -MediumSize 3 -Content {
                        New-UDPaper -Style @{padding = '15px'} -Content {
                            New-UDTypography -Text "Days in Herd" -Variant body2 -Style @{marginBottom = '5px'; opacity = 0.7}
                            New-UDTypography -Text $(if ($daysInHerd) { "$daysInHerd days" } else { 'N/A' }) -Variant h6 -Style @{fontWeight = 'bold'}
                        }
                    }
                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -MediumSize 3 -Content {
                        New-UDPaper -Style @{padding = '15px'} -Content {
                            New-UDTypography -Text "Status" -Variant body2 -Style @{marginBottom = '5px'; opacity = 0.7}
                            New-UDTypography -Text $animal.Status -Variant h6 -Style @{fontWeight = 'bold'; color = $(if ($animal.Status -eq 'Active') { '#2e7d32' } else { '#f57c00' })}
                        }
                    }
                }
            }
            
            # ============ PERFORMANCE SUMMARY ============
            New-UDCard -Style @{
                marginBottom = '25px'
                borderRadius = '8px'
                boxShadow = '0 2px 8px rgba(0,0,0,0.1)'
                borderLeft = '5px solid #1565c0'
            } -Content {
                New-UDTypography -Text "📊 Performance Summary" -Variant h5 -Style @{
                    color = '#1565c0'
                    fontWeight = 'bold'
                    marginBottom = '20px'
                }
                
                New-UDGrid -Container -Spacing 3 -Content {
                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -MediumSize 3 -Content {
                        New-UDPaper -Elevation 2 -Style @{padding = '20px'; backgroundColor = '#e3f2fd'; textAlign = 'center'} -Content {
                            New-UDTypography -Text "Current Weight" -Variant body2 -Style @{marginBottom = '10px'; color = '#1565c0'}
                            New-UDTypography -Text $(if ($currentWeight) { "$currentWeight lbs" } else { 'N/A' }) -Variant h5 -Style @{fontWeight = 'bold'; color = '#1565c0'}
                        }
                    }
                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -MediumSize 3 -Content {
                        New-UDPaper -Elevation 2 -Style @{padding = '20px'; backgroundColor = '#f3e5f5'; textAlign = 'center'} -Content {
                            New-UDTypography -Text "Starting Weight" -Variant body2 -Style @{marginBottom = '10px'; color = '#7b1fa2'}
                            New-UDTypography -Text $(if ($startingWeight) { "$startingWeight lbs" } else { 'N/A' }) -Variant h5 -Style @{fontWeight = 'bold'; color = '#7b1fa2'}
                        }
                    }
                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -MediumSize 3 -Content {
                        New-UDPaper -Elevation 2 -Style @{padding = '20px'; backgroundColor = '#e8f5e9'; textAlign = 'center'} -Content {
                            New-UDTypography -Text "Total Gain" -Variant body2 -Style @{marginBottom = '10px'; color = '#2e7d32'}
                            New-UDTypography -Text $(if ($totalGain) { "$totalGain lbs" } else { 'N/A' }) -Variant h5 -Style @{fontWeight = 'bold'; color = '#2e7d32'}
                        }
                    }
                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -MediumSize 3 -Content {
                        New-UDPaper -Elevation 2 -Style @{padding = '20px'; backgroundColor = '#fff3e0'; textAlign = 'center'} -Content {
                            New-UDTypography -Text "Average ADG" -Variant body2 -Style @{marginBottom = '10px'; color = '#f57c00'}
                            New-UDTypography -Text $(if ($avgADG) { "$avgADG lbs/day" } else { 'N/A' }) -Variant h5 -Style @{fontWeight = 'bold'; color = '#f57c00'}
                        }
                    }
                }
            }
            
            # ============ WEIGHT HISTORY ============
            if ($weightHistory -and $weightHistory.Count -gt 0) {
                New-UDCard -Style @{
                    marginBottom = '25px'
                    borderRadius = '8px'
                    boxShadow = '0 2px 8px rgba(0,0,0,0.1)'
                } -Content {
                    New-UDTypography -Text "⚖️ Weight History" -Variant h5 -Style @{
                        color = '#2e7d32'
                        fontWeight = 'bold'
                        marginBottom = '20px'
                    }
                    
                    # Weight trend chart
                    if ($weightHistory.Count -gt 1) {
                        $chartData = $weightHistory | Sort-Object WeightDate | ForEach-Object {
                            $dateStr = Format-Date $_.WeightDate
                            if ($dateStr -eq '-') { $dateStr = $_.WeightDate -replace ' \d{2}:\d{2}:\d{2}.*$', '' }
                            [PSCustomObject]@{
                                Date = $dateStr
                                Weight = [decimal]$_.Weight
                            }
                        }
                        
                        New-UDElement -Tag 'div' -Attributes @{style = @{maxHeight = '300px'; marginBottom = '20px'}} -Content {
                            New-UDChartJS -Type line -Data $chartData -DataProperty 'Weight' -LabelProperty 'Date' `
                                -BackgroundColor 'rgba(46, 125, 50, 0.2)' `
                                -BorderColor 'rgba(46, 125, 50, 1)' `
                                -BorderWidth 3 `
                                -Options @{
                                responsive = $true
                                maintainAspectRatio = $false
                                plugins = @{
                                    legend = @{
                                        display = $false
                                    }
                                }
                                scales = @{
                                    y = @{
                                        beginAtZero = $false
                                        title = @{
                                            display = $true
                                            text = 'Weight (lbs)'
                                        }
                                    }
                                    x = @{
                                        title = @{
                                            display = $true
                                            text = 'Date'
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    # Weight records table
                        New-UDTable -Data $weightHistory -Columns @(
                        New-UDTableColumn -Property WeightDate -Title "Date" -Render {
                            $fd = Format-Date $EventData.WeightDate
                            if ($fd -ne '-') { $fd } else { $EventData.WeightDate -replace ' \d{2}:\d{2}:\d{2}.*$', '' }
                        }
                        New-UDTableColumn -Property Weight -Title "Weight (lbs)"
                        New-UDTableColumn -Property WeightUnit -Title "Unit"
                        New-UDTableColumn -Property MeasurementMethod -Title "Method"
                        New-UDTableColumn -Property RecordedBy -Title "Recorded By"
                    ) -Sort -PageSize 10 -Dense -ShowPagination
                }
            }
            
            # ============ RATE OF GAIN HISTORY ============
            if ($rogHistory -and $rogHistory.Count -gt 0) {
                New-UDCard -Style @{
                    marginBottom = '25px'
                    borderRadius = '8px'
                    boxShadow = '0 2px 8px rgba(0,0,0,0.1)'
                } -Content {
                    New-UDTypography -Text "📈 Rate of Gain History" -Variant h5 -Style @{
                        color = '#1565c0'
                        fontWeight = 'bold'
                        marginBottom = '20px'
                    }
                    
                        New-UDTable -Data $rogHistory -Columns @(
                        New-UDTableColumn -Property StartDate -Title "Start Date" -Render {
                            Format-Date $EventData.StartDate
                        }
                        New-UDTableColumn -Property EndDate -Title "End Date" -Render {
                            Format-Date $EventData.EndDate
                        }
                        New-UDTableColumn -Property DaysBetween -Title "Days"
                        New-UDTableColumn -Property StartWeight -Title "Start (lbs)"
                        New-UDTableColumn -Property EndWeight -Title "End (lbs)"
                        New-UDTableColumn -Property TotalWeightGain -Title "Gain (lbs)"
                        New-UDTableColumn -Property AverageDailyGain -Title "ADG"
                        New-UDTableColumn -Property MonthlyGain -Title "Monthly"
                    ) -Sort -PageSize 10 -Dense -ShowPagination
                }
            }
            
            # ============ HEALTH RECORDS ============
            if ($healthRecords -and $healthRecords.Count -gt 0) {
                New-UDCard -Style @{
                    marginBottom = '25px'
                    borderRadius = '8px'
                    boxShadow = '0 2px 8px rgba(0,0,0,0.1)'
                } -Content {
                    New-UDTypography -Text "🏥 Health Records" -Variant h5 -Style @{
                        color = '#d32f2f'
                        fontWeight = 'bold'
                        marginBottom = '20px'
                    }
                    
                        New-UDTable -Data $healthRecords -Columns @(
                        New-UDTableColumn -Property RecordDate -Title "Date" -Render {
                            $fd = Format-Date $EventData.RecordDate
                            if ($fd -ne '-') { $fd } else { $EventData.RecordDate -replace ' \d{2}:\d{2}:\d{2}.*$', '' }
                        }
                        New-UDTableColumn -Property RecordType -Title "Type"
                        New-UDTableColumn -Property Title -Title "Title"
                        New-UDTableColumn -Property NextDueDate -Title "Next Due" -Render {
                            if ($EventData.NextDueDate) {
                                $fd = Format-Date $EventData.NextDueDate
                                if ($fd -ne '-') { $fd } else { $EventData.NextDueDate -replace ' \d{2}:\d{2}:\d{2}.*$', '' }
                            } else {
                                'N/A'
                            }
                        }
                        New-UDTableColumn -Property RecordedBy -Title "Recorded By"
                    ) -Sort -PageSize 10 -Dense -ShowPagination
                }
            }
            
            # If no data at all
            if ((-not $weightHistory -or $weightHistory.Count -eq 0) -and 
                (-not $rogHistory -or $rogHistory.Count -eq 0) -and 
                (-not $healthRecords -or $healthRecords.Count -eq 0)) {
                New-UDPaper -Style @{padding = '40px'; textAlign = 'center'; marginTop = '20px'} -Content {
                    New-UDTypography -Text "📋 No additional records found for this animal" -Variant h6 -Style @{color = '#999'}
                }
            }
            
        } catch {
            New-UDPaper -Style @{padding = '40px'; textAlign = 'center'; borderLeft = '4px solid #d32f2f'} -Content {
                New-UDTypography -Text "❌ Error generating report: $($_.Exception.Message)" -Variant body1 -Style @{color = '#d32f2f'}
            }
        }
    }
}






