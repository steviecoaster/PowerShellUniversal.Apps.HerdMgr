$healthMgmt = New-UDPage -Name 'Health Records' -Url '/health' -Content {
    
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
        New-UDTypography -Text "🩺 Health Records" -Variant h4 -Style @{
            fontWeight   = 'bold'
            marginBottom = '10px'
        }
        New-UDTypography -Text "Track vaccinations, treatments, and health observations for your herd" -Variant body1 -Style @{
            opacity = '0.9'
        }
    }
    
    New-UDGrid -Container -Spacing 3 -Content {
        # Add New Health Record Button
        New-UDGrid -Item -Content {
            New-UDButton -Text "➕ Add Health Record" -Variant contained -Style @{
                backgroundColor = '#2e7d32'
                color           = 'white'
                marginBottom    = '20px'
            } -OnClick {
                Show-UDModal -Content {
                    New-UDTypography -Text "Add Health Record" -Variant h5 -Style @{
                        color        = '#2e7d32'
                        marginBottom = '20px'
                        fontWeight   = 'bold'
                    }
                    
                    # Cattle Selection
                    New-UDAutocomplete -Id 'health-cattle-select' -Label 'Select Cattle *' -Options {
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
                    
                    # Record Type
                    New-UDSelect -Id 'health-record-type' -Label 'Record Type *' -Option {
                        New-UDSelectOption -Name 'Vaccination' -Value 'Vaccination'
                        New-UDSelectOption -Name 'Treatment' -Value 'Treatment'
                        New-UDSelectOption -Name 'Observation' -Value 'Observation'
                        New-UDSelectOption -Name 'Veterinary Visit' -Value 'Veterinary Visit'
                        New-UDSelectOption -Name 'Other' -Value 'Other'
                    } -FullWidth
                    
                    New-UDElement -Tag 'br'
                    New-UDElement -Tag 'br'
                    
                    # Title
                    New-UDTextbox -Id 'health-title' -Label 'Title *' -FullWidth
                    
                    New-UDElement -Tag 'br'
                    New-UDElement -Tag 'br'

                    # Date
                    New-UDDatePicker -Id 'health-record-date' -Label 'Record Date *' -Value ([DateTime]::Now)
                    
                    New-UDElement -Tag 'br'
                    
                    # Description
                    New-UDTextbox -Id 'health-description' -Label 'Description' -Multiline -Rows 3 -FullWidth
                    
                    New-UDElement -Tag 'br'
                    
                    # Veterinarian Name
                    New-UDTextbox -Id 'health-vet-name' -Label 'Veterinarian Name' -FullWidth
                    
                    New-UDElement -Tag 'br'
                    
                    # Medication
                    New-UDTextbox -Id 'health-medication' -Label 'Medication/Product' -FullWidth
                    
                    New-UDElement -Tag 'br'
                    
                    # Dosage
                    New-UDTextbox -Id 'health-dosage' -Label 'Dosage' -FullWidth
                    
                    New-UDElement -Tag 'br'
                    
                    # Cost
                    New-UDTextbox -Id 'health-cost' -Label 'Cost ($)' -Type 'number' -FullWidth
                    
                    New-UDElement -Tag 'br'
                    New-UDElement -Tag 'br'
                    New-UDElement -Tag 'br'
                    
                    # Next Due Date
                    New-UDDatePicker -Id 'health-next-due' -Label 'Next Due Date (Optional)'
                    
                    New-UDElement -Tag 'br'
                    
                    # Notes
                    New-UDTextbox -Id 'health-notes' -Label 'Notes' -Multiline -Rows 3 -FullWidth
                    
                } -Footer {
                    New-UDButton -Text "Cancel" -OnClick { Hide-UDModal }
                    New-UDButton -Text "Add Health Record" -Variant contained -Style @{backgroundColor = '#2e7d32'; color = 'white' } -OnClick {
                        $cattleId = (Get-UDElement -Id 'health-cattle-select').value
                        $recordType = (Get-UDElement -Id 'health-record-type').value
                        $title = (Get-UDElement -Id 'health-title').value
                        $recordDateValue = (Get-UDElement -Id 'health-record-date').value
                        $description = (Get-UDElement -Id 'health-description').value
                        $vetName = (Get-UDElement -Id 'health-vet-name').value
                        $medication = (Get-UDElement -Id 'health-medication').value
                        $dosage = (Get-UDElement -Id 'health-dosage').value
                        $costValue = (Get-UDElement -Id 'health-cost').value
                        $nextDueValue = (Get-UDElement -Id 'health-next-due').value
                        $notes = (Get-UDElement -Id 'health-notes').value
                        
                        # Validation
                        if (-not $cattleId) {
                            Show-UDToast -Message "Please select a cattle" -MessageColor red
                            return
                        }
                        
                        if (-not $recordType) {
                            Show-UDToast -Message "Please select a record type" -MessageColor red
                            return
                        }
                        
                        if (-not $title) {
                            Show-UDToast -Message "Please enter a title" -MessageColor red
                            return
                        }
                        
                        if (-not $recordDateValue) {
                            Show-UDToast -Message "Please select a record date" -MessageColor red
                            return
                        }
                        
                        try {
                            $params = @{
                                CattleID   = [int]$cattleId
                                RecordType = $recordType
                                Title      = $title
                                RecordDate = [DateTime]$recordDateValue
                            }
                            
                            if ($description) { $params.Description = $description }
                            if ($vetName) { $params.VeterinarianName = $vetName }
                            if ($medication) { $params.Medication = $medication }
                            if ($dosage) { $params.Dosage = $dosage }
                            if ($costValue) { $params.Cost = [decimal]$costValue }
                            if ($nextDueValue) { $params.NextDueDate = [DateTime]$nextDueValue }
                            if ($notes) { $params.Notes = $notes }
                            
                            Add-HealthRecord @params
                            
                            Show-UDToast -Message "Health record added successfully!" -MessageColor green
                            Hide-UDModal
                            Sync-UDElement -Id 'health-records-table'
                            Sync-UDElement -Id 'upcoming-events-card'
                        }
                        catch {
                            Show-UDToast -Message "Error adding health record: $($_.Exception.Message)" -MessageColor red
                        }
                    }
                } -FullWidth -MaxWidth 'md'
            }
        }
        
        # Upcoming Events Table
        New-UDGrid -Item -ExtraSmallSize 12 -Content {
            New-UDDynamic -Id 'upcoming-events-card' -Content {
                $upcomingEvents = Get-UpcomingHealthEvents -DaysAhead 30
                
                if ($upcomingEvents -and $upcomingEvents.Count -gt 0) {
                    New-UDCard -Content {
                        New-UDTypography -Text "📅 Upcoming Health Events (Next 30 Days)" -Variant h6 -Style @{
                            color        = '#ff6f00'
                            marginBottom = '15px'
                            fontWeight   = 'bold'
                        }
                        
                        New-UDTable -Data $upcomingEvents -Columns @(
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
                                try {
                                    ([DateTime]::Parse($EventData.NextDueDate)).ToString('MM/dd/yyyy')
                                } catch {
                                    $EventData.NextDueDate -replace ' \d{2}:\d{2}:\d{2}.*$', ''
                                }
                            }
                            New-UDTableColumn -Property DaysUntilDue -Title "Days Until" -ShowSort -Render {
                                $daysUntil = $EventData.DaysUntilDue
                                $color = if ($daysUntil -le 7) { '#d32f2f' } elseif ($daysUntil -le 14) { '#f57c00' } else { '#1976d2' }
                                $weight = if ($daysUntil -le 7) { 'bold' } else { 'normal' }
                                New-UDElement -Tag 'span' -Attributes @{style = @{color = $color; fontWeight = $weight}} -Content { "$daysUntil days" }
                            }
                            New-UDTableColumn -Property HealthRecordID -Title "Actions" -Render {
                                New-UDButton -Text "Details" -Size small -Variant outlined -OnClick {
                                    $evt = $EventData
                                    $daysUntil = $evt.DaysUntilDue
                                    $urgency = if ($daysUntil -le 7) { 'high' } elseif ($daysUntil -le 14) { 'medium' } else { 'low' }
                                    $urgencyColor = switch ($urgency) {
                                        'high' { '#d32f2f' }
                                        'medium' { '#f57c00' }
                                        'low' { '#1976d2' }
                                    }
                                    
                                    Show-UDModal -Content {
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
                                                New-UDTypography -Text "Due Date: $(([DateTime]::Parse($evt.NextDueDate)).ToString('MM/dd/yyyy'))" -Variant body1
                                                New-UDTypography -Text "Days Until: $daysUntil days" -Variant body1 -Style @{
                                                    color = $urgencyColor
                                                    fontWeight = 'bold'
                                                }
                                                if ($evt.RecordedBy) {
                                                    New-UDTypography -Text "Recorded By: $($evt.RecordedBy)" -Variant body2 -Style @{opacity = 0.7; marginTop = '10px'}
                                                }
                                            }
                                        }
                                    } -Header {
                                        New-UDTypography -Text "📅 Upcoming Health Event" -Variant h5
                                    } -Footer {
                                        New-UDButton -Text "Close" -OnClick { Hide-UDModal }
                                    } -FullWidth -MaxWidth 'md'
                                }
                            }
                        ) -Sort -PageSize 10 -Dense -ShowPagination
                    }
                }
            }
        }
    }
    
    # Health Records Table
    New-UDDynamic -Id 'health-records-table' -Content {
        
        $healthRecords = Get-HealthRecords
        
        $columns = @(
            New-UDTableColumn -Property TagNumber -Title "Tag #" -ShowSort
            New-UDTableColumn -Property CattleName -Title "Name" -ShowSort -Render {
                if ($EventData.CattleName) {
                    $EventData.CattleName
                } else {
                    New-UDElement -Tag 'span' -Attributes @{style = @{color = '#999'; fontStyle = 'italic'}} -Content { 'N/A' }
                }
            }
            New-UDTableColumn -Property RecordDate -Title "Date" -ShowSort -Render {
                ([DateTime]$EventData.RecordDate).ToString('MM/dd/yyyy')
            }
            New-UDTableColumn -Property RecordType -Title "Type" -ShowSort -Render {
                $color = switch ($EventData.RecordType) {
                    'Vaccination' { '#2e7d32' }
                    'Treatment' { '#1976d2' }
                    'Observation' { '#f57c00' }
                    'Veterinary Visit' { '#7b1fa2' }
                    default { '#666' }
                }
                New-UDChip -Label $EventData.RecordType -Style @{backgroundColor = $color; color = 'white'; fontSize = '11px'}
            }
            New-UDTableColumn -Property Title -Title "Title" -ShowSort
            New-UDTableColumn -Property Medication -Title "Medication" -Render {
                if ($EventData.Medication) {
                    $EventData.Medication
                } else {
                    '-'
                }
            }
            New-UDTableColumn -Property Cost -Title "Cost" -ShowSort -Render {
                if ($EventData.Cost) {
                    "`$$($EventData.Cost)"
                } else {
                    '-'
                }
            }
            New-UDTableColumn -Property NextDueDate -Title "Next Due" -ShowSort -Render {
                if ($EventData.NextDueDate) {
                    ([DateTime]$EventData.NextDueDate).ToString('MM/dd/yyyy')
                } else {
                    '-'
                }
            }
            New-UDTableColumn -Property Actions -Title "Actions" -Render {
                New-UDButton -Text "📋 Details" -Size small -Variant outlined -Style @{borderColor = '#2e7d32'; color = '#2e7d32'} -OnClick {
                    $record = $EventData
                    
                    Show-UDModal -Content {
                        New-UDTypography -Text "Health Record Details" -Variant h5 -Style @{
                            color        = '#2e7d32'
                            marginBottom = '20px'
                            fontWeight   = 'bold'
                        }
                        
                        New-UDCard -Style @{marginBottom = '15px'; padding = '15px'} -Content {
                            New-UDTypography -Text "Cattle Information" -Variant h6 -Style @{marginBottom = '10px'; color = '#2e7d32'}
                            New-UDTypography -Text "Tag: $($record.TagNumber)$(if($record.CattleName){" - $($record.CattleName)"})" -Variant body1
                        }
                        
                        New-UDCard -Style @{marginBottom = '15px'; padding = '15px'} -Content {
                            New-UDTypography -Text "Record Details" -Variant h6 -Style @{marginBottom = '10px'; color = '#2e7d32'}
                            New-UDTypography -Text "Type: $($record.RecordType)" -Variant body2
                            New-UDTypography -Text "Title: $($record.Title)" -Variant body2
                            New-UDTypography -Text "Date: $(([DateTime]$record.RecordDate).ToString('MM/dd/yyyy'))" -Variant body2
                            if ($record.Description) {
                                New-UDElement -Tag 'br'
                                New-UDTypography -Text "Description:" -Variant body2 -Style @{fontWeight = 'bold'}
                                New-UDTypography -Text $record.Description -Variant body2
                            }
                        }
                        
                        if ($record.VeterinarianName -or $record.Medication -or $record.Dosage -or $record.Cost) {
                            New-UDCard -Style @{marginBottom = '15px'; padding = '15px'} -Content {
                                New-UDTypography -Text "Treatment Details" -Variant h6 -Style @{marginBottom = '10px'; color = '#2e7d32'}
                                if ($record.VeterinarianName) {
                                    New-UDTypography -Text "Veterinarian: $($record.VeterinarianName)" -Variant body2
                                }
                                if ($record.Medication) {
                                    New-UDTypography -Text "Medication: $($record.Medication)" -Variant body2
                                }
                                if ($record.Dosage) {
                                    New-UDTypography -Text "Dosage: $($record.Dosage)" -Variant body2
                                }
                                if ($record.Cost) {
                                    New-UDTypography -Text "Cost: `$$($record.Cost)" -Variant body2
                                }
                            }
                        }
                        
                        if ($record.NextDueDate) {
                            New-UDCard -Style @{borderLeft = '4px solid #2e7d32'; padding = '15px'; marginBottom = '15px'} -Content {
                                New-UDTypography -Text "📅 Next Due Date: $(([DateTime]$record.NextDueDate).ToString('MM/dd/yyyy'))" -Variant body1 -Style @{
                                    fontWeight = 'bold'
                                    color      = '#2e7d32'
                                }
                            }
                        }
                        
                        if ($record.Notes) {
                            New-UDCard -Style @{marginBottom = '15px'; padding = '15px'} -Content {
                                New-UDTypography -Text "Notes" -Variant h6 -Style @{marginBottom = '10px'; color = '#2e7d32'}
                                New-UDTypography -Text $record.Notes -Variant body2
                            }
                        }
                        
                    } -Footer {
                        New-UDButton -Text "Close" -Variant contained -Style @{backgroundColor = '#2e7d32'; color = 'white'} -OnClick {
                            Hide-UDModal
                        }
                    } -FullWidth -MaxWidth 'md'
                }
                
                New-UDButton -Text "🗑️ Delete" -Size small -Variant text -Style @{color = '#d32f2f'} -OnClick {
                    $healthRecordId = $EventData.HealthRecordID
                    $title = $EventData.Title
                    $dateValue = ([DateTime]$EventData.RecordDate).ToString('MM/dd/yyyy')
                    
                    Show-UDModal -Content {
                        New-UDTypography -Text "⚠️ Confirm Delete" -Variant h5 -Style @{color = '#d32f2f'; marginBottom = '20px'}
                        New-UDTypography -Text "Are you sure you want to delete this health record?" -Variant body1
                        New-UDTypography -Text "$title on $dateValue" -Variant body2 -Style @{color = '#666'; marginTop = '10px'}
                    } -Footer {
                        New-UDButton -Text "Cancel" -OnClick { Hide-UDModal }
                        New-UDButton -Text "Delete" -Variant contained -Style @{backgroundColor = '#d32f2f'; color = 'white'} -OnClick {
                            try {
                                Remove-HealthRecord -HealthRecordID $healthRecordId
                                
                                Show-UDToast -Message "Health record deleted successfully" -MessageColor green
                                Hide-UDModal
                                Sync-UDElement -Id 'health-records-table'
                                Sync-UDElement -Id 'upcoming-events-card'
                            }
                            catch {
                                Show-UDToast -Message "Error deleting health record: $($_.Exception.Message)" -MessageColor red
                            }
                        }
                    }
                }
            }
        )
        
        New-UDCard -Content {
            New-UDTypography -Text "Health Records" -Variant h6 -Style @{marginBottom = '15px'; color = '#2e7d32'}
            New-UDTable -Data $healthRecords -Columns $columns -ShowPagination -PageSize 15 -ShowSearch -Dense
        }
    }
}
