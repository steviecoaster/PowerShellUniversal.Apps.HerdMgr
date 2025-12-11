function Add-WeightRecord {
    <#
    .SYNOPSIS
    Adds a weight measurement for a specific animal
    
    .DESCRIPTION
    Records a weight measurement for tracking animal growth over time.
    Weight records are used to calculate rate of gain and monitor animal health.
    
    .PARAMETER CattleID
    Database ID of the cattle being weighed (required)
    
    .PARAMETER WeightDate
    Date the weight measurement was taken (required)
    
    .PARAMETER Weight
    Weight value (required). Unit is specified by WeightUnit parameter
    
    .PARAMETER WeightUnit
    Unit of measurement for the weight. Valid values: 'lbs' or 'kg'. Default is 'lbs'
    
    .PARAMETER MeasurementMethod
    Method used to obtain the weight (e.g., 'Scale', 'Visual Estimate', 'Tape Measure')
    
    .PARAMETER RecordedBy
    Name of the person who recorded the weight
    
    .PARAMETER Notes
    Additional notes about the measurement or animal condition
    
    .EXAMPLE
    Add-WeightRecord -CattleID 5 -WeightDate (Get-Date) -Weight 850
    
    Records a weight of 850 lbs for cattle ID 5 on today's date
    
    .EXAMPLE
    Add-WeightRecord -CattleID 12 -WeightDate "2025-12-01" -Weight 385 -WeightUnit "kg" -MeasurementMethod "Scale" -RecordedBy "John Smith" -Notes "Healthy weight gain"
    
    Records a detailed weight measurement with all tracking information
    
    .NOTES
    Weight records are essential for calculating Average Daily Gain (ADG) and monitoring herd performance.
    Multiple weight records over time create a growth history for each animal.
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