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
        [Nullable[DateTime]]
        $BirthDate,
        
        [Parameter()]
        [Nullable[DateTime]]
        $PurchaseDate,
        
        [Parameter()]
        [ValidateSet('Active', 'Sold', 'Deceased', 'Transferred')]
        [string]
        $Status = 'Active',
        
        [Parameter()]
        [string]
        $Notes
    )
    
    # Build UPDATE query dynamically - only update provided fields
    $updates = @()
    $updates += "TagNumber = $(ConvertTo-SqlValue -Value $TagNumber)"
    $updates += "OriginFarm = $(ConvertTo-SqlValue -Value $OriginFarm)"
    
    if ($PSBoundParameters.ContainsKey('OriginFarmID')) {
        $updates += "OriginFarmID = $OriginFarmID"
    }
    if ($PSBoundParameters.ContainsKey('Name')) {
        $updates += "Name = $(ConvertTo-SqlValue -Value $Name)"
    }
    if ($PSBoundParameters.ContainsKey('Breed')) {
        $updates += "Breed = $(ConvertTo-SqlValue -Value $Breed)"
    }
    if ($PSBoundParameters.ContainsKey('Gender')) {
        $updates += "Gender = $(ConvertTo-SqlValue -Value $Gender)"
    }
    if ($PSBoundParameters.ContainsKey('BirthDate')) {
        $updates += "BirthDate = $(ConvertTo-SqlValue -Value $BirthDate)"
    }
    if ($PSBoundParameters.ContainsKey('PurchaseDate')) {
        $updates += "PurchaseDate = $(ConvertTo-SqlValue -Value $PurchaseDate)"
    }
    if ($PSBoundParameters.ContainsKey('Location')) {
        $updates += "Location = $(ConvertTo-SqlValue -Value $Location)"
    }
    if ($PSBoundParameters.ContainsKey('Owner')) {
        $updates += "Owner = $(ConvertTo-SqlValue -Value $Owner)"
    }
    if ($PSBoundParameters.ContainsKey('PricePerDay')) {
        $updates += "PricePerDay = $PricePerDay"
    }
    if ($PSBoundParameters.ContainsKey('Status')) {
        $updates += "Status = $(ConvertTo-SqlValue -Value $Status)"
    }
    if ($PSBoundParameters.ContainsKey('Notes')) {
        $updates += "Notes = $(ConvertTo-SqlValue -Value $Notes)"
    }
    
    $updates += "ModifiedDate = CURRENT_TIMESTAMP"
    
    $setClause = $updates -join ', '
    $query = "UPDATE Cattle SET $setClause WHERE CattleID = $CattleID"
    
    Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $query
}






