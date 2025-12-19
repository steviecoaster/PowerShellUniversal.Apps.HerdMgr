Describe 'Set-SystemInfo' {
    It 'exposes an Established parameter when the module is loaded from source' {
        $manifest = Join-Path $PSScriptRoot '..\src\PowerShellUniversal.Apps.HerdManager\PowerShellUniversal.Apps.HerdManager.psd1'

        # Import module from source so test validates source signatures
        Import-Module -Force $manifest

        (Get-Command Set-SystemInfo).Parameters.Keys | Should -Contain 'Established'
    }
}
