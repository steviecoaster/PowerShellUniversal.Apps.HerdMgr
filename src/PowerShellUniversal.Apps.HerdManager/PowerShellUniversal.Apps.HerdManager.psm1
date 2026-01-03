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

# Load Schema.sql from module package
$SchemaPath = Join-Path $PSScriptRoot 'data' 'Database-Schema.sql'
if (-not (Test-Path $SchemaPath)) {
    throw "Database-Schema.sql not found at: $SchemaPath"
}

# Pick a simple, stable data path based on OS
# Windows: $env:ProgramData\HerdManager
# Linux:   $env:HOME/herdmanager  (PSU runs under the service user; writable)
if ($IsWindows) {
    $BasePath = Join-Path $env:ProgramData 'HerdManager'
}
elseif ($IsLinux) {
    if (-not $env:HOME) {
        throw "Linux detected but `$env:HOME is not set. Cannot determine HerdManager data folder."
    }
    $BasePath = Join-Path $env:HOME 'herdmanager'
}
else {
    # Fallback for other platforms
    $BasePath = Join-Path ([System.IO.Path]::GetTempPath()) 'herdmanager'
}

# Define stable database path
$script:DatabasePath = Join-Path $BasePath 'HerdManager.db'

# Create directories if missing
if (-not (Test-Path $BasePath)) {
    $null = New-Item -Path $BasePath -ItemType Directory -Force
}

# Initialize DB + schema (idempotent)
Initialize-HerdDbFile -Database $script:DatabasePath
Initialize-HerdDatabase -Schema $SchemaPath -Database $script:DatabasePath

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