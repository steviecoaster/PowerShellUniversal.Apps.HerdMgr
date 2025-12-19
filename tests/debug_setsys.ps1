Import-Module .\src\PowerShellUniversal.Apps.HerdManager\PowerShellUniversal.Apps.HerdManager.psm1 -Force

$db = Join-Path $env:TEMP 'gr_sysinfo_debug.db' ; if (Test-Path $db) { Remove-Item $db -Force }
Initialize-HerdDatabase -DatabasePath $db

# Simulate PSBoundParameters
$PSBoundParameters = @{
  'DefaultCurrency' = 'GBP'
  'Established' = '2001'
  'FarmName' = 'Test Farm'
  'PhoneNumber' = '111-1111'
  'Notes' = 'initial'
}

$DefaultCurrency='GBP'
$DefaultCulture=$null
$inferredDefaultCulture='en-GB'

$currencyValToConvert = if ($PSBoundParameters.ContainsKey('DefaultCurrency') ) { $DefaultCurrency } else { 'USD' }
$currencyValue = ConvertTo-SqlValue -Value $currencyValToConvert

if ($PSBoundParameters.ContainsKey('DefaultCulture')) { $cultureToUse = $DefaultCulture }
elseif ($inferredDefaultCulture) { $cultureToUse = $inferredDefaultCulture } else { $cultureToUse = 'en-US' }
$cultureValue = ConvertTo-SqlValue -Value $cultureToUse
$Established = '2001'
$establishedValue = 'NULL'
if ($PSBoundParameters.ContainsKey('Established') -and ($null -ne $Established) -and ($Established -ne '')) {
  try {
    $val = if ($Established -is [System.Array]) { $Established[0] } else { $Established }
    if ($val -is [int]) { $estDt = [DateTime]::new([int]$val, 1, 1) }
    elseif ($val -is [DateTime]) { $estDt = $val }
    else {
      $s = $val.ToString().Trim()
      if ($s -match '^[0-9]{4}$') { $estDt = [DateTime]::new([int]$s, 1, 1) } else { $estDt = Parse-Date $s }
    }
    $establishedValue = ConvertTo-SqlValue -Value $estDt
  }
  catch {
    $establishedValue = 'NULL'
  }
}

Write-Host ("currency: {0}, culture: {1}, established: {2}" -f $currencyValue, $cultureValue, $establishedValue)
