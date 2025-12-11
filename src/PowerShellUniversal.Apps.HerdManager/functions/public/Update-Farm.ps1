function Update-Farm {
    <#
    .SYNOPSIS
    Updates an existing farm record
    
    .DESCRIPTION
    Modifies farm information in the database. Uses dynamic SQL to only update
    fields that are provided, leaving others unchanged.
    
    .PARAMETER FarmID
    Database ID of the farm to update (required)
    
    .PARAMETER FarmName
    Updated farm name
    
    .PARAMETER Address
    Updated street address
    
    .PARAMETER City
    Updated city
    
    .PARAMETER State
    Updated state
    
    .PARAMETER ZipCode
    Updated ZIP/postal code
    
    .PARAMETER PhoneNumber
    Updated phone number
    
    .PARAMETER Email
    Updated email address
    
    .PARAMETER ContactPerson
    Updated contact person name
    
    .PARAMETER Notes
    Updated notes
    
    .PARAMETER IsOrigin
    Updated origin farm flag. Set to 1 to mark as origin farm, 0 for owner/customer farm
    
    .PARAMETER IsActive
    Updated active status. Set to 1 for active, 0 to deactivate
    
    .EXAMPLE
    Update-Farm -FarmID 3 -PhoneNumber "405-555-9999" -Email "newemail@example.com"
    
    Updates contact information for farm ID 3
    
    .EXAMPLE
    Update-Farm -FarmID 5 -IsActive 0
    
    Deactivates farm ID 5 (removes from active lists)
    
    .EXAMPLE
    Update-Farm -FarmID 7 -IsOrigin 1 -Notes "Now purchasing cattle from this farm"
    
    Marks farm as an origin farm
    
    .NOTES
    Only provide parameters for fields you want to update. Unprovided fields remain unchanged.
    #>
    param(
        [Parameter(Mandatory)]
        [int]$FarmID,
        
        [string]$FarmName,
        [string]$Address,
        [string]$City,
        [string]$State,
        [string]$ZipCode,
        [string]$PhoneNumber,
        [string]$Email,
        [string]$ContactPerson,
        [string]$Notes,
        [int]$IsOrigin,
        [int]$IsActive
    )
    
    $updates = @()
    $params = @{ FarmID = $FarmID }
    
    if ($PSBoundParameters.ContainsKey('FarmName')) {
        $updates += "FarmName = @FarmName"
        $params['FarmName'] = $FarmName
    }
    if ($PSBoundParameters.ContainsKey('Address')) {
        $updates += "Address = @Address"
        $params['Address'] = $Address
    }
    if ($PSBoundParameters.ContainsKey('City')) {
        $updates += "City = @City"
        $params['City'] = $City
    }
    if ($PSBoundParameters.ContainsKey('State')) {
        $updates += "State = @State"
        $params['State'] = $State
    }
    if ($PSBoundParameters.ContainsKey('ZipCode')) {
        $updates += "ZipCode = @ZipCode"
        $params['ZipCode'] = $ZipCode
    }
    if ($PSBoundParameters.ContainsKey('PhoneNumber')) {
        $updates += "PhoneNumber = @PhoneNumber"
        $params['PhoneNumber'] = $PhoneNumber
    }
    if ($PSBoundParameters.ContainsKey('Email')) {
        $updates += "Email = @Email"
        $params['Email'] = $Email
    }
    if ($PSBoundParameters.ContainsKey('ContactPerson')) {
        $updates += "ContactPerson = @ContactPerson"
        $params['ContactPerson'] = $ContactPerson
    }
    if ($PSBoundParameters.ContainsKey('Notes')) {
        $updates += "Notes = @Notes"
        $params['Notes'] = $Notes
    }
    if ($PSBoundParameters.ContainsKey('IsOrigin')) {
        $updates += "IsOrigin = @IsOrigin"
        $params['IsOrigin'] = $IsOrigin
    }
    if ($PSBoundParameters.ContainsKey('IsActive')) {
        $updates += "IsActive = @IsActive"
        $params['IsActive'] = $IsActive
    }
    
    if ($updates.Count -eq 0) {
        Write-Warning "No fields to update"
        return
    }
    
    $updates += "ModifiedDate = CURRENT_TIMESTAMP"
    
    $query = "UPDATE Farms SET $($updates -join ', ') WHERE FarmID = @FarmID"
    
    Invoke-SqliteQuery -DataSource $script:DatabasePath -Query $query -SqlParameters $params
}
