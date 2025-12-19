function Set-SystemInfo {
    <#
    .SYNOPSIS
    Creates or updates the single SystemInfo row.

    .DESCRIPTION
    Inserts a SystemInfo row if none exists, or updates the existing row with provided fields.
    Only parameters supplied will be updated; unspecified fields will be left unchanged on update.

    .PARAMETER SystemID
    Optional ID to target a specific row for update.

    .PARAMETER FarmName, Address, City, State, ZipCode, PhoneNumber, Email, ContactPerson, Notes
    System fields to set.

    .PARAMETER DefaultCurrency
    Currency code used by Format-Currency by default (e.g. 'USD').

    .PARAMETER DefaultCulture
    Culture used for currency formatting (e.g. 'en-US').
    
    .PARAMETER Established
    A year (e.g. 2000), a date string (e.g. '2000-01-01'), or a [DateTime]. If a year is provided it will be stored
    as January 1st of that year. Empty/omitted values will not modify the existing field.
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [int]
        $SystemID,

        [Parameter()]
        [string]
        $FarmName,

        [Parameter()]
        [string]
        $Address,

        [Parameter()]
        [string]
        $City,

        [Parameter()]
        [string]
        $State,

        [Parameter()]
        [string]
        $ZipCode,

        [Parameter()]
        [string]
        $PhoneNumber,

        [Parameter()]
        [string]
        $Email,

        [Parameter()]
        [string]
        $ContactPerson,

        [Parameter()]
        [string]
        $Notes,

        [Parameter()]
        [object]
        $Established,

        [Parameter()]
        [string]
        $DefaultCurrency = 'USD',

        [Parameter()]
        [string]
        $DefaultCulture = 'en-US',

        [Parameter()]
        [string]
        $DatabasePath = $script:DatabasePath

    )

    # Currency -> culture mapping; if user supplied only DefaultCurrency infer a DefaultCulture
    $map = @{
        'USD' = 'en-US'
        'GBP' = 'en-GB'
        'EUR' = 'fr-FR'
        'CAD' = 'en-CA'
        'AUD' = 'en-AU'
    }
    $inferredDefaultCulture = $null
    if ($PSBoundParameters.ContainsKey('DefaultCurrency') -and -not $PSBoundParameters.ContainsKey('DefaultCulture')) {
        if ($map.ContainsKey($DefaultCurrency)) { $inferredDefaultCulture = $map[$DefaultCurrency] }
    }

    # Check if a SystemInfo row exists (extract scalar count reliably)
    $countRow = Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query "SELECT COUNT(*) AS cnt FROM SystemInfo;"
    if ($countRow -and $countRow.Count -gt 0) { $count = [int]$countRow[0].cnt } else { $count = 0 }

    if ($count -eq 0) {
        # Insert a new row; use provided parameters when present, otherwise NULL or defaults
        $farmNameValue = ConvertTo-SqlValue -Value $FarmName
        $addressValue = ConvertTo-SqlValue -Value $Address
        $cityValue = ConvertTo-SqlValue -Value $City
        $stateValue = ConvertTo-SqlValue -Value $State
        $zipValue = ConvertTo-SqlValue -Value $ZipCode
        $phoneValue = ConvertTo-SqlValue -Value $PhoneNumber
        $emailValue = ConvertTo-SqlValue -Value $Email
        $contactValue = ConvertTo-SqlValue -Value $ContactPerson
        $notesValue = ConvertTo-SqlValue -Value $Notes
    if ($PSBoundParameters.ContainsKey('DefaultCurrency')) { $currencyValToConvert = $DefaultCurrency } else { $currencyValToConvert = 'USD' }
    $currencyValue = ConvertTo-SqlValue -Value $currencyValToConvert

    if ($PSBoundParameters.ContainsKey('DefaultCulture')) { $cultureToUse = $DefaultCulture }
    elseif ($inferredDefaultCulture) { $cultureToUse = $inferredDefaultCulture } else { $cultureToUse = 'en-US' }
    $cultureValue = ConvertTo-SqlValue -Value $cultureToUse
        # Normalize Established for insert: accept year (int or 4-digit string) or date and convert to DateTime (Jan 1)
        $establishedValue = 'NULL'
        if ($PSBoundParameters.ContainsKey('Established') -and ($null -ne $Established) -and ($Established -ne '')) {
            try {
                if ($Established -is [System.Array]) { $val = $Established[0] } else { $val = $Established }
                if ($val -is [int]) { $estDt = [DateTime]::new([int]$val, 1, 1) }
                elseif ($val -is [DateTime]) { $estDt = $val }
                else {
                    $s = $val.ToString().Trim()
                    if ($s -match '^[0-9]{4}$') { $estDt = [DateTime]::new([int]$s, 1, 1) } else { $estDt = Parse-Date $s }
                }
                $establishedValue = ConvertTo-SqlValue -Value $estDt
            }
            catch { $establishedValue = 'NULL' }
        }

    # Build column/value lists aligned with the current table schema (SystemInfo may or may not have Established)
    $cols = @('FarmName','Address','City','State','ZipCode','PhoneNumber','Email','ContactPerson')
    $vals = @($farmNameValue,$addressValue,$cityValue,$stateValue,$zipValue,$phoneValue,$emailValue,$contactValue)

    $pragma = Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query "PRAGMA table_info('SystemInfo');"
    $hasEstablished = $false
    if ($pragma -and $pragma.Count -gt 0) { if ($pragma | Where-Object { $_.name -eq 'Established' }) { $hasEstablished = $true } }
    if ($hasEstablished) { $cols += 'Established'; $vals += $establishedValue }

    $cols += 'Notes'; $vals += $notesValue
    $cols += 'DefaultCurrency'; $vals += $currencyValue
    $cols += 'DefaultCulture'; $vals += $cultureValue
    $cols += 'CreatedDate'; $vals += 'CURRENT_TIMESTAMP'
    $cols += 'ModifiedDate'; $vals += 'CURRENT_TIMESTAMP'

    $insertQuery = "INSERT INTO SystemInfo (" + ($cols -join ', ') + ") VALUES (" + ($vals -join ', ') + ")"
        Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query $insertQuery

        # Post-insert: if multiple rows exist (race or previous bad state), collapse to the most recently modified row
        try {
            $countRowAfter = Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query "SELECT COUNT(*) AS cnt FROM SystemInfo;"
            $countAfter = if ($countRowAfter -and $countRowAfter.Count -gt 0) { [int]$countRowAfter[0].cnt } else { 0 }
            if ($countAfter -gt 1) {
                $keepRow = Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query "SELECT SystemID FROM SystemInfo ORDER BY ModifiedDate DESC LIMIT 1;"
                if ($keepRow -and $keepRow.Count -gt 0) {
                    $keepId = $keepRow[0].SystemID
                    Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query "DELETE FROM SystemInfo WHERE SystemID <> $keepId;"
                }
            }
        } catch {
            Write-Warning "Failed to collapse duplicate SystemInfo rows after insert: $_"
        }
    }
    else {
        # Update existing row - only modify fields provided
        $updates = @()

        if ($PSBoundParameters.ContainsKey('FarmName')) { $updates += "FarmName = $(ConvertTo-SqlValue -Value $FarmName)" }
        if ($PSBoundParameters.ContainsKey('Address')) { $updates += "Address = $(ConvertTo-SqlValue -Value $Address)" }
        if ($PSBoundParameters.ContainsKey('City')) { $updates += "City = $(ConvertTo-SqlValue -Value $City)" }
        if ($PSBoundParameters.ContainsKey('State')) { $updates += "State = $(ConvertTo-SqlValue -Value $State)" }
        if ($PSBoundParameters.ContainsKey('ZipCode')) { $updates += "ZipCode = $(ConvertTo-SqlValue -Value $ZipCode)" }
        if ($PSBoundParameters.ContainsKey('PhoneNumber')) { $updates += "PhoneNumber = $(ConvertTo-SqlValue -Value $PhoneNumber)" }
        if ($PSBoundParameters.ContainsKey('Email')) { $updates += "Email = $(ConvertTo-SqlValue -Value $Email)" }
        if ($PSBoundParameters.ContainsKey('ContactPerson')) { $updates += "ContactPerson = $(ConvertTo-SqlValue -Value $ContactPerson)" }
        if ($PSBoundParameters.ContainsKey('Notes')) { $updates += "Notes = $(ConvertTo-SqlValue -Value $Notes)" }
        if ($PSBoundParameters.ContainsKey('DefaultCurrency')) { $updates += "DefaultCurrency = $(ConvertTo-SqlValue -Value $DefaultCurrency)" }
        if ($PSBoundParameters.ContainsKey('DefaultCulture')) { $updates += "DefaultCulture = $(ConvertTo-SqlValue -Value $DefaultCulture)" }
        elseif ($inferredDefaultCulture) { $updates += "DefaultCulture = $(ConvertTo-SqlValue -Value $inferredDefaultCulture)" }
        if ($PSBoundParameters.ContainsKey('Established')) {
            # Try to coerce to DateTime for consistent formatting. Accept year, date string, DateTime, or an array.
            try {
                if ($Established -is [System.Array]) { $v = $Established[0] } else { $v = $Established }
                if ($v -is [int]) { $Established = [DateTime]::new([int]$v, 1, 1) }
                elseif ($v -is [DateTime]) { $Established = $v }
                else {
                    $s = $v.ToString().Trim()
                    if ($s -match '^[0-9]{4}$') { $Established = [DateTime]::new([int]$s, 1, 1) } else { $Established = Parse-Date $s }
                }
            }
            catch {}
            $updates += "Established = $(ConvertTo-SqlValue -Value $Established)"
        }

        if ($updates.Count -gt 0) {
            $setClause = ($updates -join ', ') + ', ModifiedDate = CURRENT_TIMESTAMP'

            if ($PSBoundParameters.ContainsKey('SystemID')) {
                $where = "WHERE SystemID = $SystemID"
            }
            else {
                # Update the first row (single-row table)
                $where = "WHERE SystemID = (SELECT SystemID FROM SystemInfo LIMIT 1)"
            }

            $updateQuery = "UPDATE SystemInfo SET $setClause $where"
            Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query $updateQuery

                # If there are duplicate rows, collapse them: keep the lowest SystemID and remove others
                if ($count -gt 1) {
                    try {
                        $keepRow = Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query "SELECT SystemID FROM SystemInfo ORDER BY SystemID LIMIT 1;"
                        if ($keepRow -and $keepRow.Count -gt 0) {
                            $keepId = $keepRow[0].SystemID
                            Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query "DELETE FROM SystemInfo WHERE SystemID <> $keepId;"
                        }
                    } catch {
                        Write-Warning "Failed to collapse duplicate SystemInfo rows: $_"
                    }
                }
            }
        }

    return Get-SystemInfo
}
