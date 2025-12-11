# Migration Script: Add OriginFarmID to Cattle Table
# Run this to link cattle records to farm records

param(
    [Parameter()]
    [string]$DatabasePath = "C:\ProgramData\UniversalAutomation\Repository\Modules\PowerShellUniversal.Apps.HerdManager\data\HerdManager.db"
)

Write-Host "Migration: Adding OriginFarmID to Cattle table..." -ForegroundColor Cyan
Write-Host "Database: $DatabasePath" -ForegroundColor Yellow

if (-not (Test-Path $DatabasePath)) {
    Write-Host "ERROR: Database not found at $DatabasePath" -ForegroundColor Red
    exit 1
}

# Check if OriginFarmID column already exists
$checkQuery = "PRAGMA table_info(Cattle)"
$columns = Invoke-SqliteQuery -DataSource $DatabasePath -Query $checkQuery
$columnExists = $columns | Where-Object { $_.name -eq 'OriginFarmID' }

if ($columnExists) {
    Write-Host "OriginFarmID column already exists. Migration not needed." -ForegroundColor Green
    exit 0
}

# Add OriginFarmID column to Cattle table
$addColumnQuery = @"
ALTER TABLE Cattle ADD COLUMN OriginFarmID INTEGER REFERENCES Farms(FarmID);
"@

try {
    Write-Host "Adding OriginFarmID column to Cattle table..." -ForegroundColor Cyan
    Invoke-SqliteQuery -DataSource $DatabasePath -Query $addColumnQuery
    Write-Host "✓ OriginFarmID column added successfully" -ForegroundColor Green
    
    # Create index for better performance on farm lookups
    $createIndex = "CREATE INDEX idx_cattle_originfarm ON Cattle(OriginFarmID);"
    Invoke-SqliteQuery -DataSource $DatabasePath -Query $createIndex
    Write-Host "✓ Index on OriginFarmID created" -ForegroundColor Green
    
    Write-Host "`nMigration completed successfully!" -ForegroundColor Green
    Write-Host "Cattle can now be linked to Farm records." -ForegroundColor Yellow
    Write-Host "Note: Existing cattle will have NULL OriginFarmID - assign farms as needed." -ForegroundColor Yellow
}
catch {
    Write-Host "ERROR during migration: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
