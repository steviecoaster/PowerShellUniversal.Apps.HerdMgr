function Initialize-HerdDbFile {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [String]
        $DatabaseFile
    )
    
    if(-not (Test-Path $DatabaseFile)) {
        $null = New-Item $DatabaseFile -ItemType File -Force
    }
}