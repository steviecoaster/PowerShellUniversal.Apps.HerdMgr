function ConvertTo-CssString {
    <#
    .SYNOPSIS
    Serializes a CSS rules hashtable into a CSS string for use with New-UDStyle.

    .DESCRIPTION
    Converts a structured [ordered]@{} hashtable of CSS rules into a valid CSS string.
    Supports a nested '@media ...' key for media query blocks.

    .PARAMETER Rules
    An ordered hashtable of CSS selectors to property hashtables.
    A key starting with '@media' is treated as a media query block containing
    its own selector->property hashtables.

    .EXAMPLE
    ConvertTo-CssString $HerdStyles.PrintCSS.Invoice
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [System.Collections.IDictionary]$Rules
    )

    $sb = [System.Text.StringBuilder]::new()

    foreach ($key in $Rules.Keys) {
        if ($key -like '@media*') {
            $null = $sb.AppendLine("$key {")
            foreach ($selector in $Rules[$key].Keys) {
                $null = $sb.AppendLine("    $selector {")
                foreach ($prop in $Rules[$key][$selector].Keys) {
                    $null = $sb.AppendLine("        ${prop}: $($Rules[$key][$selector][$prop]);")
                }
                $null = $sb.AppendLine('    }')
            }
            $null = $sb.AppendLine('}')
        }
        else {
            $null = $sb.AppendLine("$key {")
            foreach ($prop in $Rules[$key].Keys) {
                $null = $sb.AppendLine("    ${prop}: $($Rules[$key][$prop]);")
            }
            $null = $sb.AppendLine('}')
        }
    }

    return $sb.ToString()
}
