$systemSettings = New-UDPage -Name 'System Settings' -Url '/settings' -Content {
    New-UDCard -Title 'System Settings' -Content {
        # Load current settings
        $session:sys = Get-SystemInfo

        New-UDForm -Id 'system-settings-form' -OnSubmit {
            $farmName = $EventData.'farm-name'
            $address = $EventData.'address'
            $city = $EventData.'city'
            $state = $EventData.'state'
            $zip = $EventData.'zip'
            $phone = $EventData.'phone'
            $email = $EventData.'email'
            $contact = $EventData.'contact'
            $notes = $EventData.'notes'
            $currency = $EventData.'default-currency'
            $culture = $EventData.'default-culture'
            $established = $EventData.established
                        
            try {

                # Build parameters and only include Established when provided
                $params = @{
                    FarmName        = $farmName
                    Address         = $address
                    City            = $city
                    State           = $state
                    ZipCode         = $zip
                    PhoneNumber     = $phone
                    Email           = $email
                    ContactPerson   = $contact
                    Notes           = $notes
                    DefaultCurrency = $currency
                    DefaultCulture  = $culture
                    Established     = $established
                }


                Set-SystemInfo @params | Out-Null
                Show-UDToast -Message 'System settings saved' -MessageColor green
                Sync-UDElement -Id 'system-info-display'
            }
            catch {
                Show-UDToast -Message "Failed to save system settings: $($_.Exception.Message)" -MessageColor red -Duration 5000
            }
        } -Content {
            New-UDTextbox -Id 'farm-name' -Label 'Farm Name' -Value $session:sys.FarmName -FullWidth
            New-UDTextbox -Id 'address' -Label 'Address' -Value $session:sys.Address -FullWidth
            New-UDGrid -Container -Spacing 2 -Content {
                New-UDGrid -Item -SmallSize 6 -Content { New-UDTextbox -Id 'city' -Label 'City' -Value $session:sys.City }
                New-UDGrid -Item -SmallSize 6 -Content { New-UDTextbox -Id 'state' -Label 'State' -Value $session:sys.State }
            }
            New-UDGrid -Container -Spacing 2 -Content {
                New-UDGrid -Item -SmallSize 6 -Content { New-UDTextbox -Id 'zip' -Label 'Zip Code' -Value $session:sys.ZipCode }
                New-UDGrid -Item -SmallSize 6 -Content { New-UDTextbox -Id 'phone' -Label 'Phone' -Value $session:sys.PhoneNumber }
            }
            New-UDTextbox -Id 'email' -Label 'Email' -Value $session:sys.Email -FullWidth
            New-UDTextbox -Id 'contact' -Label 'Contact Person' -Value $session:sys.ContactPerson -FullWidth
            $parsedEstablished = if ($session:sys.Established) { 
                (Parse-Date $session:sys.Established).Year.ToString() 
            } 
            else {
                (Get-Date).Year
            } 
            New-UDTextbox -Id 'established' -Label 'Established' -Value $parsedEstablished  -FullWidth
            New-UDTextbox -Id 'notes' -Label 'Notes' -Value $session:sys.Notes -FullWidth -Multiline -Rows 3

            New-UDGrid -Container -Spacing 2 -Content {
                New-UDGrid -Item -SmallSize 6 -Content {
                    New-UDSelect -Id 'default-currency' -Label 'Default Currency' -DefaultValue ($session:sys.DefaultCurrency -or 'USD') -Option {
                        New-UDSelectOption -Name 'USD ($)' -Value 'USD'
                        New-UDSelectOption -Name 'GBP (£)' -Value 'GBP'
                        New-UDSelectOption -Name 'EUR (€)' -Value 'EUR'
                        New-UDSelectOption -Name 'CAD ($)' -Value 'CAD'
                        New-UDSelectOption -Name 'AUD ($)' -Value 'AUD'
                    }
                }
                New-UDGrid -Item -SmallSize 6 -Content {
                    New-UDSelect -Id 'default-culture' -Label 'Default Culture' -DefaultValue ($session:sys.DefaultCulture -or 'en-US') -Option {
                        New-UDSelectOption -Name 'en-US' -Value 'en-US'
                        New-UDSelectOption -Name 'en-GB' -Value 'en-GB'
                        New-UDSelectOption -Name 'fr-FR' -Value 'fr-FR'
                        New-UDSelectOption -Name 'en-CA' -Value 'en-CA'
                        New-UDSelectOption -Name 'en-AU' -Value 'en-AU'
                    }
                }
            }

            New-UDElement -Tag 'br'
        }

        New-UDElement -Tag 'br'

        # Reset / Clear System Settings
        New-UDButton -Text 'Reset System Settings' -Variant outlined -Style @{color = '#d32f2f'; borderColor = '#d32f2f' } -OnClick {
            Show-UDModal -Content {
                New-UDTypography -Text '⚠️ Reset System Settings' -Variant h5 -Style @{color = '#d32f2f'; marginBottom = '12px' }
                New-UDTypography -Text 'This will clear all global system settings and return the application to an unconfigured state. This action cannot be undone.' -Variant body2
            } -Footer {
                New-UDButton -Text 'Cancel' -OnClick { Hide-UDModal }
                New-UDButton -Text 'Reset' -Variant contained -Style @{backgroundColor = '#d32f2f'; color = 'white' } -OnClick {
                    try {
                        Clear-SystemInfo -Force | Out-Null
                        Show-UDToast -Message 'System settings cleared' -MessageColor green
                        Hide-UDModal
                        Sync-UDElement -Id 'system-info-display'

                        # Clear form fields
                        Set-UDElement -Id 'farm-name' -Properties @{value = '' }
                        Set-UDElement -Id 'address' -Properties @{value = '' }
                        Set-UDElement -Id 'city' -Properties @{value = '' }
                        Set-UDElement -Id 'state' -Properties @{value = '' }
                        Set-UDElement -Id 'zip' -Properties @{value = '' }
                        Set-UDElement -Id 'phone' -Properties @{value = '' }
                        Set-UDElement -Id 'email' -Properties @{value = '' }
                        Set-UDElement -Id 'contact' -Properties @{value = '' }
                        Set-UDElement -Id 'established' -Properties @{value = '' }
                        Set-UDElement -Id 'notes' -Properties @{value = '' }
                        Set-UDElement -Id 'default-currency' -Properties @{value = 'USD' }
                        Set-UDElement -Id 'default-culture' -Properties @{value = 'en-US' }
                    }
                    catch {
                        Show-UDToast -Message "Error clearing settings: $($_.Exception.Message)" -MessageColor red
                    }
                }
            }
        }

        New-UDDynamic -Id 'system-info-display' -Content {
            New-UDCard -Title 'Current System Info' -Content {
                $s = Get-SystemInfo
                if ($s) {
                    New-UDTypography -Text "Farm: $($s.FarmName)" -Variant body1
                    New-UDTypography -Text "Address: $($s.Address) $($s.City) $($s.State) $($s.ZipCode)" -Variant body2
                    New-UDTypography -Text "Phone: $($s.PhoneNumber) | Email: $($s.Email)" -Variant body2
                    New-UDTypography -Text "Contact: $($s.ContactPerson)" -Variant body2
                    New-UDTypography -Text "Established: $(if ($s.Established) { (Parse-Date $s.Established).Year } else { '' })" -Variant body2
                    New-UDTypography -Text "Currency/Culture: $($s.DefaultCurrency)/$($s.DefaultCulture)" -Variant body2
                }
                else {
                    New-UDTypography -Text 'No system settings configured yet.' -Variant body2
                }
            }
        }
    }
}
