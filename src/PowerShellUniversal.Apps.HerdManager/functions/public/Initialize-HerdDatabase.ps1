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
    Requires the PSSQLite module to be installed.
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
    
    # Check if PSSQLite module is available
    if (-not (Get-Module -ListAvailable -Name PSSQLite)) {
        Write-Warning "PSSQLite module not found. Install with: Install-Module PSSQLite -Force"
        return $false
    }
    
    Import-Module PSSQLite -ErrorAction Stop
    
    # Read schema file from module's data directory
    $moduleRoot = (Get-Module -Name 'PowerShellUniversal.Apps.HerdManager').ModuleBase
    $schemaPath = Join-Path $moduleRoot 'data\Database-Schema.sql'
    if (-not (Test-Path $schemaPath)) {
        Write-Error "Schema file not found at $schemaPath"
        return $false
    }
    
    $schema = Get-Content $schemaPath -Raw
    
    # Split by semicolons and execute each statement
    $statements = $schema -split ';' | Where-Object { $_.Trim() -ne '' }
    
    foreach ($statement in $statements) {
        if ($statement.Trim()) {
            Invoke-SqliteQuery -DataSource $DatabasePath -Query $statement
        }
    }
    
    Write-Host "Database initialized successfully at $DatabasePath" -ForegroundColor Green
    return $true
}