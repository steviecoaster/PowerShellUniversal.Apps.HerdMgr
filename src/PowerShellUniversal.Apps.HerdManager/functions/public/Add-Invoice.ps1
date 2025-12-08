function Add-Invoice {
    <#
    .SYNOPSIS
    Creates a new invoice record
    #>
    param(
        [Parameter(Mandatory)]
        [string]$InvoiceNumber,
        
        [Parameter(Mandatory)]
        [int]$CattleID,
        
        [Parameter(Mandatory)]
        [DateTime]$InvoiceDate,
        
        [Parameter(Mandatory)]
        [DateTime]$StartDate,
        
        [Parameter(Mandatory)]
        [DateTime]$EndDate,
        
        [Parameter(Mandatory)]
        [int]$DaysOnFeed,
        
        [Parameter(Mandatory)]
        [decimal]$PricePerDay,
        
        [Parameter(Mandatory)]
        [decimal]$FeedingCost,
        
        [Parameter(Mandatory)]
        [decimal]$HealthCost,
        
        [Parameter(Mandatory)]
        [decimal]$TotalCost,
        
        [string]$Notes,
        [string]$CreatedBy
    )
    
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
