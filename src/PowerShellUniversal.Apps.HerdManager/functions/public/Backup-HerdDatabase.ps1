function Backup-HerdDatabase {
    param(
        [string]$BackupPath = "c:\Backups\HerdManager\HerdManager_$(Get-Date -Format 'yyyyMMdd_HHmmss').db"
    )
    
    $sourcePath = Get-DatabasePath
    
    # Ensure backup directory exists
    $backupDir = Split-Path $BackupPath -Parent
    if (-not (Test-Path $backupDir)) { 
        $null = New-Item -ItemType Directory -Path $backupDir -Force
    }
    
    # Using sqlite3.exe (if installed)
    if (Get-Command sqlite3 -ErrorAction SilentlyContinue) {
        sqlite3 $sourcePath ".backup '$BackupPath'"
        Write-Host "✅ Database backed up to: $BackupPath" -ForegroundColor Green
    }
    
    # Fallback to file copy (works when database is not locked)
    try {
        Copy-Item -Path $sourcePath -Destination $BackupPath -Force
        Write-Host "✅ Database backed up to: $BackupPath" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to backup database: $_"
    }
}