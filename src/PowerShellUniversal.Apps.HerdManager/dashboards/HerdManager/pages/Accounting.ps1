$accounting = New-UDPage -Name "Accounting" -Content {
    # Capture database path in closure
    $dbPath = $script:DatabasePath
    
    New-UDTypography -Text "💰 Accounting & Invoices" -Variant h4 -Style @{
        marginBottom = '20px'
        color = '#2e7d32'
        fontWeight = 'bold'
    }

    # Search and Generate Section
    New-UDCard -Title "Invoice Management" -Content {
        New-UDGrid -Container -Content {
            # Search by Invoice Number
            New-UDGrid -Item -ExtraSmallSize 12 -MediumSize 6 -Content {
                New-UDCard -Title "Search Invoice" -Content {
                    New-UDTextbox -Id 'search-invoice-number' -Label 'Invoice Number' -FullWidth
                    New-UDElement -Tag 'br'
                    New-UDButton -Text "🔍 Search" -Variant contained -FullWidth -OnClick {
                        $invoiceNumber = (Get-UDElement -Id 'search-invoice-number').value
                        
                        if (-not $invoiceNumber) {
                            Show-UDToast -Message "Please enter an invoice number" -MessageColor red
                            return
                        }
                        
                        $invoice = Get-Invoice -InvoiceNumber $invoiceNumber
                        
                        if (-not $invoice) {
                            Show-UDToast -Message "Invoice not found" -MessageColor red
                            return
                        }
                        
                        # Open invoice in new tab
                        Invoke-UDRedirect -Url "/herdmanager/invoice/$invoiceNumber" -OpenInNewWindow
                    }
                }
            }
            
            # Generate Invoice
            New-UDGrid -Item -ExtraSmallSize 12 -MediumSize 6 -Content {
                New-UDCard -Title "Generate Invoice" -Content {
                    New-UDAutoComplete -Id 'invoice-cattle-select' -Options @((Get-AllCattle | Where-Object Status -eq 'Active' | ForEach-Object { "$($_.TagNumber) - $($_.Name)" })) -Label "Select Cattle" -FullWidth
                    New-UDElement -Tag 'br'
                    New-UDButton -Text "📄 Generate Invoice" -Variant contained -FullWidth -Style @{backgroundColor = '#2e7d32'; color = 'white'} -OnClick {
                        $selectedCattle = (Get-UDElement -Id 'invoice-cattle-select').value
                        
                        if (-not $selectedCattle) {
                            Show-UDToast -Message "Please select a cattle" -MessageColor red
                            return
                        }
                        
                        # Extract tag number
                        $tagNumber = $selectedCattle -split ' - ' | Select-Object -First 1
                        $cattle = Get-AllCattle | Where-Object TagNumber -eq $tagNumber | Select-Object -First 1
                        
                        if (-not $cattle) {
                            Show-UDToast -Message "Cattle not found" -MessageColor red
                            return
                        }
                        
                        # Get purchase date and current date
                        $purchaseDate = if ($cattle.PurchaseDate) { [DateTime]::Parse($cattle.PurchaseDate) } else { $null }
                        $currentDate = Get-Date
                        
                        if (-not $purchaseDate) {
                            Show-UDToast -Message "Cattle must have a purchase date to generate invoice" -MessageColor red
                            return
                        }
                        
                        # Calculate days on feed
                        $daysOnFeed = ($currentDate - $purchaseDate).Days
                        
                        # Get price per day
                        $pricePerDay = if ($cattle.PricePerDay) { $cattle.PricePerDay } else { 0 }
                        
                        if ($pricePerDay -eq 0) {
                            Show-UDToast -Message "Cattle must have a Price Per Day set to generate invoice" -MessageColor red
                            return
                        }
                        
                        # Calculate feeding cost
                        $feedingCost = $daysOnFeed * $pricePerDay
                        
                        # Get health costs
                        $healthQuery = @"
SELECT COALESCE(SUM(Cost), 0) AS TotalHealthCost
FROM HealthRecords
WHERE CattleID = @CattleID AND Cost > 0
"@
                        $healthCostResult = Invoke-SqliteQuery -DataSource $dbPath -Query $healthQuery -SqlParameters @{
                            CattleID = $cattle.CattleID
                        } -As PSObject
                        
                        $healthCost = $healthCostResult.TotalHealthCost
                        $totalCost = $feedingCost + $healthCost
                        
                        # Show invoice generation modal
                        Show-UDModal -Content {
                            New-UDTypography -Text "Generate Invoice for $($cattle.TagNumber)" -Variant h5 -Style @{
                                color = '#2e7d32'
                                marginBottom = '20px'
                                fontWeight = 'bold'
                            }
                            
                            New-UDTextbox -Id 'new-invoice-number' -Label 'Invoice Number *' -FullWidth
                            New-UDElement -Tag 'br'
                            New-UDDatePicker -Id 'new-invoice-date' -Label 'Invoice Date' -Value $currentDate
                            New-UDElement -Tag 'br'
                            New-UDDatePicker -Id 'new-start-date' -Label 'Start Date' -Value $purchaseDate
                            New-UDElement -Tag 'br'
                            New-UDDatePicker -Id 'new-end-date' -Label 'End Date' -Value $currentDate
                            New-UDElement -Tag 'br'
                            New-UDTextbox -Id 'new-days-on-feed' -Label 'Days on Feed' -Value $daysOnFeed -Disabled
                            New-UDElement -Tag 'br'
                            New-UDTextbox -Id 'new-price-per-day' -Label 'Price Per Day' -Value $pricePerDay -Disabled
                            New-UDElement -Tag 'br'
                            New-UDTextbox -Id 'new-feeding-cost' -Label 'Feeding Cost' -Value ([math]::Round($feedingCost, 2)) -Disabled
                            New-UDElement -Tag 'br'
                            New-UDTextbox -Id 'new-health-cost' -Label 'Health Cost' -Value ([math]::Round($healthCost, 2)) -Disabled
                            New-UDElement -Tag 'br'
                            New-UDTextbox -Id 'new-total-cost' -Label 'Total Cost' -Value ([math]::Round($totalCost, 2)) -Disabled
                            New-UDElement -Tag 'br'
                            New-UDSelect -Id 'new-created-by' -Label 'Created By' -Option {
                                New-UDSelectOption -Name 'Brandon' -Value 'Brandon'
                                New-UDSelectOption -Name 'Jerry' -Value 'Jerry'
                                New-UDSelectOption -Name 'Stephanie' -Value 'Stephanie'
                            } -DefaultValue 'Brandon' -FullWidth
                            New-UDElement -Tag 'br'
                            New-UDTextbox -Id 'new-invoice-notes' -Label 'Notes' -Multiline -Rows 3 -FullWidth
                            
                        } -Footer {
                            New-UDButton -Text "Cancel" -OnClick { Hide-UDModal }
                            New-UDButton -Text "Create Invoice" -Variant contained -Style @{backgroundColor = '#2e7d32'; color = 'white'} -OnClick {
                                $invoiceNumber = (Get-UDElement -Id 'new-invoice-number').value
                                $invoiceDate = (Get-UDElement -Id 'new-invoice-date').value
                                $startDate = (Get-UDElement -Id 'new-start-date').value
                                $endDate = (Get-UDElement -Id 'new-end-date').value
                                $createdBy = (Get-UDElement -Id 'new-created-by').value
                                $notes = (Get-UDElement -Id 'new-invoice-notes').value
                                
                                if (-not $invoiceNumber) {
                                    Show-UDToast -Message "Invoice number is required" -MessageColor red
                                    return
                                }
                                
                                # Recalculate based on selected dates
                                $startDateParsed = [DateTime]$startDate
                                $endDateParsed = [DateTime]$endDate
                                $daysOnFeedFinal = ($endDateParsed - $startDateParsed).Days
                                $feedingCostFinal = $daysOnFeedFinal * $pricePerDay
                                $totalCostFinal = $feedingCostFinal + $healthCost
                                
                                try {
                                    Add-Invoice -InvoiceNumber $invoiceNumber `
                                        -CattleID $cattle.CattleID `
                                        -InvoiceDate ([DateTime]$invoiceDate) `
                                        -StartDate $startDateParsed `
                                        -EndDate $endDateParsed `
                                        -DaysOnFeed $daysOnFeedFinal `
                                        -PricePerDay $pricePerDay `
                                        -FeedingCost $feedingCostFinal `
                                        -HealthCost $healthCost `
                                        -TotalCost $totalCostFinal `
                                        -Notes $notes `
                                        -CreatedBy $createdBy
                                    
                                    Show-UDToast -Message "Invoice created successfully!" -MessageColor green
                                    Hide-UDModal
                                    Sync-UDElement -Id 'invoices-table'
                                }
                                catch {
                                    Show-UDToast -Message "Error creating invoice: $($_.Exception.Message)" -MessageColor red
                                }
                            }
                        } -FullWidth -MaxWidth 'md'
                    }
                }
            }
        }
    }
    
    # Invoices Table
    New-UDCard -Title "All Invoices" -Content {
        New-UDDynamic -Id 'invoices-table' -Content {
            $invoices = Get-Invoice -All
            
            if (-not $invoices) {
                New-UDTypography -Text "No invoices found" -Variant body2 -Style @{color = '#666'}
            }
            else {
                New-UDTable -Data $invoices -Columns @(
                    New-UDTableColumn -Property InvoiceNumber -Title "Invoice #" -ShowSort
                    New-UDTableColumn -Property TagNumber -Title "Tag #" -ShowSort
                    New-UDTableColumn -Property CattleName -Title "Name" -ShowSort
                    New-UDTableColumn -Property Owner -Title "Owner" -ShowSort
                    New-UDTableColumn -Property InvoiceDate -Title "Invoice Date" -ShowSort -Render {
                        [DateTime]::Parse($EventData.InvoiceDate).ToString('MM/dd/yyyy')
                    }
                    New-UDTableColumn -Property DaysOnFeed -Title "Days on Feed" -ShowSort
                    New-UDTableColumn -Property TotalCost -Title "Total Cost" -ShowSort -Render {
                        "`$$([math]::Round($EventData.TotalCost, 2))"
                    }
                    New-UDTableColumn -Property Actions -Title "Actions" -Render {
                        New-UDButton -Text "👁️ View" -Size small -Variant text -OnClick {
                            $invoiceNumber = $EventData.InvoiceNumber
                            # Open invoice in new tab
                            Invoke-UDRedirect -Url "/herdmanager/invoice/$invoiceNumber" -OpenInNewWindow
                        }
                    }
                    New-UDTableColumn -Property PrintAction -Title "Print" -Render {
                        New-UDButton -Text "🖨️ Print" -Size small -Variant text -OnClick {
                            $invoiceNumber = $EventData.InvoiceNumber
                            # Open invoice in new tab for printing
                            Invoke-UDRedirect -Url "/herdmanager/invoice/$invoiceNumber" -OpenInNewWindow
                        }
                    }
                ) -ShowPagination -PageSize 10 -ShowSearch -Dense
            }
        }
    }
} -Url "/accounting" -Icon (New-UDIcon -Icon 'Calculator')
