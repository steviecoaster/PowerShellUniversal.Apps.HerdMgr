function Add-Farm {
    <#
    .SYNOPSIS
    Creates a new farm record
    
    .DESCRIPTION
    Adds a farm or ranch to the database with complete contact information.
    Farms can be designated as origin farms (where cattle are purchased from) 
    or owner farms (customers/destinations).
    
    .PARAMETER FarmName
    Name of the farm or ranch (required)
    
    .PARAMETER Address
    Street address of the farm
    
    .PARAMETER City
    City where the farm is located
    
    .PARAMETER State
    State where the farm is located
    
    .PARAMETER ZipCode
    Postal/ZIP code for the farm
    
    .PARAMETER PhoneNumber
    Contact phone number for the farm
    
    .PARAMETER Email
    Contact email address for the farm
    
    .PARAMETER ContactPerson
    Primary contact person's name at the farm
    
    .PARAMETER Notes
    Additional notes or information about the farm
    
    .PARAMETER IsOrigin
    Switch to mark this farm as an origin farm (where cattle are purchased from).
    Origin farms appear in the Origin Farm dropdown when adding cattle.
    If not specified, the farm is treated as an owner/customer farm.
    
    .EXAMPLE
    Add-Farm -FarmName "Whispering Pines Ranch" -IsOrigin
    
    Creates a basic origin farm record
    
    .EXAMPLE
    Add-Farm -FarmName "Johnson Feedlot" -Address "789 Ranch Road" -City "Oklahoma City" -State "OK" -ZipCode "73102" -PhoneNumber "405-555-2002" -Email "johnson@example.com" -ContactPerson "Lisa Johnson" -Notes "Large-scale operation"
    
    Creates a complete owner farm record with full contact information
    
    .NOTES
    All farms are created with IsActive=1 by default. Use Update-Farm to deactivate a farm.
    #>
    param(
        [Parameter(Mandatory)]
        [string]$FarmName,
        
        [string]$Address,
        [string]$City,
        [string]$State,
        [string]$ZipCode,
        [string]$PhoneNumber,
        [string]$Email,
        [string]$ContactPerson,
        [string]$Notes,
        [switch]$IsOrigin
    )
    
    # Convert values
    $farmNameValue = ConvertTo-SqlValue -Value $FarmName
    $addressValue = ConvertTo-SqlValue -Value $Address
    $cityValue = ConvertTo-SqlValue -Value $City
    $stateValue = ConvertTo-SqlValue -Value $State
    $zipValue = ConvertTo-SqlValue -Value $ZipCode
    $phoneValue = ConvertTo-SqlValue -Value $PhoneNumber
    $emailValue = ConvertTo-SqlValue -Value $Email
    $contactValue = ConvertTo-SqlValue -Value $ContactPerson
    $notesValue = ConvertTo-SqlValue -Value $Notes
    $isOriginValue = ConvertTo-SqlValue -Value $IsOrigin.IsPresent

    $query = "INSERT INTO Farms (FarmName, Address, City, State, ZipCode, PhoneNumber, Email, ContactPerson, Notes, IsOrigin, IsActive) VALUES ($farmNameValue, $addressValue, $cityValue, $stateValue, $zipValue, $phoneValue, $emailValue, $contactValue, $notesValue, $isOriginValue, 1)"

    try {
        Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $query -ErrorAction Stop
        Write-Verbose "Created farm: $FarmName"
    }
    catch {
      $_.Exception.Message
    }
}






