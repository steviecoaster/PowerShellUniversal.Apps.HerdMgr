$invoicePage = New-UDPage -Name "Invoice" -Url "/invoice/:invoiceNumber" -Blank -Content {
    $invoiceNumber = $InvoiceNumber
    
    # Get invoice details
    $invoiceData = Get-Invoice -InvoiceNumber $invoiceNumber
    
    if (-not $invoiceData) {
        New-UDTypography -Text "Invoice not found" -Variant h4 -Style @{color = 'red'; textAlign = 'center'; marginTop = '50px' }
        return
    }
    
    # Check if this is a multi-cattle invoice
    $isMultiCattle = $invoiceData.IsMultiCattle
    
    # Debug logging
    Write-Host "Invoice: $invoiceNumber, IsMultiCattle: $isMultiCattle, LineItems: $($invoiceData.LineItems.Count)"
    
    # Print-friendly styles
    New-UDStyle -Style @'
        @media print {
            .MuiAppBar-root, .MuiDrawer-root, button, .no-print {
                display: none !important;
            }
            body {
                margin: 0;
                padding: 10px;
                font-size: 11pt;
            }
            .invoice-container {
                max-width: 100% !important;
                margin: 0 !important;
                padding: 15px !important;
                box-shadow: none !important;
            }
            .invoice-header {
                padding-bottom: 10px;
                margin-bottom: 15px;
            }
            .invoice-header h2 {
                font-size: 18pt;
                margin: 0;
            }
            .invoice-header h3 {
                font-size: 14pt;
            }
            .invoice-header p {
                font-size: 9pt;
                margin: 1px 0;
            }
            .invoice-section {
                margin-bottom: 15px;
            }
            .invoice-section h6 {
                font-size: 12pt;
                margin-bottom: 8px;
            }
            .invoice-info-row {
                margin-bottom: 5px;
            }
            .invoice-info-row p,
            .invoice-info-row span {
                font-size: 10pt;
            }
            .invoice-table {
                font-size: 9pt;
                margin-top: 8px;
            }
            .invoice-table th {
                padding: 6px;
            }
            .invoice-table td {
                padding: 5px;
            }
            .invoice-total {
                padding: 10px;
                margin-top: 15px;
                font-size: 14pt;
            }
        }
        .invoice-container {
            max-width: 900px;
            margin: 20px auto;
            padding: 30px;
            background: white;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .invoice-header {
            border-bottom: 3px solid #2e7d32;
            padding-bottom: 20px;
            margin-bottom: 30px;
        }
        .invoice-section {
            margin-bottom: 25px;
        }
        .invoice-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
            table-layout: fixed;
        }
        .invoice-table th {
            background-color: #2e7d32;
            color: white;
            padding: 10px;
            text-align: left;
        }
        .invoice-table th:nth-child(1) { width: 15%; }
        .invoice-table th:nth-child(2) { width: 20%; }
        .invoice-table th:nth-child(3) { width: 50%; }
        .invoice-table th:nth-child(4) { width: 15%; text-align: right; }
        .invoice-table td {
            padding: 8px;
            border-bottom: 1px solid #ddd;
            word-wrap: break-word;
        }
        .invoice-total {
            background-color: #e8f5e9;
            padding: 15px;
            margin-top: 20px;
            text-align: right;
            font-size: 1.3em;
            font-weight: bold;
            color: #2e7d32;
        }
        .invoice-info-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 10px;
        }
        .invoice-label {
            font-weight: bold;
            color: #555;
        }
'@ -Content {
        New-UDElement -Tag 'div' -Attributes @{class = 'invoice-container' } -Content {
            # Header
            $invoiceDate = Parse-Date $invoiceData.InvoiceDate
            $dueDate = $invoiceDate.AddDays(30)

            # Use system-level info if configured
            $system = Get-SystemInfo
            $companyName = if ($system -and $system.FarmName) { $system.FarmName } else { 'Acme Fictitious Ranch' }
            $companyAddress1 = if ($system -and $system.Address) { $system.Address } else { '42 Imaginary Way' }
            $companyCityStateZip = if ($system -and ($system.City -or $system.State -or $system.ZipCode)) { "$($system.City) $($system.State) $($system.ZipCode)" } else { 'Nowhere, ZZ 00000' }
            $companyPhone = if ($system -and $system.PhoneNumber) { $system.PhoneNumber } else { '(000) 000-0000' }
            $companyEmail = if ($system -and $system.Email) { $system.Email } else { 'billing@example.invalid' }

            $headerHtml = @"
<div class="invoice-header">
    <div style="display: flex; justify-content: space-between;">
        <div>
            <h2 style="color: #2e7d32; font-weight: bold; margin: 0;">$companyName</h2>
        </div>
        <div style="text-align: right;">
            <p style="margin: 2px 0;">$companyAddress1</p>
            <p style="margin: 2px 0;">$companyCityStateZip</p>
            <p style="margin: 2px 0;">Phone: $companyPhone</p>
            <p style="margin: 2px 0;">Email: $companyEmail</p>
        </div>
    </div>
    <div style="display: flex; justify-content: space-between; margin-top: 20px;">
        <div>
            <p style="font-size: 1.1em; font-weight: bold; margin: 5px 0;">Invoice #: $($invoiceData.InvoiceNumber)</p>
            <p style="margin: 5px 0;">Date: $(Format-Date $invoiceDate 'MMMM dd, yyyy')</p>
            <p style="margin: 5px 0; font-size: 0.9em;">Created By: $($invoiceData.CreatedBy)</p>
        </div>
        <div style="text-align: right;">
            <p style="font-weight: bold; margin: 5px 0;">Payment Terms: NET 30</p>
            <p style="margin: 5px 0;">Due Date: $(Format-Date $dueDate 'MMMM dd, yyyy')</p>
        </div>
    </div>
</div>
"@
            New-UDHtml -Markup $headerHtml
            
            # Owner/Customer Information - Try to get farm details
            $ownerFarm = if ($invoiceData.Owner) { 
                Get-Farm -FarmName $invoiceData.Owner 
            } else { 
                $null 
            }
            
            if ($ownerFarm) {
                # Farm found - build complete farm information
                $cityStateZip = @()
                if ($ownerFarm.City) { $cityStateZip += $ownerFarm.City }
                if ($ownerFarm.State) { 
                    if ($cityStateZip.Count -gt 0) {
                        $cityStateZip += ", $($ownerFarm.State)"
                    } else {
                        $cityStateZip += $ownerFarm.State
                    }
                }
                if ($ownerFarm.ZipCode) { $cityStateZip += " $($ownerFarm.ZipCode)" }
                $cityStateZipLine = $cityStateZip -join ''
                
                $billToHtml = @"
<div class="invoice-section">
    <h6 style="color: #2e7d32; font-weight: bold; margin-bottom: 10px; border-bottom: 2px solid #2e7d32; padding-bottom: 5px;">BILL TO</h6>
    <p style="font-weight: bold; font-size: 1.1em; margin: 5px 0;">$($ownerFarm.FarmName)</p>
"@
                if ($ownerFarm.ContactPerson) {
                    $billToHtml += "`n    <p style='margin: 3px 0;'>Attn: $($ownerFarm.ContactPerson)</p>"
                }
                if ($ownerFarm.Address) {
                    $billToHtml += "`n    <p style='margin: 3px 0;'>$($ownerFarm.Address)</p>"
                }
                if ($cityStateZipLine) {
                    $billToHtml += "`n    <p style='margin: 3px 0;'>$cityStateZipLine</p>"
                }
                if ($ownerFarm.PhoneNumber) {
                    $billToHtml += "`n    <p style='margin: 3px 0;'>Phone: $($ownerFarm.PhoneNumber)</p>"
                }
                if ($ownerFarm.Email) {
                    $billToHtml += "`n    <p style='margin: 3px 0;'>Email: $($ownerFarm.Email)</p>"
                }
                $billToHtml += "`n</div>"
            } else {
                # No farm found - show owner name only
                $billToHtml = @"
<div class="invoice-section">
    <h6 style="color: #2e7d32; font-weight: bold; margin-bottom: 10px; border-bottom: 2px solid #2e7d32; padding-bottom: 5px;">BILL TO</h6>
    <p style="font-weight: bold; font-size: 1.1em; margin: 5px 0;">$($invoiceData.Owner)</p>
</div>
"@
            }
            
            New-UDHtml -Markup $billToHtml
            
            if ($isMultiCattle) {
                # Multi-cattle invoice - show line items
                # Build HTML for all line items
                $lineItemsHtml = @"
<div class="invoice-section">
    <h6 style="color: #2e7d32; font-weight: bold; margin-bottom: 15px; border-bottom: 2px solid #2e7d32; padding-bottom: 5px;">INVOICE LINE ITEMS</h6>
"@
                
                $lineItemNumber = 1
                foreach ($lineItem in $invoiceData.LineItems) {
                    # Get cattle details
                    $cattle = Get-CattleById -CattleID $lineItem.CattleID
                    
                    # Get health records with costs for this animal
                    $healthRecords = Get-HealthRecordsWithCost -CattleID $lineItem.CattleID 
                    
                    # Build line item HTML
                    $lineItemsHtml += @"
    <div style="border: 1px solid #ddd; padding: 15px; margin-bottom: 20px; background-color: #fafafa;">
        <h6 style="color: #2e7d32; font-weight: bold; margin-bottom: 10px;">Animal #$lineItemNumber - $($lineItem.TagNumber) ($($lineItem.CattleName))</h6>
        
        <div style="margin-bottom: 10px;">
            <div class="invoice-info-row">
                <span class="invoice-label">Breed:</span>
                <span>$($cattle.Breed)</span>
            </div>
            <div class="invoice-info-row">
                <span class="invoice-label">Origin Farm:</span>
                <span>$($cattle.OriginFarm)</span>
            </div>
        </div>
        
        <p style="font-weight: bold; margin-top: 10px; margin-bottom: 5px; font-size: 0.9em;">Feeding Costs:</p>
        <div style="margin-left: 20px;">
            <div class="invoice-info-row">
                <span>Period: </span>
                <span>$(Format-Date $lineItem.StartDate) - $(Format-Date $lineItem.EndDate)</span>
            </div>
            <div class="invoice-info-row">
                <span>Days on Feed: </span>
                <span>$($lineItem.DaysOnFeed) days</span>
            </div>
            <div class="invoice-info-row">
                <span>Rate: </span>
                <span>$(Format-Currency ([math]::Round($lineItem.PricePerDay, 2))) per day</span>
            </div>
            <div class="invoice-info-row">
                <span style="font-weight: bold;">Feeding Subtotal: </span>
                <span style="font-weight: bold;">$(Format-Currency ([math]::Round($lineItem.FeedingCost, 2)))</span>
            </div>
        </div>
"@
                    
                    # Health costs
                    if ($healthRecords) {
                        $lineItemsHtml += @"
        <p style="font-weight: bold; margin-top: 15px; margin-bottom: 5px; font-size: 0.9em;">Health & Veterinary Costs:</p>
        <div style="margin-left: 20px;">
        <table class="invoice-table" style="font-size: 0.9em;">
            <thead>
                <tr>
                    <th style="width: 20%;">Date</th>
                    <th style="width: 25%;">Type</th>
                    <th style="width: 40%;">Description</th>
                    <th style="width: 15%; text-align: right;">Cost</th>
                </tr>
            </thead>
            <tbody>
"@
                        foreach ($record in $healthRecords) {
                            $date = Format-Date $record.RecordDate
                            $type = $record.RecordType
                            $desc = if ($record.Title) { $record.Title } else { $record.Description }
                            $cost = Format-Currency ([math]::Round($record.Cost, 2))
                            
                            $lineItemsHtml += @"
                <tr>
                    <td>$date</td>
                    <td>$type</td>
                    <td>$desc</td>
                    <td style="text-align: right;">$cost</td>
                </tr>
"@
                        }
                        
                        $lineItemsHtml += @"
            </tbody>
        </table>
    <div style="text-align: right; font-weight: bold; margin-top: 10px;">Health Subtotal: $(Format-Currency ([math]::Round($lineItem.HealthCost, 2)))</div>
        </div>
"@
                    } else {
                        $lineItemsHtml += @"
        <p style="font-weight: bold; margin-top: 15px; margin-left: 20px; font-size: 0.9em;">Health & Veterinary Costs: `$0.00</p>
"@
                    }
                    
                    $lineItemsHtml += @"
        <div style="text-align: right; font-weight: bold; font-size: 1.2em; margin-top: 15px; padding-top: 10px; border-top: 2px solid #2e7d32; color: #2e7d32;">
            Animal Total: $(Format-Currency ([math]::Round($lineItem.LineItemTotal, 2)))
        </div>
    </div>
"@
                    
                    $lineItemNumber++
                }
                
                $lineItemsHtml += "</div>"
                
                # Render the complete HTML
                New-UDHtml -Markup $lineItemsHtml
            } else {
                # Single-cattle invoice (legacy format)
                $cattle = Get-CattleById -CattleID $invoiceData.CattleID
                
                # Get health records with costs for this animal
                $healthRecords = Get-HealthRecordsWithCost -CattleID $invoiceData.CattleID 
                
                # Cattle Information Section
                New-UDElement -Tag 'div' -Attributes @{class = 'invoice-section' } -Content {
                    New-UDTypography -Text "ANIMAL INFORMATION" -Variant h6 -Style @{
                        color         = '#2e7d32'
                        fontWeight    = 'bold'
                        marginBottom  = '15px'
                        borderBottom  = '2px solid #2e7d32'
                        paddingBottom = '5px'
                    }
                    
                    New-UDElement -Tag 'div' -Attributes @{class = 'invoice-info-row' } -Content {
                        New-UDElement -Tag 'span' -Attributes @{class = 'invoice-label' } -Content { "Tag Number:" }
                        New-UDElement -Tag 'span' -Content { $cattle.TagNumber }
                    }
                    
                    New-UDElement -Tag 'div' -Attributes @{class = 'invoice-info-row' } -Content {
                        New-UDElement -Tag 'span' -Attributes @{class = 'invoice-label' } -Content { "Name:" }
                        New-UDElement -Tag 'span' -Content { $cattle.Name }
                    }
                    
                    New-UDElement -Tag 'div' -Attributes @{class = 'invoice-info-row' } -Content {
                        New-UDElement -Tag 'span' -Attributes @{class = 'invoice-label' } -Content { "Breed:" }
                        New-UDElement -Tag 'span' -Content { $cattle.Breed }
                    }
                    
                    New-UDElement -Tag 'div' -Attributes @{class = 'invoice-info-row' } -Content {
                        New-UDElement -Tag 'span' -Attributes @{class = 'invoice-label' } -Content { "Origin Farm:" }
                        New-UDElement -Tag 'span' -Content { $cattle.OriginFarm }
                    }
                }
                
                # Feeding Costs Section
                New-UDElement -Tag 'div' -Attributes @{class = 'invoice-section' } -Content {
                    New-UDTypography -Text "FEEDING COSTS" -Variant h6 -Style @{
                        color         = '#2e7d32'
                        fontWeight    = 'bold'
                        marginBottom  = '15px'
                        borderBottom  = '2px solid #2e7d32'
                        paddingBottom = '5px'
                    }
                    
                        New-UDElement -Tag 'div' -Attributes @{class = 'invoice-info-row' } -Content {
                        New-UDElement -Tag 'span' -Attributes @{class = 'invoice-label' } -Content { "Start Date:" }
                        New-UDElement -Tag 'span' -Content { Format-Date $invoiceData.StartDate }
                    }
                    
                        New-UDElement -Tag 'div' -Attributes @{class = 'invoice-info-row' } -Content {
                        New-UDElement -Tag 'span' -Attributes @{class = 'invoice-label' } -Content { "End Date:" }
                        New-UDElement -Tag 'span' -Content { Format-Date $invoiceData.EndDate }
                    }
                    
                    New-UDElement -Tag 'div' -Attributes @{class = 'invoice-info-row' } -Content {
                        New-UDElement -Tag 'span' -Attributes @{class = 'invoice-label' } -Content { "Days on Feed:" }
                        New-UDElement -Tag 'span' -Content { "$($invoiceData.DaysOnFeed) days" }
                    }
                    
                    New-UDElement -Tag 'div' -Attributes @{class = 'invoice-info-row' } -Content {
                        New-UDElement -Tag 'span' -Attributes @{class = 'invoice-label' } -Content { "Price per Day:" }
                        $ppdValue = [math]::Round($invoiceData.PricePerDay, 2)
                        $PricePerDay = Format-Currency $ppdValue
                        New-UDElement -Tag 'span' -Content { $PricePerDay }
                    }

                    $totalFeedingCost = [math]::Round($invoiceData.FeedingCost, 2)
                    New-UDTypography -Text "Total Feed Cost: $(Format-Currency $totalFeedingCost)" -Variant body1 -Style @{
                        fontWeight = 'bold'
                        fontSize   = '1.1em'
                        marginTop  = '15px'
                        textAlign  = 'right'
                    }
                }
                
                # Health Costs Section
                New-UDElement -Tag 'div' -Attributes @{class = 'invoice-section' } -Content {
                    New-UDTypography -Text "HEALTH & VETERINARY COSTS" -Variant h6 -Style @{
                        color         = '#2e7d32'
                        fontWeight    = 'bold'
                        marginBottom  = '15px'
                        borderBottom  = '2px solid #2e7d32'
                        paddingBottom = '5px'
                    }
                    
                    if ($healthRecords) {
                        # Create table header HTML
                        $tableHtml = @"
<table class="invoice-table">
    <thead>
        <tr>
            <th style="width: 15%;">Date</th>
            <th style="width: 20%;">Type</th>
            <th style="width: 50%;">Description</th>
            <th style="width: 15%; text-align: right;">Cost</th>
        </tr>
    </thead>
    <tbody>
"@
                        # Add each health record as a row
                        foreach ($record in $healthRecords) {
                            $date = Format-Date $record.RecordDate
                            $type = $record.RecordType
                            $desc = if ($record.Title) { $record.Title } else { $record.Description }
                            $costValue = [math]::Round($record.Cost, 2)
                            $cost = Format-Currency $costValue
                            
                            $tableHtml += @"
        <tr>
            <td>$date</td>
            <td>$type</td>
            <td>$desc</td>
            <td style="text-align: right;">$cost</td>
        </tr>
"@
                        }
                        
                        $tableHtml += @"
    </tbody>
</table>
"@
                        
                        New-UDHtml -Markup $tableHtml
                        
                        $totalHealthCost = [math]::Round($invoiceData.HealthCost, 2)
                        New-UDTypography -Text "Total Health Cost: $(Format-Currency $totalHealthCost)" -Variant body1 -Style @{
                            fontWeight = 'bold'
                            fontSize   = '1.1em'
                            marginTop  = '15px'
                            textAlign  = 'right'
                        }
                    }
                    else {
                        New-UDTypography -Text "No health costs associated with this animal" -Variant body2 -Style @{
                            color     = '#666'
                            fontStyle = 'italic'
                            marginTop = '10px'
                        }
                        New-UDElement -Tag 'div' -Attributes @{style = 'font-weight: bold; font-size: 1.1em; margin-top: 15px; text-align: right;' } -Content {
                            "Total Health Cost: `$0.00"
                        }
                    }
                }
            }
            
            # Total Section
            New-UDElement -Tag 'div' -Attributes @{class = 'invoice-total' } -Content {
                $totalCost = [math]::Round($invoiceData.TotalCost, 2)
                "TOTAL COST: $(Format-Currency $totalCost)"
            }
            
            # Notes Section
            if ($invoiceData.Notes) {
                New-UDElement -Tag 'div' -Attributes @{class = 'invoice-section'; style = 'margin-top: 30px;' } -Content {
                    New-UDTypography -Text "NOTES" -Variant h6 -Style @{
                        color         = '#2e7d32'
                        fontWeight    = 'bold'
                        marginBottom  = '10px'
                        borderBottom  = '2px solid #2e7d32'
                        paddingBottom = '5px'
                    }
                    New-UDTypography -Text $invoiceData.Notes -Variant body2 -Style @{color = '#555' }
                }
            }
            
            # Print Button (hidden when printing)
            New-UDElement -Tag 'div' -Attributes @{class = 'no-print'; style = 'text-align: center; margin-top: 30px;' } -Content {
                New-UDButton -Text "🖨️ Print Invoice" -Variant contained -OnClick {
                    Invoke-UDJavaScript -JavaScript "window.print();"
                } -Style @{
                    backgroundColor = '#2e7d32'
                    color           = 'white'
                    padding         = '12px 30px'
                    fontSize        = '1.1em'
                }
            }
        }
    }
}






