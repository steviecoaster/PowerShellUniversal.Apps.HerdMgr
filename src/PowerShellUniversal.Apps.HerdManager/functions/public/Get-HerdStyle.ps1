function Get-HerdStyle {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Category,
        
        [Parameter(Mandatory)]
        [string]$Style
    )
    
    return $Script:HerdStyles[$Category][$Style]
}