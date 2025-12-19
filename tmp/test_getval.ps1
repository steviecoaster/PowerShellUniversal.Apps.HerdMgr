$Body = @{ Context = @{ 'setup-farmname' = 'MyFarm'; 'setup-contact' = 'Bob' ; 'setup-defaultCurrency' = @{ value = 'USD' }; 'setup-established' = @{ value = '2001-01-01' } } }
$ctx = $Body.Context
$getVal = {
    param($k)
    if (-not $ctx) { return $null }
    $v = $null

    if ($ctx -is [System.Collections.IDictionary]) {
        if ($ctx.Contains($k)) { $v = $ctx[$k] }
    }
    else {
        try { $v = $ctx.$k } catch { $v = $null }
        if ($null -eq $v) {
            $p = $ctx.PSObject.Properties.Match($k)
            if ($p) { $v = $p.Value }
        }
    }

    if ($v -and ($v -is [psobject]) -and ($v.PSObject.Properties.Name -contains 'value')) { return $v.value }
    return $v
}

Write-Output (& $getVal 'setup-farmname')
Write-Output (& $getVal 'setup-contact')
Write-Output (& $getVal 'setup-defaultCurrency')
Write-Output (& $getVal 'setup-established')
