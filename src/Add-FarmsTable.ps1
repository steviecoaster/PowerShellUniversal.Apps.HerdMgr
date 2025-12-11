# Migration Script: Add Farms Table
# Run this to add farm management capabilities to existing HerdManager databases

param(
    [Parameter()]
    [string]$DatabasePath = "C:\ProgramData\UniversalAutomation\Repository\Modules\PowerShellUniversal.Apps.HerdManager\data\HerdManager.db"
)

Write-Host "Migration: Adding Farms table to HerdManager database..." -ForegroundColor Cyan
Write-Host "Database: $DatabasePath" -ForegroundColor Yellow

if (-not (Test-Path $DatabasePath)) {
    Write-Host "ERROR: Database not found at $DatabasePath" -ForegroundColor Red
    exit 1
}

# Check if Farms table already exists
$checkQuery = "SELECT name FROM sqlite_master WHERE type='table' AND name='Farms'"
$tableExists = Invoke-SqliteQuery -DataSource $DatabasePath -Query $checkQuery

if ($tableExists) {
    Write-Host "Farms table already exists. Migration not needed." -ForegroundColor Green
    exit 0
}

# Create Farms table
$createFarmsTable = @"
CREATE TABLE Farms (
    FarmID INTEGER PRIMARY KEY AUTOINCREMENT,
    FarmName TEXT NOT NULL,
    Address TEXT,
    City TEXT,
    State TEXT,
    ZipCode TEXT,
    PhoneNumber TEXT,
    Email TEXT,
    ContactPerson TEXT,
    Notes TEXT,
    IsActive INTEGER DEFAULT 1,
    CreatedDate TEXT DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate TEXT DEFAULT CURRENT_TIMESTAMP
);
"@

try {
    Write-Host "Creating Farms table..." -ForegroundColor Cyan
    Invoke-SqliteQuery -DataSource $DatabasePath -Query $createFarmsTable
    Write-Host "✓ Farms table created successfully" -ForegroundColor Green
    
    # Create index on FarmName for faster lookups
    $createIndex = "CREATE INDEX idx_farms_name ON Farms(FarmName);"
    Invoke-SqliteQuery -DataSource $DatabasePath -Query $createIndex
    Write-Host "✓ Index on FarmName created" -ForegroundColor Green
    
    Write-Host "`nMigration completed successfully!" -ForegroundColor Green
    Write-Host "You can now use the Farms page to add farm records." -ForegroundColor Yellow
}
catch {
    Write-Host "ERROR during migration: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
