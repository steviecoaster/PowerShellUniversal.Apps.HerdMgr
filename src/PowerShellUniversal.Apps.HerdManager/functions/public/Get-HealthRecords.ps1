function Get-HealthRecords {
    <#
    .SYNOPSIS
    Gets health records for a specific cattle or all cattle
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
    
    $query = @"
SELECT 
    hr.HealthRecordID,
    hr.CattleID,
    c.TagNumber,
    c.Name as CattleName,
    hr.RecordDate,
    hr.RecordType,
    hr.Title,
    hr.Description,
    hr.VeterinarianName,
    hr.Medication,
    hr.Dosage,
    hr.Cost,
    hr.NextDueDate,
    hr.Notes,
    hr.RecordedBy,
    hr.CreatedDate
FROM HealthRecords hr
INNER JOIN Cattle c ON hr.CattleID = c.CattleID
WHERE 1=1
"@
    
    $sqlParams = @{}
    
    if ($CattleID) {
        $query += " AND hr.CattleID = @CattleID"
        $sqlParams.CattleID = $CattleID
    }
    
    if ($RecordType) {
        $query += " AND hr.RecordType = @RecordType"
        $sqlParams.RecordType = $RecordType
    }
    
    $query += " ORDER BY hr.RecordDate DESC, hr.CreatedDate DESC"
    
    Invoke-SqliteQuery -DataSource $script:DatabasePath -Query $query -SqlParameters $sqlParams -As PSObject
}
