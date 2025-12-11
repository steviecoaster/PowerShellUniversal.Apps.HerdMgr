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
        $query = @"
INSERT INTO Invoices (InvoiceNumber, CattleID, InvoiceDate, StartDate, EndDate, DaysOnFeed, PricePerDay, FeedingCost, HealthCost, TotalCost, Notes, CreatedBy)
VALUES (@InvoiceNumber, @CattleID, @InvoiceDate, @StartDate, @EndDate, @DaysOnFeed, @PricePerDay, @FeedingCost, @HealthCost, @TotalCost, @Notes, @CreatedBy)
"@
        
        $params = @{
            DataSource = $script:DatabasePath
            Query = $query
            SqlParameters = @{
                InvoiceNumber = $InvoiceNumber
                CattleID = $CattleID
                InvoiceDate = $InvoiceDate.ToString('MM/dd/yyyy HH:mm:ss')
                StartDate = $StartDate.ToString('MM/dd/yyyy HH:mm:ss')
                EndDate = $EndDate.ToString('MM/dd/yyyy HH:mm:ss')
                DaysOnFeed = $DaysOnFeed
                PricePerDay = $PricePerDay
                FeedingCost = $FeedingCost
                HealthCost = $HealthCost
                TotalCost = $TotalCost
                Notes = $Notes
                CreatedBy = $CreatedBy
            }
        }
        
        Invoke-SqliteQuery @params
    }
    else {
        # Multi-cattle invoice with line items
        # First, create the invoice header
        $headerQuery = @"
INSERT INTO Invoices (InvoiceNumber, InvoiceDate, TotalCost, Notes, CreatedBy)
VALUES (@InvoiceNumber, @InvoiceDate, @TotalCost, @Notes, @CreatedBy)
"@
        
        $headerParams = @{
            DataSource = $script:DatabasePath
            Query = $headerQuery
            SqlParameters = @{
                InvoiceNumber = $InvoiceNumber
                InvoiceDate = $InvoiceDate.ToString('MM/dd/yyyy HH:mm:ss')
                TotalCost = $TotalCost
                Notes = $Notes
                CreatedBy = $CreatedBy
            }
        }
        
        Invoke-SqliteQuery @headerParams
        
        # Get the InvoiceID of the newly created invoice
        $invoiceIdQuery = "SELECT InvoiceID FROM Invoices WHERE InvoiceNumber = @InvoiceNumber"
        $invoiceIdResult = Invoke-SqliteQuery -DataSource $script:DatabasePath -Query $invoiceIdQuery -SqlParameters @{
            InvoiceNumber = $InvoiceNumber
        } -As PSObject
        
        $invoiceId = $invoiceIdResult.InvoiceID
        
        # Insert line items
        foreach ($item in $LineItems) {
            $lineItemQuery = @"
INSERT INTO InvoiceLineItems (InvoiceID, CattleID, StartDate, EndDate, DaysOnFeed, PricePerDay, FeedingCost, HealthCost, LineItemTotal, Notes)
VALUES (@InvoiceID, @CattleID, @StartDate, @EndDate, @DaysOnFeed, @PricePerDay, @FeedingCost, @HealthCost, @LineItemTotal, @Notes)
"@
            
            $lineItemParams = @{
                DataSource = $script:DatabasePath
                Query = $lineItemQuery
                SqlParameters = @{
                    InvoiceID = $invoiceId
                    CattleID = $item.CattleID
                    StartDate = $item.StartDate.ToString('MM/dd/yyyy HH:mm:ss')
                    EndDate = $item.EndDate.ToString('MM/dd/yyyy HH:mm:ss')
                    DaysOnFeed = $item.DaysOnFeed
                    PricePerDay = $item.PricePerDay
                    FeedingCost = $item.FeedingCost
                    HealthCost = $item.HealthCost
                    LineItemTotal = $item.LineItemTotal
                    Notes = if ($item.Notes) { $item.Notes } else { $null }
                }
            }
            
            Invoke-SqliteQuery @lineItemParams
        }
    }
}
