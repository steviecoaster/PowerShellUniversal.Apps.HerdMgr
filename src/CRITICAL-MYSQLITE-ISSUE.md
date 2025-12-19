# CRITICAL MySQLite Issue Found

## Problem
MySQLite does NOT support parameterized queries. When using direct PowerShell variable substitution in SQL queries, **string values MUST be quoted**.

## Current State
The bulk replacements changed:
```powershell
# Before (PSSQLite with parameters)
WHERE Status = @Status
# Became
WHERE Status = $Status  ❌ WRONG - produces: WHERE Status = Active
```

## Required Fix
String variables need single quotes:
```powershell
WHERE Status = '$Status'  ✅ CORRECT - produces: WHERE Status = 'Active'
```

## Testing Results

### ✅ What Works
- Module imports successfully with MySQLite
- Database auto-creates on first import
- Basic queries work with numeric values: `WHERE CattleID = $CattleID`

### ❌ What's Broken
- **ALL string comparisons fail** because values aren't quoted
- Example error: `no such column: Active` (SQL thinks Active is a column name)

## Files Affected
Potentially **ALL** query files that compare string values:
- Get-AllCattle.ps1 - `WHERE Status = $Status` needs `WHERE Status = '$Status'`
- Get-CattleById.ps1 - May have TagNumber comparisons
- Get-Farm.ps1 - `WHERE FarmName = $FarmName` needs quotes
- Get-Invoice.ps1 - `WHERE InvoiceNumber = $InvoiceNumber` needs quotes
- Get-HealthRecords.ps1 - RecordType comparisons need quotes
- And many more...

## Variable Types That Need Quotes
- ✅ **Need quotes:** String values (Status, Name, TagNumber, InvoiceNumber, RecordType, etc.)
- ❌ **No quotes:** Numeric values (CattleID, FarmID, quantities, prices, dates in proper format)

## Recommended Action
1. **Do NOT waste time** - this needs systematic fixing
2. Need to review EVERY query and add quotes around string variables
3. Consider using a function to escape strings properly
4. Test each function after fixing

## Alternative Solutions

### Option 1: Manual Quoting (Current Need)
```powershell
$query = "SELECT * FROM Cattle WHERE Status = '$Status' AND Owner = '$Owner'"
```
**Pros:** Simple, straightforward
**Cons:** Risk of SQL injection if not careful

### Option 2: Use Double-Quoting for Safety
```powershell
$query = "SELECT * FROM Cattle WHERE TagNumber = ""$TagNumber"""
```
**Pros:** More visible in code
**Cons:** Harder to read

### Option 3: Escape Function
```powershell
function ConvertTo-SqlString {
    param($Value)
    if ($Value -is [string]) {
        return "'$($Value -replace "'", "''")'"
    }
    return $Value
}
$query = "SELECT * FROM Cattle WHERE Status = $(ConvertTo-SqlString $Status)"
```
**Pros:** Handles SQL injection (escapes single quotes)
**Cons:** More complex

## Security Note
Without parameterized queries, we're vulnerable to SQL injection. For example:
```powershell
$TagNumber = "'; DROP TABLE Cattle; --"
$query = "SELECT * FROM Cattle WHERE TagNumber = '$TagNumber'"
# Results in: SELECT * FROM Cattle WHERE TagNumber = ''; DROP TABLE Cattle; --'
```

**Recommendation:** Create a SQL string escaping function that replaces `'` with `''`

## Next Steps
1. ✅ Verified MySQLite works with proper syntax
2. ❌ Found critical quoting issue in all string comparisons
3. ⏳ Need to systematically fix ALL query files
4. ⏳ Should add SQL escaping function for security
5. ⏳ Need comprehensive testing after fixes

**Estimated Effort:** 2-3 hours to fix all queries properly
