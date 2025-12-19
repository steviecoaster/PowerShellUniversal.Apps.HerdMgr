function Get-DatabasePath {
    [CmdletBinding()]
    Param(
        [Parameter()]
        [String]
        $Root = (Join-Path $((Get-Module PowerShellUniversal.Apps.HerdManager).ModuleBase) -ChildPath 'data'), 

        [Parameter()]
        [String]
        $Database = 'HerdManager.db'
    )

    end {
        $dbPath = Join-Path $Root -ChildPath $Database
        return $dbPath
    }
}