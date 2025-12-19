# PowerShell Universal Herd Manager App Module

# Dot source all public and private functions (cross-platform paths)
$Public = @( Get-ChildItem -Path (Join-Path $PSScriptRoot 'functions' 'public' '*.ps1') -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path (Join-Path $PSScriptRoot 'functions' 'private' '*.ps1') -ErrorAction SilentlyContinue )

# Dot source the functions so helper functions (like Invoke-UniversalSQLiteQuery) are available for initialization
foreach ($import in @($Public + $Private)) {
    try {
        . $import.FullName
    }
    catch {
        Write-Error -Message "Failed to import function $($import.FullName): $_"
    }
}

# Set the database path at module scope (cross-platform)
$script:DatabasePath = Join-Path $PSScriptRoot 'data' 'HerdManager.db'

# Initialize database if it doesn't exist
if (-not (Test-Path $script:DatabasePath)) {
    Write-Verbose "Database not found. Initializing new database at $script:DatabasePath"
    
    # Ensure data directory exists
    $dataDir = Split-Path $script:DatabasePath -Parent
    if (-not (Test-Path $dataDir)) {
        New-Item -ItemType Directory -Path $dataDir -Force | Out-Null
    }
    
    # Create database with schema
    $schemaPath = Join-Path $PSScriptRoot 'data' 'Database-Schema.sql'
    if (Test-Path $schemaPath) {
        $schema = Get-Content $schemaPath -Raw
        Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $schema
        Write-Verbose "Database initialized successfully"
    }
    else {
        Write-Warning "Database schema file not found at $schemaPath. Database created but not initialized."
    }
}

# Ensure sensible PRAGMA settings for concurrency/ durability even if DB already existed
try {
    Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query "PRAGMA journal_mode = WAL;"
    Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query "PRAGMA synchronous = 2;"
    Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query "PRAGMA wal_autocheckpoint = 1000;"
    Write-Verbose "Database PRAGMAs enforced: journal_mode=WAL, synchronous=2, wal_autocheckpoint=1000"
}
catch {
    Write-Warning "Failed to enforce database PRAGMAs: $_"
}