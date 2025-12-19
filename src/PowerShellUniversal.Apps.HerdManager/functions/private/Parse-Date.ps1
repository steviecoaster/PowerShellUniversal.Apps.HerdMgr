function Parse-Date {
    <#
    .SYNOPSIS
    Robust date/time parser that accepts multiple common formats and returns a [DateTime]

    .DESCRIPTION
    Tries a list of common date formats using invariant culture, then falls back to TryParse with
    invariant and current culture. Throws if input cannot be parsed.

    .PARAMETER InputDate
    A string or DateTime object to parse.

    .OUTPUTS
    [DateTime]
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [object]$InputDate
    )

    process {
        if ($null -eq $InputDate -or $InputDate -eq '') { return $null }
        if ($InputDate -is [DateTime]) { return $InputDate }

        $s = $InputDate.ToString()
        $formats = @(
            'yyyy-MM-dd HH:mm:ss',
            'yyyy-MM-dd',
            'MM/dd/yyyy HH:mm:ss',
            'MM/dd/yyyy',
            'M/d/yyyy',
            'M/d/yyyy HH:mm:ss',
            'yyyy-MM-ddTHH:mm:ss',
            'yyyy-MM-ddTHH:mm:ssZ'
        )

        foreach ($fmt in $formats) {
            try {
                return [DateTime]::ParseExact($s, $fmt, [System.Globalization.CultureInfo]::InvariantCulture)
            }
            catch {
                # ignore and try next format
            }
        }

        # Try parsing with invariant culture, then current culture
        try { return [DateTime]::Parse($s, [System.Globalization.CultureInfo]::InvariantCulture) } catch {}
        try { return [DateTime]::Parse($s) } catch {}

        throw "Invalid date format: $s"
    }
}