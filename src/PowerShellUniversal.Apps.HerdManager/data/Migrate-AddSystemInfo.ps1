<#
.SYNOPSIS
Adds SystemInfo table to an existing database and seeds a default row if none exists.

.PARAMETER DatabasePath
Path to the SQLite database file

.EXAMPLE
.\Migrate-AddSystemInfo.ps1 -DatabasePath "C:\data\HerdManager.db"
#>

param(
    [Parameter(Mandatory)]
    [string]$DatabasePath
)

if (-not (Test-Path $DatabasePath)) {
    Write-Error "Database file not found: $DatabasePath"
    exit 1
}

Write-Host "Starting migration: Add SystemInfo table..." -ForegroundColor Cyan

try {
    $createQuery = @"
-- Table: SystemInfo
CREATE TABLE IF NOT EXISTS SystemInfo (
    SystemID INTEGER PRIMARY KEY AUTOINCREMENT,
    FarmName VARCHAR(200),
    Address TEXT,
    City VARCHAR(100),
    State VARCHAR(50),
    ZipCode VARCHAR(20),
    PhoneNumber VARCHAR(20),
    Email VARCHAR(100),
    ContactPerson VARCHAR(100),
    Notes TEXT,
    DefaultCurrency VARCHAR(10) DEFAULT 'USD',
    DefaultCulture VARCHAR(10) DEFAULT 'en-US',
    CreatedDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate DATETIME DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_systeminfo_id ON SystemInfo(SystemID);
"@

    Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query $createQuery
    Write-Host "✓ SystemInfo table ensured" -ForegroundColor Green

    # Seed default row if table empty
    $count = (Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query "SELECT COUNT(*) AS Count FROM SystemInfo").Count
    if ($count -eq 0) {
        Write-Host "Seeding default system settings..." -ForegroundColor Yellow
        $seedQuery = "INSERT INTO SystemInfo (DefaultCurrency, DefaultCulture, CreatedDate, ModifiedDate) VALUES ('USD', 'en-US', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)"
        Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query $seedQuery
        Write-Host "✓ Default system settings inserted" -ForegroundColor Green
    }

    Write-Host "Migration completed successfully." -ForegroundColor Green
    Write-Host "Note: Restart your PowerShell Universal dashboard to load updated code (if you changed function signatures)." -ForegroundColor Yellow
}
catch {
    Write-Error "Migration failed: $($_.Exception.Message)"
    exit 1
}
