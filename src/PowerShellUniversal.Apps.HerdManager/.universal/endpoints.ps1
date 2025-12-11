$getEndpoint = @{
    Url = '/herdapi'
    Method = 'GET'
    Module = 'PowerShellUniversal.Apps.HerdManager'
    Command = 'Invoke-HerdApi'
}

New-PSUEndpoint @getEndpoint

$postEndpoint = @{
    Url = '/herdapi'
    Method = 'POST'
    Module = 'PowerShellUniversal.Apps.HerdManager'
    Command = 'Invoke-HerdApi'
}

New-PSUEndpoint @postEndpoint