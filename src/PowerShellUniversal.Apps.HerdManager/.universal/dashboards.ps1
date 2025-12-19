$app = @{
    Name        = "Herd Manager"
    BaseUrl     = '/herdmanager'
    Module      = 'PowerShellUniversal.Apps.HerdManagement'
    Command     = 'New-UDHerdManagerApp'
    AutoDeploy  = $true
    Description = "A cattle management app for PowerShell Universal"
    Environment = 'PowerShell 7'
}

New-PSUApp @app



