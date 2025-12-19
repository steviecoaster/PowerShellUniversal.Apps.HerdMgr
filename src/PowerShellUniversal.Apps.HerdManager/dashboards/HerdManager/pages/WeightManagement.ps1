$weightMgmt = New-UDPage -Name 'Weight Management' -Url '/weights' -Content {
    
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
        New-UDTypography -Text "⚖️ Weight Management" -Variant h4 -Style @{
            fontWeight   = 'bold'
            marginBottom = '10px'
        }
        New-UDTypography -Text "Record and track weight measurements for your cattle" -Variant body1 -Style @{
            opacity = '0.9'
        }
    }
    
    # Add New Weight Record Button
    New-UDButton -Text "➕ Add Weight Record" -Variant contained -Style @{
        backgroundColor = '#2e7d32'
        color           = 'white'
        marginBottom    = '20px'
    } -OnClick {
        Show-UDModal -Content {
            New-UDTypography -Text "Add Weight Record" -Variant h5 -Style @{
                color        = '#2e7d32'
                marginBottom = '20px'
                fontWeight   = 'bold'
            }
            
            # Cattle Selection
            New-UDAutocomplete -Id 'weight-cattle-select' -Label 'Select Cattle *' -Options {
                $allCattle = Get-AllCattle | Where-Object { $_.Status -eq 'Active' }
                $allCattle | ForEach-Object {
                    $displayText = if ($_.Name) {
                        "$($_.TagNumber) - $($_.Name)"
                    } else {
                        $_.TagNumber
                    }
                    New-UDAutoCompleteOption -Name $displayText -Value $_.CattleID
                }
            } -FullWidth
            
            New-UDElement -Tag 'br'
            
            # Weight Input
            New-UDTextbox -Id 'weight-value' -Label 'Weight (lbs) *' -Type 'number' -FullWidth
            
            New-UDElement -Tag 'br'
            New-UDElement -Tag 'br'

            # Date Picker
            New-UDDatePicker -Id 'weight-date' -Label 'Weight Date *' -Value ([DateTime]::Now)
            
            New-UDElement -Tag 'br'
            
            # Notes
            New-UDTextbox -Id 'weight-notes' -Label 'Notes (Optional)' -Multiline -Rows 3 -FullWidth
            
        } -Footer {
            New-UDButton -Text "Cancel" -OnClick { Hide-UDModal }
            New-UDButton -Text "Add Weight Record" -Variant contained -Style @{backgroundColor = '#2e7d32'; color = 'white' } -OnClick {
                $cattleId = (Get-UDElement -Id 'weight-cattle-select').value
                $weightValue = (Get-UDElement -Id 'weight-value').value
                $weightDateValue = (Get-UDElement -Id 'weight-date').value
                $notes = (Get-UDElement -Id 'weight-notes').value
                
                # Validation
                if (-not $cattleId) {
                    Show-UDToast -Message "Please select a cattle" -MessageColor red
                    return
                }
                
                if (-not $weightValue -or [decimal]$weightValue -le 0) {
                    Show-UDToast -Message "Please enter a valid weight" -MessageColor red
                    return
                }
                
                if (-not $weightDateValue) {
                    Show-UDToast -Message "Please select a date" -MessageColor red
                    return
                }
                
                try {
                    $params = @{
                        CattleID   = [int]$cattleId
                        Weight     = [decimal]$weightValue
                        WeightDate = [DateTime]$weightDateValue
                    }
                    
                    if ($notes) { $params.Notes = $notes }
                    
                    Add-WeightRecord @params
                    
                    Show-UDToast -Message "Weight record added successfully!" -MessageColor green
                    Hide-UDModal
                    Sync-UDElement -Id 'weight-records-table'
                }
                catch {
                    Show-UDToast -Message "Error adding weight record: $($_.Exception.Message)" -MessageColor red
                }
            }
        } -FullWidth -MaxWidth 'md'
    }
    
    # Weight Records Table
    New-UDDynamic -Id 'weight-records-table' -Content {
        
        # Get all weight records with cattle info
        $weightRecords = Get-AllWeightRecords
        
        $columns = @(
            New-UDTableColumn -Property TagNumber -Title "Tag #" -ShowSort
            New-UDTableColumn -Property CattleName -Title "Name" -ShowSort -Render {
                if ($EventData.CattleName) {
                    $EventData.CattleName
                } else {
                    New-UDElement -Tag 'span' -Attributes @{style = @{color = '#999'; fontStyle = 'italic'}} -Content { 'N/A' }
                }
            }
            New-UDTableColumn -Property Weight -Title "Weight (lbs)" -ShowSort -Render {
                New-UDTypography -Text "$($EventData.Weight) lbs" -Style @{fontWeight = 'bold'; color = '#2e7d32'}
            }
            New-UDTableColumn -Property WeightDate -Title "Date" -ShowSort -Render {
                Format-Date $EventData.WeightDate
            }
            New-UDTableColumn -Property Notes -Title "Notes" -Render {
                if ($EventData.Notes) {
                    $EventData.Notes
                } else {
                    New-UDElement -Tag 'span' -Attributes @{style = @{color = '#999'; fontStyle = 'italic'}} -Content { 'No notes' }
                }
            }
            New-UDTableColumn -Property Actions -Title "Actions" -Render {
                New-UDButton -Text "📊 History" -Size small -Variant outlined -Style @{borderColor = '#2e7d32'; color = '#2e7d32'} -OnClick {
                    $cattleId = $EventData.CattleID
                    $tagNumber = $EventData.TagNumber
                    $cattleName = $EventData.CattleName
                    
                    # Get weight history for this cattle
                    $weightHistory = Get-WeightHistory -CattleID $cattleId
                    
                    Show-UDModal -Content {
                        $displayName = if ($cattleName) { "$tagNumber - $cattleName" } else { $tagNumber }
                        New-UDTypography -Text "Weight History: $displayName" -Variant h5 -Style @{
                            color = '#2e7d32'
                            marginBottom = '20px'
                            fontWeight = 'bold'
                        }
                        
                        if ($weightHistory -and $weightHistory.Count -gt 0) {
                            # Chart
                            New-UDElement -Tag 'div' -Attributes @{style = @{maxHeight = '300px'; marginBottom = '20px'}} -Content {
                                $chartData = $weightHistory | Sort-Object WeightDate | ForEach-Object {
                                        $dateStr = Format-Date $_.WeightDate
                                        if ($dateStr -eq '-') { $dateStr = $_.WeightDate -replace ' \d{2}:\d{2}:\d{2}.*$', '' }
                                        [PSCustomObject]@{
                                        Date = $dateStr
                                        Weight = [decimal]$_.Weight
                                    }
                                }
                                
                                New-UDChartJS -Type line -Data $chartData -DataProperty Weight -LabelProperty Date -Options @{
                                    maintainAspectRatio = $false
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
                            
                            # Table
                                New-UDTable -Data $weightHistory -Columns @(
                                New-UDTableColumn -Property WeightDate -Title "Date" -Render {
                                    Format-Date $EventData.WeightDate
                                }
                                New-UDTableColumn -Property Weight -Title "Weight (lbs)" -Render {
                                    "$($EventData.Weight) lbs"
                                }
                                New-UDTableColumn -Property Notes -Title "Notes" -Render {
                                    if ($EventData.Notes) {
                                        $EventData.Notes
                                    } else {
                                        '-'
                                    }
                                }
                            ) -Dense -ShowSort
                            
                            # Summary Stats
                            $weights = $weightHistory | ForEach-Object { [decimal]$_.Weight }
                            $minWeight = ($weights | Measure-Object -Minimum).Minimum
                            $maxWeight = ($weights | Measure-Object -Maximum).Maximum
                            $avgWeight = ($weights | Measure-Object -Average).Average
                            
                            New-UDElement -Tag 'br'
                            New-UDCard -Style @{borderLeft = '4px solid #2e7d32'; padding = '15px'; marginTop = '20px'} -Content {
                                New-UDTypography -Text "Summary Statistics" -Variant h6 -Style @{marginBottom = '10px'; color = '#2e7d32'}
                                New-UDTypography -Text "• Total Records: $($weightHistory.Count)" -Variant body2
                                New-UDTypography -Text "• Min Weight: $minWeight lbs" -Variant body2
                                New-UDTypography -Text "• Max Weight: $maxWeight lbs" -Variant body2
                                New-UDTypography -Text "• Average Weight: $([Math]::Round($avgWeight, 2)) lbs" -Variant body2
                                New-UDTypography -Text "• Total Gain: $($maxWeight - $minWeight) lbs" -Variant body2
                            }
                        } else {
                            New-UDAlert -Severity info -Text "No weight history available for this cattle."
                        }
                        
                    } -Footer {
                        New-UDButton -Text "Close" -Variant contained -Style @{backgroundColor = '#2e7d32'; color = 'white'} -OnClick {
                            Hide-UDModal
                        }
                    } -FullWidth -MaxWidth 'lg'
                }
                
                New-UDButton -Text "🗑️ Delete" -Size small -Variant text -Style @{color = '#d32f2f'} -OnClick {
                    $weightRecordId = $EventData.WeightRecordID
                    $weightValue = $EventData.Weight
                    $dateValue = Format-Date $EventData.WeightDate
                    
                    Show-UDModal -Content {
                        New-UDTypography -Text "⚠️ Confirm Delete" -Variant h5 -Style @{color = '#d32f2f'; marginBottom = '20px'}
                        New-UDTypography -Text "Are you sure you want to delete this weight record?" -Variant body1
                        New-UDTypography -Text "Weight: $weightValue lbs on $dateValue" -Variant body2 -Style @{color = '#666'; marginTop = '10px'}
                    } -Footer {
                        New-UDButton -Text "Cancel" -OnClick { Hide-UDModal }
                        New-UDButton -Text "Delete" -Variant contained -Style @{backgroundColor = '#d32f2f'; color = 'white'} -OnClick {
                            try {
                                Remove-WeightRecord -WeightRecordID $weightRecordId
                                
                                Show-UDToast -Message "Weight record deleted successfully" -MessageColor green
                                Hide-UDModal
                                Sync-UDElement -Id 'weight-records-table'
                            }
                            catch {
                                Show-UDToast -Message "Error deleting weight record: $($_.Exception.Message)" -MessageColor red
                            }
                        }
                    }
                }
            }
        )
        
        New-UDCard -Content {
            New-UDTypography -Text "Recent Weight Records" -Variant h6 -Style @{marginBottom = '15px'; color = '#2e7d32'}
            New-UDTable -Data $weightRecords -Columns $columns -ShowPagination -PageSize 15 -ShowSearch -Dense
        }
    }
}






