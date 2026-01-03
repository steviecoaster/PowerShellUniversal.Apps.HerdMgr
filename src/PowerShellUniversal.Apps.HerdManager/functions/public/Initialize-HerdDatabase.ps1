function Initialize-HerdDatabase {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Schema,

        [Parameter(Mandatory)]
        [string]$Database
    )

    # Ensure db file exists (your SQLite wrapper requires it)
    if (-not (Test-Path $Database)) {
        $dbFolder = Split-Path $Database -Parent
        if ($dbFolder -and -not (Test-Path $dbFolder)) {
            New-Item -Path $dbFolder -ItemType Directory -Force | Out-Null
        }
        New-Item -Path $Database -ItemType File -Force | Out-Null
    }

    # Schema can be either:
    # - A file path to Schema.sql
    # - The raw SQL contents of Schema.sql
    $schemaSql = $null

    if (Test-Path $Schema) {
        # It's a file path
        $schemaSql = Get-Content -Raw $Schema
    }
    else {
        # It's raw SQL
        $schemaSql = $Schema
    }

    if (-not $schemaSql -or $schemaSql.Trim().Length -eq 0) {
        throw "Initialize-RecipeDatabase: Schema SQL was empty."
    }

    # Apply schema (safe due to IF NOT EXISTS)
    Invoke-UniversalSQLiteQuery -Path $Database -Query $schemaSql | Out-Null
}