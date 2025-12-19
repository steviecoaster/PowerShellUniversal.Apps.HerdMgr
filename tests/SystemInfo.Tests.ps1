Describe 'SystemInfo functions' {
    It 'inserts a single SystemInfo row and updates single-row invariant' {
        $db = Join-Path $env:TEMP 'gr_sysinfo_test.db'
        if (Test-Path $db) { Remove-Item $db -Force }

        Initialize-HerdDatabase -DatabasePath $db | Out-Null

        $countRow = Invoke-UniversalSQLiteQuery -Path $db -Query "SELECT COUNT(*) AS cnt FROM SystemInfo;"
        $cnt = if ($countRow -and $countRow.Count -gt 0) { [int]$countRow[0].cnt } else { 0 }
        $cnt | Should -Be 0

        Set-SystemInfo -DatabasePath $db -FarmName 'Test Farm' -PhoneNumber '111-1111' -DefaultCurrency 'GBP' -Established '2001' -Notes 'initial' | Out-Null

        $countRow = Invoke-UniversalSQLiteQuery -Path $db -Query "SELECT COUNT(*) AS cnt FROM SystemInfo;"
        $cnt = [int]$countRow[0].cnt
        $cnt | Should -Be 1

        $sys = Get-SystemInfo -DbPath $db
        if ($sys -is [System.Array]) { $sys = $sys[0] }
        $sys.FarmName | Should -Be 'Test Farm'
        $sys.DefaultCurrency | Should -Be 'GBP'
        # If DefaultCulture inference works it should be en-GB
        $sys.DefaultCulture | Should -Be 'en-GB'

        # Update a field and ensure still one row
        Set-SystemInfo -DatabasePath $db -PhoneNumber '999-9999' | Out-Null
        $countRow = Invoke-UniversalSQLiteQuery -Path $db -Query "SELECT COUNT(*) AS cnt FROM SystemInfo;"; $cnt = [int]$countRow[0].cnt
        $cnt | Should -Be 1
        $sys2 = Get-SystemInfo -DbPath $db
        if ($sys2 -is [System.Array]) { $sys2 = $sys2[0] }
        $sys2.PhoneNumber | Should -Be '999-9999'

        # Insert duplicate row manually
        Invoke-UniversalSQLiteQuery -Path $db -Query "INSERT INTO SystemInfo (FarmName, CreatedDate, ModifiedDate) VALUES ('Dup', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);"
        $countRow = Invoke-UniversalSQLiteQuery -Path $db -Query "SELECT COUNT(*) AS cnt FROM SystemInfo;"; $cnt = [int]$countRow[0].cnt
        $cnt | Should -BeGreaterThan 1

        # Trigger collapse via update
        Set-SystemInfo -DatabasePath $db -Notes 'collapsed' | Out-Null
        $countRow = Invoke-UniversalSQLiteQuery -Path $db -Query "SELECT COUNT(*) AS cnt FROM SystemInfo;"; $cnt = [int]$countRow[0].cnt
        $cnt | Should -Be 1

        $sys3 = Get-SystemInfo -DbPath $db
        if ($sys3 -is [System.Array]) { $sys3 = $sys3[0] }
        $sys3.Notes | Should -Be 'collapsed'

        # Clear
        Clear-SystemInfo -Force -DatabasePath $db | Out-Null
        $countRow = Invoke-UniversalSQLiteQuery -Path $db -Query "SELECT COUNT(*) AS cnt FROM SystemInfo;"; $cnt = [int]$countRow[0].cnt
        $cnt | Should -Be 0

        Remove-Item $db -Force -ErrorAction SilentlyContinue
    }
}
