# Fix MySQLite Queries
# MySQLite doesn't support -Parameters hashtable like PSSQLite did
# We need to use direct string substitution in queries

$filesToFix = Get-ChildItem -Path "C:\Users\stephen\Documents\Git\GundyRidgeHerdManager\src" -Filter *.ps1 -Recurse

foreach ($file in $filesToFix) {
    $content = Get-Content $file.FullName -Raw
    $modified = $false
    
    # Remove  from single-line calls
    if ($content -match '-Parameters @\{[^}]+\}') {
        $content = $content -replace '-Parameters @\{[^}]+\}', ''
        $modified = $true
    }
    
    # Remove multi-line -Parameters blocks
    if ($content -match '-Parameters @\{[\s\S]*?\n\s*\}') {
        $content = $content -replace '-Parameters @\{[\s\S]*?\n\s*\}', ''
        $modified = $true
    }
    
    if ($modified) {
        Write-Host "Fixed: $($file.FullName)" -ForegroundColor Green
        Set-Content -Path $file.FullName -Value $content -NoNewline
    }
}

Write-Host "`nNow you need to manually update queries to use string substitution instead of @ParameterName" -ForegroundColor Yellow
Write-Host "Example: WHERE CattleID = $CattleID  -->  WHERE CattleID = $CattleID" -ForegroundColor Yellow
