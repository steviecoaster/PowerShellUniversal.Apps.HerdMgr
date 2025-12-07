function Add-CattleRecord {
    <#
    .SYNOPSIS
    Adds a new cattle record to the database
    #>
    param(
        [Parameter(Mandatory)]
        [string]$TagNumber,
        
        [Parameter(Mandatory)]
        [string]$OriginFarm,
        
        [string]$Name,
        [string]$Breed,
        [ValidateSet('Steer', 'Heifer')]
        [string]$Gender,
        [ValidateSet('Pen 1', 'Pen 2', 'Pen 3', 'Pen 4', 'Pen 5', 'Pen 6', 'Quarantine', 'Pasture')]
        [string]$Location,
        [DateTime]$BirthDate,
        [DateTime]$PurchaseDate,
        [string]$Notes
    )
    
    $query = @"
INSERT INTO Cattle (TagNumber, OriginFarm, Name, Breed, Gender, Location, BirthDate, PurchaseDate, Notes)
VALUES (@TagNumber, @OriginFarm, @Name, @Breed, @Gender, @Location, @BirthDate, @PurchaseDate, @Notes)
"@
    
    $params = @{
        DataSource = $script:DatabasePath
        Query = $query
        SqlParameters = @{
            TagNumber = $TagNumber
            OriginFarm = $OriginFarm
            Name = $Name
            Breed = $Breed
            Gender = $Gender
            Location = $Location
            BirthDate = $BirthDate
            PurchaseDate = $PurchaseDate
            Notes = $Notes
        }
    }
    
    Invoke-SqliteQuery @params
}