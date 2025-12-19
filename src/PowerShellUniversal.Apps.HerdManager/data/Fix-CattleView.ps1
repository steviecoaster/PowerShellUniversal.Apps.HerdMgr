<#
.SYNOPSIS
Fixes the CattleWithLatestWeight view to include PurchaseDate

.DESCRIPTION
This script updates the CattleWithLatestWeight view to include the PurchaseDate field,
which is needed for invoice generation. Safe to run multiple times.

.PARAMETER DatabasePath
Path to the SQLite database file

.EXAMPLE
.\Fix-CattleView.ps1 -DatabasePath "C:\HerdManager\HerdManager.db"
#>

param(
    [Parameter(Mandatory)]
    [string]$DatabasePath
)

if (-not (Test-Path $DatabasePath)) {
    Write-Error "Database file not found: $DatabasePath"
    exit 1
}

Write-Host "Fixing CattleWithLatestWeight view..." -ForegroundColor Cyan
Write-Host "Database: $DatabasePath" -ForegroundColor Cyan

try {
    # Import MySQLite module
    if (-not (Get-Module -ListAvailable -Name MySQLite)) {
        Write-Error "MySQLite module not found. Please install it first: Install-Module MySQLite"
        exit 1
    }
    
    Import-Module MySQLite -ErrorAction Stop
    
    Write-Host "Dropping existing view..." -ForegroundColor Yellow
    
    # Drop the existing view
    $dropViewQuery = "DROP VIEW IF EXISTS CattleWithLatestWeight;"
    Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query $dropViewQuery
    
    Write-Host "Creating updated view with PurchaseDate..." -ForegroundColor Yellow
    
    # Recreate the view with PurchaseDate included
    $createViewQuery = @"
CREATE VIEW CattleWithLatestWeight AS
SELECT 
    c.CattleID,
    c.TagNumber,
    c.OriginFarm,
    c.Name,
    c.Breed,
    c.Gender,
    c.BirthDate,
    c.PurchaseDate,
    c.Location,
    c.Owner,
    c.PricePerDay,
    c.Status,
    w.WeightDate AS LatestWeightDate,
    w.Weight AS LatestWeight,
    w.WeightUnit
FROM Cattle c
LEFT JOIN (
    SELECT CattleID, WeightDate, Weight, WeightUnit,
           ROW_NUMBER() OVER (PARTITION BY CattleID ORDER BY WeightDate DESC) as rn
    FROM WeightRecords
) w ON c.CattleID = w.CattleID AND w.rn = 1;
"@
    
    Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query $createViewQuery
    
    Write-Host "✓ View updated successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "The CattleWithLatestWeight view now includes PurchaseDate." -ForegroundColor White
    Write-Host "Invoice generation should now work correctly." -ForegroundColor White
    Write-Host ""
    Write-Host "Note: Restart your PowerShell Universal dashboard to pick up the changes." -ForegroundColor Yellow
}
catch {
    Write-Error "Fix failed: $($_.Exception.Message)"
    Write-Error $_.ScriptStackTrace
    exit 1
}





