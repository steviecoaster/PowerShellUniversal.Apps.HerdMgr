function Format-Date {
    <#
    .SYNOPSIS
    Formats a DateTime or date-like value for UI output.

    .DESCRIPTION
    Accepts a [DateTime], or string that can be parsed by Parse-Date, and returns a formatted
    date string. If the value is null or cannot be parsed, returns a configurable default ("-").

    .PARAMETER Date
    The value to format. Can be a [DateTime] or a parseable string.

    .PARAMETER Format
    The .NET date format string to use. Defaults to 'MM/dd/yyyy'.

    .PARAMETER Default
    The string to return for null/unparseable values. Defaults to '-'.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
        [AllowNull()][object]$Date,

        [Parameter(Position=1)]
        [string]$Format = 'MM/dd/yyyy',

        [Parameter(Position=2)]
        [string]$Default = '-'
    )

    process {
        if ($null -eq $Date -or $Date -eq '') {
            return $Default
        }

        try {
            if ($Date -is [DateTime]) {
                $dt = $Date
            }
            else {
                # Use the project's robust parser
                $dt = Parse-Date $Date
            }

            if ($null -eq $dt) { return $Default }
            return $dt.ToString($Format)
        }
        catch {
            return $Default
        }
    }
}
