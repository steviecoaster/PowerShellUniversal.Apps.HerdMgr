function Add-CattleRecord {
    <#
    .SYNOPSIS
    Adds a new cattle record to the database
    
    .DESCRIPTION
    Creates a new cattle record in the herd management database with comprehensive tracking information.
    Supports linking to origin farms and owner farms for complete traceability.
    
    .PARAMETER TagNumber
    Unique identifier tag for the animal (required)
    
    .PARAMETER OriginFarm
    Name of the farm where the animal was purchased or originated (required)
    
    .PARAMETER OriginFarmID
    Database ID of the origin farm (links to Farms table)
    
    .PARAMETER Name
    Optional name for the animal
    
    .PARAMETER Breed
    Breed of the animal (e.g., Angus, Hereford)
    
    .PARAMETER Gender
    Gender of the animal. Must be either 'Steer' or 'Heifer'
    
    .PARAMETER Location
    Current location/pen assignment. Valid values: Pen 1-6, Quarantine, or Pasture
    
    .PARAMETER Owner
    Name of the owner or destination farm
    
    .PARAMETER PricePerDay
    Daily feeding/care cost rate for this animal
    
    .PARAMETER BirthDate
    Date the animal was born
    
    .PARAMETER PurchaseDate
    Date the animal was purchased or acquired
    
    .PARAMETER Notes
    Additional notes or observations about the animal
    
    .EXAMPLE
    Add-CattleRecord -TagNumber "A001" -OriginFarm "Smith Ranch" -Gender "Steer" -Breed "Angus"
    
    Creates a basic cattle record with required fields
    
    .EXAMPLE
    Add-CattleRecord -TagNumber "H042" -OriginFarm "Red River Cattle Co" -OriginFarmID 3 -Name "Duke" -Breed "Hereford" -Gender "Steer" -Owner "Johnson Feedlot" -BirthDate "2024-03-15" -PurchaseDate "2024-09-01" -Location "Pen 2" -Notes "Fast grower"
    
    Creates a complete cattle record with all tracking information
    
    .NOTES
    The function uses dynamic SQL generation to only insert fields that were provided,
    avoiding NULL value constraint issues with CHECK constraints in the database.
    #>
    param(
        [Parameter(Mandatory)]
        [string]$TagNumber,
        
        [Parameter(Mandatory)]
        [string]$OriginFarm,
        
        [int]$OriginFarmID,
        
        [string]$Name,
        [string]$Breed,
        [ValidateSet('Steer', 'Heifer')]
        [string]$Gender,
        [ValidateSet('Pen 1', 'Pen 2', 'Pen 3', 'Pen 4', 'Pen 5', 'Pen 6', 'Quarantine', 'Pasture')]
        [string]$Location,
        [string]$Owner,
        [decimal]$PricePerDay,
        [DateTime]$BirthDate,
        [DateTime]$PurchaseDate,
        [string]$Notes
    )
    
    # Build dynamic INSERT based on provided parameters
    $columns = @('TagNumber', 'OriginFarm')
    $values = @('@TagNumber', '@OriginFarm')
    $sqlParams = @{
        TagNumber = $TagNumber
        OriginFarm = $OriginFarm
    }
    
    if ($PSBoundParameters.ContainsKey('OriginFarmID')) {
        $columns += 'OriginFarmID'
        $values += '@OriginFarmID'
        $sqlParams['OriginFarmID'] = $OriginFarmID
    }
    if ($PSBoundParameters.ContainsKey('Name')) {
        $columns += 'Name'
        $values += '@Name'
        $sqlParams['Name'] = $Name
    }
    if ($PSBoundParameters.ContainsKey('Breed')) {
        $columns += 'Breed'
        $values += '@Breed'
        $sqlParams['Breed'] = $Breed
    }
    if ($PSBoundParameters.ContainsKey('Gender')) {
        $columns += 'Gender'
        $values += '@Gender'
        $sqlParams['Gender'] = $Gender
    }
    if ($PSBoundParameters.ContainsKey('Location')) {
        $columns += 'Location'
        $values += '@Location'
        $sqlParams['Location'] = $Location
    }
    if ($PSBoundParameters.ContainsKey('Owner')) {
        $columns += 'Owner'
        $values += '@Owner'
        $sqlParams['Owner'] = $Owner
    }
    if ($PSBoundParameters.ContainsKey('PricePerDay')) {
        $columns += 'PricePerDay'
        $values += '@PricePerDay'
        $sqlParams['PricePerDay'] = $PricePerDay
    }
    if ($PSBoundParameters.ContainsKey('BirthDate')) {
        $columns += 'BirthDate'
        $values += '@BirthDate'
        $sqlParams['BirthDate'] = $BirthDate
    }
    if ($PSBoundParameters.ContainsKey('PurchaseDate')) {
        $columns += 'PurchaseDate'
        $values += '@PurchaseDate'
        $sqlParams['PurchaseDate'] = $PurchaseDate
    }
    if ($PSBoundParameters.ContainsKey('Notes')) {
        $columns += 'Notes'
        $values += '@Notes'
        $sqlParams['Notes'] = $Notes
    }
    
    $columnList = $columns -join ', '
    $valueList = $values -join ', '
    
    $query = "INSERT INTO Cattle ($columnList) VALUES ($valueList)"
    
    $params = @{
        DataSource = $script:DatabasePath
        Query = $query
        SqlParameters = $sqlParams
    }
    
    Invoke-SqliteQuery @params
}