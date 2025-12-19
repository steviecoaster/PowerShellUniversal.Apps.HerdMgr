<#
.SYNOPSIS
Migrates Invoices table to support NULL CattleID for multi-cattle invoices

.DESCRIPTION
This script recreates the Invoices table to allow NULL CattleID for multi-cattle invoices.
It preserves all existing invoice data. This is required because SQLite doesn't support
ALTER COLUMN to change NOT NULL constraints.

.PARAMETER DatabasePath
Path to the SQLite database file

.EXAMPLE
.\Fix-InvoicesTable.ps1 -DatabasePath "C:\HerdManager\HerdManager.db"
#>

param(
    [Parameter(Mandatory)]
    [string]$DatabasePath
)

if (-not (Test-Path $DatabasePath)) {
    Write-Error "Database file not found: $DatabasePath"
    exit 1
}

Write-Host "Migrating Invoices table to support multi-cattle invoices..." -ForegroundColor Cyan
Write-Host "Database: $DatabasePath" -ForegroundColor Cyan

try {
    # Import MySQLite module
    if (-not (Get-Module -ListAvailable -Name MySQLite)) {
        Write-Error "MySQLite module not found. Please install it first: Install-Module MySQLite"
        exit 1
    }
    
    Import-Module MySQLite -ErrorAction Stop
    
    Write-Host "Checking current table structure..." -ForegroundColor Yellow
    
    # Check if we need to migrate
    $checkQuery = "PRAGMA table_info(Invoices);"
    $tableInfo = Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query $checkQuery
    
    $cattleIdColumn = $tableInfo | Where-Object { $_.name -eq 'CattleID' }
    
    if ($cattleIdColumn.notnull -eq 0) {
        Write-Host "✓ Invoices table already allows NULL CattleID. No migration needed." -ForegroundColor Green
        exit 0
    }
    
    Write-Host "Migration needed. Starting transaction..." -ForegroundColor Yellow
    
    # Begin transaction
    Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query "BEGIN TRANSACTION;"
    
    try {
        # Step 1: Rename existing table
        Write-Host "  1. Backing up existing Invoices table..." -ForegroundColor Yellow
        Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query "ALTER TABLE Invoices RENAME TO Invoices_OLD;"
        
        # Step 2: Create new table with correct schema
        Write-Host "  2. Creating new Invoices table with nullable CattleID..." -ForegroundColor Yellow
        $createNewTable = @"
CREATE TABLE Invoices (
    InvoiceID INTEGER PRIMARY KEY AUTOINCREMENT,
    InvoiceNumber VARCHAR(50) UNIQUE NOT NULL,
    CattleID INTEGER,
    InvoiceDate DATE NOT NULL,
    StartDate DATE,
    EndDate DATE,
    DaysOnFeed INTEGER,
    PricePerDay DECIMAL(10,2),
    FeedingCost DECIMAL(10,2),
    HealthCost DECIMAL(10,2) DEFAULT 0,
    TotalCost DECIMAL(10,2) NOT NULL,
    Notes TEXT,
    CreatedBy VARCHAR(100),
    CreatedDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (CattleID) REFERENCES Cattle(CattleID)
);
"@
        Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query $createNewTable
        
        # Step 3: Copy data from old table
        Write-Host "  3. Copying existing invoice data..." -ForegroundColor Yellow
        $copyData = @"
INSERT INTO Invoices (
    InvoiceID, InvoiceNumber, CattleID, InvoiceDate, StartDate, EndDate,
    DaysOnFeed, PricePerDay, FeedingCost, HealthCost, TotalCost, Notes,
    CreatedBy, CreatedDate
)
SELECT 
    InvoiceID, InvoiceNumber, CattleID, InvoiceDate, StartDate, EndDate,
    DaysOnFeed, PricePerDay, FeedingCost, HealthCost, TotalCost, Notes,
    CreatedBy, CreatedDate
FROM Invoices_OLD;
"@
        Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query $copyData
        
        # Step 4: Recreate indexes
        Write-Host "  4. Recreating indexes..." -ForegroundColor Yellow
        Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query "CREATE INDEX IF NOT EXISTS idx_invoice_number ON Invoices(InvoiceNumber);"
        Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query "CREATE INDEX IF NOT EXISTS idx_invoice_cattle ON Invoices(CattleID);"
        Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query "CREATE INDEX IF NOT EXISTS idx_invoice_date ON Invoices(InvoiceDate);"
        
        # Step 5: Drop old table
        Write-Host "  5. Removing backup table..." -ForegroundColor Yellow
        Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query "DROP TABLE Invoices_OLD;"
        
        # Commit transaction
        Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query "COMMIT;"
        
        Write-Host "✓ Migration completed successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Summary:" -ForegroundColor Cyan
        Write-Host "  - Invoices table now allows NULL CattleID" -ForegroundColor White
        Write-Host "  - All existing invoice data preserved" -ForegroundColor White
        Write-Host "  - Indexes recreated" -ForegroundColor White
        Write-Host "  - Multi-cattle invoices will now work correctly" -ForegroundColor White
        Write-Host ""
        Write-Host "Note: Restart your PowerShell Universal dashboard to pick up changes." -ForegroundColor Yellow
    }
    catch {
        # Rollback on error
        Write-Host "Error during migration. Rolling back..." -ForegroundColor Red
        Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query "ROLLBACK;" -ErrorAction SilentlyContinue
        throw
    }
}
catch {
    Write-Error "Migration failed: $($_.Exception.Message)"
    Write-Error $_.ScriptStackTrace
    exit 1
}





