function Update-CattleRecord {
    <#
    .SYNOPSIS
    Updates an existing cattle record
    
    .DESCRIPTION
    Modifies cattle information in the database. All fields except CattleID can be updated.
    Only provides values for fields you want to change.
    
    .PARAMETER CattleID
    Database ID of the cattle to update (required)
    
    .PARAMETER TagNumber
    New tag number for the animal (required)
    
    .PARAMETER OriginFarm
    Name of the origin farm (required)
    
    .PARAMETER OriginFarmID
    Database ID of the origin farm
    
    .PARAMETER Name
    Updated name for the animal
    
    .PARAMETER Breed
    Updated breed designation
    
    .PARAMETER Gender
    Updated gender. Valid values: 'Steer' or 'Heifer'
    
    .PARAMETER Location
    Updated location/pen assignment
    
    .PARAMETER Owner
    Updated owner or destination farm
    
    .PARAMETER PricePerDay
    Updated daily care cost rate
    
    .PARAMETER BirthDate
    Updated birth date
    
    .PARAMETER PurchaseDate
    Updated purchase date
    
    .PARAMETER Status
    Updated status. Valid values: 'Active', 'Sold', 'Deceased', 'Transferred'
    
    .PARAMETER Notes
    Updated notes or observations
    
    .EXAMPLE
    Update-CattleRecord -CattleID 5 -TagNumber "A042" -OriginFarm "Smith Ranch" -Location "Pen 3"
    
    Updates the location for cattle ID 5
    
    .EXAMPLE
    Update-CattleRecord -CattleID 12 -TagNumber "H015" -OriginFarm "Red River" -Status "Sold" -Notes "Sold to Johnson Feedlot on 12/10/2025"
    
    Marks cattle as sold and adds notes
    
    .NOTES
    The ModifiedDate field is automatically updated to the current timestamp.
    #>
    param(
        [Parameter(Mandatory)]
        [int]$CattleID,
        
        [Parameter(Mandatory)]
        [string]$TagNumber,
        
        [Parameter(Mandatory)]
        [string]$OriginFarm,
        
        [Parameter()]
        [int]$OriginFarmID,
        
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
        [String]
        $Owner,

        [Parameter()]
        [decimal]
        $PricePerDay,

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
    OriginFarmID = @OriginFarmID,
    Name = @Name,
    Breed = @Breed,
    Gender = @Gender,
    BirthDate = @BirthDate,
    PurchaseDate = @PurchaseDate,
    Location = @Location,
    Owner = @Owner,
    PricePerDay = @PricePerDay,
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
            OriginFarmID = $OriginFarmID
            Name = $Name
            Breed = $Breed
            Gender = $Gender
            BirthDate = $BirthDate
            PurchaseDate = $PurchaseDate
            Location = $Location
            Owner = $Owner
            PricePerDay = $PricePerDay
            Status = $Status
            Notes = $Notes
        }
    }
    
    Invoke-SqliteQuery @params
}
