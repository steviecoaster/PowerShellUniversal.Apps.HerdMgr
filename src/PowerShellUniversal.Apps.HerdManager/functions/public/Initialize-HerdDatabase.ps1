function Initialize-HerdDatabase {
    <#
    .SYNOPSIS
    Initializes the SQLite database with the schema
    
    .DESCRIPTION
    Creates the herd management database file and executes the schema SQL to create
    all necessary tables, views, indexes, and triggers. This function is idempotent -
    it's safe to run multiple times as it uses CREATE TABLE IF NOT EXISTS statements.
    
    .PARAMETER DatabasePath
    Path where the database file should be created. If not specified, uses the
    module's default database path ($script:DatabasePath).
    
    .OUTPUTS
    Returns $true if initialization succeeds, $false if it fails.
    Also outputs status messages about the initialization process.
    
    .EXAMPLE
    Initialize-HerdDatabase
    
    Creates the database at the default module location
    
    .EXAMPLE
    Initialize-HerdDatabase -DatabasePath "C:\Data\MyHerd.db"
    
    Creates the database at a custom location
    
    .NOTES
    Requires the MySQLite module to be installed.
    Creates the following tables:
    - Farms: Farm/ranch contact information
    - Cattle: Animal records
    - WeightRecords: Weight measurements
    - HealthRecords: Medical history
    - RateOfGainCalculations: ROG tracking
    - Invoices: Billing records
    - InvoiceLineItems: Multi-cattle invoice details
    
    Also creates views and indexes for optimized queries.
    #>
    param(
        [string]$DatabasePath = $script:DatabasePath
    )
        
    # Read schema file from module's data directory (cross-platform)
    $moduleRoot = (Get-Module -Name 'PowerShellUniversal.Apps.HerdManager').ModuleBase
    $schemaPath = Join-Path $moduleRoot 'data' 'Database-Schema.sql'
    if (-not (Test-Path $schemaPath)) {
        Write-Error "Schema file not found at $schemaPath"
        return $false
    }
    
    $schema = Get-Content $schemaPath -Raw
    
    # Split by semicolons and execute each statement
    $statements = $schema -split ';' | Where-Object { $_.Trim() -ne '' }
    
    # Ensure the database file exists so sqlite can open it (creates empty file if necessary)
    $dbDir = Split-Path $DatabasePath -Parent
    if (-not (Test-Path $dbDir)) { New-Item -Path $dbDir -ItemType Directory -Force | Out-Null }
    if (-not (Test-Path $DatabasePath)) { New-Item -Path $DatabasePath -ItemType File -Force | Out-Null }

    foreach ($statement in $statements) {
        if ($statement.Trim()) {
            Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query $statement
        }
    }

    # Ensure WAL and sensible concurrency/durability settings
    try {
        Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query "PRAGMA journal_mode = WAL;"
        Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query "PRAGMA synchronous = 2;"
        Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query "PRAGMA wal_autocheckpoint = 1000;"
        Write-Verbose "Initialization: set PRAGMA journal_mode=WAL, synchronous=2, wal_autocheckpoint=1000"
    }
    catch {
        Write-Warning "Failed to set PRAGMA during initialization: $_"
    }

    # Run lightweight migrations: add Established column to SystemInfo if missing
    try {
        $cols = Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query "PRAGMA table_info('SystemInfo');"
        $hasEstablished = $false
        if ($cols -and $cols.Count -gt 0) { if ($cols | Where-Object { $_.name -eq 'Established' }) { $hasEstablished = $true } }
        if (-not $hasEstablished) {
            Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query "ALTER TABLE SystemInfo ADD COLUMN Established DATE;"
            Write-Verbose "Migration: added Established column to SystemInfo"
        }
    } catch {
        Write-Warning "Migration check for Established column failed: $_"
    }
    
    Write-Host "Database initialized successfully at $DatabasePath" -ForegroundColor Green
    return $true
}





