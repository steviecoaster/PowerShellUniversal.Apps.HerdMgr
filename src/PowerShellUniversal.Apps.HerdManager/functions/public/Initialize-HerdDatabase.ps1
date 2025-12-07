function Initialize-HerdDatabase {
    <#
    .SYNOPSIS
    Initializes the SQLite database with the schema
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