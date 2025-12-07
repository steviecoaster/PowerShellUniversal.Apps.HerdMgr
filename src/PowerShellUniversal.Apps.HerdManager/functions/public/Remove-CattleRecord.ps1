function Remove-CattleRecord {
    <#
    .SYNOPSIS
    Removes a cattle record from the database
    .DESCRIPTION
    Permanently deletes a cattle record and all associated weight records and calculations
    #>
    param(
        [Parameter(Mandatory)]
        [int]$CattleID
    )
    
    $query = @"
DELETE FROM Cattle
WHERE CattleID = @CattleID
"@
    
    $params = @{
        DataSource = $script:DatabasePath
        Query = $query
        SqlParameters = @{
            CattleID = $CattleID
        }
    }
    
    Invoke-SqliteQuery @params
}
