# Migration Script: Add IsOrigin Column to Farms Table
# Run this to add the IsOrigin flag to distinguish origin farms from other farms

param(
    [Parameter()]
    [string]$DatabasePath = "C:\ProgramData\UniversalAutomation\Repository\Modules\PowerShellUniversal.Apps.HerdManager\data\HerdManager.db"
)

Write-Host "Migration: Adding IsOrigin column to Farms table..." -ForegroundColor Cyan
Write-Host "Database: $DatabasePath" -ForegroundColor Yellow

if (-not (Test-Path $DatabasePath)) {
    Write-Host "ERROR: Database not found at $DatabasePath" -ForegroundColor Red
    exit 1
}

# Check if IsOrigin column already exists
$checkQuery = "PRAGMA table_info(Farms)"
$columns = Invoke-SqliteQuery -DataSource $DatabasePath -Query $checkQuery
$columnExists = $columns | Where-Object { $_.name -eq 'IsOrigin' }

if ($columnExists) {
    Write-Host "IsOrigin column already exists. Migration not needed." -ForegroundColor Green
    exit 0
}

# Add IsOrigin column to Farms table
$addColumnQuery = @"
ALTER TABLE Farms ADD COLUMN IsOrigin INTEGER DEFAULT 0;
"@

try {
    Write-Host "Adding IsOrigin column to Farms table..." -ForegroundColor Cyan
    Invoke-SqliteQuery -DataSource $DatabasePath -Query $addColumnQuery
    Write-Host "✓ IsOrigin column added successfully" -ForegroundColor Green
    
    Write-Host "`nMigration completed successfully!" -ForegroundColor Green
    Write-Host "You can now mark farms as cattle origins using the checkbox on the Farms page." -ForegroundColor Yellow
    Write-Host "Origin farms will appear in the Origin Farm dropdown when adding/editing cattle." -ForegroundColor Yellow
}
catch {
    Write-Host "ERROR during migration: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
