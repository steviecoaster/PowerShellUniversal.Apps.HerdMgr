# Comprehensive Database Seeding Script
# Seeds realistic data directly using SQL

$DatabasePath = "$PSScriptRoot\PowerShellUniversal.Apps.HerdManager\data\HerdManager.db"

Write-Host "Seeding database with 6 months of realistic cattle data..." -ForegroundColor Green
Write-Host "Database: $DatabasePath`n" -ForegroundColor Gray

# Farm names
$farms = @('Maple Ridge Farm', 'Sunset Valley Ranch', 'Green Acres', 'Cedar Creek Farm', 'Rolling Hills Ranch')
$breeds = @('Angus', 'Hereford', 'Simmental', 'Charolais', 'Red Angus', 'Black Baldy', '')
$names = @('Bessie', 'Daisy', 'Buttercup', 'Clover', 'Rosie', 'Lily', 'Bella', 'Duke', 'Buck', 'Tank', 'Chief', 'Thor', 'Rex', 'Max', 'Blaze', 'Shadow', 'Storm', 'Rocky', '', '', '', '')
$recordedBy = @('Brandon', 'Jerry', 'Stephanie')

$baseDate = (Get-Date).AddMonths(-6)

Write-Host "Creating 30 cattle..." -ForegroundColor Yellow

# Create cattle
for ($i = 1; $i -le 30; $i++) {
    $tagNumber = "BR-$(Get-Random -Minimum 1000 -Maximum 9999)"
    $originFarm = $farms | Get-Random
    $breed = $breeds | Get-Random
    $gender = @('Steer', 'Heifer') | Get-Random
    $name = $names | Get-Random
    $birthDate = $baseDate.AddDays(-(Get-Random -Minimum 180 -Maximum 540)).ToString('yyyy-MM-dd')
    $purchaseDate = $baseDate.AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString('yyyy-MM-dd')
    $status = if ($i -le 27) { 'Active' } elseif ($i -eq 28) { 'Sold' } elseif ($i -eq 29) { 'Transferred' } else { 'Active' }
    
    $insertCattle = @"
INSERT INTO Cattle (TagNumber, OriginFarm, Name, Breed, Gender, BirthDate, PurchaseDate, Status)
VALUES ('$tagNumber', '$originFarm', $(if($name){"'$name'"}else{'NULL'}), $(if($breed){"'$breed'"}else{'NULL'}), '$gender', '$birthDate', '$purchaseDate', '$status');
"@
    
    Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query $insertCattle
    Write-Host "  ✓ Created: $tagNumber $(if($name){"($name)"}else{''}) [$status]" -ForegroundColor Gray
}

Write-Host "`nAdding weight records over 6 months..." -ForegroundColor Yellow

# Get all active cattle
$cattle = Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query "SELECT CattleID, TagNumber FROM Cattle WHERE Status = 'Active'"

foreach ($animal in $cattle) {
    # Starting weight (400-600 lbs)
    $currentWeight = Get-Random -Minimum 400 -Maximum 600
    
    # Add 7 weight records (one every month)
    for ($month = 0; $month -le 6; $month++) {
        $weightDate = $baseDate.AddMonths($month)
        
        if ($weightDate -gt (Get-Date)) { break }
        
        # Add realistic daily gain between records
        if ($month -gt 0) {
            $dailyGain = Get-Random -Minimum 1.5 -Maximum 3.5
            $currentWeight += ($dailyGain * 30)
        }
        
        $method = @('Scale', 'Scale', 'Scale', 'Tape Measure') | Get-Random
        $person = $recordedBy | Get-Random
        
        $insertWeight = @"
INSERT INTO WeightRecords (CattleID, WeightDate, Weight, WeightUnit, MeasurementMethod, RecordedBy)
VALUES ($($animal.CattleID), '$($weightDate.ToString('yyyy-MM-dd'))', $([Math]::Round($currentWeight, 2)), 'lbs', '$method', '$person');
"@
        
        Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query $insertWeight
    }
    Write-Host "  ✓ Added weight history for $($animal.TagNumber)" -ForegroundColor Gray
}

Write-Host "`nCalculating Rate of Gain..." -ForegroundColor Yellow

# Calculate ROG for all cattle
foreach ($animal in $cattle) {
    $weights = Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query "SELECT WeightRecordID, WeightDate, Weight FROM WeightRecords WHERE CattleID = $($animal.CattleID) ORDER BY WeightDate"
    
    if ($weights.Count -ge 2) {
        for ($i = 0; $i -lt ($weights.Count - 1); $i++) {
            $w1 = $weights[$i]
            $w2 = $weights[$i + 1]
            
            $startDate = [DateTime]::Parse($w1.WeightDate)
            $endDate = [DateTime]::Parse($w2.WeightDate)
            $days = ($endDate - $startDate).TotalDays
            
            $weightGain = $w2.Weight - $w1.Weight
            $adg = [Math]::Round(($weightGain / $days), 4)
            
            $insertROG = @"
INSERT INTO RateOfGainCalculations 
(CattleID, StartWeightRecordID, EndWeightRecordID, StartDate, EndDate, StartWeight, EndWeight, TotalWeightGain, DaysBetween, AverageDailyGain)
VALUES 
($($animal.CattleID), $($w1.WeightRecordID), $($w2.WeightRecordID), '$($w1.WeightDate)', '$($w2.WeightDate)', $($w1.Weight), $($w2.Weight), $weightGain, $days, $adg);
"@
            
            try {
                Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query $insertROG
            } catch {
                # Skip duplicates
            }
        }
        Write-Host "  ✓ Calculated ROG for $($animal.TagNumber)" -ForegroundColor Gray
    }
}

Write-Host "`nAdding health records..." -ForegroundColor Yellow

# Health event templates
$healthEvents = @(
    @{Type='Vaccination'; Title='Initial Vaccination - Modified Live Virus'; Medication='Bovi-Shield Gold 5'; Cost=12.50}
    @{Type='Vaccination'; Title='Clostridial Vaccination'; Medication='Vision 7 with SPUR'; Cost=8.75}
    @{Type='Vaccination'; Title='Booster Shot - MLV'; Medication='Bovi-Shield Gold 5'; Cost=12.50}
    @{Type='Treatment'; Title='Deworming Treatment'; Medication='Ivermectin Pour-On'; Cost=6.50}
    @{Type='Treatment'; Title='Antibiotic Treatment - Respiratory'; Medication='Draxxin'; Cost=45.00}
    @{Type='Observation'; Title='Routine Health Check'; Medication=''; Cost=0}
    @{Type='Veterinary Visit'; Title='Herd Health Inspection'; Medication=''; Cost=150.00}
)

# Add 3-7 health records per cattle (first 20 cattle)
$activeCattle = $cattle | Select-Object -First 20

foreach ($animal in $activeCattle) {
    $numRecords = Get-Random -Minimum 3 -Maximum 7
    
    for ($j = 0; $j -lt $numRecords; $j++) {
        $evt = $healthEvents | Get-Random
        $recordDate = $baseDate.AddDays((Get-Random -Minimum 1 -Maximum 180))
        
        if ($recordDate -gt (Get-Date)) { continue }
        
        $person = $recordedBy | Get-Random
        $nextDue = 'NULL'
        
        if ($evt.Type -eq 'Vaccination') {
            $nextDate = $recordDate.AddDays((Get-Random -Minimum 21 -Maximum 30))
            if ($nextDate -le (Get-Date).AddDays(60)) {
                $nextDue = "'$($nextDate.ToString('yyyy-MM-dd'))'"
            }
        }
        
        $medValue = if ($evt.Medication) { "'$($evt.Medication)'" } else { 'NULL' }
        $dosageValue = if ($evt.Medication) { "'Per label instructions'" } else { 'NULL' }
        $costValue = if ($evt.Cost -gt 0) { $evt.Cost } else { 'NULL' }
        
        $insertHealth = @"
INSERT INTO HealthRecords 
(CattleID, RecordDate, RecordType, Title, Description, Medication, Dosage, Cost, NextDueDate, RecordedBy)
VALUES 
($($animal.CattleID), '$($recordDate.ToString('yyyy-MM-dd'))', '$($evt.Type)', '$($evt.Title)', 
'Routine $($evt.Type.ToLower()) as part of herd health program', 
$medValue, $dosageValue, $costValue, $nextDue, '$person');
"@
        
        Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query $insertHealth
    }
    Write-Host "  ✓ Added health records for $($animal.TagNumber)" -ForegroundColor Gray
}

# Add some upcoming events
Write-Host "`nAdding upcoming health events..." -ForegroundColor Yellow

$upcomingCattle = $cattle | Select-Object -First 5
foreach ($animal in $upcomingCattle) {
    $futureDate = (Get-Date).AddDays((Get-Random -Minimum 5 -Maximum 25))
    
    $insertUpcoming = @"
INSERT INTO HealthRecords 
(CattleID, RecordDate, RecordType, Title, Description, Medication, Dosage, Cost, NextDueDate, RecordedBy)
VALUES 
($($animal.CattleID), '$(Get-Date -Format 'yyyy-MM-dd')', 'Vaccination', 'Annual Booster Scheduled', 
'Annual booster vaccination scheduled', 'Bovi-Shield Gold 5', '2ml SubQ', 12.50, 
'$($futureDate.ToString('yyyy-MM-dd'))', 'Brandon');
"@
    
    Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query $insertUpcoming
    Write-Host "  ✓ Scheduled booster for $($animal.TagNumber) on $($futureDate.ToString('MM/dd/yyyy'))" -ForegroundColor Gray
}

Write-Host "`n✅ Database seeding complete!`n" -ForegroundColor Green

# Summary stats
$totalCattle = (Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query "SELECT COUNT(*) as Count FROM Cattle").Count
$activeCattle = (Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query "SELECT COUNT(*) as Count FROM Cattle WHERE Status='Active'").Count
$totalWeights = (Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query "SELECT COUNT(*) as Count FROM WeightRecords").Count
$totalROG = (Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query "SELECT COUNT(*) as Count FROM RateOfGainCalculations").Count
$totalHealth = (Invoke-UniversalSQLiteQuery -Path $DatabasePath -Query "SELECT COUNT(*) as Count FROM HealthRecords").Count

Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  - Total Cattle: $totalCattle ($activeCattle active)" -ForegroundColor White
Write-Host "  - Weight Records: $totalWeights" -ForegroundColor White
Write-Host "  - ROG Calculations: $totalROG" -ForegroundColor White
Write-Host "  - Health Records: $totalHealth" -ForegroundColor White




