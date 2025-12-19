function ConvertTo-SqlValue {
    <#
    .SYNOPSIS
    Converts a PowerShell value to a properly formatted SQL value string.
    
    .DESCRIPTION
    This function takes a PowerShell value and converts it to a properly formatted
    SQL value string. String values are quoted and escaped, numeric values are 
    returned as-is, and null values are converted to SQL NULL.
    
    .PARAMETER Value
    The value to convert to SQL format.
    
    .EXAMPLE
    ConvertTo-SqlValue -Value "John's Farm"
    Returns: 'John''s Farm' (properly escaped single quote)
    
    .EXAMPLE
    ConvertTo-SqlValue -Value 123
    Returns: 123 (numeric value, no quotes)
    
    .EXAMPLE
    ConvertTo-SqlValue -Value $null
    Returns: NULL
    
    .NOTES
    This function is used internally to safely format values for SQL queries
    when using MySQLite which doesn't support parameterized queries.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        $Value
    )
    
    # Handle null values
    if ($null -eq $Value -or $Value -eq '') {
        return 'NULL'
    }
    
    # Handle boolean values
    if ($Value -is [bool]) {
        return if ($Value) { '1' } else { '0' }
    }
    
    # Handle numeric values (don't quote)
    if ($Value -is [int] -or $Value -is [long] -or $Value -is [decimal] -or $Value -is [double] -or $Value -is [float]) {
        return $Value.ToString()
    }
    
    # Handle DateTime values
    if ($Value -is [DateTime]) {
        return "'{0:yyyy-MM-dd HH:mm:ss}'" -f $Value
    }
    
    # Handle string values (quote and escape)
    if ($Value -is [string]) {
        # Escape single quotes by doubling them (SQL standard)
        $escapedValue = $Value -replace "'", "''"
        return "'$escapedValue'"
    }
    
    # Default: treat as string
    $escapedValue = $Value.ToString() -replace "'", "''"
    return "'$escapedValue'"
}
