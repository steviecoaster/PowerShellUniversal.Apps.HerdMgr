# ========================================
# CATTLE ENDPOINTS
# ========================================

# GET/POST cattle
$newPSUEndpointSplat = @{
    Url = '/herdapi/cattle'
    Method = @('GET', 'POST')
    Module = 'PowerShellUniversal.Apps.HerdManager'
    Command = 'Invoke-CattleApi'
}

New-PSUEndpoint @newPSUEndpointSplat

# GET specific cattle by tag
$newPSUEndpointSplat = @{
    Url = '/herdapi/cattle/:tag'
    Method = 'GET'
    Module = 'PowerShellUniversal.Apps.HerdManager'
    Command = 'Invoke-CattleApi'
}

New-PSUEndpoint @newPSUEndpointSplat

# ========================================
# WEIGHT ENDPOINTS  
# ========================================

$newPSUEndpointSplat = @{
    Url = '/herdapi/weights'
    Method = @('GET', 'POST')
    Module = 'PowerShellUniversal.Apps.HerdManager'
    Command = 'Invoke-WeightApi'
}

New-PSUEndpoint @newPSUEndpointSplat

$newPSUEndpointSplat = @{
    Url = '/herdapi/cattle/:tag/weights'
    Method = 'GET'
    Module = 'PowerShellUniversal.Apps.HerdManager'
    Command = 'Invoke-WeightApi'
}

New-PSUEndpoint @newPSUEndpointSplat

# ========================================
# FEED ENDPOINTS
# ========================================

$newPSUEndpointSplat = @{
    Url = '/herdapi/feed'
    Method = @('GET', 'POST')
    Module = 'PowerShellUniversal.Apps.HerdManager'
    Command = 'Invoke-FeedApi'
}

New-PSUEndpoint @newPSUEndpointSplat

$newPSUEndpointSplat = @{
    Url = '/herdapi/feed/:id'
    Method = @('GET', 'PUT', 'DELETE')
    Module = 'PowerShellUniversal.Apps.HerdManager'
    Command = 'Invoke-FeedApi'
}

New-PSUEndpoint @newPSUEndpointSplat

# ========================================
# FARM ENDPOINTS
# ========================================

$newPSUEndpointSplat = @{
    Url = '/herdapi/farms'
    Method = 'GET'
    Module = 'PowerShellUniversal.Apps.HerdManager'
    Command = 'Invoke-FarmApi'
}

New-PSUEndpoint @newPSUEndpointSplat

$newPSUEndpointSplat = @{
    Url = '/herdapi/farms/:farmname'
    Method = 'GET'
    Module = 'PowerShellUniversal.Apps.HerdManager'
    Command = 'Invoke-FarmApi'
}

New-PSUEndpoint @newPSUEndpointSplat

# ========================================
# RATE OF GAIN ENDPOINTS
# ========================================

$newPSUEndpointSplat = @{
    Url = '/herdapi/cattle/:tag/rog'
    Method = 'GET'
    Module = 'PowerShellUniversal.Apps.HerdManager'
    Command = 'Invoke-RateOfGainApi'
}

New-PSUEndpoint @newPSUEndpointSplat



