function Add-Invoice {
    <#
    .SYNOPSIS
    Creates a new invoice record (supports single or multiple cattle)
    
    .DESCRIPTION
    Creates an invoice with either a single cattle (legacy mode) or multiple cattle via line items.
    When LineItems parameter is provided, creates a multi-cattle invoice.
    
    .PARAMETER LineItems
    Array of hashtables containing line item details for multi-cattle invoices.
    Each hashtable should have: CattleID, StartDate, EndDate, DaysOnFeed, PricePerDay, FeedingCost, HealthCost, LineItemTotal, Notes
    
    .EXAMPLE
    # Single cattle invoice (legacy)
    Add-Invoice -InvoiceNumber "INV-001" -CattleID 1 -InvoiceDate (Get-Date) -StartDate (Get-Date).AddDays(-30) -EndDate (Get-Date) -DaysOnFeed 30 -PricePerDay 5.00 -FeedingCost 150.00 -HealthCost 25.00 -TotalCost 175.00
    
    .EXAMPLE
    # Multi-cattle invoice
    $lineItems = @(
        @{CattleID=1; StartDate=(Get-Date).AddDays(-30); EndDate=(Get-Date); DaysOnFeed=30; PricePerDay=5.00; FeedingCost=150.00; HealthCost=25.00; LineItemTotal=175.00}
        @{CattleID=2; StartDate=(Get-Date).AddDays(-25); EndDate=(Get-Date); DaysOnFeed=25; PricePerDay=5.50; FeedingCost=137.50; HealthCost=15.00; LineItemTotal=152.50}
    )
    Add-Invoice -InvoiceNumber "INV-002" -InvoiceDate (Get-Date) -LineItems $lineItems -TotalCost 327.50
    #>
    param(
        [Parameter(Mandatory, ParameterSetName = 'Single')]
        [Parameter(Mandatory, ParameterSetName = 'Multi')]
        [string]$InvoiceNumber,
        
        [Parameter(Mandatory, ParameterSetName = 'Single')]
        [Parameter(Mandatory, ParameterSetName = 'Multi')]
        [DateTime]$InvoiceDate,
        
        [Parameter(Mandatory, ParameterSetName = 'Single')]
        [Parameter(Mandatory, ParameterSetName = 'Multi')]
        [decimal]$TotalCost,
        
        [Parameter(ParameterSetName = 'Single')]
        [Parameter(ParameterSetName = 'Multi')]
        [string]$Notes,
        
        [Parameter(ParameterSetName = 'Single')]
        [Parameter(ParameterSetName = 'Multi')]
        [string]$CreatedBy,
        
        # Single cattle parameters (legacy)
        [Parameter(Mandatory, ParameterSetName = 'Single')]
        [int]$CattleID,
        
        [Parameter(Mandatory, ParameterSetName = 'Single')]
        [DateTime]$StartDate,
        
        [Parameter(Mandatory, ParameterSetName = 'Single')]
        [DateTime]$EndDate,
        
        [Parameter(Mandatory, ParameterSetName = 'Single')]
        [int]$DaysOnFeed,
        
        [Parameter(Mandatory, ParameterSetName = 'Single')]
        [decimal]$PricePerDay,
        
        [Parameter(Mandatory, ParameterSetName = 'Single')]
        [decimal]$FeedingCost,
        
        [Parameter(Mandatory, ParameterSetName = 'Single')]
        [decimal]$HealthCost,
        
        # Multi-cattle parameters
        [Parameter(Mandatory, ParameterSetName = 'Multi')]
        [hashtable[]]$LineItems
    )
    
    if ($PSCmdlet.ParameterSetName -eq 'Single') {
        # Legacy single-cattle invoice
        $invoiceNumberValue = ConvertTo-SqlValue -Value $InvoiceNumber
        $invoiceDateValue = ConvertTo-SqlValue -Value $InvoiceDate
        $startDateValue = ConvertTo-SqlValue -Value $StartDate
        $endDateValue = ConvertTo-SqlValue -Value $EndDate
        $notesValue = ConvertTo-SqlValue -Value $Notes
        $createdByValue = ConvertTo-SqlValue -Value $CreatedBy
        
        $query = "INSERT INTO Invoices (InvoiceNumber, CattleID, InvoiceDate, StartDate, EndDate, DaysOnFeed, PricePerDay, FeedingCost, HealthCost, TotalCost, Notes, CreatedBy) VALUES ($invoiceNumberValue, $CattleID, $invoiceDateValue, $startDateValue, $endDateValue, $DaysOnFeed, $PricePerDay, $FeedingCost, $HealthCost, $TotalCost, $notesValue, $createdByValue)"
        
        Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $query
    }
    else {
        # Multi-cattle invoice with line items
        # First, create the invoice header
        $invoiceNumberValue = ConvertTo-SqlValue -Value $InvoiceNumber
        $invoiceDateValue = ConvertTo-SqlValue -Value $InvoiceDate
        $notesValue = ConvertTo-SqlValue -Value $Notes
        $createdByValue = ConvertTo-SqlValue -Value $CreatedBy
        
        $headerQuery = "INSERT INTO Invoices (InvoiceNumber, InvoiceDate, TotalCost, Notes, CreatedBy) VALUES ($invoiceNumberValue, $invoiceDateValue, $TotalCost, $notesValue, $createdByValue)"
        
        Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $headerQuery
        
        # Get the InvoiceID of the newly created invoice
        $invoiceIdQuery = "SELECT InvoiceID FROM Invoices WHERE InvoiceNumber = $invoiceNumberValue"
        $invoiceIdResult = Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $invoiceIdQuery 
        
        $invoiceId = $invoiceIdResult.InvoiceID
        
        # Insert line items
        foreach ($item in $LineItems) {
            $startDateValue = ConvertTo-SqlValue -Value $item.StartDate
            $endDateValue = ConvertTo-SqlValue -Value $item.EndDate
            $itemNotesValue = ConvertTo-SqlValue -Value $item.Notes
            
            $lineItemQuery = "INSERT INTO InvoiceLineItems (InvoiceID, CattleID, StartDate, EndDate, DaysOnFeed, PricePerDay, FeedingCost, HealthCost, LineItemTotal, Notes) VALUES ($invoiceId, $($item.CattleID), $startDateValue, $endDateValue, $($item.DaysOnFeed), $($item.PricePerDay), $($item.FeedingCost), $($item.HealthCost), $($item.LineItemTotal), $itemNotesValue)"
            
            Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $lineItemQuery
        }
    }
}






