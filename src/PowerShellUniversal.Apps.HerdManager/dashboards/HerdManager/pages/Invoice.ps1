$invoicePage = New-UDPage -Name "Invoice" -Url "/invoice/:invoiceNumber" -Content {
    $invoiceNumber = $InvoiceNumber
    
    $dbPath = $script:DatabasePath
    
    # Get invoice details
    $invoiceData = Get-Invoice -InvoiceNumber $invoiceNumber
    
    if (-not $invoiceData) {
        New-UDTypography -Text "Invoice not found" -Variant h4 -Style @{color = 'red'; textAlign = 'center'; marginTop = '50px' }
        return
    }
    
    # Get cattle details
    $cattle = Get-CattleById -CattleID $invoiceData.CattleID
    
    # Get health records with costs
    $healthQuery = @"
SELECT 
    CAST(RecordDate AS TEXT) AS RecordDate,
    RecordType,
    Title,
    Description,
    Cost,
    VeterinarianName,
    RecordedBy
FROM HealthRecords
WHERE CattleID = @CattleID AND Cost > 0
ORDER BY RecordDate
"@
    $healthRecords = Invoke-SqliteQuery -DataSource $dbPath -Query $healthQuery -SqlParameters @{
        CattleID = $invoiceData.CattleID
    } -As PSObject
    
    # Print-friendly styles
    New-UDStyle -Style @'
        @media print {
            .MuiAppBar-root, .MuiDrawer-root, button, .no-print {
                display: none !important;
            }
            body {
                margin: 0;
                padding: 20px;
            }
            .invoice-container {
                max-width: 100% !important;
                margin: 0 !important;
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
            $invoiceDate = [DateTime]::Parse($invoiceData.InvoiceDate)
            $dueDate = $invoiceDate.AddDays(30)
            $headerHtml = @"
<div class="invoice-header">
    <div style="display: flex; justify-content: space-between;">
        <div>
            <h2 style="color: #2e7d32; font-weight: bold; margin: 0;">🐄 Gundy Ridge Farms</h2>
        </div>
        <div style="text-align: right;">
            <p style="margin: 2px 0;">123 Farm Road</p>
            <p style="margin: 2px 0;">Gundy Ridge, State 12345</p>
            <p style="margin: 2px 0;">Phone: (555) 123-4567</p>
            <p style="margin: 2px 0;">Email: billing@gundyridge.farm</p>
        </div>
    </div>
    <div style="display: flex; justify-content: space-between; margin-top: 20px;">
        <div>
            <p style="font-size: 1.1em; font-weight: bold; margin: 5px 0;">Invoice #: $($invoiceData.InvoiceNumber)</p>
            <p style="margin: 5px 0;">Date: $($invoiceDate.ToString('MMMM dd, yyyy'))</p>
            <p style="margin: 5px 0; font-size: 0.9em;">Created By: $($invoiceData.CreatedBy)</p>
        </div>
        <div style="text-align: right;">
            <p style="font-weight: bold; margin: 5px 0;">Payment Terms: NET 30</p>
            <p style="margin: 5px 0;">Due Date: $($dueDate.ToString('MMMM dd, yyyy'))</p>
        </div>
    </div>
</div>
"@
            New-UDHtml -Markup $headerHtml
            
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
                
                if ($cattle.Owner) {
                    New-UDElement -Tag 'div' -Attributes @{class = 'invoice-info-row' } -Content {
                        New-UDElement -Tag 'span' -Attributes @{class = 'invoice-label' } -Content { "Owner:" }
                        New-UDElement -Tag 'span' -Content { $cattle.Owner }
                    }
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
                    New-UDElement -Tag 'span' -Content { [DateTime]::Parse($invoiceData.StartDate).ToString('MM/dd/yyyy') }
                }
                
                New-UDElement -Tag 'div' -Attributes @{class = 'invoice-info-row' } -Content {
                    New-UDElement -Tag 'span' -Attributes @{class = 'invoice-label' } -Content { "End Date:" }
                    New-UDElement -Tag 'span' -Content { [DateTime]::Parse($invoiceData.EndDate).ToString('MM/dd/yyyy') }
                }
                
                New-UDElement -Tag 'div' -Attributes @{class = 'invoice-info-row' } -Content {
                    New-UDElement -Tag 'span' -Attributes @{class = 'invoice-label' } -Content { "Days on Feed:" }
                    New-UDElement -Tag 'span' -Content { "$($invoiceData.DaysOnFeed) days" }
                }
                
                New-UDElement -Tag 'div' -Attributes @{class = 'invoice-info-row' } -Content {
                    New-UDElement -Tag 'span' -Attributes @{class = 'invoice-label' } -Content { "Price per Day:" }
                    $ppdValue = [math]::Round($invoiceData.PricePerDay, 2)
                        $PricePerDay = $ppdValue.ToString('C2')
                    New-UDElement -Tag 'span' -Content { $PricePerDay }
                }

                $totalFeedingCost = [math]::Round($invoiceData.FeedingCost, 2)
                New-UDTypography -Text "Total Feed Cost: $($totalFeedingCost.ToString('C2'))" -Variant body1 -Style @{
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
                        $date = [DateTime]::Parse($record.RecordDate).ToString('MM/dd/yyyy')
                        $type = $record.RecordType
                        $desc = if ($record.Title) { $record.Title } else { $record.Description }
                        $costValue = [math]::Round($record.Cost, 2)
                        $cost = $costValue.ToString('C2')
                        
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
                    New-UDTypography -Text "Total Health Cost: $($totalHealthCost.ToString('C2'))" -Variant body1 -Style @{
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
            
            # Total Section
            New-UDElement -Tag 'div' -Attributes @{class = 'invoice-total' } -Content {
                $totalCost = [math]::Round($invoiceData.TotalCost, 2)
                "TOTAL COST: $($totalCost.ToString('C2'))"
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
