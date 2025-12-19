Describe 'Clear-SystemInfo' {
    It 'Removes existing SystemInfo rows and leaves table empty' {
        # Ensure there is a row
        Set-SystemInfo -FarmName 'TestClear' -DefaultCurrency 'USD' | Out-Null
        $before = (Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query "SELECT COUNT(*) as Count FROM SystemInfo").Count
        $before | Should -BeGreaterThan 0

        # Clear
        Clear-SystemInfo -Force | Out-Null

        $after = (Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query "SELECT COUNT(*) as Count FROM SystemInfo").Count
        $after | Should -Be 0

        # Get-SystemInfo should return $null or empty
        $sys = Get-SystemInfo
        $sys | Should -BeNullOrEmpty
    }
}
