# Seed Realistic Data for Herd Manager
# This script populates the database with several months of realistic data

$DatabasePath = "$PSScriptRoot\PowerShellUniversal.Apps.HerdManager\data\HerdManager.db"

Write-Host "Seeding database with realistic data..." -ForegroundColor Green

# Import the module
Import-Module "$PSScriptRoot\PowerShellUniversal.Apps.HerdManager\PowerShellUniversal.Apps.HerdManagement.psm1" -Force

# Origin Farms
$farms = @(
    'Maple Ridge Farm'
    'Sunset Valley Ranch'
    'Green Acres'
    'Cedar Creek Farm'
    'Rolling Hills Ranch'
)

# Common breeds
$breeds = @(
    'Angus'
    'Hereford'
    'Simmental'
    'Charolais'
    'Red Angus'
    'Black Baldy'
    $null  # Some cattle don't have breed recorded
)

# Names (optional - about 60% have names)
$names = @(
    'Bessie', 'Daisy', 'Buttercup', 'Clover', 'Rosie', 'Lily', 'Bella'
    'Duke', 'Buck', 'Tank', 'Chief', 'Thor', 'Rex', 'Max'
    'Blaze', 'Shadow', 'Storm', 'Rocky', 'Buster', 'Scout'
    $null, $null, $null, $null, $null  # 40% don't have names
)

# Create 30 cattle with historical data
Write-Host "Creating cattle records..." -ForegroundColor Yellow

$cattleIds = @()
$baseDate = (Get-Date).AddMonths(-6)  # Start 6 months ago

for ($i = 1; $i -le 30; $i++) {
    $tagNumber = "BR-$(Get-Random -Minimum 1000 -Maximum 9999)"
    $originFarm = $farms | Get-Random
    $breed = $breeds | Get-Random
    $gender = @('Steer', 'Heifer') | Get-Random
    $name = $names | Get-Random
    $birthDate = $baseDate.AddDays(-(Get-Random -Minimum 180 -Maximum 540))  # 6-18 months old
    $purchaseDate = $baseDate.AddDays(-(Get-Random -Minimum 1 -Maximum 60))
    
    # 90% active, some sold or transferred
    $status = if ($i -le 27) { 'Active' } elseif ($i -eq 28) { 'Sold' } else { 'Transferred' }
    
    $params = @{
        TagNumber    = $tagNumber
        OriginFarm   = $originFarm
        Gender       = $gender
        BirthDate    = $birthDate.ToString('yyyy-MM-dd')
        PurchaseDate = $purchaseDate.ToString('yyyy-MM-dd')
    }
    
    if ($breed) { $params['Breed'] = $breed }
    if ($name) { $params['Name'] = $name }
    
    try {
        Add-CattleRecord @params
        $cattle = Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query "SELECT CattleID FROM Cattle WHERE TagNumber = '$tagNumber'"
        
        # Update status if not Active
        if ($status -ne 'Active') {
            Update-CattleRecord -CattleID $cattle.CattleID -Status $status
        }
        
        $cattleIds += [PSCustomObject]@{
            CattleID   = $cattle.CattleID
            TagNumber  = $tagNumber
            Status     = $status
            Name       = $name
            Gender     = $gender
            OriginFarm = $originFarm
        }
        Write-Host "  Created: $tagNumber ($name) [$status]" -ForegroundColor Gray
    } catch {
        Write-Host "  Error creating $tagNumber : $_" -ForegroundColor Red
    }
}

Write-Host "`nCreating weight records over time..." -ForegroundColor Yellow

# Add weight records for each active cattle over the past 6 months
foreach ($cattle in ($cattleIds | Where-Object { $_.Status -eq 'Active' })) {
    # Initial weight (lighter, 400-600 lbs)
    $currentWeight = Get-Random -Minimum 400 -Maximum 600
    $currentDate = $baseDate
    
    # Record weights monthly with realistic daily gains (1.5-3.5 lbs/day)
    for ($month = 0; $month -le 6; $month++) {
        $weightDate = $currentDate.AddMonths($month)
        
        # Skip future dates
        if ($weightDate -gt (Get-Date)) { break }
        
        # Add some randomness to weight gain
        $dailyGain = Get-Random -Minimum 1.5 -Maximum 3.5
        $daysElapsed = if ($month -eq 0) { 0 } else { 30 }
        $currentWeight += ($dailyGain * $daysElapsed)
        
        $method = @('Scale', 'Scale', 'Scale', 'Tape Measure') | Get-Random  # Mostly scale
        $recordedBy = @('Brandon', 'Jerry', 'Stephanie') | Get-Random
        
        Add-WeightRecord -CattleID $cattle.CattleID -WeightDate $weightDate.ToString('yyyy-MM-dd') `
            -Weight ([Math]::Round($currentWeight, 2)) -MeasurementMethod $method -RecordedBy $recordedBy
    }
    
    Write-Host "  Added weight history for $($cattle.TagNumber)" -ForegroundColor Gray
}

Write-Host "`nCalculating rate of gain for all cattle..." -ForegroundColor Yellow

# Calculate ROG for all active cattle between various date ranges
foreach ($cattle in ($cattleIds | Where-Object { $_.Status -eq 'Active' })) {
    # Get their weight records
    $weights = Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query @"
SELECT WeightRecordID, WeightDate, Weight 
FROM WeightRecords 
WHERE CattleID = $($cattle.CattleID)
ORDER BY WeightDate
"@
    
    if ($weights.Count -ge 2) {
        # Calculate ROG for consecutive periods
        for ($i = 0; $i -lt ($weights.Count - 1); $i++) {
            try {
                Measure-RateOfGain -CattleID $cattle.CattleID `
                    -StartDate $weights[$i].WeightDate `
                    -EndDate $weights[$i + 1].WeightDate | Out-Null
            } catch {
                # Skip if already calculated
            }
        }
        Write-Host "  Calculated ROG for $($cattle.TagNumber)" -ForegroundColor Gray
    }
}

Write-Host "`nAdding health records..." -ForegroundColor Yellow

# Add various health records for cattle
$healthEventTypes = @(
    @{Type = 'Vaccination'; Title = 'Initial Vaccination - Modified Live Virus'; Medication = 'Bovi-Shield Gold 5'; Cost = 12.50}
    @{Type = 'Vaccination'; Title = 'Clostridial Vaccination'; Medication = 'Vision 7 with SPUR'; Cost = 8.75}
    @{Type = 'Vaccination'; Title = 'Booster Shot - MLV'; Medication = 'Bovi-Shield Gold 5'; Cost = 12.50}
    @{Type = 'Treatment'; Title = 'Deworming Treatment'; Medication = 'Ivermectin Pour-On'; Cost = 6.50}
    @{Type = 'Treatment'; Title = 'Antibiotic Treatment - Respiratory'; Medication = 'Draxxin'; Cost = 45.00}
    @{Type = 'Treatment'; Title = 'Foot Rot Treatment'; Medication = 'LA-200'; Cost = 18.50}
    @{Type = 'Observation'; Title = 'Routine Health Check'; Medication = $null; Cost = 0}
    @{Type = 'Observation'; Title = 'Slight Limp - Monitoring'; Medication = $null; Cost = 0}
    @{Type = 'Veterinary Visit'; Title = 'Herd Health Inspection'; Medication = $null; Cost = 150.00}
)

$recordedByPeople = @('Brandon', 'Jerry', 'Stephanie')

# Add 3-8 health records per active cattle
foreach ($cattle in ($cattleIds | Where-Object { $_.Status -eq 'Active' } | Select-Object -First 20)) {
    $numRecords = Get-Random -Minimum 3 -Maximum 8
    
    for ($i = 0; $i -lt $numRecords; $i++) {
        $healthEvent = $healthEventTypes | Get-Random
        $recordDate = $baseDate.AddDays((Get-Random -Minimum 1 -Maximum 180))
        
        # Skip future dates
        if ($recordDate -gt (Get-Date)) { continue }
        
        $params = @{
            CattleID    = $cattle.CattleID
            RecordDate  = $recordDate.ToString('yyyy-MM-dd')
            RecordType  = $healthEvent.Type
            Title       = $healthEvent.Title
            Description = "Routine $($healthEvent.Type.ToLower()) as part of herd health program"
            RecordedBy  = $recordedByPeople | Get-Random
        }
        
        if ($healthEvent.Medication) { 
            $params['Medication'] = $healthEvent.Medication 
            $params['Dosage'] = "Per label instructions"
        }
        if ($healthEvent.Cost -gt 0) { $params['Cost'] = $healthEvent.Cost }
        
        # Add NextDueDate for vaccinations (21-30 days out)
        if ($healthEvent.Type -eq 'Vaccination') {
            $nextDue = $recordDate.AddDays((Get-Random -Minimum 21 -Maximum 30))
            if ($nextDue -le (Get-Date).AddDays(60)) {  # Only if in near future
                $params['NextDueDate'] = $nextDue.ToString('yyyy-MM-dd')
            }
        }
        
        try {
            Add-HealthRecord @params
        } catch {
            Write-Host "  Error adding health record: $_" -ForegroundColor Red
        }
    }
    
    Write-Host "  Added health records for $($cattle.TagNumber)" -ForegroundColor Gray
}

# Add some upcoming health events
Write-Host "`nAdding upcoming health events..." -ForegroundColor Yellow

$upcomingCattle = $cattleIds | Where-Object { $_.Status -eq 'Active' } | Select-Object -First 5

foreach ($cattle in $upcomingCattle) {
    $futureDate = (Get-Date).AddDays((Get-Random -Minimum 5 -Maximum 25))
    
    Add-HealthRecord -CattleID $cattle.CattleID `
        -RecordDate (Get-Date).ToString('yyyy-MM-dd') `
        -RecordType 'Vaccination' `
        -Title 'Annual Booster Scheduled' `
        -Medication 'Bovi-Shield Gold 5' `
        -Dosage '2ml SubQ' `
        -Cost 12.50 `
        -NextDueDate $futureDate.ToString('yyyy-MM-dd') `
        -RecordedBy 'Brandon' `
        -Description 'Annual booster vaccination scheduled'
    
    Write-Host "  Scheduled upcoming booster for $($cattle.TagNumber) on $($futureDate.ToString('MM/dd/yyyy'))" -ForegroundColor Gray
}

Write-Host "`n✅ Database seeding complete!" -ForegroundColor Green
Write-Host "`nSummary:" -ForegroundColor Cyan
Write-Host "  - 30 cattle created (27 active, 1 sold, 2 transferred)" -ForegroundColor White
Write-Host "  - ~6 months of weight records per animal" -ForegroundColor White
Write-Host "  - Rate of gain calculations for all periods" -ForegroundColor White
Write-Host "  - 60-160 health records across the herd" -ForegroundColor White
Write-Host "  - Multiple upcoming health events scheduled" -ForegroundColor White




