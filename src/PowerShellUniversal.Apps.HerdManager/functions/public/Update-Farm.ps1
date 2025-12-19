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
    
    if ($PSBoundParameters.ContainsKey('FarmName')) {
        $farmNameValue = ConvertTo-SqlValue -Value $FarmName
        $updates += "FarmName = $farmNameValue"
    }
    if ($PSBoundParameters.ContainsKey('Address')) {
        $addressValue = ConvertTo-SqlValue -Value $Address
        $updates += "Address = $addressValue"
    }
    if ($PSBoundParameters.ContainsKey('City')) {
        $cityValue = ConvertTo-SqlValue -Value $City
        $updates += "City = $cityValue"
    }
    if ($PSBoundParameters.ContainsKey('State')) {
        $stateValue = ConvertTo-SqlValue -Value $State
        $updates += "State = $stateValue"
    }
    if ($PSBoundParameters.ContainsKey('ZipCode')) {
        $zipValue = ConvertTo-SqlValue -Value $ZipCode
        $updates += "ZipCode = $zipValue"
    }
    if ($PSBoundParameters.ContainsKey('PhoneNumber')) {
        $phoneValue = ConvertTo-SqlValue -Value $PhoneNumber
        $updates += "PhoneNumber = $phoneValue"
    }
    if ($PSBoundParameters.ContainsKey('Email')) {
        $emailValue = ConvertTo-SqlValue -Value $Email
        $updates += "Email = $emailValue"
    }
    if ($PSBoundParameters.ContainsKey('ContactPerson')) {
        $contactValue = ConvertTo-SqlValue -Value $ContactPerson
        $updates += "ContactPerson = $contactValue"
    }
    if ($PSBoundParameters.ContainsKey('Notes')) {
        $notesValue = ConvertTo-SqlValue -Value $Notes
        $updates += "Notes = $notesValue"
    }
    if ($PSBoundParameters.ContainsKey('IsOrigin')) {
        $updates += "IsOrigin = $IsOrigin"
    }
    if ($PSBoundParameters.ContainsKey('IsActive')) {
        $updates += "IsActive = $IsActive"
    }
    
    if ($updates.Count -eq 0) {
        Write-Warning "No fields to update"
        return
    }
    
    $updates += "ModifiedDate = CURRENT_TIMESTAMP"
    
    $query = "UPDATE Farms SET $($updates -join ', ') WHERE FarmID = $FarmID"
    
    Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $query
}






