$cattleMgmt = New-UDPage -Name 'Cattle Management' -Url '/cattle' -Content {
    
    # Page Header
    New-UDCard -Style (Merge-HerdStyle -BaseStyle $HerdStyles.PageHeader.Hero -CustomStyle @{
        backgroundColor = '#2e7d32'
        color           = 'white'
        padding         = '30px'
        backgroundImage = 'linear-gradient(135deg, #2e7d32 0%, #66bb6a 100%)'
    }) -Content {
        New-UDTypography -Text "🐄 Cattle Management" -Variant h4 -Style $HerdStyles.PageHeader.Title
        New-UDTypography -Text "Add, edit, and manage your cattle records" -Variant body1 -Style $HerdStyles.PageHeader.Subtitle
    }
    
    New-UDGrid -Container -RowSpacing 3 -Content {
        # Add New Cattle Button
        New-UDGrid -Item -Content {
            
            New-UDButton -Text "➕ Add New Cattle" -Variant contained -Style (Merge-HerdStyle -BaseStyle $HerdStyles.Button.Primary -CustomStyle @{
                marginBottom = '20px'
            }) -OnClick {
                Show-UDModal -Content {
                    New-UDTypography -Text "Add New Cattle" -Variant h5 -Style $HerdStyles.Typography.ModalTitle
            
                    New-UDTextbox -Id 'new-tag-number' -Label 'Tag Number *' -FullWidth
                    New-UDElement -Tag 'br'
                    New-UDAutoComplete -Id 'new-origin-farm' -Label 'Origin Farm *' -Options {
                        $farms = Get-Farm -OriginOnly
                        $farms | ForEach-Object { $_.FarmName }
                    } -FullWidth -OnChange {
                        # Store the selected farm ID
                        $selectedFarm = Get-Farm -FarmName $EventData
                        Set-UDElement -Id 'new-origin-farm-id' -Properties @{value = $selectedFarm.FarmID }
                    }
                    New-UDTextbox -Id 'new-origin-farm-id' -Style @{display = 'none' }
                    New-UDElement -Tag 'br'
                    New-UDTextbox -Id 'new-name' -Label 'Name (Optional)' -FullWidth
                    New-UDElement -Tag 'br'
                    New-UDTextbox -Id 'new-breed' -Label 'Breed (Optional)' -FullWidth
                    New-UDElement -Tag 'br'
                    New-UDSelect -Id 'new-gender' -Label 'Gender' -Option {
                        New-UDSelectOption -Name 'Steer' -Value 'Steer'
                        New-UDSelectOption -Name 'Heifer' -Value 'Heifer'
                    } -FullWidth
                    New-UDElement -Tag 'br'
                    New-UDElement -Tag 'br'
                    New-UDSelect -Id 'new-location' -Label 'Location' -Option {
                        New-UDSelectOption -Name 'Pen 1' -Value 'Pen 1'
                        New-UDSelectOption -Name 'Pen 2' -Value 'Pen 2'
                        New-UDSelectOption -Name 'Pen 3' -Value 'Pen 3'
                        New-UDSelectOption -Name 'Pen 4' -Value 'Pen 4'
                        New-UDSelectOption -Name 'Pen 5' -Value 'Pen 5'
                        New-UDSelectOption -Name 'Pen 6' -Value 'Pen 6'
                        New-UDSelectOption -Name 'Quarantine' -Value 'Quarantine'
                        New-UDSelectOption -Name 'Pasture' -Value 'Pasture'
                    } -FullWidth
                    New-UDElement -Tag 'br'
                    New-UDElement -Tag 'br'
                    
                    # Owner field - dropdown if farms exist, textbox otherwise
                    New-UDDynamic -Content {
                        $farms = Get-Farm -ActiveOnly
                        if ($farms) {
                            New-UDSelect -Id 'new-owner' -Label 'Owner (optional)' -Option {
                                New-UDSelectOption -Name '(Select Farm)' -Value ''
                                $farms | ForEach-Object {
                                    New-UDSelectOption -Name $_.FarmName -Value $_.FarmName
                                }
                            } -FullWidth
                        }
                        else {
                            New-UDTextbox -Id 'new-owner' -Label 'Owner (optional)' -FullWidth
                        }
                    }
                    
                    New-UDElement -Tag 'br'
                    New-UDTextbox -Id 'new-price-per-day' -Label 'Price Per Day (optional)' -FullWidth
                    New-UDElement -Tag 'br'
                    New-UDElement -Tag 'br'
                    New-UDDatePicker -Id 'new-birth-date' -Label 'Birth Date'
                    New-UDElement -Tag 'br'
                    New-UDDatePicker -Id 'new-purchase-date' -Label 'Purchase Date'
                    New-UDElement -Tag 'br'
                    New-UDTextbox -Id 'new-notes' -Label 'Notes' -Multiline -Rows 3 -FullWidth
            
                } -Footer {
                    New-UDButton -Text "Cancel" -OnClick { Hide-UDModal }
                    New-UDButton -Text "Add Cattle" -Variant contained -Style $HerdStyles.Button.Primary -OnClick {
                        $tagNumber = (Get-UDElement -Id 'new-tag-number').value
                        $originFarm = (Get-UDElement -Id 'new-origin-farm').value
                        $originFarmID = (Get-UDElement -Id 'new-origin-farm-id').value
                        $name = (Get-UDElement -Id 'new-name').value
                        $breed = (Get-UDElement -Id 'new-breed').value
                        $gender = (Get-UDElement -Id 'new-gender').value
                        $location = (Get-UDElement -Id 'new-location').value
                        $owner = (Get-UDElement -Id 'new-owner').value
                        $pricePerDay = (Get-UDElement -Id 'new-price-per-day').value
                        $birthDateValue = (Get-UDElement -Id 'new-birth-date').value
                        $purchaseDateValue = (Get-UDElement -Id 'new-purchase-date').value
                        $notes = (Get-UDElement -Id 'new-notes').value
                
                        if (-not $tagNumber) {
                            Show-UDToast -Message "Tag Number is required" -MessageColor red
                            return
                        }
                
                        if (-not $originFarm) {
                            Show-UDToast -Message "Origin Farm is required" -MessageColor red
                            return
                        }
                
                        try {
                            $params = @{
                                TagNumber  = $tagNumber
                                OriginFarm = $originFarm
                            }
                    
                            if ($originFarmID) { $params.OriginFarmID = [int]$originFarmID }
                            if ($name) { $params.Name = $name }
                            if ($breed) { $params.Breed = $breed }
                            if ($gender) { $params.Gender = $gender }
                            if ($location) { $params.Location = $location }
                            if ($owner) { $params.Owner = $owner }
                            if ($pricePerDay) { $params.PricePerDay = [decimal]$pricePerDay }
                            if ($birthDateValue) { $params.BirthDate = [DateTime]$birthDateValue }
                            if ($purchaseDateValue) { $params.PurchaseDate = [DateTime]$purchaseDateValue }
                            if ($notes) { $params.Notes = $notes }
                    
                            Add-CattleRecord @params
                    
                            Show-UDToast -Message "Cattle record added successfully!" -MessageColor green
                            Hide-UDModal
                            Sync-UDElement -Id 'cattle-table'
                        }
                        catch {
                            Show-UDToast -Message "Error adding cattle: $($_.Exception.Message)" -MessageColor red
                        }
                    }
                } -FullWidth -MaxWidth 'md'
            }
        }

        # Import Cattle button
        New-UDGrid -Item -Content {
            New-UDButton -Text "📂 Import from CSV" -Variant outlined -Style @{
                borderColor  = '#2e7d32'
                color        = '#2e7d32'
                marginBottom = '20px'
            } -OnClick {
                Show-UDModal -Content {
                    New-UDTypography -Text "Import Cattle from CSV" -Variant h5 -Style @{
                        color        = '#2e7d32'
                        marginBottom = '20px'
                        fontWeight   = 'bold'
                    }
                    
                    New-UDTypography -Text "CSV Format Requirements:" -Variant body1 -Style @{
                        fontWeight   = 'bold'
                        marginBottom = '10px'
                    }
                    
                    New-UDTypography -Text "Required columns: TagNumber, OriginFarm" -Variant body2 -Style @{
                        color        = '#666'
                        marginBottom = '5px'
                    }
                    
                    New-UDTypography -Text "Optional columns: Name, Breed, Gender, BirthDate, PurchaseDate, Notes" -Variant body2 -Style @{
                        color        = '#666'
                        marginBottom = '15px'
                    }
                    
                    New-UDTypography -Text "Gender values: Steer, Heifer" -Variant body2 -Style @{
                        color        = '#666'
                        marginBottom = '5px'
                    }
                    
                    New-UDTypography -Text "Date format: MM/dd/yyyy or yyyy-MM-dd" -Variant body2 -Style @{
                        color        = '#666'
                        marginBottom = '20px'
                    }
                    
                    New-UDUpload -Id 'csv-upload' -Text 'Click or drag CSV file here' -OnUpload {
                        try {
                            $Data = $Body | ConvertFrom-Json
                            
                            if (-not $Data) {
                                throw "No file data received"
                            }
                            
                            # The file content is base64 encoded in the 'data' property
                            if (-not $Data.data) {
                                throw "No data property found in upload"
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
                                    if (-not $row.OriginFarm) {
                                        throw "OriginFarm is required"
                                    }
                                    
                                    # Build parameters
                                    $params = @{
                                        TagNumber  = $row.TagNumber
                                        OriginFarm = if ($row.OriginFarm) {
                                            $row.OriginFarm
                                        }
                                        else {
                                            'Unknown'
                                        }
                                    }
                                    
                                    if ($row.Name) { $params.Name = $row.Name }
                                    if ($row.Breed) { $params.Breed = $row.Breed }
                                    if ($row.Gender) { 
                                        if ($row.Gender -notin @('Steer', 'Heifer')) {
                                            throw "Invalid Gender '$($row.Gender)'. Must be 'Steer' or 'Heifer'"
                                        }
                                        $params.Gender = $row.Gender 
                                    }
                                    if ($row.Notes) { $params.Notes = $row.Notes }
                                    
                                    # Parse dates if provided
                                    if ($row.BirthDate) {
                                        try {
                                            $params.BirthDate = Parse-Date $row.BirthDate
                                        }
                                        catch {
                                            throw "Invalid BirthDate format: $($row.BirthDate)"
                                        }
                                    }
                                    
                                    if ($row.PurchaseDate) {
                                        try {
                                            $params.PurchaseDate = Parse-Date $row.PurchaseDate
                                        }
                                        catch {
                                            throw "Invalid PurchaseDate format: $($row.PurchaseDate)"
                                        }
                                    }
                                    
                                    # Add the cattle record
                                    Add-CattleRecord @params
                                    $successCount++
                                    
                                }
                                catch {
                                    $errorCount++
                                    $errors += "Row with TagNumber '$($row.TagNumber)': $($_.Exception.Message)"
                                }
                            }
                            
                            # Show summary in a new modal
                            Hide-UDModal
                            
                            Show-UDModal -Content {
                                New-UDTypography -Text "Import Results" -Variant h5 -Style @{
                                    color        = if ($errorCount -gt 0) { '#f57c00' } else { '#2e7d32' }
                                    marginBottom = '20px'
                                    fontWeight   = 'bold'
                                }
                                
                                New-UDCard -Style @{
                                    borderLeft   = '4px solid #2e7d32'
                                    marginBottom = '15px'
                                } -Content {
                                    New-UDTypography -Text "✅ Successfully Imported: $successCount" -Variant h6 -Style @{color = '#2e7d32' }
                                }
                                
                                if ($errorCount -gt 0) {
                                    New-UDCard -Style @{
                                        borderLeft   = '4px solid #f57c00'
                                        marginBottom = '15px'
                                    } -Content {
                                        New-UDTypography -Text "⚠️ Errors: $errorCount" -Variant h6 -Style @{color = '#f57c00'; marginBottom = '10px' }
                                        
                                        New-UDElement -Tag 'div' -Attributes @{style = @{
                                                maxHeight    = '300px'
                                                overflow     = 'auto'
                                                padding      = '10px'
                                                borderRadius = '4px'
                                                border       = '1px solid rgba(0,0,0,0.12)'
                                            }
                                        } -Content {
                                            foreach ($errorMsg in $errors) {
                                                New-UDTypography -Text "• $errorMsg" -Variant body2 -Style @{
                                                    color        = '#d32f2f'
                                                    marginBottom = '5px'
                                                    fontFamily   = 'monospace'
                                                }
                                            }
                                        }
                                    }
                                }
                                
                            } -Footer {
                                New-UDButton -Text "Close" -Variant contained -Style @{backgroundColor = '#2e7d32'; color = 'white' } -OnClick {
                                    Hide-UDModal
                                }
                            } -FullWidth -MaxWidth 'md' -Persistent
                            
                            Sync-UDElement -Id 'cattle-table'
                            
                        }
                        catch {
                            Hide-UDModal
                            
                            # Debug info
                            $debugInfo = @"
Error: $($_.Exception.Message)

Stack Trace:
$($_.ScriptStackTrace)

Body Content:
$Body

Data Properties:
$($Data | ConvertTo-Json -Depth 3)
"@
                            
                            Show-UDModal -Content {
                                New-UDTypography -Text "Import Error" -Variant h5 -Style @{
                                    color        = '#d32f2f'
                                    marginBottom = '20px'
                                    fontWeight   = 'bold'
                                }
                                New-UDTypography -Text "Error processing CSV file:" -Variant body1 -Style @{marginBottom = '10px' }
                                New-UDElement -Tag 'pre' -Attributes @{style = @{
                                        backgroundColor = '#ffebee'
                                        padding         = '15px'
                                        borderRadius    = '4px'
                                        color           = '#c62828'
                                        overflow        = 'auto'
                                        maxHeight       = '400px'
                                        fontSize        = '12px'
                                    }
                                } -Content {
                                    $debugInfo
                                }
                            } -Footer {
                                New-UDButton -Text "Close" -OnClick { Hide-UDModal }
                            } -FullWidth -MaxWidth 'md'
                        }
                    }
                    
                    New-UDElement -Tag 'br'
                    
                    New-UDTypography -Text "Example CSV:" -Variant body1 -Style @{
                        fontWeight   = 'bold'
                        marginTop    = '20px'
                        marginBottom = '10px'
                    }
                    
                    New-UDElement -Tag 'pre' -Attributes @{style = @{
                            backgroundColor = '#f5f5f5'
                            padding         = '10px'
                            borderRadius    = '4px'
                            fontSize        = '12px'
                            overflow        = 'auto'
                        }
                    } -Content {
                        "TagNumber,OriginFarm,Name,Breed,Gender,BirthDate,PurchaseDate,Notes
004,Smith Ranch,Betsy,Angus,Cow,01/15/2020,03/20/2021,Good temperament
005,Johnson Farm,Rocky,Hereford,Bull,05/10/2019,08/15/2020,
006,Smith Ranch,Molly,Angus,Heifer,11/22/2021,01/10/2022,First calf heifer"
                    }
                    
                } -Footer {
                    New-UDButton -Text "Close" -OnClick { Hide-UDModal }
                } -FullWidth -MaxWidth 'md'
            }
        }

        # Bulk Edit Button
        New-UDGrid -Item -Content {
            New-UDButton -Text "✏️ Bulk Edit" -Variant outlined -Style @{
                borderColor  = '#1565c0'
                color        = '#1565c0'
                marginBottom = '20px'
            } -OnClick {
                Show-UDModal -Content {
                    New-UDTypography -Text "Bulk Edit Cattle" -Variant h5 -Style @{
                        color        = '#1565c0'
                        marginBottom = '20px'
                        fontWeight   = 'bold'
                    }
                    
                    New-UDAlert -Severity 'info' -Text 'Select multiple cattle by tag number and update shared attributes like Location. Useful for moving groups of cattle together.' -Style @{marginBottom = '20px' }
                    
                    # Tag number selection
                    $allCattle = Get-AllCattle | Where-Object Status -eq 'Active'
                    $tagOptions = $allCattle | ForEach-Object { 
                        "$($_.TagNumber) - $($_.Breed) $($_.Gender) ($($_.Location))"
                    }
                    
                    New-UDAutoComplete -Id 'bulk-tags' -Label 'Select Cattle by Tag Number *' -Multiple -Options @($tagOptions) -FullWidth
                    
                    New-UDElement -Tag 'br'
                    New-UDElement -Tag 'br'
                    
                    New-UDTypography -Text "Update Fields (leave blank to skip):" -Variant subtitle1 -Style @{
                        fontWeight   = 'bold'
                        marginBottom = '15px'
                    }
                    
                    # Location field
                    New-UDSelect -Id 'bulk-location' -Label 'New Location' -Option {
                        New-UDSelectOption -Name '(No Change)' -Value ''
                        New-UDSelectOption -Name 'Pen 1' -Value 'Pen 1'
                        New-UDSelectOption -Name 'Pen 2' -Value 'Pen 2'
                        New-UDSelectOption -Name 'Pen 3' -Value 'Pen 3'
                        New-UDSelectOption -Name 'Pen 4' -Value 'Pen 4'
                        New-UDSelectOption -Name 'Pen 5' -Value 'Pen 5'
                        New-UDSelectOption -Name 'Pen 6' -Value 'Pen 6'
                        New-UDSelectOption -Name 'Quarantine' -Value 'Quarantine'
                        New-UDSelectOption -Name 'Pasture' -Value 'Pasture'
                    } -FullWidth
                    
                    New-UDElement -Tag 'br'
                    New-UDElement -Tag 'br'
                    
                    # Status field
                    New-UDSelect -Id 'bulk-status' -Label 'New Status' -Option {
                        New-UDSelectOption -Name '(No Change)' -Value ''
                        New-UDSelectOption -Name 'Active' -Value 'Active'
                        New-UDSelectOption -Name 'Sold' -Value 'Sold'
                        New-UDSelectOption -Name 'Deceased' -Value 'Deceased'
                        New-UDSelectOption -Name 'Transferred' -Value 'Transferred'
                    } -FullWidth
                    
                    New-UDElement -Tag 'br'
                    New-UDElement -Tag 'br'
                    
                    # Owner field
                    New-UDDynamic -Content {
                        $farms = Get-Farm -ActiveOnly
                        if ($farms) {
                            New-UDSelect -Id 'bulk-owner' -Label 'New Owner' -Option {
                                New-UDSelectOption -Name '(No Change)' -Value ''
                                $farms | ForEach-Object {
                                    New-UDSelectOption -Name $_.FarmName -Value $_.FarmName
                                }
                            } -FullWidth
                        }
                        else {
                            New-UDTextbox -Id 'bulk-owner' -Label 'New Owner' -FullWidth
                        }
                    }
                    
                    New-UDElement -Tag 'br'
                    New-UDElement -Tag 'br'
                    
                    # Notes field
                    New-UDTextbox -Id 'bulk-notes' -Label 'Notes to Add' -Multiline -Rows 3 -FullWidth
                    New-UDElement -Tag 'br'
                    New-UDCheckbox -Id 'bulk-append-notes' -Label 'Append to existing notes (instead of replacing)' -Checked $false
                    
                } -Footer {
                    New-UDButton -Text "Cancel" -OnClick { Hide-UDModal }
                    New-UDButton -Text "Update Selected Cattle" -Variant contained -Style @{backgroundColor = '#1565c0'; color = 'white' } -OnClick {
                        $selectedOptions = (Get-UDElement -Id 'bulk-tags').value
                        
                        # Extract tag numbers from selected options (format: "1001 - Black Angus Steer (Pen 1)")
                        $selectedTags = $selectedOptions | ForEach-Object {
                            if ($_ -match '^(\d+)') {
                                $matches[1]
                            }
                        }
                        
                        $location = (Get-UDElement -Id 'bulk-location').value
                        $status = (Get-UDElement -Id 'bulk-status').value
                        $owner = (Get-UDElement -Id 'bulk-owner').value
                        $notes = (Get-UDElement -Id 'bulk-notes').value
                        $appendNotes = (Get-UDElement -Id 'bulk-append-notes').checked
                        
                        # Validate selection
                        if (-not $selectedTags -or $selectedTags.Count -eq 0) {
                            Show-UDToast -Message "Please select at least one cattle to update" -MessageColor red
                            return
                        }
                        
                        # Validate at least one update field
                        if (-not $location -and -not $status -and -not $owner -and -not $notes) {
                            Show-UDToast -Message "Please specify at least one field to update" -MessageColor red
                            return
                        }
                        
                        try {
                            # Build parameters
                            $params = @{
                                TagNumbers = $selectedTags
                            }
                            
                            if ($location) { $params.Location = $location }
                            if ($status) { $params.Status = $status }
                            if ($owner) { $params.Owner = $owner }
                            if ($notes) { 
                                $params.Notes = $notes 
                                if ($appendNotes) {
                                    $params.AppendNotes = $true
                                }
                            }
                            
                            # Execute bulk update
                            $result = Update-BulkCattle @params
                            
                            # Show result
                            if ($result.FailedCount -gt 0) {
                                Show-UDToast -Message "Updated $($result.SuccessCount) cattle. Failed: $($result.FailedCount) ($($result.FailedTags -join ', '))" -MessageColor orange -Duration 10000
                            }
                            else {
                                Show-UDToast -Message "Successfully updated $($result.SuccessCount) cattle!" -MessageColor green
                            }
                            
                            Hide-UDModal
                            Sync-UDElement -Id 'cattle-table'
                        }
                        catch {
                            Show-UDToast -Message "Error during bulk update: $($_.Exception.Message)" -MessageColor red
                        }
                    }
                } -FullWidth -MaxWidth 'md'
            }
        }

        New-UDGrid -Item -Content {
            New-UDButton -Text "⬇️ Download Template" -Variant outlined -Style @{
                borderColor  = '#1565c0'
                color        = '#1565c0'
                marginBottom = '20px'
            } -OnClick {
                $templateContent = @"
TagNumber,OriginFarm,Name,Breed,Gender,BirthDate,PurchaseDate,Notes
"@

                Start-UDDownload -StringData $templateContent -FileName 'cattle_import_template.csv' -ContentType 'text/csv'
            }
        }
    }
   
    
    # Cattle Table
    New-UDDynamic -Id 'cattle-table' -Content {
        $cattle = Get-AllCattle
        
        $columns = @(
            New-UDTableColumn -Property TagNumber -Title 'Tag #' -ShowSort
            New-UDTableColumn -Property OriginFarm -Title 'Origin Farm' -ShowSort
            New-UDTableColumn -Property Name -Title 'Name' -ShowSort
            New-UDTableColumn -Property Gender -Title 'Gender' -ShowSort
            New-UDTableColumn -Property Location -Title 'Location' -ShowSort -Render {
                if ($EventData.Location) {
                    $EventData.Location
                }
                else {
                    'Unknown'
                }
            }
            New-UDTableColumn -Property Status -Title "Status" -ShowSort -Render {
                $color = switch ($EventData.Status) {
                    'Active' { '#2e7d32' }
                    'Sold' { '#1565c0' }
                    'Deceased' { '#d32f2f' }
                    'Transferred' { '#f57c00' }
                    default { '#666' }
                }
                New-UDChip -Label $EventData.Status -Style @{backgroundColor = $color; color = 'white' }
            }
            New-UDTableColumn -Property BirthDate -Title "Birth Date" -ShowSort -Render {
                if ($EventData.BirthDate) {
                    Format-Date $EventData.BirthDate
                }
                else {
                    'N/A'
                }
            }
            New-UDTableColumn -Property Actions -Title "Actions" -Render {
                New-UDButton -Text "✏️ Edit" -Size small -Variant text -OnClick {
                    $cattleId = $EventData.CattleID
                    $cattle = Get-CattleById -CattleID $cattleId
                    
                    Show-UDModal -Content {
                        New-UDTypography -Text "Edit Cattle Record" -Variant h5 -Style @{
                            color        = '#2e7d32'
                            marginBottom = '20px'
                            fontWeight   = 'bold'
                        }
                        
                        New-UDTextbox -Id 'edit-tag-number' -Label 'Tag Number *' -Value $cattle.TagNumber -FullWidth
                        New-UDElement -Tag 'br'
                        New-UDAutoComplete -Id 'edit-origin-farm' -Label 'Origin Farm *' -Options {
                            $farms = Get-Farm -OriginOnly
                            $farms | ForEach-Object { $_.FarmName }
                        } -Value $cattle.OriginFarm -FullWidth -OnChange {
                            # Store the selected farm ID
                            $selectedFarm = Get-Farm -FarmName $EventData
                            Set-UDElement -Id 'edit-origin-farm-id' -Properties @{value = $selectedFarm.FarmID }
                        }
                        New-UDTextbox -Id 'edit-origin-farm-id' -Value $cattle.OriginFarmID -Style @{display = 'none' }
                        New-UDElement -Tag 'br'
                        New-UDTextbox -Id 'edit-name' -Label 'Name' -Value $cattle.Name -FullWidth
                        New-UDElement -Tag 'br'
                        New-UDTextbox -Id 'edit-breed' -Label 'Breed (Optional)' -Value $cattle.Breed -FullWidth
                        New-UDElement -Tag 'br'
                        New-UDSelect -Id 'edit-gender' -Label 'Gender' -DefaultValue $cattle.Gender -Option {
                            New-UDSelectOption -Name 'Steer' -Value 'Steer'
                            New-UDSelectOption -Name 'Heifer' -Value 'Heifer'
                        } -FullWidth
                        New-UDElement -Tag 'br'
                        New-UDSelect -Id 'edit-location' -Label 'Location' -DefaultValue $(if ($cattle.Location) { $cattle.Location } else { 'Unknown' })-Option {
                            New-UDSelectOption -Name 'Pen 1' -Value 'Pen 1'
                            New-UDSelectOption -Name 'Pen 2' -Value 'Pen 2'
                            New-UDSelectOption -Name 'Pen 3' -Value 'Pen 3'
                            New-UDSelectOption -Name 'Pen 4' -Value 'Pen 4'
                            New-UDSelectOption -Name 'Pen 5' -Value 'Pen 5'
                            New-UDSelectOption -Name 'Pen 6' -Value 'Pen 6'
                            New-UDSelectOption -Name 'Quarantine' -Value 'Quarantine'
                            New-UDSelectOption -Name 'Pasture' -Value 'Pasture'
                        }
                        New-UDElement -Tag 'br'
                        
                        # Owner field - dropdown if farms exist, textbox otherwise
                        New-UDDynamic -Content {
                            $farms = Get-Farm -ActiveOnly
                            if ($farms) {
                                New-UDSelect -Id 'edit-owner' -Label 'Owner (optional)' -DefaultValue $cattle.Owner -Option {
                                    New-UDSelectOption -Name '(Select Farm)' -Value ''
                                    $farms | ForEach-Object {
                                        New-UDSelectOption -Name $_.FarmName -Value $_.FarmName
                                    }
                                } -FullWidth
                            }
                            else {
                                New-UDTextbox -Id 'edit-owner' -Label 'Owner (optional)' -Value $cattle.Owner -FullWidth
                            }
                        }
                        
                        New-UDElement -Tag 'br'
                        New-UDTextbox -Id 'edit-price-per-day' -Label 'Price Per Day (optional)' -Value $cattle.PricePerDay -FullWidth
                        New-UDElement -Tag 'br'
                        New-UDSelect -Id 'edit-status' -Label 'Status' -DefaultValue $(if ($cattle.Status) { $cattle.Status } else { 'Active' }) -Option {
                            New-UDSelectOption -Name 'Active' -Value 'Active'
                            New-UDSelectOption -Name 'Sold' -Value 'Sold'
                        } -FullWidth
                        New-UDElement -Tag 'br'
                        New-UDElement -Tag 'br'
                        New-UDElement -Tag 'br'
                        
                        # Birth Date - only pass Value if not null
                        if ($cattle.BirthDate) {
                            New-UDDatePicker -Id 'edit-birth-date' -Label 'Birth Date' -Value $cattle.BirthDate
                        } else {
                            New-UDDatePicker -Id 'edit-birth-date' -Label 'Birth Date'
                        }
                        
                        New-UDElement -Tag 'br'
                        
                        # Purchase Date - only pass Value if not null
                        if ($cattle.PurchaseDate) {
                            New-UDDatePicker -Id 'edit-purchase-date' -Label 'Purchase Date' -Value $cattle.PurchaseDate
                        } else {
                            New-UDDatePicker -Id 'edit-purchase-date' -Label 'Purchase Date'
                        }
                        
                        New-UDElement -Tag 'br'
                        New-UDTextbox -Id 'edit-notes' -Label 'Notes' -Value $cattle.Notes -Multiline -Rows 3 -FullWidth
                        
                    } -Footer {
                        New-UDButton -Text "Cancel" -OnClick { Hide-UDModal }
                        New-UDButton -Text "Update" -Variant contained -Style @{backgroundColor = '#2e7d32'; color = 'white' } -OnClick {
                            $tagNumber = (Get-UDElement -Id 'edit-tag-number').value
                            $originFarm = (Get-UDElement -Id 'edit-origin-farm').value
                            $originFarmID = (Get-UDElement -Id 'edit-origin-farm-id').value
                            $name = (Get-UDElement -Id 'edit-name').value
                            $breed = (Get-UDElement -Id 'edit-breed').value
                            $gender = (Get-UDElement -Id 'edit-gender').value
                            $location = (Get-UDElement -Id 'edit-location').value
                            $owner = (Get-UDElement -Id 'edit-owner').value
                            $pricePerDay = (Get-UDElement -Id 'edit-price-per-day').value
                            $status = (Get-UDElement -Id 'edit-status').value
                            $birthDateValue = (Get-UDElement -Id 'edit-birth-date').value
                            $purchaseDateValue = (Get-UDElement -Id 'edit-purchase-date').value
                            $notes = (Get-UDElement -Id 'edit-notes').value
                            
                            if (-not $tagNumber) {
                                Show-UDToast -Message "Tag Number is required" -MessageColor red
                                return
                            }
                            
                            if (-not $originFarm) {
                                Show-UDToast -Message "Origin Farm is required" -MessageColor red
                                return
                            }
                            
                            try {
                                $params = @{
                                    CattleID   = $cattleId
                                    TagNumber  = $tagNumber
                                    OriginFarm = $originFarm
                                    Name       = $name
                                    Breed      = $breed
                                    Gender     = $gender
                                    Status     = $status
                                    Location   = $location
                                    Notes      = $notes
                                }
                                
                                if ($originFarmID) { $params.OriginFarmID = [int]$originFarmID }
                                if ($owner) { $params.Owner = $owner }
                                if ($pricePerDay) { $params.PricePerDay = [decimal]$pricePerDay }
                                if ($birthDateValue) { $params.BirthDate = [DateTime]$birthDateValue }
                                if ($purchaseDateValue) { $params.PurchaseDate = [DateTime]$purchaseDateValue }
                                
                                Update-CattleRecord @params
                                
                                Show-UDToast -Message "Cattle record updated successfully!" -MessageColor green
                                Hide-UDModal
                                Sync-UDElement -Id 'cattle-table'
                            }
                            catch {
                                Show-UDToast -Message "Error updating cattle: $($_.Exception.Message)" -MessageColor red
                            }
                        }
                    } -FullWidth -MaxWidth 'md'
                }
                
                New-UDButton -Text "🗑️ Delete" -Size small -Variant text -Style @{color = '#d32f2f' } -OnClick {
                    $cattleId = $EventData.CattleID
                    $tagNumber = $EventData.TagNumber
                    
                    Show-UDModal -Content {
                        New-UDTypography -Text "⚠️ Confirm Delete" -Variant h5 -Style @{color = '#d32f2f'; marginBottom = '20px' }
                        New-UDTypography -Text "Are you sure you want to delete cattle record $tagNumber?" -Variant body1
                        New-UDTypography -Text "This will permanently delete the record and all associated weight records and calculations." -Variant body2 -Style @{color = '#666'; marginTop = '10px' }
                    } -Footer {
                        New-UDButton -Text "Cancel" -OnClick { Hide-UDModal }
                        New-UDButton -Text "Delete" -Variant contained -Style @{backgroundColor = '#d32f2f'; color = 'white' } -OnClick {
                            try {
                                Remove-CattleRecord -CattleID $cattleId
                                Show-UDToast -Message "Cattle record deleted successfully" -MessageColor green
                                Hide-UDModal
                                Sync-UDElement -Id 'cattle-table'
                            }
                            catch {
                                Show-UDToast -Message "Error deleting cattle: $($_.Exception.Message)" -MessageColor red
                            }
                        }
                    }
                }
            }
        )
        
        New-UDTable -Data $cattle -Columns $columns -ShowPagination -PageSize 10 -ShowSearch -Dense -ShowSort -ShowExport
    }
}






