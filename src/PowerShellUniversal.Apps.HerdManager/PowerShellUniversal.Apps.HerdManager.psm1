# PowerShell Universal Herd Manager App Module

# Setup status flags
$script:PSSQLiteAvailable = $false
$script:DatabaseReady = $false

# Check PSSQLite dependency
if (Get-Module PSSQLite -ListAvailable) {
    Import-Module PSSQLite
    $script:PSSQLiteAvailable = $true
}
else {
    Write-Warning "PSSQLite module not found. The app will start in setup mode."
}

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

# Define stable database path and schema path
$script:DatabasePath = Join-Path $BasePath 'HerdManager.db'
$script:SchemaPath = Join-Path $PSScriptRoot 'data' 'Database-Schema.sql'

# Create directories if missing
if (-not (Test-Path $BasePath)) {
    $null = New-Item -Path $BasePath -ItemType Directory -Force
}

# Initialize DB if PSSQLite is available
if ($script:PSSQLiteAvailable) {
    try {
        Initialize-HerdDbFile -Database $script:DatabasePath
        Initialize-HerdDatabase -Schema $script:SchemaPath -Database $script:DatabasePath
        $script:DatabaseReady = $true

        # Ensure sensible PRAGMA settings for concurrency/durability
        Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query "PRAGMA journal_mode = WAL;"
        Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query "PRAGMA synchronous = 2;"
        Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query "PRAGMA wal_autocheckpoint = 1000;"
        Write-Verbose "Database PRAGMAs enforced: journal_mode=WAL, synchronous=2, wal_autocheckpoint=1000"
    }
    catch {
        Write-Warning "Database initialization failed: $_"
    }
}