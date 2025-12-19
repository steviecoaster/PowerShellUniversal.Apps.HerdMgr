## First Run Setup - Stepper-based wizard
$setupPage = New-UDPage -Name 'Setup' -Url '/setup' -Content {
    
    $session:FarmParameters = @{}

    New-UDCard -Title 'First Run Setup' -Style @{ padding = '20px' } -Content {
        New-UDTypography -Text "Welcome! Let's get your herd manager configured." -Variant body1 -Style @{marginBottom = '12px' }

        New-UDStepper -Id 'setup-stepper' -AlternativeLabel -Steps {
            New-UDStep -OnLoad {
                New-UDTypography -Text 'Database setup' -Variant h6
                New-UDTypography -Text ("Database path: $script:DatabasePath") -Variant caption

                New-UDDynamic -Id 'db-status' -Content {
                    try {
                        $exists = Test-Path $script:DatabasePath
                        if (-not $exists) { New-UDTypography -Text 'Database file not found' -Variant body2; return }

                        $hasSystemInfo = $false
                        try {
                            $res = Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query "SELECT name FROM sqlite_master WHERE type='table' AND name='SystemInfo';"
                            if ($res -and $res.Count -gt 0) { $hasSystemInfo = $true }
                        }
                        catch { }

                        if ($hasSystemInfo) { New-UDTypography -Text 'Schema appears to be applied (SystemInfo table present)' -Variant body2 }
                        else { New-UDTypography -Text 'Database file present but schema not applied' -Variant body2 }
                    }
                    catch {
                        New-UDTypography -Text "Error checking database: $($_.Exception.Message)" -Variant body2 -Style @{ color = 'red' }
                    }
                }

                New-UDButton -Text 'Initialize Database' -Variant contained -Style @{ backgroundColor = '#1976d2'; color = 'white' } -OnClick {
                    try {
                        Initialize-HerdDatabase -DatabasePath $script:DatabasePath | Out-Null
                        Show-UDToast -Message 'Database initialized' -MessageColor green
                    }
                    catch { Show-UDToast -Message "Initialization failed: $($_.Exception.Message)" -MessageColor red }
                    Sync-UDElement -Id 'db-status'
                }
            } -Label 'Database'

            New-UDStep -OnLoad {
                # Mirror SystemSettings form fields
                $sys = Get-SystemInfo
                $parsedEstablished = if ($sys.Established) { (Parse-Date $sys.Established).Year.ToString() } else { '' }

                New-UDGrid -Container -Spacing 2 -Content {
                    New-UDGrid -Item -SmallSize 6 -Content { New-UDTextbox -Id 'FarmName' -Label 'Farm Name *' -Value $sys.FarmName -FullWidth }
                    New-UDGrid -Item -SmallSize 6 -Content { New-UDTextbox -Id 'Address' -Label 'Address' -Value $sys.Address -FullWidth }
                }

                New-UDGrid -Container -Spacing 2 -Content {
                    New-UDGrid -Item -SmallSize 4 -Content { New-UDTextbox -Id 'City' -Label 'City' -Value $sys.City -FullWidth }
                    New-UDGrid -Item -SmallSize 4 -Content { New-UDTextbox -Id 'State' -Label 'State' -Value $sys.State -FullWidth }
                    New-UDGrid -Item -SmallSize 4 -Content { New-UDTextbox -Id 'ZipCode' -Label 'Zip Code' -Value $sys.ZipCode -FullWidth }
                }

                New-UDGrid -Container -Spacing 2 -Content {
                    New-UDGrid -Item -SmallSize 4 -Content { New-UDTextbox -Id 'PhoneNumber' -Label 'Phone' -Value $sys.PhoneNumber -FullWidth }
                    New-UDGrid -Item -SmallSize 8 -Content { New-UDTextbox -Id 'Email' -Label 'Email' -Value $sys.Email -FullWidth }
                }

                New-UDGrid -Container -Spacing 2 -Content {
                    New-UDGrid -Item -SmallSize 8 -Content { New-UDTextbox -Id 'ContactPerson' -Label 'Contact Person' -Value $sys.ContactPerson -FullWidth }
                    New-UDGrid -Item -SmallSize 4 -Content { New-UDTextbox -Id 'Established' -Label 'Established (Optional, year)' -Value $parsedEstablished -FullWidth }
                }

                New-UDGrid -Container -Spacing 2 -Content {
                    New-UDGrid -Item -SmallSize 12 -Content { New-UDTextbox -Id 'Notes' -Label 'Notes' -Value $sys.Notes -FullWidth -Multiline -Rows 4 }
                }
            } -Label 'Farm'

            New-UDStep -OnLoad {
                New-UDGrid -Container -Spacing 2 -Content {
                    New-UDGrid -Item -Content {
                        New-UDSelect -Id 'DefaultCurrency' -Label 'Default Currency' -Option {
                            New-UDSelectOption -Name 'USD ($)' -Value 'USD'
                            New-UDSelectOption -Name 'GBP (£)' -Value 'GBP'
                            New-UDSelectOption -Name 'EUR (€)' -Value 'EUR'
                            New-UDSelectOption -Name 'CAD ($)' -Value 'CAD'
                            New-UDSelectOption -Name 'AUD ($)' -Value 'AUD'
                        } -FullWidth
                    }
                    New-UDGrid -Item -Content {
                        New-UDSelect -Id 'DefaultCulture' -Label 'Default Culture' -Option {
                            New-UDSelectOption -Name 'en-US' -Value 'en-US'
                            New-UDSelectOption -Name 'en-GB' -Value 'en-GB'
                            New-UDSelectOption -Name 'fr-FR' -Value 'fr-FR'
                            New-UDSelectOption -Name 'en-CA' -Value 'en-CA'
                            New-UDSelectOption -Name 'en-AU' -Value 'en-AU'
                        } -FullWidth
                    }
                }
            } -Label 'Defaults'

            New-UDStep -OnLoad {
                
                $stepperData = ($Body | ConvertFrom-Json).Context
                
                $stepperData.psobject.properties | ForEach-Object {
                    Write-Verbose "Adding $($_.Name) to FarmParameters"
                    $session:FarmParameters.Add($_.Name, $_.Value)
                }

                New-UDTypography -Text $('Farm: {0}' -f $stepperData.FarmName)
                New-UDElement -Tag 'br'
                New-UDTypography -Text $('Address: {0}' -f $stepperData.Address)
                New-UDElement -Tag 'br'
                New-UDTypography -Text $('City: {0}' -f $stepperData.City)
                New-UDElement -Tag 'br'
                New-UDTypography -Text $('State: {0}' -f $stepperData.State)
                New-UDElement -Tag 'br'
                New-UDTypography -Text $('Zip: {0}' -f $stepperData.ZipCode)
                New-UDElement -Tag 'br'
                New-UDTypography -Text $('Phone: {0}' -f $stepperData.PhoneNumber)
                New-UDElement -Tag 'br'
                New-UDTypography -Text $('Email: {0}' -f $stepperData.Email)
                New-UDElement -Tag 'br'
                New-UDTypography -Text $('Contact: {0}' -f $stepperData.ContactPerson)
                New-UDElement -Tag 'br'
                New-UDTypography -Text $('Established: {0}' -f $stepperData.Established)
                New-UDElement -Tag 'br'
                New-UDTypography -Text $('Notes: {0}' -f $stepperData.Notes)
                New-UDElement -Tag 'br'
                New-UDTypography -Text $('Currency: {0}' -f $stepperData.DefaultCurrency)
                New-UDElement -Tag 'br'
                New-UDTypography -Text $('Culture: {0}' -f $stepperData.DefaultCulture)
            } -Label 'Review'
        } -OnValidateStep {
            param($EventData)
            # Step 0: ensure DB initialized
            if ($EventData.CurrentStep -eq 0) {
                try {
                    $res = Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query "SELECT name FROM sqlite_master WHERE type='table' AND name='SystemInfo';"
                    if (-not ($res -and $res.Count -gt 0)) { 
                        return New-UDValidationResult -ValidationError 'Database not initialized. Please initialize the database.' 
                    }
                }
                catch { 
                    return New-UDValidationResult -ValidationError 'Database not initialized. Please initialize the database.' 
                }
            }

            # Step 1: Farm name required
            if ($EventData.CurrentStep -eq 1) {
                $src = if ($EventData.Context) { $EventData.Context } else { $EventData }
                $raw = & $Resolve $src 'farm-name'
                $farmVal = & $Unwrap $raw
                if (-not $farmVal -or $farmVal -eq '') { return New-UDValidationResult -ValidationError 'Farm Name is required' }
            }

            return New-UDValidationResult -Valid
        } -OnFinish {
                $farmParms = $session:FarmParameters
                $farmParms | ConvertTo-Json | out-File C:\temp\farmparams.txt
            Show-UDToast -Message $('Executing: Set-SystemInfo with data: {0}' -f $($farmParms | ConvertTo-Json))
            Set-SystemInfo @farmParams
            Show-UDToast -Message 'System setup complete!' -MessageColor green
        }
    
    }
}