function Get-Farm {
    <#
    .SYNOPSIS
    Retrieves farm records
    
    .DESCRIPTION
    Gets farm information using multiple filter options. Supports querying by ID, name,
    all farms, active farms only, or origin farms only. Origin farms are those marked
    as sources where cattle are purchased from.
    
    .PARAMETER FarmID
    Get a specific farm by its database ID
    
    .PARAMETER FarmName
    Get a specific farm by its name (exact match)
    
    .PARAMETER All
    Return all farms regardless of status or type
    
    .PARAMETER ActiveOnly
    Return only active farms (IsActive=1). Includes both origin and owner farms.
    
    .PARAMETER OriginOnly
    Return only origin farms (IsOrigin=1) that are also active.
    Used to populate the Origin Farm dropdown when adding cattle.
    
    .OUTPUTS
    Farm record(s) with properties:
    FarmID, FarmName, Address, City, State, ZipCode, PhoneNumber, Email,
    ContactPerson, Notes, IsOrigin, IsActive
    
    .EXAMPLE
    Get-Farm -FarmID 3
    
    Returns farm with ID 3
    
    .EXAMPLE
    Get-Farm -OriginOnly
    
    Returns all active origin farms (for cattle purchase sources)
    
    .EXAMPLE
    Get-Farm -ActiveOnly | Where-Object { $_.State -eq 'OK' }
    
    Returns all active farms in Oklahoma
    
    .EXAMPLE
    Get-Farm -FarmName "Smith Family Farms"
    
    Returns the farm with exact name match
    
    .NOTES
    The OriginOnly parameter is specifically used by the cattle management UI to filter
    farms in the Origin Farm dropdown to only show purchase sources.
    #>
    [CmdletBinding()]
    param(
        [Parameter(ParameterSetName = 'ById')]
        [int]
        $FarmID,
        
        [Parameter(ParameterSetName = 'ByName')]
        [string]
        $FarmName,
        
        [Parameter(ParameterSetName = 'All')]
        [switch]
        $All,
        
        [Parameter(ParameterSetName = 'Active')]
        [switch]
        $ActiveOnly,
        
        [Parameter(ParameterSetName = 'Origins')]
        [switch]
        $OriginOnly
    )
    
    switch ($PSCmdlet.ParameterSetName) {
        'ById' {
            $query = "SELECT * FROM Farms WHERE FarmID = $FarmID"
            $result = Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $query 
        }
        'ByName' {
            $farmNameValue = ConvertTo-SqlValue -Value $FarmName
            $query = "SELECT * FROM Farms WHERE FarmName = $farmNameValue"
            $result = Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $query 
        }
        'All' {
            $query = "SELECT * FROM Farms ORDER BY FarmName"
            $result = Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $query
        }

        'Active' {
            $query = "SELECT * FROM Farms WHERE IsActive = 1 ORDER BY FarmName"
            $result = Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $query
        }
        
        'Origins' {
            $query = "SELECT * FROM Farms WHERE IsActive = 1 AND IsOrigin = 1 ORDER BY FarmName"
            $result = Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $query
        }
    }

    return $result
}






