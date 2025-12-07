function Add-HealthRecord {
    <#
    .SYNOPSIS
    Adds a new health record for a cattle
    #>
    param(
        [Parameter(Mandatory)]
        [int]
        $CattleID,

        [Parameter(Mandatory)]
        [DateTime]
        $RecordDate,

        [Parameter(Mandatory)]
        [ValidateSet('Vaccination', 'Treatment', 'Observation', 'Veterinary Visit', 'Other')]
        [string]
        $RecordType,

        [Parameter(Mandatory)]
        [string]
        $Title,

        [Parameter()]
        [string]
        $Description,

        [Parameter()]
        [string]
        $VeterinarianName,

        [Parameter()]
        [string]
        $Medication,

        [Parameter()]
        [string]
        $Dosage,

        [Parameter()]
        [decimal]
        $Cost,
        
        [Parameter()]
        [DateTime]
        $NextDueDate,
        
        [Parameter()]
        [string]
        $Notes,
        
        [Parameter()]
        [ValidateSet('Brandon','Jerry','Stephanie')]
        [string]
        $RecordedBy
    )
    
    $query = @"
INSERT INTO HealthRecords (CattleID, RecordDate, RecordType, Title, Description, VeterinarianName, Medication, Dosage, Cost, NextDueDate, Notes, RecordedBy)
VALUES (@CattleID, @RecordDate, @RecordType, @Title, @Description, @VeterinarianName, @Medication, @Dosage, @Cost, @NextDueDate, @Notes, @RecordedBy)
"@
    
    $params = @{
        DataSource = $script:DatabasePath
        Query = $query
        SqlParameters = @{
            CattleID = $CattleID
            RecordDate = $RecordDate
            RecordType = $RecordType
            Title = $Title
            Description = $Description
            VeterinarianName = $VeterinarianName
            Medication = $Medication
            Dosage = $Dosage
            Cost = $Cost
            NextDueDate = $NextDueDate
            Notes = $Notes
            RecordedBy = $RecordedBy
        }
    }
    
    Invoke-SqliteQuery @params
}
