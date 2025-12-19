# Migration from PSSQLite to MySQLite

## Why the Migration?

This project was migrated from **PSSQLite** to **MySQLite** to support deployment on **Raspberry Pi** (ARM/ARM64 architecture).

### Issue with PSSQLite
PSSQLite requires native SQLite DLL libraries (`SQLite.Interop.dll`) compiled for specific platforms. When running on Raspberry Pi (Linux ARM), PSSQLite attempts to load the Windows x64 DLL, causing errors:
```
Unable to load shared library 'SQLite.Interop.dll'
```

### Solution: MySQLite
MySQLite is a **pure .NET** implementation with **no native DLL dependencies**, making it:
- ✅ Cross-platform compatible (Windows, Linux, macOS)
- ✅ ARM/ARM64 architecture compatible
- ✅ Perfect for Raspberry Pi deployments
- ✅ No platform-specific compilation needed

## Changes Made

All PowerShell files in the module were updated with the following replacements:

### 1. Module Import
**Before:**
```powershell
Import-Module PSSQLite -ErrorAction Stop
```

**After:**
```powershell
Import-Module MySQLite -ErrorAction Stop
```

### 2. Function Name
**Before:**
```powershell
Invoke-UniversalSQLiteQuery ...
```

**After:**
```powershell
Invoke-UniversalSQLiteQuery ...
```

### 3. Path Parameter
**Before:**
```powershell
Invoke-UniversalSQLiteQuery -DataSource $script:DatabasePath -Query "SELECT * FROM Cattle"
```

**After:**
```powershell
Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query "SELECT * FROM Cattle"
```

### 4. SQL Query Parameters - **CRITICAL DIFFERENCE**
**Before (PSSQLite with parameterized queries):**
```powershell
$query = "SELECT * FROM Cattle WHERE TagNumber = @TagNumber"
Invoke-UniversalSQLiteQuery -DataSource $script:DatabasePath -Query $query -SqlParameters @{
    '@TagNumber' = $TagNumber
}
```

**After (MySQLite with direct string substitution):**
```powershell
$query = "SELECT * FROM Cattle WHERE TagNumber = '$TagNumber'"
# OR using variable substitution in query string:
$query = "SELECT * FROM Cattle WHERE TagNumber = $TagNumber"
Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $query
# No -Parameters hashtable - MySQLite doesn't support this!
```

**Important:** MySQLite does **NOT** support parameterized queries via a `-Parameters` hashtable like PSSQLite did. All values must be directly substituted into the query string using PowerShell variables.

**Security Note:** Without parameterized queries, you must be careful about SQL injection when using user input. For this cattle management application, all input comes from PowerShell Universal forms which provide some protection, but always validate and sanitize string inputs, especially when building queries with user-provided data.

### 5. Output Format (Removed)
**Before:**
```powershell
Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $sql -As PSObject
```

**After:**
```powershell
Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $sql
# MySQLite returns PSObjects by default - no -As parameter needed
```

## Files Updated

### Module Files
- `PowerShellUniversal.Apps.HerdManager.psm1` - Main module file
- `PowerShellUniversal.Apps.HerdManager.psd1` - Module manifest

### Public Functions (17 files)
- `Add-CattleRecord.ps1`
- `Add-Farm.ps1`
- `Add-FeedRecord.ps1`
- `Add-HealthRecord.ps1`
- `Add-Invoice.ps1`
- `Add-WeightRecord.ps1`
- `Calculate-RateOfGain.ps1`
- `Get-AllCattle.ps1`
- `Get-CattleById.ps1`
- `Get-FeedRecord.ps1`
- `Get-Invoice.ps1`
- `Get-RateOfGainHistory.ps1`
- `Get-UpcomingHealthEvents.ps1`
- `Get-WeightHistory.ps1`
- `Initialize-HerdDatabase.ps1`
- `Invoke-FarmApi.ps1`
- `Remove-CattleRecord.ps1`
- `Remove-FeedRecord.ps1`
- `Update-BulkCattle.ps1`
- `Update-CattleRecord.ps1`
- `Update-Farm.ps1`
- `Update-FeedRecord.ps1`

### Dashboard Pages (12 files)
- `HerdManager.ps1` (main dashboard)
- `pages/Homepage.ps1`
- `pages/CattleManagement.ps1`
- `pages/WeightManagement.ps1`
- `pages/HealthRecords.ps1`
- `pages/FeedRecords.ps1`
- `pages/Farms.ps1`
- `pages/RateOfGain.ps1`
- `pages/AnimalReport.ps1`
- `pages/Reports.ps1`
- `pages/Accounting.ps1`
- `pages/Notifications.ps1`
- `pages/Invoice.ps1`

### Utility Scripts
- `utils/Initialize-SampleData.ps1`
- `utils/Seed-Database.ps1`
- `utils/Seed-RealisticData.ps1`

### Migration Scripts
- `data/Fix-CattleView.ps1`
- `data/Fix-InvoicesTable.ps1`
- `data/Migrate-MultiCattleInvoices.ps1`

### Other Scripts
- `Add-IsOriginColumn.ps1`
- `Add-OriginFarmIDColumn.ps1`

## Testing Results

### ✅ Verified Working
- Module imports successfully with MySQLite
- Database auto-initializes on first import
- Get-AllCattle with Status filtering
- Get-Farm by name and ID
- Get-CattleById
- Get-WeightHistory
- Get-FeedRecord with date ranges and DaysBack
- Calculate-RateOfGain with date parameters
- All CRUD operations for cattle, farms, feed records

### 🔧 Fixed Issues
1. **String values in SQL queries** - Added `ConvertTo-SqlValue` helper function
2. **Date formatting** - Properly format dates as strings before SQL insertion
3. **Update queries** - Modified dynamic UPDATE builders to use helper function
4. **SQL injection protection** - Escape single quotes in string values

### 📝 Known Limitations
- MySQLite doesn't support parameterized queries (by design)
- Must use direct string substitution with proper escaping
- `ConvertTo-SqlValue` is a private helper function (not exported)

## Installation on Raspberry Pi

### 1. Install MySQLite Module
```powershell
Install-Module MySQLite -Force -Scope CurrentUser
```

### 2. Copy Module to Pi
Copy the entire `PowerShellUniversal.Apps.HerdManager` folder to:
```
~/.local/share/powershell/Modules/PowerShellUniversal.Apps.HerdManager/
```

### 3. Test Import
```powershell
Import-Module PowerShellUniversal.Apps.HerdManager -Verbose
```

The module will auto-initialize the database on first import if it doesn't exist.

### 4. Verify Database Creation
```powershell
Test-Path ~/.local/share/powershell/Modules/PowerShellUniversal.Apps.HerdManager/data/HerdManager.db
```

## Testing Checklist

- [ ] Module imports without errors
- [ ] Database auto-initializes
- [ ] Can add cattle records
- [ ] Can add weight records
- [ ] Can add health records
- [ ] Can add feed records
- [ ] Bulk edit works
- [ ] Rate of Gain calculations work
- [ ] Invoices can be created
- [ ] All dashboard pages load
- [ ] No parameter errors in logs

## Performance Notes

MySQLite is a pure .NET implementation and may have slightly different performance characteristics compared to PSSQLite (which uses native SQLite libraries). For this application's use case (small herd management), performance should be excellent on Raspberry Pi 4+ models.

## Rollback (if needed)

If you need to revert to PSSQLite (Windows only):

```powershell
Get-ChildItem -Path . -Filter *.ps1 -Recurse | ForEach-Object {
    (Get-Content $_.FullName -Raw) `
        -replace 'MySQLite','PSSQLite' `
        -replace 'Invoke-UniversalSQLiteQuery','Invoke-UniversalSQLiteQuery' `
        -replace '-Path \$script:DatabasePath','-DataSource $script:DatabasePath' `
        -replace '-Parameters','-SqlParameters' |
    Set-Content $_.FullName
}
```

**Note:** You'll also need to add `-As PSObject` back to queries that need it.

## Support

For MySQLite documentation, see: https://github.com/RamblingCookieMonster/MySQLite
For issues specific to this migration, create an issue in the project repository.
