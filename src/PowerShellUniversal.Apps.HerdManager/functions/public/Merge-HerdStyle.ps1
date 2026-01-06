function Merge-HerdStyle {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [hashtable]$BaseStyle,
        
        [Parameter()]
        [hashtable]$CustomStyle = @{}
    )
    
    $merged = $BaseStyle.Clone()
    foreach ($key in $CustomStyle.Keys) {
        $merged[$key] = $CustomStyle[$key]
    }
    return $merged
}