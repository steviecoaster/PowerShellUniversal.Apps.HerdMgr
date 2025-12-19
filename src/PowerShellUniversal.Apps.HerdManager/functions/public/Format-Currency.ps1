function Format-Currency {
    <#
    .SYNOPSIS
    Formats a numeric value as currency for UI output using a specified culture (default en-US).

    .DESCRIPTION
    Accepts numeric values or strings that can be converted to decimal and returns a localized
    currency string. If the value is null or cannot be parsed, returns a configurable default ('-').

    .PARAMETER Amount
    The numeric amount to format (decimal, int, or string).

    .PARAMETER Culture
    The culture code to use for currency formatting (defaults to 'en-US').

    .PARAMETER Default
    The string to return for null/unparseable values. Defaults to '-'.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
        [AllowNull()][object]$Amount,

    [Parameter(Position=1)]
    [string]$Culture = $null,

        [Parameter(Position=2)]
        [string]$Default = '-'
    )

    process {
        if ($null -eq $Amount -or $Amount -eq '') { return $Default }

        try {
            $dec = [decimal]$Amount
        }
        catch {
            return $Default
        }

        # Determine culture: explicit param overrides system setting; otherwise use system DefaultCulture if configured
        $cultureToUse = 'en-US'
        if ($Culture -and $Culture -ne '') {
            $cultureToUse = $Culture
        }
        else {
            try {
                $sys = Get-SystemInfo
                if ($sys -and $sys.DefaultCulture) { $cultureToUse = $sys.DefaultCulture }
            }
            catch {
                # ignore and fall back to en-US
            }
        }

        try {
            $ci = [System.Globalization.CultureInfo]::GetCultureInfo($cultureToUse)
        }
        catch {
            $ci = [System.Globalization.CultureInfo]::GetCultureInfo('en-US')
        }

        try {
            return $dec.ToString('C2', $ci)
        }
        catch {
            return $Default
        }
    }
}
