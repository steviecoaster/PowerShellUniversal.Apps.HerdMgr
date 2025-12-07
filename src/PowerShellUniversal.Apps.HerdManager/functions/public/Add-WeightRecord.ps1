function Add-WeightRecord {
    <#
    .SYNOPSIS
    Adds a weight measurement for a specific animal
    #>
    param(
        [Parameter(Mandatory)]
        [int]$CattleID,
        
        [Parameter(Mandatory)]
        [DateTime]$WeightDate,
        
        [Parameter(Mandatory)]
        [decimal]$Weight,
        
        [ValidateSet('lbs', 'kg')]
        [string]$WeightUnit = 'lbs',
        
        [string]$MeasurementMethod,
        [string]$RecordedBy,
        [string]$Notes
    )
    
    $query = @"
INSERT INTO WeightRecords (CattleID, WeightDate, Weight, WeightUnit, MeasurementMethod, RecordedBy, Notes)
VALUES (@CattleID, @WeightDate, @Weight, @WeightUnit, @MeasurementMethod, @RecordedBy, @Notes)
"@
    
    $params = @{
        DataSource = $script:DatabasePath
        Query = $query
        SqlParameters = @{
            CattleID = $CattleID
            WeightDate = $WeightDate
            Weight = $Weight
            WeightUnit = $WeightUnit
            MeasurementMethod = $MeasurementMethod
            RecordedBy = $RecordedBy
            Notes = $Notes
        }
    }
    
    Invoke-SqliteQuery @params
}