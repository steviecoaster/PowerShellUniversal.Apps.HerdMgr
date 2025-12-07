function Get-CattleById {
    <#
    .SYNOPSIS
    Gets a specific cattle record by ID
    #>
    param(
        [Parameter(Mandatory)]
        [int]$CattleID
    )
    
    $query = @"
SELECT CattleID, TagNumber, OriginFarm, Name, Breed, Gender, BirthDate, PurchaseDate, Location, Status, Notes, CreatedDate, ModifiedDate
FROM Cattle
WHERE CattleID = @CattleID
"@
    
    $result = Invoke-SqliteQuery -DataSource $script:DatabasePath -Query $query -SqlParameters @{
        CattleID = $CattleID
    } -As PSObject
    
    return $result
}
