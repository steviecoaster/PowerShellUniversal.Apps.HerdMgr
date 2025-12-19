function Invoke-FarmApi {
    [CmdletBinding()]
    Param(
        [Parameter()]
        [String]
        $farmname
    )

    end {
        switch ($Method) {
            'GET' {
                if ($farmname) {
                    $decodedName = [uri]::UnescapeDataString($farmname)
                    
                    $result = Get-Farm -FarmName $decodedName
                    
                    if (-not $result) {
                        return New-PSUApiResponse -StatusCode 404 -Body (@{
                            error = "Farm '$farmname' not found"
                            receivedParameter = $farmname
                        } | ConvertTo-Json)
                    }
                    
                    return $result
                }
                else {
                    Get-Farm -All
                }
            }
            'POST' {
                $AvailableKeys = @(
                    'FarmName',
                    'Address',
                    'City',
                    'State',
                    'ZipCode',
                    'PhoneNumber',
                    'Email',
                    'ContactPerson',
                    'Notes'
                )

                $payload = $Body | ConvertFrom-Json -AsHashtable
                $payload.GetEnumerator() | Foreach-Object {
                    if ($_.key -notin $AvailableKeys) {
                        throw "$($_.Key) is not a valid parameter. Valid parameters: $AvailableKeys"
                    }

                    Add-CattleRecord @payload
                }


            }
        }
    }
}





