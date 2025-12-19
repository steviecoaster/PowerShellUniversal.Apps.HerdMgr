function Get-CattleById {
    <#
    .SYNOPSIS
    Gets a specific cattle record by ID
    
    .DESCRIPTION
    Retrieves complete cattle information for a single animal using its database ID.
    
    .PARAMETER CattleID
    Database ID of the cattle to retrieve (required)
    
    .OUTPUTS
    PSCustomObject containing all cattle record fields:
    CattleID, TagNumber, OriginFarm, Name, Breed, Gender, BirthDate, PurchaseDate,
    Location, Owner, PricePerDay, Status, Notes, CreatedDate, ModifiedDate
    
    .EXAMPLE
    Get-CattleById -CattleID 5
    
    Returns the cattle record for ID 5
    
    .EXAMPLE
    $cattle = Get-CattleById -CattleID 12
    Write-Host "$($cattle.Name) is a $($cattle.Breed) $($cattle.Gender)"
    
    Retrieves cattle data and displays formatted information
    #>
    param(
        [Parameter(Mandatory)]
        [int]$CattleID
    )
    
    $query = @"
SELECT CattleID, TagNumber, OriginFarm, Name, Breed, Gender, BirthDate, PurchaseDate, Location, Owner, PricePerDay, Status, Notes, CreatedDate, ModifiedDate
FROM Cattle
WHERE CattleID = $CattleID
"@
    
    $result = Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $query 
    
    return $result
}






