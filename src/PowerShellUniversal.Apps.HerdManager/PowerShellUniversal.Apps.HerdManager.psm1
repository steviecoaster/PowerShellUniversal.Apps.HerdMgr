# PowerShell Universal Herd Manager App Module

# Set the database path at module scope
$script:DatabasePath = Join-Path $PSScriptRoot 'data\HerdManager.db'

# Dot source all public functions
$Public = @( Get-ChildItem -Path $PSScriptRoot\functions\public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\functions\private\*.ps1 -ErrorAction SilentlyContinue )

# Dot source the functions
foreach ($import in @($Public + $Private)) {
    try {
        . $import.FullName
    }
    catch {
        Write-Error -Message "Failed to import function $($import.FullName): $_"
    }
}