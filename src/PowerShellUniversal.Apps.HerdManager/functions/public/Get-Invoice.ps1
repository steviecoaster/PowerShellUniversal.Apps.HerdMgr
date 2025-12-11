function Get-Invoice {
    <#
    .SYNOPSIS
    Gets invoice(s) by invoice number or cattle ID (supports both single and multi-cattle invoices)
    
    .DESCRIPTION
    Retrieves invoice data. For invoices with line items (multi-cattle), adds a LineItems property
    containing all cattle details. For legacy single-cattle invoices, returns data as before.
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
        # Get invoice header
        $query = @"
SELECT 
    i.InvoiceID,
    i.InvoiceNumber,
    i.CattleID,
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
WHERE i.InvoiceNumber = @InvoiceNumber
"@
        
        $result = Invoke-SqliteQuery -DataSource $script:DatabasePath -Query $query -SqlParameters @{
            InvoiceNumber = $InvoiceNumber
        } -As PSObject
        
        if ($result) {
            # Check if this is a multi-cattle invoice (has line items)
            $lineItemsQuery = @"
SELECT 
    li.LineItemID,
    li.CattleID,
    c.TagNumber,
    c.Name AS CattleName,
    c.Owner,
    CAST(li.StartDate AS TEXT) AS StartDate,
    CAST(li.EndDate AS TEXT) AS EndDate,
    li.DaysOnFeed,
    li.PricePerDay,
    li.FeedingCost,
    li.HealthCost,
    li.LineItemTotal,
    li.Notes AS LineItemNotes
FROM InvoiceLineItems li
JOIN Cattle c ON li.CattleID = c.CattleID
WHERE li.InvoiceID = @InvoiceID
ORDER BY c.TagNumber
"@
            
            $lineItems = Invoke-SqliteQuery -DataSource $script:DatabasePath -Query $lineItemsQuery -SqlParameters @{
                InvoiceID = $result.InvoiceID
            } -As PSObject
            
            if ($lineItems) {
                # Multi-cattle invoice - add line items and get owner from first cattle
                $result | Add-Member -MemberType NoteProperty -Name 'LineItems' -Value $lineItems -Force
                $result | Add-Member -MemberType NoteProperty -Name 'Owner' -Value $lineItems[0].Owner -Force
                $result | Add-Member -MemberType NoteProperty -Name 'IsMultiCattle' -Value $true -Force
            }
            else {
                # Legacy single-cattle invoice - get cattle details
                if ($result.CattleID) {
                    $cattleQuery = @"
SELECT TagNumber, Name AS CattleName, Owner
FROM Cattle
WHERE CattleID = @CattleID
"@
                    $cattle = Invoke-SqliteQuery -DataSource $script:DatabasePath -Query $cattleQuery -SqlParameters @{
                        CattleID = $result.CattleID
                    } -As PSObject
                    
                    if ($cattle) {
                        $result | Add-Member -MemberType NoteProperty -Name 'TagNumber' -Value $cattle.TagNumber -Force
                        $result | Add-Member -MemberType NoteProperty -Name 'CattleName' -Value $cattle.CattleName -Force
                        $result | Add-Member -MemberType NoteProperty -Name 'Owner' -Value $cattle.Owner -Force
                    }
                }
                $result | Add-Member -MemberType NoteProperty -Name 'IsMultiCattle' -Value $false -Force
            }
        }
    }
    elseif ($CattleID) {
        # Get all invoices for a specific cattle (both as primary and in line items)
        $query = @"
SELECT DISTINCT
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
LEFT JOIN Cattle c ON i.CattleID = c.CattleID
LEFT JOIN InvoiceLineItems li ON i.InvoiceID = li.InvoiceID
WHERE i.CattleID = @CattleID OR li.CattleID = @CattleID
ORDER BY i.InvoiceDate DESC
"@
        
        $result = Invoke-SqliteQuery -DataSource $script:DatabasePath -Query $query -SqlParameters @{
            CattleID = $CattleID
        } -As PSObject
    }
    else {
        # Get all invoices (simplified for table display)
        $query = @"
SELECT 
    i.InvoiceID,
    i.InvoiceNumber,
    i.CattleID,
    COALESCE(c.TagNumber, 'Multiple') AS TagNumber,
    COALESCE(c.Name, 'Multiple Cattle') AS CattleName,
    COALESCE(c.Owner, (SELECT Owner FROM Cattle WHERE CattleID = (SELECT CattleID FROM InvoiceLineItems WHERE InvoiceID = i.InvoiceID LIMIT 1))) AS Owner,
    CAST(i.InvoiceDate AS TEXT) AS InvoiceDate,
    i.TotalCost,
    CASE WHEN EXISTS(SELECT 1 FROM InvoiceLineItems WHERE InvoiceID = i.InvoiceID) THEN 1 ELSE 0 END AS IsMultiCattle
FROM Invoices i
LEFT JOIN Cattle c ON i.CattleID = c.CattleID
ORDER BY i.InvoiceDate DESC
"@
        
        $result = Invoke-SqliteQuery -DataSource $script:DatabasePath -Query $query -As PSObject
    }
    
    return $result
}
