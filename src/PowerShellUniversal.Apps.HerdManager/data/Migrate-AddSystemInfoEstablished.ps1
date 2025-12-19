<#
.SYNOPSIS
Adds the Established column to SystemInfo if it doesn't exist yet.

.PARAMETER DatabasePath
Path to the SQLite database file

.EXAMPLE
.\Migrate-AddSystemInfoEstablished.ps1 -DatabasePath "C:\data\HerdManager.db"
#>

param(
    [Parameter(Mandatory)]
    [string]$DatabasePath
)

if (-not (Test-Path $DatabasePath)) {
    Write-Error "Database file not found: $DatabasePath"
    exit 1
}

Write-Host "Starting migration: Add Established column to SystemInfo..." -ForegroundColor Cyan

try {
    # Ensure SystemInfo table exists
    $table = Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query "SELECT name FROM sqlite_master WHERE type='table' AND name='SystemInfo';"
    if (-not $table) {
        Write-Error "SystemInfo table not found in database $DatabasePath"
        exit 1
    }

    # Check if column exists
    $cols = Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query "PRAGMA table_info('SystemInfo');"
    $exists = $false
    foreach ($c in $cols) { if ($c.name -eq 'Established') { $exists = $true; break } }

    if ($exists) {
        Write-Host "✓ Established column already exists. No action needed." -ForegroundColor Green
        exit 0
    }

    # Add column
    Write-Host "Adding Established column..." -ForegroundColor Yellow
    Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query "ALTER TABLE SystemInfo ADD COLUMN Established DATE;"

    Write-Host "✓ Established column added successfully" -ForegroundColor Green
    Write-Host "Note: Restart your PowerShell Universal dashboard to load the updated code (Set-SystemInfo signature changes)." -ForegroundColor Yellow
}
catch {
    Write-Error "Migration failed: $($_.Exception.Message)"
    exit 1
}
