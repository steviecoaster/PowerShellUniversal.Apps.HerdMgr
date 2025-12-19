function Add-HealthRecord {
    <#
    .SYNOPSIS
    Adds a new health record for a cattle
    
    .DESCRIPTION
    Records health-related events, treatments, vaccinations, and veterinary visits for an animal.
    Health records help track medical history and schedule upcoming care.
    
    .PARAMETER CattleID
    Database ID of the cattle receiving care (required)
    
    .PARAMETER RecordDate
    Date the health event occurred (required)
    
    .PARAMETER RecordType
    Type of health record (required). Valid values:
    - Vaccination: Immunization records
    - Treatment: Medical treatments
    - Observation: Health observations or checkups
    - Veterinary Visit: Professional veterinary care
    - Other: Other health-related events
    
    .PARAMETER Title
    Brief title/summary of the health event (required)
    
    .PARAMETER Description
    Detailed description of the treatment, medication, or observation
    
    .PARAMETER VeterinarianName
    Name of the veterinarian who provided care
    
    .PARAMETER Medication
    Name and dosage of medication administered
    
    .PARAMETER Cost
    Cost of the treatment or veterinary visit
    
    .PARAMETER NextDueDate
    Date when follow-up care is needed (for vaccinations or follow-up treatments)
    
    .PARAMETER RecordedBy
    Name of the person who administered treatment or recorded the observation
    
    .PARAMETER Notes
    Additional notes about the health event
    
    .EXAMPLE
    Add-HealthRecord -CattleID 7 -RecordDate (Get-Date) -RecordType "Vaccination" -Title "Annual Vaccine"
    
    Records a basic vaccination event
    
    .EXAMPLE
    Add-HealthRecord -CattleID 12 -RecordDate "2025-12-01" -RecordType "Treatment" -Title "Respiratory Infection" -Description "Treated for respiratory symptoms" -Medication "Antibiotic 10cc IM" -VeterinarianName "Dr. Sarah Johnson" -Cost 75.00 -NextDueDate "2025-12-10" -RecordedBy "John Smith"
    
    Records a complete treatment with full details
    
    .NOTES
    Follow-up dates automatically create entries in the upcoming health events tracking system.
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
    [Alias('FollowUpDate')]
    [DateTime]
    $NextDueDate,
        
        [Parameter()]
        [string]
        $Notes,
        
    [Parameter()]
    [Alias('PerformedBy')]
    [ValidateSet('Brandon','Jerry','Stephanie')]
    [string]
    $RecordedBy
    )
    
    # Convert values to SQL-safe representations
    $cattleIdValue = ConvertTo-SqlValue -Value $CattleID
    $recordDateValue = ConvertTo-SqlValue -Value $RecordDate
    $recordTypeValue = ConvertTo-SqlValue -Value $RecordType
    $titleValue = ConvertTo-SqlValue -Value $Title
    $descriptionValue = ConvertTo-SqlValue -Value $Description
    $vetValue = ConvertTo-SqlValue -Value $VeterinarianName
    $medValue = ConvertTo-SqlValue -Value $Medication
    $dosageValue = ConvertTo-SqlValue -Value $Dosage
    $costValue = ConvertTo-SqlValue -Value $Cost
    $nextDueValue = ConvertTo-SqlValue -Value $NextDueDate
    $notesValue = ConvertTo-SqlValue -Value $Notes
    $recordedByValue = ConvertTo-SqlValue -Value $RecordedBy

    $query = "INSERT INTO HealthRecords (CattleID, RecordDate, RecordType, Title, Description, VeterinarianName, Medication, Dosage, Cost, NextDueDate, Notes, RecordedBy) VALUES ($cattleIdValue, $recordDateValue, $recordTypeValue, $titleValue, $descriptionValue, $vetValue, $medValue, $dosageValue, $costValue, $nextDueValue, $notesValue, $recordedByValue)"

    try {
        Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $query
        Write-Verbose "Health record added for CattleID $CattleID on $(Format-Date $RecordDate)"
    }
    catch {
        throw $_
    }
}






