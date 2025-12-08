function Get-Invoice {
    <#
    .SYNOPSIS
    Gets invoice(s) by invoice number or cattle ID
    #>
    param(
        [Parameter(ParameterSetName = 'ByNumber')]
        [string]$InvoiceNumber,
        
        [Parameter(ParameterSetName = 'ByCattle')]
        [int]$CattleID,
        
        [Parameter(ParameterSetName = 'All')]
        [switch]$All
    )
    
    if ($InvoiceNumber) {
        $query = @"
SELECT 
    i.InvoiceID,
    i.InvoiceNumber,
    i.CattleID,
    c.TagNumber,
    c.Name AS CattleName,
    c.Owner,
    CAST(i.InvoiceDate AS TEXT) AS InvoiceDate,
    CAST(i.StartDate AS TEXT) AS StartDate,
    CAST(i.EndDate AS TEXT) AS EndDate,
    i.DaysOnFeed,
    i.PricePerDay,
    i.FeedingCost,
    i.HealthCost,
    i.TotalCost,
    i.Notes,
    i.CreatedBy,
    CAST(i.CreatedDate AS TEXT) AS CreatedDate
FROM Invoices i
JOIN Cattle c ON i.CattleID = c.CattleID
WHERE i.InvoiceNumber = @InvoiceNumber
"@
        
        $result = Invoke-SqliteQuery -DataSource $script:DatabasePath -Query $query -SqlParameters @{
            InvoiceNumber = $InvoiceNumber
        } -As PSObject
    }
    elseif ($CattleID) {
        $query = @"
SELECT 
    i.InvoiceID,
    i.InvoiceNumber,
    i.CattleID,
    c.TagNumber,
    c.Name AS CattleName,
    c.Owner,
    CAST(i.InvoiceDate AS TEXT) AS InvoiceDate,
    CAST(i.StartDate AS TEXT) AS StartDate,
    CAST(i.EndDate AS TEXT) AS EndDate,
    i.DaysOnFeed,
    i.PricePerDay,
    i.FeedingCost,
    i.HealthCost,
    i.TotalCost,
    i.Notes,
    i.CreatedBy,
    CAST(i.CreatedDate AS TEXT) AS CreatedDate
FROM Invoices i
JOIN Cattle c ON i.CattleID = c.CattleID
WHERE i.CattleID = @CattleID
ORDER BY i.InvoiceDate DESC
"@
        
        $result = Invoke-SqliteQuery -DataSource $script:DatabasePath -Query $query -SqlParameters @{
            CattleID = $CattleID
        } -As PSObject
    }
    else {
        $query = @"
SELECT 
    i.InvoiceID,
    i.InvoiceNumber,
    i.CattleID,
    c.TagNumber,
    c.Name AS CattleName,
    c.Owner,
    CAST(i.InvoiceDate AS TEXT) AS InvoiceDate,
    CAST(i.StartDate AS TEXT) AS StartDate,
    CAST(i.EndDate AS TEXT) AS EndDate,
    i.DaysOnFeed,
    i.PricePerDay,
    i.FeedingCost,
    i.HealthCost,
    i.TotalCost,
    i.Notes,
    i.CreatedBy,
    CAST(i.CreatedDate AS TEXT) AS CreatedDate
FROM Invoices i
JOIN Cattle c ON i.CattleID = c.CattleID
ORDER BY i.InvoiceDate DESC
"@
        
        $result = Invoke-SqliteQuery -DataSource $script:DatabasePath -Query $query -As PSObject
    }
    
    return $result
}
