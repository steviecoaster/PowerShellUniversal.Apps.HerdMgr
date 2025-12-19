function Invoke-CattleApi {
    [CmdletBinding()]
    Param(
        [Parameter()]
        [String]
        $Tag
    )

    switch ($Method) {
        'GET' {
            if ($tag) {
                Get-AllCattle | Where-Object Tagnumber -eq $tag
            }
            else {
                Get-AllCattle
            }
        }
        'POST' {
            $commandArgs = $Body | ConvertFrom-Json -AsHashtable
    
            if (-not $commandArgs['TagNumber'] -and $commandArgs['OriginFarm'] -and $commandArgs['PurchaseDate']) {
                throw 'Both TagNumber and OriginFarm are required when adding an animal'
            }

            Add-CattleRecord @commandArgs
        }
        default {
            New-PSUApiResponse -StatusCode 405 -Body (@{Error = 'Method not allowed' } | ConvertTo-Json)
        }
    }
}





