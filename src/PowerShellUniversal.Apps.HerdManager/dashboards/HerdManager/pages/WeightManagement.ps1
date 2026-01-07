$weightMgmt = New-UDPage -Name 'Weight Management' -Url '/weights' -Content {
    
    # Page Header
    New-UDCard -Style (Merge-HerdStyle -BaseStyle $HerdStyles.PageHeader.Hero -CustomStyle @{
        backgroundColor = '#2e7d32'
        color           = 'white'
        padding         = '30px'
        backgroundImage = 'linear-gradient(135deg, #2e7d32 0%, #66bb6a 100%)'
    }) -Content {
        New-UDTypography -Text "⚖️ Weight Management" -Variant h4 -Style $HerdStyles.PageHeader.Title
        New-UDTypography -Text "Record and track weight measurements for your cattle" -Variant body1 -Style $HerdStyles.PageHeader.Subtitle
    }
    
    # Buttons container
    New-UDGrid -Container -Spacing 2 -Style $HerdStyles.Layout.Container -Content {
        # Add New Weight Record Button
        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -MediumSize 4 -Content {
            New-UDButton -Text "➕ Add Weight Record" -Variant contained -FullWidth -Style $HerdStyles.Button.Primary -OnClick {
                Show-UDModal -Content {
                    New-UDTypography -Text "Add Weight Record" -Variant h5 -Style $HerdStyles.Typography.ModalTitle
            
                    # Cattle Selection
                    New-UDAutocomplete -Id 'weight-cattle-select' -Label 'Select Cattle *' -Options {
                        $allCattle = Get-AllCattle | Where-Object { $_.Status -eq 'Active' }
                        $allCattle | ForEach-Object {
                            $displayText = if ($_.Name) {
                                "$($_.TagNumber) - $($_.Name)"
                            }
                            else {
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
                    New-UDButton -Text "Cancel" -OnClick { Hide-UDModal } -Variant outlined
                    New-UDButton -Text "Add Weight Record" -Variant contained -Style $HerdStyles.Button.Primary -OnClick {
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
        }
        
        # Import Weights from CSV Button
        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -MediumSize 4 -Content {
            New-UDButton -Text "📂 Import from CSV" -Variant outlined -FullWidth -Style (Merge-HerdStyle -BaseStyle $HerdStyles.Button.Secondary -CustomStyle @{
                borderColor = '#2e7d32'
                color       = '#2e7d32'
            }) -OnClick {
                Show-UDModal -Content {
                    New-UDTypography -Text "Import Weight Records from CSV" -Variant h5 -Style $HerdStyles.Typography.ModalTitle
                    
                    New-UDTypography -Text "CSV Format Requirements:" -Variant body1 -Style @{
                        fontWeight   = 'bold'
                        marginBottom = '10px'
                    }
                    
                    New-UDTypography -Text "Required columns: TagNumber, WeightDate, Weight" -Variant body2 -Style @{
                        color        = '#666'
                        marginBottom = '5px'
                    }
                    
                    New-UDTypography -Text "Optional columns: Notes" -Variant body2 -Style @{
                        color        = '#666'
                        marginBottom = '15px'
                    }
                    
                    New-UDTypography -Text "Date format: MM/dd/yyyy or yyyy-MM-dd" -Variant body2 -Style @{
                        color        = '#666'
                        marginBottom = '20px'
                    }
                    
                    New-UDUpload -Id 'weight-csv-upload' -Text 'Click or drag CSV file here' -OnUpload {
                        try {
                            $Data = $Body | ConvertFrom-Json
                            
                            if (-not $Data -or -not $Data.data) {
                                throw "No file data received"
                            }
                            
                            # Decode the base64 content
                            $base64Content = $Data.data
                            $csvBytes = [System.Convert]::FromBase64String($base64Content)
                            $csvContent = [System.Text.Encoding]::UTF8.GetString($csvBytes)
                            
                            # Parse the CSV content
                            $importedData = $csvContent | ConvertFrom-Csv
                            
                            $successCount = 0
                            $errorCount = 0
                            $errors = @()
                            
                            foreach ($row in $importedData) {
                                try {
                                    # Validate required fields
                                    if (-not $row.TagNumber) {
                                        throw "TagNumber is required"
                                    }
                                    if (-not $row.Weight) {
                                        throw "Weight is required"
                                    }
                                    if (-not $row.WeightDate) {
                                        throw "WeightDate is required"
                                    }
                                    
                                    # Find cattle by tag number
                                    $cattle = Get-AllCattle | Where-Object { $_.TagNumber -eq $row.TagNumber -and $_.Status -eq 'Active' } | Select-Object -First 1
                                    if (-not $cattle) {
                                        throw "No active cattle found with TagNumber: $($row.TagNumber)"
                                    }
                                    
                                    # Validate weight
                                    $weightValue = [decimal]$row.Weight
                                    if ($weightValue -le 0) {
                                        throw "Invalid Weight value: $($row.Weight)"
                                    }
                                    
                                    # Parse date
                                    try {
                                        $weightDate = Parse-Date $row.WeightDate
                                    }
                                    catch {
                                        throw "Invalid WeightDate format: $($row.WeightDate)"
                                    }
                                    
                                    # Build parameters
                                    $params = @{
                                        CattleID   = $cattle.CattleID
                                        Weight     = $weightValue
                                        WeightDate = $weightDate
                                    }
                                    
                                    if ($row.Notes) { $params.Notes = $row.Notes }
                                    
                                    # Add the weight record
                                    Add-WeightRecord @params
                                    $successCount++
                                    
                                }
                                catch {
                                    $errorCount++
                                    $errors += "Row with TagNumber '$($row.TagNumber)': $($_.Exception.Message)"
                                }
                            }
                            
                            # Show summary
                            $summary = "Import complete: $successCount successful, $errorCount failed"
                            if ($errorCount -gt 0) {
                                $errorList = $errors -join "`n"
                                Show-UDToast -Message "$summary`n`nErrors:`n$errorList" -MessageColor orange -Duration 10000
                            }
                            else {
                                Show-UDToast -Message $summary -MessageColor green -Duration 5000
                            }
                            
                            Hide-UDModal
                            Sync-UDElement -Id 'weight-records-table'
                            
                        }
                        catch {
                            Show-UDToast -Message "Import failed: $($_.Exception.Message)" -MessageColor red -Duration 5000
                        }
                    }
                    
                    New-UDElement -Tag 'div' -Attributes @{style = @{marginTop = '20px'; paddingTop = '20px'; borderTop = '1px solid #ddd' } } -Content {
                        New-UDTypography -Text "Download Template" -Variant body1 -Style @{
                            fontWeight   = 'bold'
                            marginBottom = '10px'
                        }
                        
                        New-UDButton -Text "📥 Download CSV Template" -Variant outlined -OnClick {
                            $templateContent = @"
TagNumber,WeightDate,Weight,Notes
"@
                           
                            Start-UDDownload -StringData $templateContent -FileName 'weight_import_template.csv' -ContentType 'text/csv'
                        }
                    }
                    
                } -Header {
                    New-UDTypography -Text "📂 Import Weight Records" -Variant h5 -Style @{
                        padding      = '20px'
                        background   = 'linear-gradient(135deg, #2e7d32 0%, #66bb6a 100%)'
                        color        = 'white'
                        margin       = '-20px -20px 20px -20px'
                        borderRadius = '8px 8px 0 0'
                    }
                } -Footer {
                    New-UDButton -Text "Close" -OnClick { Hide-UDModal } -Variant outlined
                } -FullWidth -MaxWidth 'md' -Persistent -Style @{
                    borderRadius = '8px'
                    boxShadow    = '0 8px 32px rgba(0,0,0,0.3)'
                }
            }
        }
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
                }
                else {
                    New-UDElement -Tag 'span' -Attributes @{style = @{color = '#999'; fontStyle = 'italic' } } -Content { 'N/A' }
                }
            }
            New-UDTableColumn -Property Weight -Title "Weight (lbs)" -ShowSort -Render {
                New-UDTypography -Text "$($EventData.Weight) lbs" -Style @{fontWeight = 'bold'; color = '#2e7d32' }
            }
            New-UDTableColumn -Property WeightDate -Title "Date" -ShowSort -Render {
                Format-Date $EventData.WeightDate
            }
            New-UDTableColumn -Property Notes -Title "Notes" -Render {
                if ($EventData.Notes) {
                    $EventData.Notes
                }
                else {
                    New-UDElement -Tag 'span' -Attributes @{style = @{color = '#999'; fontStyle = 'italic' } } -Content { 'No notes' }
                }
            }
            New-UDTableColumn -Property Actions -Title "Actions" -Render {
                New-UDButton -Text "📊 History" -Size small -Variant outlined -Style (Merge-HerdStyle -BaseStyle $HerdStyles.Button.Secondary -CustomStyle @{borderColor = '#2e7d32'; color = '#2e7d32' }) -OnClick {
                    $cattleId = $EventData.CattleID
                    $tagNumber = $EventData.TagNumber
                    $cattleName = $EventData.CattleName
                    
                    # Get weight history for this cattle
                    $weightHistory = Get-WeightHistory -CattleID $cattleId
                    
                    Show-UDModal -Content {
                        $displayName = if ($cattleName) { "$tagNumber - $cattleName" } else { $tagNumber }
                        New-UDTypography -Text "Weight History: $displayName" -Variant h5 -Style $HerdStyles.Typography.ModalTitle
                        
                        if ($weightHistory -and $weightHistory.Count -gt 0) {
                            # Chart
                            New-UDElement -Tag 'div' -Attributes @{style = @{maxHeight = '300px'; marginBottom = '20px' } } -Content {
                                $chartData = $weightHistory | Sort-Object WeightDate | ForEach-Object {
                                    $dateStr = Format-Date $_.WeightDate
                                    if ($dateStr -eq '-') { $dateStr = $_.WeightDate -replace ' \d{2}:\d{2}:\d{2}.*$', '' }
                                    [PSCustomObject]@{
                                        Date   = $dateStr
                                        Weight = [decimal]$_.Weight
                                    }
                                }
                                
                                New-UDChartJS -Type line -Data $chartData -DataProperty Weight -LabelProperty Date -Options @{
                                    maintainAspectRatio = $false
                                    scales              = @{
                                        y = @{
                                            beginAtZero = $false
                                            title       = @{
                                                display = $true
                                                text    = 'Weight (lbs)'
                                            }
                                        }
                                        x = @{
                                            title = @{
                                                display = $true
                                                text    = 'Date'
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
                                    }
                                    else {
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
                            New-UDCard -Style @{borderLeft = '4px solid #2e7d32'; padding = '15px'; marginTop = '20px' } -Content {
                                New-UDTypography -Text "Summary Statistics" -Variant h6 -Style @{marginBottom = '10px'; color = '#2e7d32' }
                                New-UDTypography -Text "• Total Records: $($weightHistory.Count)" -Variant body2
                                New-UDTypography -Text "• Min Weight: $minWeight lbs" -Variant body2
                                New-UDTypography -Text "• Max Weight: $maxWeight lbs" -Variant body2
                                New-UDTypography -Text "• Average Weight: $([Math]::Round($avgWeight, 2)) lbs" -Variant body2
                                New-UDTypography -Text "• Total Gain: $($maxWeight - $minWeight) lbs" -Variant body2
                            }
                        }
                        else {
                            New-UDAlert -Severity info -Text "No weight history available for this cattle."
                        }
                        
                    } -Footer {
                        New-UDButton -Text "Close" -Variant contained -Style $HerdStyles.Button.Primary -OnClick {
                            Hide-UDModal
                        }
                    } -FullWidth -MaxWidth 'lg'
                }
                
                New-UDButton -Text "🗑️ Delete" -Size small -Variant text -Style $HerdStyles.Button.Danger -OnClick {
                    $weightRecordId = $EventData.WeightRecordID
                    $weightValue = $EventData.Weight
                    $dateValue = Format-Date $EventData.WeightDate
                    
                    Show-UDModal -Content {
                        New-UDTypography -Text "⚠️ Confirm Delete" -Variant h5 -Style (Merge-HerdStyle -BaseStyle $HerdStyles.Typography.ModalTitle -CustomStyle @{color = '#d32f2f'})
                        New-UDTypography -Text "Are you sure you want to delete this weight record?" -Variant body1
                        New-UDTypography -Text "Weight: $weightValue lbs on $dateValue" -Variant body2 -Style @{color = '#666'; marginTop = '10px' }
                    } -Footer {
                        New-UDButton -Text "Cancel" -OnClick { Hide-UDModal }
                        New-UDButton -Text "Delete" -Variant contained -Style $HerdStyles.Button.Danger -OnClick {
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
            New-UDTypography -Text "Recent Weight Records" -Variant h6 -Style @{marginBottom = '15px'; color = '#2e7d32' }
            New-UDTable -Data $weightRecords -Columns $columns -ShowPagination -PageSize 15 -ShowSearch -Dense
        }
    }
}






