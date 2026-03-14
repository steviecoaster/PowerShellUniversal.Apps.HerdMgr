function Invoke-UniversalSQLiteQuery {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter(Mandatory)]
        [string]$Query
    )

    if (-not (Test-Path $Path)) {
        throw "Database file not found: $Path"
    }

    Invoke-SqliteQuery -DataSource $Path -Query $Query
}
