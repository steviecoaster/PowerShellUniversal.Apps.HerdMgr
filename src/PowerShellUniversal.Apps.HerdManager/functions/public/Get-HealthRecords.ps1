function Get-HealthRecords {
    <#
    .SYNOPSIS
    Gets health records for a specific cattle or all cattle
    
    .DESCRIPTION
    Retrieves health records from the database with optional filtering by cattle ID
    and/or record type. Returns records in descending date order (most recent first).
    
    .PARAMETER CattleID
    Filter to health records for a specific animal
    
    .PARAMETER RecordType
    Filter by type of health record. Valid values:
    - Vaccination
    - Treatment
    - Observation
    - Veterinary Visit
    - Other
    
    .OUTPUTS
    Health records with properties:
    HealthRecordID, CattleID, TagNumber, CattleName, RecordDate, RecordType,
    Title, Description, VeterinarianName, Medication, Cost, NextDueDate,
    PerformedBy, Notes
    
    .EXAMPLE
    Get-HealthRecords -CattleID 7
    
    Returns all health records for cattle ID 7
    
    .EXAMPLE
    Get-HealthRecords -RecordType "Vaccination"
    
    Returns all vaccination records across all cattle
    
    .EXAMPLE
    Get-HealthRecords -CattleID 12 -RecordType "Treatment"
    
    Returns only treatment records for cattle ID 12
    
    .EXAMPLE
    Get-HealthRecords | Where-Object { $_.Cost -gt 100 }
    
    Returns all health records with cost over $100
    
    .NOTES
    Records are joined with cattle information to include TagNumber and Name.
    Results are ordered by RecordDate DESC (newest first).
    #>
    param(
        [Parameter()]
        [int]
        $CattleID,

        [Parameter()]
        [ValidateSet('Vaccination', 'Treatment', 'Observation', 'Veterinary Visit', 'Other')]
        [string]
        $RecordType
    )
    
    $query = "SELECT hr.HealthRecordID, hr.CattleID, c.TagNumber, c.Name as CattleName, hr.RecordDate, hr.RecordType, hr.Title, hr.Description, hr.VeterinarianName, hr.Medication, hr.Dosage, hr.Cost, hr.NextDueDate, hr.Notes, hr.RecordedBy, hr.CreatedDate FROM HealthRecords hr INNER JOIN Cattle c ON hr.CattleID = c.CattleID WHERE 1=1"
    
    if ($CattleID) {
        $query += " AND hr.CattleID = $CattleID"
    }
    
    if ($RecordType) {
        $recordTypeValue = ConvertTo-SqlValue -Value $RecordType
        $query += " AND hr.RecordType = $recordTypeValue"
    }
    
    $query += " ORDER BY hr.RecordDate DESC, hr.CreatedDate DESC"
    
    Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $query
}






