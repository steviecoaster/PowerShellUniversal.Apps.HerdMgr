$rog = New-UDPage -Name 'Rate Of Gain' -Url '/rog' -Content {
    
    # Page Header with Farm Theme
    New-UDCard -Style (Merge-HerdStyle -BaseStyle $HerdStyles.PageHeader.Hero -CustomStyle @{
        backgroundColor = '#2e7d32'
        padding         = '30px'
        backgroundImage = 'linear-gradient(135deg, #2e7d32 0%, #66bb6a 100%)'
    }) -Content {
        New-UDTypography -Text "📊 Rate of Gain Calculator" -Variant h4 -Style $HerdStyles.PageHeader.Title
        New-UDTypography -Text "Calculate Average Daily Gain (ADG) for your cattle between two recorded weight dates." -Variant body1 -Style $HerdStyles.PageHeader.Subtitle
    }
    
    # Calculator Card
    New-UDCard -Style $HerdStyles.Card.Elevated -Content {
        New-UDTypography -Text "⚖️ Calculate Rate of Gain" -Variant h5 -Style $HerdStyles.Typography.SectionHeader
        
        # Animal Selection Section
        New-UDTypography -Text "Select Animal" -Variant body2 -Style @{
            fontWeight   = 'bold'
            marginBottom = '8px'
            marginTop    = '10px'
            color        = '#555'
        }
        New-UDDynamic -Id 'cattle-select-dynamic' -Content {
            New-UDSelect -Id 'cattle-select' -Option {
                $cattle = Get-AllCattle -Status 'Active'
                foreach ($animal in $cattle) {
                    $displayText = if ($animal.Name) {
                        "$($animal.TagNumber) - $($animal.Name)"
                    }
                    else {
                        $animal.TagNumber
                    }
                    New-UDSelectOption -Name $displayText -Value $animal.CattleID
                }
            } -OnChange {
                # Clear previous results and update weight history when cattle is selected
                Clear-UDElement -Id 'rog-results'
                Sync-UDElement -Id 'weight-history-grid'
                Sync-UDElement -Id 'rog-history-grid'
            } -FullWidth
        } -LoadingComponent {
            New-UDSkeleton -Variant text -Height 56
        }
        
        New-UDElement -Tag 'br'
        
        # Date Range Section
        New-UDTypography -Text "Date Range" -Variant body2 -Style @{
            fontWeight   = 'bold'
            marginBottom = '12px'
            color        = '#555'
        }

        New-UDElement -Tag 'br'

        New-UDGrid -Container -Spacing 3 -Content {
            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                New-UDDatePicker -Id 'start-date' -Label 'Start Date' -Value ((Get-Date).AddDays(-90).ToString('yyyy-MM-dd'))
            }
            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                New-UDDatePicker -Id 'end-date' -Label 'End Date' -Value ((Get-Date).ToString('yyyy-MM-dd'))
            }
        }
        
        New-UDElement -Tag 'br'
        
        # Calculate button
        New-UDButton -Text "Calculate Rate of Gain" -Variant contained -Style (Merge-HerdStyle -BaseStyle $HerdStyles.Button.Primary -CustomStyle @{
            padding  = '10px 30px'
            fontSize = '16px'
        }) -OnClick {
            $cattleId = (Get-UDElement -Id 'cattle-select').value
            $startDateValue = (Get-UDElement -Id 'start-date').value
            $endDateValue = (Get-UDElement -Id 'end-date').value
                
            if (-not $cattleId) {
                Show-UDToast -Message "Please select an animal" -MessageColor red
                return
            }
                
            # Convert date values to DateTime objects
            try {
                $startDate = ConvertFrom-DateString $startDateValue
                $endDate = ConvertFrom-DateString $endDateValue
            }
            catch {
                Show-UDToast -Message "Invalid date format. Error: $($_.Exception.Message)" -MessageColor red
                return
            }
                
            if ($endDate -le $startDate) {
                Show-UDToast -Message "End date must be after start date." -MessageColor red
                return
            }
                
            try {
                $result = Measure-RateOfGain -CattleID $cattleId -StartDate $startDate -EndDate $endDate
                    
                if ($result) {
                    Set-UDElement -Id 'rog-results' -Content {
                        New-UDCard -Style @{
                            marginTop    = '25px'
                            borderLeft   = '5px solid #2e7d32'
                            borderRadius = '8px'
                        } -Content {
                            New-UDTypography -Text "📈 Results" -Variant h6 -Style @{
                                color        = '#2e7d32'
                                fontWeight   = 'bold'
                                marginBottom = '15px'
                            }
                                
                            # Period Info
                            New-UDGrid -Container -Spacing 2 -Content {
                                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                    New-UDPaper -Style @{padding = '15px' } -Content {
                                        New-UDTypography -Text "📅 Period" -Variant body2 -Style @{marginBottom = '5px'; opacity = 0.7 }
                                        New-UDTypography -Text "$(Format-Date $result.StartDate) to $(Format-Date $result.EndDate)" -Variant body1 -Style @{fontWeight = 'bold' }
                                    }
                                }
                                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                    New-UDPaper -Style @{padding = '15px' } -Content {
                                        New-UDTypography -Text "⏱️ Duration" -Variant body2 -Style @{marginBottom = '5px'; opacity = 0.7 }
                                        New-UDTypography -Text "$($result.DaysBetween) days" -Variant body1 -Style @{fontWeight = 'bold' }
                                    }
                                }
                            }
                                
                            New-UDElement -Tag 'br'
                                
                            # Weight Info
                            New-UDGrid -Container -Spacing 2 -Content {
                                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 4 -Content {
                                    New-UDPaper -Style @{padding = '15px' } -Content {
                                        New-UDTypography -Text "Start Weight" -Variant body2 -Style @{marginBottom = '5px'; opacity = 0.7 }
                                        New-UDTypography -Text "$($result.StartWeight) lbs" -Variant h6 -Style @{color = '#1565c0'; fontWeight = 'bold' }
                                    }
                                }
                                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 4 -Content {
                                    New-UDPaper -Style @{padding = '15px' } -Content {
                                        New-UDTypography -Text "End Weight" -Variant body2 -Style @{marginBottom = '5px'; opacity = 0.7 }
                                        New-UDTypography -Text "$($result.EndWeight) lbs" -Variant h6 -Style @{color = '#1565c0'; fontWeight = 'bold' }
                                    }
                                }
                                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 4 -Content {
                                    New-UDPaper -Style @{padding = '15px' } -Content {
                                        New-UDTypography -Text "Total Gain" -Variant body2 -Style @{marginBottom = '5px'; opacity = 0.7 }
                                        New-UDTypography -Text "$($result.TotalWeightGain) lbs" -Variant h6 -Style @{color = '#2e7d32'; fontWeight = 'bold' }
                                    }
                                }
                            }
                                
                            New-UDElement -Tag 'br'
                                
                            # Key Metrics
                            New-UDGrid -Container -Spacing 2 -Content {
                                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                    New-UDPaper -Elevation 3 -Style @{padding = '20px'; backgroundColor = '#2e7d32'; color = 'white'; textAlign = 'center' } -Content {
                                        New-UDTypography -Text "Average Daily Gain (ADG)" -Variant body2 -Style @{marginBottom = '10px'; opacity = '0.9' }
                                        New-UDTypography -Text "$($result.AverageDailyGain) lbs/day" -Variant h5 -Style @{fontWeight = 'bold' }
                                    }
                                }
                                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                    New-UDPaper -Elevation 3 -Style @{padding = '20px'; backgroundColor = '#1565c0'; color = 'white'; textAlign = 'center' } -Content {
                                        New-UDTypography -Text "Estimated Monthly Gain" -Variant body2 -Style @{marginBottom = '10px'; opacity = '0.9' }
                                        New-UDTypography -Text "$($result.MonthlyGain) lbs/month" -Variant h5 -Style @{fontWeight = 'bold' }
                                    }
                                }
                            }
                                
                            New-UDElement -Tag 'br'
                                
                            # Weight Progression Chart
                            New-UDTypography -Text "📊 Weight Progression" -Variant h6 -Style @{
                                color        = '#2e7d32'
                                fontWeight   = 'bold'
                                marginBottom = '15px'
                                marginTop    = '10px'
                            }
                                
                            # Get all weight records in the date range
                            $allWeights = Get-WeightHistory -CattleID $cattleId
                            $filteredWeights = @()
                                
                                foreach ($record in $allWeights) {
                                    try {
                                        $recordDate = ConvertFrom-DateString $record.WeightDate
                                        if ($recordDate -ge $startDate -and $recordDate -le $endDate) {
                                            $filteredWeights += $record
                                        }
                                    }
                                    catch {
                                        # Skip records with bad dates
                                    }
                                }
                                
                            $filteredWeights = $filteredWeights | Sort-Object WeightDate
                                
                                if ($filteredWeights -and $filteredWeights.Count -gt 1) {
                                # Prepare chart data - convert to objects with friendly date labels
                                $chartData = $filteredWeights | ForEach-Object {
                                        $dateStr = Format-Date $_.WeightDate
                                        if ($dateStr -eq '-') { $dateStr = $_.WeightDate -replace ' \d{2}:\d{2}:\d{2}.*$', '' }
                                    [PSCustomObject]@{
                                        Date   = $dateStr
                                        Weight = [decimal]$_.Weight
                                    }
                                }
                                    
                                # Wrap chart in a container with max height
                                New-UDElement -Tag 'div' -Attributes @{style = @{maxHeight = '300px'; width = '100%' } } -Content {
                                    New-UDChartJS -Type line -Data $chartData -DataProperty 'Weight' -LabelProperty 'Date' `
                                        -BackgroundColor 'rgba(46, 125, 50, 0.2)' `
                                        -BorderColor 'rgba(46, 125, 50, 1)' `
                                        -BorderWidth 3 `
                                        -Options @{
                                        responsive          = $true
                                        maintainAspectRatio = $false
                                        plugins             = @{
                                            legend = @{
                                                display  = $true
                                                position = 'top'
                                            }
                                            title  = @{
                                                display = $false
                                            }
                                        }
                                        scales              = @{
                                            y = @{
                                                beginAtZero = $false
                                                title       = @{
                                                    display = $true
                                                    text    = 'Weight (lbs)'
                                                }
                                                grid        = @{
                                                    color = 'rgba(0, 0, 0, 0.1)'
                                                }
                                            }
                                            x = @{
                                                title = @{
                                                    display = $true
                                                    text    = 'Date'
                                                }
                                                grid  = @{
                                                    display = $false
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            else {
                                New-UDPaper -Style @{padding = '20px'; textAlign = 'center'; borderLeft = '4px solid #f57c00' } -Content {
                                    New-UDTypography -Text "⚠️ Not enough weight records in this date range to generate a chart (need at least 2 records)." -Variant body2 -Style @{color = '#f57c00' }
                                }
                            }
                        }
                    }
                    Show-UDToast -Message "Rate of gain calculated successfully!" -MessageColor green
                    Sync-UDElement -Id 'rog-history-grid'
                }
                else {
                    Show-UDToast -Message "Could not calculate rate of gain. Check that weight records exist for the selected date range." -MessageColor red
                }
            }
            catch {
                Show-UDToast -Message "Error: $($_.Exception)" -MessageColor red
            }
        }
    }
        
    # Results display area
    New-UDElement -Tag 'div' -Id 'rog-results'
        
    New-UDElement -Tag 'br'
        
    # Weight history for selected animal
    New-UDCard -Style @{
        marginBottom = '25px'
        borderRadius = '8px'
        boxShadow    = '0 2px 8px rgba(0,0,0,0.1)'
    } -Content {
        New-UDTypography -Text "⚖️ Weight History" -Variant h5 -Style @{
            color        = '#2e7d32'
            fontWeight   = 'bold'
            marginBottom = '15px'
        }
        New-UDDynamic -Id 'weight-history-grid' -Content {
            $cattleId = (Get-UDElement -Id 'cattle-select').value
                
            if ($cattleId) {
                # Force fresh query - no caching
                $weightHistory = Get-WeightHistory -CattleID $cattleId
                    
                if ($weightHistory) {
                        New-UDTable -Data $weightHistory -Columns @(
                        New-UDTableColumn -Property WeightDate -Title "Date" -Render {
                            New-UDElement -Tag 'div' -Content { 
                                Format-Date $EventData.WeightDate
                            }
                        }
                        New-UDTableColumn -Property Weight -Title "Weight"
                        New-UDTableColumn -Property WeightUnit -Title "Unit"
                        New-UDTableColumn -Property MeasurementMethod -Title "Method"
                        New-UDTableColumn -Property RecordedBy -Title "Recorded By"
                    ) -Sort -PageSize 10 -Dense
                }
                else {
                    New-UDPaper -Style @{padding = '20px'; textAlign = 'center' } -Content {
                        New-UDTypography -Text "📋 No weight records found for this animal." -Variant body1
                    }
                }
            }
            else {
                New-UDPaper -Style @{padding = '20px'; textAlign = 'center' } -Content {
                    New-UDTypography -Text "👈 Select an animal to view weight history." -Variant body1
                }
            }
        }
    }
        
    New-UDElement -Tag 'br'
        
    # Historical calculations
    New-UDCard -Style @{
        marginBottom = '25px'
        borderRadius = '8px'
        boxShadow    = '0 2px 8px rgba(0,0,0,0.1)'
    } -Content {
        New-UDTypography -Text "📋 Recent Rate of Gain Calculations" -Variant h5 -Style @{
            color        = '#2e7d32'
            fontWeight   = 'bold'
            marginBottom = '15px'
        }
        New-UDDynamic -Id 'rog-history-grid' -Content {
            try {
                $cattleId = (Get-UDElement -Id 'cattle-select').value
                    
                if ($cattleId) {
                    # Force fresh query - no caching
                    $propertyBag = @(
                        'StartDate',
                        'EndDate',
                        'DaysBetween',
                        @{Name = 'TotalWeightGain' ; Expression = { [Math]::Round($_.TotalWeightGain, 2) } },
                        @{Name = 'AverageDailyGain'; Expression = { [Math]::Round($_.AverageDailyGain, 2) } },
                        @{Name = 'MonthlyGain' ; Expression = {[Math]::Round($_.MonthlyGain,2)}}
                    )

                    $history = Get-RateOfGainHistory -CattleID $cattleId -Limit 20 | Select-Object $propertyBag
                        
                    if ($history) {
                        New-UDTable -Data $history -Columns @(
                            New-UDTableColumn -Property StartDate -Title "Start Date"
                            New-UDTableColumn -Property EndDate -Title "End Date"
                            New-UDTableColumn -Property DaysBetween -Title "Days"
                            New-UDTableColumn -Property TotalWeightGain -Title "Total Gain (lbs)"
                            New-UDTableColumn -Property AverageDailyGain -Title "ADG (lbs/day)"
                            New-UDTableColumn -Property MonthlyGain -Title "Monthly Gain (lbs)"
                        ) -Sort -PageSize 10 -Dense
                    }
                    else {
                        New-UDPaper -Style @{padding = '20px'; textAlign = 'center' } -Content {
                            New-UDTypography -Text "📊 No rate of gain calculations yet. Calculate your first ADG above!"  -Variant body1
                        }
                    }
                }
                else {
                    New-UDPaper -Style @{padding = '20px'; textAlign = 'center' } -Content {
                        New-UDTypography -Text "👈 Select an animal to view rate of gain history." -Variant body1
                    }
                }
            }
            catch {
                New-UDPaper -Style @{padding = '20px'; textAlign = 'center'; borderLeft = '4px solid #d32f2f' } -Content {
                    New-UDTypography -Text "❌ Error loading ROG history: $($_.Exception.Message)" -Variant body2 -Style @{color = '#d32f2f' }
                }
            }
        }
    }
}





