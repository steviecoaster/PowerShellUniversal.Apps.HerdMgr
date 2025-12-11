function Invoke-HerdApi {
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
        'POST' {}
        default {
           New-PSUApiResponse -StatusCode 405 -Body (@{Error = 'Method not allowed'} | ConvertTo-Json)
        }
    }
}