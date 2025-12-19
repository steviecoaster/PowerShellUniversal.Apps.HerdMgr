$accounting = New-UDPage -Name "Accounting" -Content {
    
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
                    New-UDAutoComplete -Id 'invoice-cattle-select' -Multiple -Options @((Get-AllCattle | Where-Object Status -eq 'Active' | ForEach-Object { "$($_.TagNumber) - $($_.Name)" })) -Label "Select Cattle (single or multiple)" -FullWidth
                    New-UDElement -Tag 'br'
                    New-UDButton -Text "📄 Generate Invoice" -Variant contained -FullWidth -Style @{backgroundColor = '#2e7d32'; color = 'white'} -OnClick {
                        $selectedCattle = (Get-UDElement -Id 'invoice-cattle-select').value
                        
                        if (-not $selectedCattle -or $selectedCattle.Count -eq 0) {
                            Show-UDToast -Message "Please select at least one cattle" -MessageColor red
                            return
                        }
                        
                        # Ensure $selectedCattle is an array
                        if ($selectedCattle -isnot [array]) {
                            $selectedCattle = @($selectedCattle)
                        }
                        
                        # Debug: Show what we received
                        Show-UDToast -Message "Selected $($selectedCattle.Count) cattle" -MessageColor blue
                        
                        $currentDate = Get-Date
                        $cattleList = @()
                        $totalInvoiceCost = 0
                        
                        # Process each selected cattle
                        foreach ($selection in $selectedCattle) {
                            # Extract tag number
                            $tagNumber = $selection -split ' - ' | Select-Object -First 1
                            $cattle = Get-AllCattle | Where-Object TagNumber -eq $tagNumber | Select-Object -First 1
                            
                            if (-not $cattle) {
                                Show-UDToast -Message "Cattle $tagNumber not found" -MessageColor red
                                return
                            }
                            
                            # Get purchase date
                            $purchaseDate = if ($cattle.PurchaseDate) { Parse-Date $cattle.PurchaseDate } else { $null }
                            
                            if (-not $purchaseDate) {
                                Show-UDToast -Message "Cattle $tagNumber must have a purchase date to generate invoice" -MessageColor red
                                return
                            }
                            
                            # Calculate days on feed
                            $daysOnFeed = ($currentDate - $purchaseDate).Days
                            
                            # Get price per day
                            $pricePerDay = if ($cattle.PricePerDay) { $cattle.PricePerDay } else { 0 }
                            
                            if ($pricePerDay -eq 0) {
                                Show-UDToast -Message "Cattle $tagNumber must have a Price Per Day set to generate invoice" -MessageColor red
                                return
                            }
                            
                            # Calculate feeding cost
                            $feedingCost = $daysOnFeed * $pricePerDay
                            
                            # Get health costs
                            $healthCost = Get-TotalHealthCost -CattleID $cattle.CattleID
                            
                            $lineItemTotal = $feedingCost + $healthCost
                            $totalInvoiceCost += $lineItemTotal
                            
                            # Add to cattle list
                            $cattleList += @{
                                Cattle = $cattle
                                PurchaseDate = $purchaseDate
                                DaysOnFeed = $daysOnFeed
                                PricePerDay = $pricePerDay
                                FeedingCost = $feedingCost
                                HealthCost = $healthCost
                                LineItemTotal = $lineItemTotal
                            }
                        }
                        
                        # Determine if single or multi-cattle invoice
                        $isSingleCattle = $cattleList.Count -eq 1
                        
                        # Show invoice generation modal
                        Show-UDModal -Content {
                            if ($isSingleCattle) {
                                New-UDTypography -Text "Generate Invoice for $($cattleList[0].Cattle.TagNumber)" -Variant h5 -Style @{
                                    color = '#2e7d32'
                                    marginBottom = '20px'
                                    fontWeight = 'bold'
                                }
                            } else {
                                New-UDTypography -Text "Generate Multi-Cattle Invoice ($($cattleList.Count) animals)" -Variant h5 -Style @{
                                    color = '#2e7d32'
                                    marginBottom = '20px'
                                    fontWeight = 'bold'
                                }
                                
                                # Show summary of selected cattle
                                New-UDCard -Content {
                                    foreach ($item in $cattleList) {
                                        New-UDTypography -Text "• $($item.Cattle.TagNumber) - $($item.Cattle.Name): $(Format-Currency ([math]::Round($item.LineItemTotal, 2)))" -Variant body2
                                    }
                                } -Style @{backgroundColor = '#f5f5f5'; marginBottom = '15px'}
                            }
                            
                            New-UDTextbox -Id 'new-invoice-number' -Label 'Invoice Number *' -FullWidth
                            New-UDElement -Tag 'br'
                            New-UDElement -Tag 'br'
                            New-UDDatePicker -Id 'new-invoice-date' -Label 'Invoice Date' -Value $currentDate
                            New-UDElement -Tag 'br'
                            
                            if ($isSingleCattle) {
                                New-UDDatePicker -Id 'new-start-date' -Label 'Start Date' -Value $cattleList[0].PurchaseDate
                                New-UDElement -Tag 'br'
                                New-UDDatePicker -Id 'new-end-date' -Label 'End Date' -Value $currentDate
                                New-UDElement -Tag 'br'
                                New-UDTextbox -Id 'new-days-on-feed' -Label 'Days on Feed' -Value $cattleList[0].DaysOnFeed -Disabled
                                New-UDElement -Tag 'br'
                                New-UDTextbox -Id 'new-price-per-day' -Label 'Price Per Day' -Value $cattleList[0].PricePerDay -Disabled
                                New-UDElement -Tag 'br'
                                New-UDTextbox -Id 'new-feeding-cost' -Label 'Feeding Cost' -Value ([math]::Round($cattleList[0].FeedingCost, 2)) -Disabled
                                New-UDElement -Tag 'br'
                                New-UDTextbox -Id 'new-health-cost' -Label 'Health Cost' -Value ([math]::Round($cattleList[0].HealthCost, 2)) -Disabled
                                New-UDElement -Tag 'br'
                            }
                            
                            New-UDTextbox -Id 'new-total-cost' -Label 'Total Invoice Amount' -Value ([math]::Round($totalInvoiceCost, 2)) -Disabled
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
                                $createdBy = (Get-UDElement -Id 'new-created-by').value
                                $notes = (Get-UDElement -Id 'new-invoice-notes').value
                                
                                if (-not $invoiceNumber) {
                                    Show-UDToast -Message "Invoice number is required" -MessageColor red
                                    return
                                }
                                
                                try {
                                    if ($isSingleCattle) {
                                        # Single-cattle invoice (legacy mode)
                                        $startDate = (Get-UDElement -Id 'new-start-date').value
                                        $endDate = (Get-UDElement -Id 'new-end-date').value
                                        $startDateParsed = [DateTime]$startDate
                                        $endDateParsed = [DateTime]$endDate
                                        $daysOnFeedFinal = ($endDateParsed - $startDateParsed).Days
                                        $feedingCostFinal = $daysOnFeedFinal * $cattleList[0].PricePerDay
                                        $totalCostFinal = $feedingCostFinal + $cattleList[0].HealthCost
                                        
                                        Add-Invoice -InvoiceNumber $invoiceNumber `
                                            -CattleID $cattleList[0].Cattle.CattleID `
                                            -InvoiceDate ([DateTime]$invoiceDate) `
                                            -StartDate $startDateParsed `
                                            -EndDate $endDateParsed `
                                            -DaysOnFeed $daysOnFeedFinal `
                                            -PricePerDay $cattleList[0].PricePerDay `
                                            -FeedingCost $feedingCostFinal `
                                            -HealthCost $cattleList[0].HealthCost `
                                            -TotalCost $totalCostFinal `
                                            -Notes $notes `
                                            -CreatedBy $createdBy
                                    }
                                    else {
                                        # Multi-cattle invoice with line items
                                        $lineItems = @()
                                        foreach ($item in $cattleList) {
                                            $lineItems += @{
                                                CattleID = $item.Cattle.CattleID
                                                StartDate = $item.PurchaseDate
                                                EndDate = $currentDate
                                                DaysOnFeed = $item.DaysOnFeed
                                                PricePerDay = $item.PricePerDay
                                                FeedingCost = $item.FeedingCost
                                                HealthCost = $item.HealthCost
                                                LineItemTotal = $item.LineItemTotal
                                                Notes = $null
                                            }
                                        }
                                        
                                        Add-Invoice -InvoiceNumber $invoiceNumber `
                                            -InvoiceDate ([DateTime]$invoiceDate) `
                                            -LineItems $lineItems `
                                            -TotalCost $totalInvoiceCost `
                                            -Notes $notes `
                                            -CreatedBy $createdBy
                                    }
                                    
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
                    New-UDTableColumn -Property Owner -Title "Owner" -ShowSort
                    New-UDTableColumn -Property InvoiceDate -Title "Invoice Date" -ShowSort -Render {
                        $fd = Format-Date $EventData.InvoiceDate
                        if ($fd -ne '-') { $fd } else { $EventData.InvoiceDate }
                    }
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
                ) -ShowPagination -PageSize 10 -ShowSearch -Dense
            }
        }
    }
} -Url "/accounting" -Icon (New-UDIcon -Icon 'Calculator')






