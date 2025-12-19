function Get-AllCattle {
    <#
    .SYNOPSIS
    Retrieves all cattle records
    
    .DESCRIPTION
    Returns cattle records from the database with their latest weight information.
    Uses the CattleWithLatestWeight view to include current weight data.
    
    .PARAMETER Status
    Filter by cattle status. Valid values:
    - Active: Currently in herd (default)
    - Sold: Animals that have been sold
    - Deceased: Animals that have died
    - Transferred: Animals transferred to another location
    
    .OUTPUTS
    Array of cattle records with the following properties:
    - CattleID, TagNumber, Name, Breed, Gender
    - BirthDate, PurchaseDate, Location, Owner
    - OriginFarm, OriginFarmID, PricePerDay
    - Status, Notes, CreatedDate, ModifiedDate
    - LatestWeight, LatestWeightDate (from most recent weight record)
    
    .EXAMPLE
    Get-AllCattle
    
    Returns all active cattle with their latest weights
    
    .EXAMPLE
    Get-AllCattle -Status Sold
    
    Returns all cattle that have been sold
    
    .EXAMPLE
    Get-AllCattle | Where-Object { $_.Breed -eq 'Angus' }
    
    Returns all active Angus cattle
    
    .NOTES
    The function queries the CattleWithLatestWeight view which automatically joins
    weight records to provide the most recent weight for each animal.
    #>
    param(
        [ValidateSet('Active', 'Sold', 'Deceased', 'Transferred')]
        [string]$Status = 'Active'
    )
    
    $statusValue = ConvertTo-SqlValue -Value $Status
    $query = "SELECT * FROM CattleWithLatestWeight WHERE Status = $statusValue ORDER BY TagNumber"
    
    Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $query 
}





