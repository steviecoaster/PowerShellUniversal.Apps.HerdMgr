$farmsPage = New-UDPage -Name "Farms" -Content {
    $dbPath = $script:DatabasePath
    
    New-UDTypography -Text "🚜 Farm Management" -Variant h4 -Style $HerdStyles.Typography.PageTitle
    
    # Add New Farm Section
    New-UDCard -Title "Add New Farm" -Style $HerdStyles.Card.Default -Content {
        New-UDGrid -Container -Content {
            New-UDGrid -Item -ExtraSmallSize 12 -MediumSize 6 -Content {
                New-UDTextbox -Id 'new-farm-name' -Label 'Farm Name *' -FullWidth
            }
            New-UDGrid -Item -ExtraSmallSize 12 -MediumSize 6 -Content {
                New-UDTextbox -Id 'new-farm-contact' -Label 'Contact Person' -FullWidth
            }
        }
        
        New-UDGrid -Container -Content {
            New-UDGrid -Item -ExtraSmallSize 12 -Content {
                New-UDTextbox -Id 'new-farm-address' -Label 'Street Address' -FullWidth
            }
        }
        
        New-UDGrid -Container -Content {
            New-UDGrid -Item -ExtraSmallSize 12 -MediumSize 4 -Content {
                New-UDTextbox -Id 'new-farm-city' -Label 'City' -FullWidth
            }
            New-UDGrid -Item -ExtraSmallSize 6 -MediumSize 4 -Content {
                New-UDTextbox -Id 'new-farm-state' -Label 'State' -FullWidth
            }
            New-UDGrid -Item -ExtraSmallSize 6 -MediumSize 4 -Content {
                New-UDTextbox -Id 'new-farm-zip' -Label 'Zip Code' -FullWidth
            }
        }
        
        New-UDGrid -Container -Content {
            New-UDGrid -Item -ExtraSmallSize 12 -MediumSize 6 -Content {
                New-UDTextbox -Id 'new-farm-phone' -Label 'Phone Number' -FullWidth
            }
            New-UDGrid -Item -ExtraSmallSize 12 -MediumSize 6 -Content {
                New-UDTextbox -Id 'new-farm-email' -Label 'Email Address' -FullWidth
            }
        }
        
        New-UDTextbox -Id 'new-farm-notes' -Label 'Notes' -Multiline -Rows 3 -FullWidth
        New-UDElement -Tag 'br'
        New-UDCheckbox -Id 'new-farm-is-origin' -Label 'This farm is a cattle origin (can be selected when adding cattle)'
        New-UDElement -Tag 'br'
        
        New-UDButton -Text "➕ Add Farm" -Variant contained -FullWidth -Style @{
            backgroundColor = '#2e7d32'
            color           = 'white'
            marginTop       = '10px'
        } -OnClick {
            $farmName = (Get-UDElement -Id 'new-farm-name').value
            $contactPerson = (Get-UDElement -Id 'new-farm-contact').value
            $address = (Get-UDElement -Id 'new-farm-address').value
            $city = (Get-UDElement -Id 'new-farm-city').value
            $state = (Get-UDElement -Id 'new-farm-state').value
            $zip = (Get-UDElement -Id 'new-farm-zip').value
            $phone = (Get-UDElement -Id 'new-farm-phone').value
            $email = (Get-UDElement -Id 'new-farm-email').value
            $notes = (Get-UDElement -Id 'new-farm-notes').value
            $isOrigin = [Boolean]::Parse($(Get-UDElement -Id 'new-farm-is-origin').checked)
            
            if (-not $farmName) {
                Show-UDToast -Message "Farm name is required" -MessageColor red
                return
            }

            # Ensure we don't emit stray values to the pipeline and only
            # include the IsOrigin switch when checked. Passing a raw
            # boolean or text into a switch parameter via splatting can
            # sometimes produce unexpected parsing behavior when the
            # scriptblock is serialized by the dashboard engine.
            
            try {
                $farmParams = @{
                    FarmName      = $farmName
                    ContactPerson = $contactPerson
                    Address       = $address
                    City          = $city
                    State         = $state
                    ZipCode       = $zip
                    PhoneNumber   = $phone
                    Email         = $email
                    Notes         = $notes
                    # IsOrigin will be added below only when true
                }

                if ($isOrigin -eq $true) {
                    # Add switch key only when checked so Add-Farm receives
                    # the switch as a SwitchParameter object (so .IsPresent
                    # is available inside the function).
                    $farmParams['IsOrigin'] = [System.Management.Automation.SwitchParameter]::new($true)
                }
                
                Add-Farm @farmParams
                
                Show-UDToast -Message "Farm added successfully!" -MessageColor green
                
                # Clear form
                Set-UDElement -Id 'new-farm-name' -Properties @{value = '' }
                Set-UDElement -Id 'new-farm-contact' -Properties @{value = '' }
                Set-UDElement -Id 'new-farm-address' -Properties @{value = '' }
                Set-UDElement -Id 'new-farm-city' -Properties @{value = '' }
                Set-UDElement -Id 'new-farm-state' -Properties @{value = '' }
                Set-UDElement -Id 'new-farm-zip' -Properties @{value = '' }
                Set-UDElement -Id 'new-farm-phone' -Properties @{value = '' }
                Set-UDElement -Id 'new-farm-email' -Properties @{value = '' }
                Set-UDElement -Id 'new-farm-notes' -Properties @{value = '' }
                
                Sync-UDElement -Id 'farms-table'
            }
            catch {
                Show-UDToast -Message "Error adding farm: $($_.Exception.Message)" -MessageColor red
            }
        }
    }
    
    # Farms Table
    New-UDCard -Title "All Farms" -Content {
        New-UDDynamic -Id 'farms-table' -Content {
            $farms = Get-Farm -All
            
            if (-not $farms) {
                New-UDTypography -Text "No farms found. Add your first farm above!" -Variant body2 -Style @{
                    color     = '#666'
                    textAlign = 'center'
                    marginTop = '20px'
                }
            }
            else {
                New-UDTable -Data $farms -Columns @(
                    New-UDTableColumn -Property FarmName -Title "Farm Name" -ShowSort
                    New-UDTableColumn -Property ContactPerson -Title "Contact" -ShowSort
                    New-UDTableColumn -Property City -Title "City" -ShowSort
                    New-UDTableColumn -Property State -Title "State" -ShowSort
                    New-UDTableColumn -Property PhoneNumber -Title "Phone" -ShowSort
                    New-UDTableColumn -Property Email -Title "Email" -ShowSort
                    New-UDTableColumn -Property IsOrigin -Title "Is Origin" -Render {
                        if ($EventData.IsOrigin -eq 1) {
                            New-UDChip -Label "Origin" -Size small -Style @{backgroundColor = '#2196f3'; color = 'white' }
                        }
                        else {
                            New-UDChip -Label "-" -Size small -Style @{backgroundColor = '#e0e0e0'; color = '#666' }
                        }
                    }
                    New-UDTableColumn -Property IsActive -Title "Active" -Render {
                        if ($EventData.IsActive -eq 1) {
                            New-UDChip -Label "Active" -Size small -Style @{backgroundColor = '#4caf50'; color = 'white' }
                        }
                        else {
                            New-UDChip -Label "Inactive" -Size small -Style @{backgroundColor = '#9e9e9e'; color = 'white' }
                        }
                    }
                    New-UDTableColumn -Property Actions -Title "Actions" -Render {
                        New-UDButton -Text "✏️ Edit" -Size small -Variant text -OnClick {
                            $farm = $EventData
                            Show-UDModal -Content {
                                New-UDTypography -Text "Edit Farm: $($farm.FarmName)" -Variant h5 -Style @{
                                    color        = '#2e7d32'
                                    marginBottom = '20px'
                                }
                                
                                New-UDTextbox -Id 'edit-farm-name' -Label 'Farm Name' -Value $farm.FarmName -FullWidth
                                New-UDElement -Tag 'br'
                                New-UDTextbox -Id 'edit-farm-contact' -Label 'Contact Person' -Value $farm.ContactPerson -FullWidth
                                New-UDElement -Tag 'br'
                                New-UDTextbox -Id 'edit-farm-address' -Label 'Street Address' -Value $farm.Address -FullWidth
                                New-UDElement -Tag 'br'
                                
                                New-UDGrid -Container -Content {
                                    New-UDGrid -Item -ExtraSmallSize 4 -Content {
                                        New-UDTextbox -Id 'edit-farm-city' -Label 'City' -Value $farm.City -FullWidth
                                    }
                                    New-UDGrid -Item -ExtraSmallSize 4 -Content {
                                        New-UDTextbox -Id 'edit-farm-state' -Label 'State' -Value $farm.State -FullWidth
                                    }
                                    New-UDGrid -Item -ExtraSmallSize 4 -Content {
                                        New-UDTextbox -Id 'edit-farm-zip' -Label 'Zip' -Value $farm.ZipCode -FullWidth
                                    }
                                }
                                
                                New-UDTextbox -Id 'edit-farm-phone' -Label 'Phone' -Value $farm.PhoneNumber -FullWidth
                                New-UDElement -Tag 'br'
                                New-UDTextbox -Id 'edit-farm-email' -Label 'Email' -Value $farm.Email -FullWidth
                                New-UDElement -Tag 'br'
                                New-UDTextbox -Id 'edit-farm-notes' -Label 'Notes' -Value $farm.Notes -Multiline -Rows 3 -FullWidth
                                New-UDElement -Tag 'br'
                                New-UDCheckbox -Id 'edit-farm-is-origin' -Label 'This farm is a cattle origin' -Checked ($farm.IsOrigin -eq 1)
                                New-UDElement -Tag 'br'
                                New-UDCheckbox -Id 'edit-farm-active' -Label 'Active' -Checked ($farm.IsActive -eq 1)
                                
                            } -Footer {
                                New-UDButton -Text "Cancel" -OnClick { Hide-UDModal }
                                New-UDButton -Text "Save Changes" -Variant contained -Style @{backgroundColor = '#2e7d32'; color = 'white' } -OnClick {
                                    $farmName = (Get-UDElement -Id 'edit-farm-name').value
                                    $contactPerson = (Get-UDElement -Id 'edit-farm-contact').value
                                    $address = (Get-UDElement -Id 'edit-farm-address').value
                                    $city = (Get-UDElement -Id 'edit-farm-city').value
                                    $state = (Get-UDElement -Id 'edit-farm-state').value
                                    $zip = (Get-UDElement -Id 'edit-farm-zip').value
                                    $phone = (Get-UDElement -Id 'edit-farm-phone').value
                                    $email = (Get-UDElement -Id 'edit-farm-email').value
                                    $notes = (Get-UDElement -Id 'edit-farm-notes').value
                                    $isOrigin = $(if ((Get-UDElement -Id 'edit-farm-is-origin').checked) { 1 } else { 0 })
                                    $isActive = $(if ((Get-UDElement -Id 'edit-farm-active').checked) { 1 } else { 0 })
                                    
                                    try {
                                        Update-Farm -FarmID $farm.FarmID -FarmName $farmName -ContactPerson $contactPerson `
                                            -Address $address -City $city -State $state -ZipCode $zip `
                                            -PhoneNumber $phone -Email $email -Notes $notes -IsOrigin $isOrigin -IsActive $isActive
                                        
                                        Show-UDToast -Message "Farm updated successfully!" -MessageColor green
                                        Hide-UDModal
                                        Sync-UDElement -Id 'farms-table'
                                    }
                                    catch {
                                        Show-UDToast -Message "Error updating farm: $($_.Exception.Message)" -MessageColor red
                                    }
                                }
                            } -FullWidth -MaxWidth 'md'
                        }
                    }
                ) -ShowPagination -PageSize 10 -ShowSearch -Dense
            }
        }
    }
} -Url "/farms" -Icon (New-UDIcon -Icon 'Tractor')






