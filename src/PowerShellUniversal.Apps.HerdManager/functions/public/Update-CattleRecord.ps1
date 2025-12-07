function Update-CattleRecord {
    <#
    .SYNOPSIS
    Updates an existing cattle record
    #>
    param(
        [Parameter(Mandatory)]
        [int]$CattleID,
        
        [Parameter(Mandatory)]
        [string]$TagNumber,
        
        [Parameter(Mandatory)]
        [string]$OriginFarm,
        
        [Parameter()]
        [string]
        $Name,
        
        [Parameter()]
        [string]
        $Breed,
        
        [Parameter()]
        [ValidateSet('Steer', 'Heifer')]
        [string]
        $Gender,

        [Parameter()]
        [String]
        $Location,

        [Parameter()]
        [DateTime]
        $BirthDate,
        
        [Parameter()]
        [DateTime]
        $PurchaseDate,
        
        [Parameter()]
        [ValidateSet('Active', 'Sold', 'Deceased', 'Transferred')]
        [string]
        $Status = 'Active',
        
        [Parameter()]
        [string]
        $Notes
    )
    
    $query = @"
UPDATE Cattle
SET TagNumber = @TagNumber,
    OriginFarm = @OriginFarm,
    Name = @Name,
    Breed = @Breed,
    Gender = @Gender,
    BirthDate = @BirthDate,
    PurchaseDate = @PurchaseDate,
    Location = @Location,
    Status = @Status,
    Notes = @Notes,
    ModifiedDate = CURRENT_TIMESTAMP
WHERE CattleID = @CattleID
"@
    
    $params = @{
        DataSource = $script:DatabasePath
        Query = $query
        SqlParameters = @{
            CattleID = $CattleID
            TagNumber = $TagNumber
            OriginFarm = $OriginFarm
            Name = $Name
            Breed = $Breed
            Gender = $Gender
            BirthDate = $BirthDate
            PurchaseDate = $PurchaseDate
            Location = $Location
            Status = $Status
            Notes = $Notes
        }
    }
    
    Invoke-SqliteQuery @params
}
