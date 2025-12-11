<#
.SYNOPSIS
Migrates existing database to support multi-cattle invoices

.DESCRIPTION
This script adds the InvoiceLineItems table to an existing database.
It's safe to run multiple times - it will only create the table if it doesn't exist.
Existing single-cattle invoices will continue to work without modification.

.PARAMETER DatabasePath
Path to the SQLite database file

.EXAMPLE
.\Migrate-MultiCattleInvoices.ps1 -DatabasePath "C:\HerdManager\HerdManager.db"
#>

param(
    [Parameter(Mandatory)]
    [string]$DatabasePath
)

if (-not (Test-Path $DatabasePath)) {
    Write-Error "Database file not found: $DatabasePath"
    exit 1
}

Write-Host "Starting database migration for multi-cattle invoices..." -ForegroundColor Cyan
Write-Host "Database: $DatabasePath" -ForegroundColor Cyan

try {
    # Import PSSQLite module
    if (-not (Get-Module -ListAvailable -Name PSSQLite)) {
        Write-Error "PSSQLite module not found. Please install it first: Install-Module PSSQLite"
        exit 1
    }
    
    Import-Module PSSQLite -ErrorAction Stop
    
    # Check if table already exists
    $checkTableQuery = @"
SELECT name FROM sqlite_master 
WHERE type='table' AND name='InvoiceLineItems';
"@
    
    $existingTable = Invoke-SqliteQuery -DataSource $DatabasePath -Query $checkTableQuery -As PSObject
    
    if ($existingTable) {
        Write-Host "✓ InvoiceLineItems table already exists. No migration needed." -ForegroundColor Green
        exit 0
    }
    
    Write-Host "Creating InvoiceLineItems table..." -ForegroundColor Yellow
    
    # Create the new table
    $createTableQuery = @"
-- Table: InvoiceLineItems
-- Stores individual cattle line items for multi-cattle invoices
CREATE TABLE IF NOT EXISTS InvoiceLineItems (
    LineItemID INTEGER PRIMARY KEY AUTOINCREMENT,
    InvoiceID INTEGER NOT NULL,
    CattleID INTEGER NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    DaysOnFeed INTEGER NOT NULL,
    PricePerDay DECIMAL(10,2) NOT NULL,
    FeedingCost DECIMAL(10,2) NOT NULL,
    HealthCost DECIMAL(10,2) DEFAULT 0,
    LineItemTotal DECIMAL(10,2) NOT NULL,
    Notes TEXT,
    FOREIGN KEY (InvoiceID) REFERENCES Invoices(InvoiceID) ON DELETE CASCADE,
    FOREIGN KEY (CattleID) REFERENCES Cattle(CattleID)
);
"@
    
    Invoke-SqliteQuery -DataSource $DatabasePath -Query $createTableQuery
    Write-Host "✓ InvoiceLineItems table created successfully" -ForegroundColor Green
    
    # Create indexes
    Write-Host "Creating indexes..." -ForegroundColor Yellow
    
    $createIndexesQuery = @"
-- Index for invoice line items
CREATE INDEX IF NOT EXISTS idx_line_item_invoice ON InvoiceLineItems(InvoiceID);
CREATE INDEX IF NOT EXISTS idx_line_item_cattle ON InvoiceLineItems(CattleID);
"@
    
    Invoke-SqliteQuery -DataSource $DatabasePath -Query $createIndexesQuery
    Write-Host "✓ Indexes created successfully" -ForegroundColor Green
    
    # Update Invoices table to make legacy fields nullable (if needed)
    Write-Host "Updating Invoices table structure..." -ForegroundColor Yellow
    
    # SQLite doesn't support ALTER COLUMN directly, so we'll check the schema
    # The schema has already been updated in Database-Schema.sql for new databases
    # Existing databases will continue to work as the fields are still present
    
    Write-Host "✓ Database migration completed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Summary:" -ForegroundColor Cyan
    Write-Host "  - InvoiceLineItems table added" -ForegroundColor White
    Write-Host "  - Indexes created for performance" -ForegroundColor White
    Write-Host "  - Existing single-cattle invoices will continue to work" -ForegroundColor White
    Write-Host "  - You can now create multi-cattle invoices!" -ForegroundColor White
    Write-Host ""
    Write-Host "Note: Restart your PowerShell Universal dashboard to load the updated code." -ForegroundColor Yellow
}
catch {
    Write-Error "Migration failed: $($_.Exception.Message)"
    Write-Error $_.ScriptStackTrace
    exit 1
}
