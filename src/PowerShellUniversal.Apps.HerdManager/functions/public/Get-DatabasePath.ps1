function Get-DatabasePath {
    [CmdletBinding()]
    Param()

    end {
        # Return the database path set by the module during initialization
        # This ensures consistency with where other functions are reading/writing
        if ($script:DatabasePath) {
            return $script:DatabasePath
        }
        
        # Fallback to default location if script variable not set
        # (shouldn't happen if module loaded properly)
        $defaultPath = Join-Path $((Get-Module PowerShellUniversal.Apps.HerdManager).ModuleBase) -ChildPath 'data\HerdManager.db'
        Write-Warning "Database path not initialized. Using default: $defaultPath"
        return $defaultPath
    }
}