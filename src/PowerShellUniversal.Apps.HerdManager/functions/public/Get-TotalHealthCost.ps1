function Get-TotalHealthCost {
    <#
    .SYNOPSIS
    Calculates the total health cost for a specific cattle
    
    .DESCRIPTION
    Sums all health record costs for a given cattle ID where cost is greater than zero.
    Returns 0 if no health costs exist.
    
    .PARAMETER CattleID
    The ID of the cattle to calculate health costs for
    
    .EXAMPLE
    Get-TotalHealthCost -CattleID 1
    
    Returns the total health costs for cattle ID 1
    
    .OUTPUTS
    Decimal value representing total health costs
    #>
    param(
        [Parameter(Mandatory)]
        [int]$CattleID
    )
    
    $query = "SELECT COALESCE(SUM(Cost), 0) AS TotalHealthCost FROM HealthRecords WHERE CattleID = $CattleID AND Cost > 0"
    
    $result = Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $query
    
    return [decimal]$result.TotalHealthCost
}
