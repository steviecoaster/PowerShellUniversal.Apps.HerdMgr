Describe 'Set-SystemInfo Established handling' {
    BeforeAll {
        # Load module from source to ensure we're testing the current implementation
        Import-Module -Force "$PSScriptRoot\..\src\PowerShellUniversal.Apps.HerdManager\PowerShellUniversal.Apps.HerdManager.psd1"
    }

    It 'accepts a 4-digit year string and stores it as Jan 1 of that year' {
        Set-SystemInfo -Established '1999' | Out-Null
        (Parse-Date (Get-SystemInfo).Established).Year | Should -Be 1999
    }

    It 'accepts an integer year and stores it as Jan 1 of that year' {
        Set-SystemInfo -Established 2001 | Out-Null
        (Parse-Date (Get-SystemInfo).Established).Year | Should -Be 2001
    }

    It 'accepts a date string and stores the same year' {
        Set-SystemInfo -Established '2002-05-06' | Out-Null
        (Parse-Date (Get-SystemInfo).Established).Year | Should -Be 2002
    }

    It 'accepts an array with a year string as the first element' {
        Set-SystemInfo -Established @('2003') | Out-Null
        (Parse-Date (Get-SystemInfo).Established).Year | Should -Be 2003
    }

    It 'accepts an array with a DateTime as the first element' {
        Set-SystemInfo -Established @([DateTime]'2004-05-06') | Out-Null
        (Parse-Date (Get-SystemInfo).Established).Year | Should -Be 2004
    }
}
