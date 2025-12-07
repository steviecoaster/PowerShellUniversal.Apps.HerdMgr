function Get-AllCattle {
    <#
    .SYNOPSIS
    Retrieves all cattle records
    #>
    param(
        [ValidateSet('Active', 'Sold', 'Deceased', 'Transferred')]
        [string]$Status = 'Active'
    )
    
    $query = "SELECT * FROM CattleWithLatestWeight WHERE Status = @Status ORDER BY TagNumber"
    
    Invoke-SqliteQuery -DataSource $script:DatabasePath -Query $query -SqlParameters @{Status = $Status} -As PSObject
}