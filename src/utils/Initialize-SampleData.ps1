# Sample Data Script for Gundy Ridge Herd Manager
# This script creates hyper-realistic sample data for a commercial cattle operation
# Reflects real-world cattle ranching scenarios with proper tag numbering

# Import the database helpers
$modulePath = Join-Path $PSScriptRoot '..\PowerShellUniversal.Apps.HerdManager\PowerShellUniversal.Apps.HerdManager.psm1'
Import-Module $modulePath -Force

Write-Host "Initializing database..." -ForegroundColor Cyan
Initialize-HerdDatabase

Write-Host "`nClearing existing sample data..." -ForegroundColor Cyan
# Clear tables in correct order (respecting foreign keys)
$dbPath = Join-Path (Split-Path $modulePath) 'data\HerdManager.db'
Invoke-UniversalSQLiteQuery -Path $dbPath -Query "DELETE FROM RateOfGainCalculations"
Invoke-UniversalSQLiteQuery -Path $dbPath -Query "DELETE FROM InvoiceLineItems"
Invoke-UniversalSQLiteQuery -Path $dbPath -Query "DELETE FROM Invoices"
Invoke-UniversalSQLiteQuery -Path $dbPath -Query "DELETE FROM WeightRecords"
Invoke-UniversalSQLiteQuery -Path $dbPath -Query "DELETE FROM HealthRecords"
Invoke-UniversalSQLiteQuery -Path $dbPath -Query "DELETE FROM Cattle"
Invoke-UniversalSQLiteQuery -Path $dbPath -Query "DELETE FROM Farms"

# Reset auto-increment counters to ensure clean IDs
Invoke-UniversalSQLiteQuery -Path $dbPath -Query "DELETE FROM sqlite_sequence WHERE name='Farms'"
Invoke-UniversalSQLiteQuery -Path $dbPath -Query "DELETE FROM sqlite_sequence WHERE name='Cattle'"
Invoke-UniversalSQLiteQuery -Path $dbPath -Query "DELETE FROM sqlite_sequence WHERE name='WeightRecords'"
Invoke-UniversalSQLiteQuery -Path $dbPath -Query "DELETE FROM sqlite_sequence WHERE name='HealthRecords'"
Invoke-UniversalSQLiteQuery -Path $dbPath -Query "DELETE FROM sqlite_sequence WHERE name='Invoices'"
Invoke-UniversalSQLiteQuery -Path $dbPath -Query "DELETE FROM sqlite_sequence WHERE name='InvoiceLineItems'"
Invoke-UniversalSQLiteQuery -Path $dbPath -Query "DELETE FROM sqlite_sequence WHERE name='RateOfGainCalculations'"

Write-Host "Existing data cleared!" -ForegroundColor Green

Write-Host "`nAdding origin farms..." -ForegroundColor Cyan

# Add origin farms (cattle auction/suppliers)
Add-Farm -FarmName "Oklahoma National Stockyards" -Address "2501 Exchange Ave" -City "Oklahoma City" -State "OK" -ZipCode "73108" -PhoneNumber "405-235-8675" -Email "info@oklahomanational.com" -ContactPerson "Mike Williams" -Notes "Major regional livestock auction - quality feeder cattle" -IsOrigin

Add-Farm -FarmName "Joplin Regional Stockyards" -Address "3002 E 7th St" -City "Joplin" -State "MO" -ZipCode "64801" -PhoneNumber "417-623-3083" -Email "sales@joplinstockyards.com" -ContactPerson "Tom Henderson" -Notes "Weekly feeder cattle auctions, good Angus stock" -IsOrigin

Add-Farm -FarmName "Enid Livestock Auction" -Address "524 W Randolph Ave" -City "Enid" -State "OK" -ZipCode "73701" -PhoneNumber "580-233-3136" -Email "office@enidlivestock.com" -ContactPerson "Randy Mitchell" -Notes "Specialized in replacement heifers and stocker cattle" -IsOrigin

Write-Host "Origin farms added successfully!" -ForegroundColor Green

Write-Host "`nAdding customer/owner farms..." -ForegroundColor Cyan

# Add customer farms (feedlots/processors)
Add-Farm -FarmName "Pratt Feeders LLC" -Address "12500 SW 15th St" -City "Pratt" -State "KS" -ZipCode "67124" -PhoneNumber "620-672-5691" -Email "cattle@prattfeeders.com" -ContactPerson "David Pratt" -Notes "30,000 head capacity feedlot - premium beef program"

Add-Farm -FarmName "Creekstone Farms" -Address "604 Hammons Dr" -City "Arkansas City" -State "KS" -ZipCode "67005" -PhoneNumber "620-442-4761" -Email "procurement@creekstone.com" -ContactPerson "Lisa Martinez" -Notes "Premium Black Angus processor - pays premium for quality"

Add-Farm -FarmName "Southwest Cattle Company" -Address "PO Box 1247" -City "Woodward" -State "OK" -ZipCode "73802" -PhoneNumber "580-256-3344" -Email "buyers@swcattle.com" -ContactPerson "James Hartley" -Notes "Backgrounding operation - 120-180 day programs"

Write-Host "Customer farms added successfully!" -ForegroundColor Green

Write-Host "`nAdding feeder cattle..." -ForegroundColor Cyan

# Realistic feeder cattle from Oklahoma National Stockyards purchase (Sept 2024)
# Lot 1: 10 Black Angus steers, 550-600 lbs
$cattle1 = @{
    TagNumber = "1001"
    Name = $null
    Breed = "Black Angus"
    Gender = "Steer"
    BirthDate = (Get-Date "2024-03-15")
    PurchaseDate = (Get-Date "2025-09-12")
    OriginFarm = "Oklahoma National Stockyards"
    OriginFarmID = 1
    Owner = "Pratt Feeders LLC"
    PricePerDay = 3.85
    Location = "Pen 1"
    Notes = "Lot 1/10 - OKC Sept sale - 575 lbs in-weight"
}
Add-CattleRecord @cattle1

$cattle2 = @{
    TagNumber = "1002"
    Breed = "Black Angus"
    Gender = "Steer"
    BirthDate = (Get-Date "2024-03-12")
    PurchaseDate = (Get-Date "2025-09-12")
    OriginFarm = "Oklahoma National Stockyards"
    OriginFarmID = 1
    Owner = "Pratt Feeders LLC"
    PricePerDay = 3.85
    Location = "Pen 1"
    Notes = "Lot 2/10 - OKC Sept sale - 590 lbs in-weight"
}
Add-CattleRecord @cattle2

$cattle3 = @{
    TagNumber = "1003"
    Breed = "Black Angus"
    Gender = "Steer"
    BirthDate = (Get-Date "2024-03-18")
    PurchaseDate = (Get-Date "2025-09-12")
    OriginFarm = "Oklahoma National Stockyards"
    OriginFarmID = 1
    Owner = "Pratt Feeders LLC"
    PricePerDay = 3.85
    Location = "Pen 1"
    Notes = "Lot 3/10 - OKC Sept sale - 565 lbs in-weight"
}
Add-CattleRecord @cattle3

# Lot 2: 8 Mixed Angus/Hereford steers from Joplin (Aug 2024)
$cattle4 = @{
    TagNumber = "2001"
    Breed = "Angus Cross"
    Gender = "Steer"
    BirthDate = (Get-Date "2024-02-20")
    PurchaseDate = (Get-Date "2025-08-28")
    OriginFarm = "Joplin Regional Stockyards"
    OriginFarmID = 2
    Owner = "Southwest Cattle Company"
    PricePerDay = 3.65
    Location = "Pen 2"
    Notes = "Joplin feeder sale - 620 lbs in-weight - red baldie cross"
}
Add-CattleRecord @cattle4

$cattle5 = @{
    TagNumber = "2002"
    Breed = "Angus Cross"
    Gender = "Steer"
    BirthDate = (Get-Date "2024-02-25")
    PurchaseDate = (Get-Date "2025-08-28")
    OriginFarm = "Joplin Regional Stockyards"
    OriginFarmID = 2
    Owner = "Southwest Cattle Company"
    PricePerDay = 3.65
    Location = "Pen 2"
    Notes = "Joplin feeder sale - 605 lbs in-weight - black baldie"
}
Add-CattleRecord @cattle5

# Replacement heifers from Enid (Oct 2024)
$cattle6 = @{
    TagNumber = "3001"
    Breed = "Black Angus"
    Gender = "Heifer"
    BirthDate = (Get-Date "2024-04-10")
    PurchaseDate = (Get-Date "2025-10-15")
    OriginFarm = "Enid Livestock Auction"
    OriginFarmID = 3
    Owner = "Creekstone Farms"
    PricePerDay = 4.25
    Location = "Pen 3"
    Notes = "Replacement heifer - excellent genetics - 525 lbs in-weight"
}
Add-CattleRecord @cattle6

$cattle7 = @{
    TagNumber = "3002"
    Breed = "Black Angus"
    Gender = "Heifer"
    BirthDate = (Get-Date "2024-04-15")
    PurchaseDate = (Get-Date "2025-10-15")
    OriginFarm = "Enid Livestock Auction"
    OriginFarmID = 3
    Owner = "Creekstone Farms"
    PricePerDay = 4.25
    Location = "Pen 3"
    Notes = "Replacement heifer - reg. Angus - 510 lbs in-weight"
}
Add-CattleRecord @cattle7

# Additional steers from OKC (Oct 2024)
$cattle8 = @{
    TagNumber = "1004"
    Breed = "Black Angus"
    Gender = "Steer"
    BirthDate = (Get-Date "2024-03-22")
    PurchaseDate = (Get-Date "2025-10-08")
    OriginFarm = "Oklahoma National Stockyards"
    OriginFarmID = 1
    Owner = "Pratt Feeders LLC"
    PricePerDay = 3.90
    Location = "Pen 1"
    Notes = "OKC Oct sale - 580 lbs in-weight - excellent frame"
}
Add-CattleRecord @cattle8

$cattle9 = @{
    TagNumber = "2003"
    Breed = "Red Angus"
    Gender = "Steer"
    BirthDate = (Get-Date "2024-02-28")
    PurchaseDate = (Get-Date "2025-09-05")
    OriginFarm = "Joplin Regional Stockyards"
    OriginFarmID = 2
    Owner = "Southwest Cattle Company"
    PricePerDay = 3.70
    Location = "Pen 2"
    Notes = "Red Angus steer - 610 lbs in-weight - good muscle"
}
Add-CattleRecord @cattle9

$cattle10 = @{
    TagNumber = "1005"
    Breed = "Black Angus"
    Gender = "Steer"
    BirthDate = (Get-Date "2024-03-25")
    PurchaseDate = (Get-Date "2025-10-08")
    OriginFarm = "Oklahoma National Stockyards"
    OriginFarmID = 1
    Owner = "Creekstone Farms"
    PricePerDay = 4.10
    Location = "Pen 4"
    Notes = "Premium Angus - Creekstone premium program - 570 lbs in-weight"
}
Add-CattleRecord @cattle10

Write-Host "Feeder cattle added successfully!" -ForegroundColor Green

Write-Host "`nAdding realistic weight records..." -ForegroundColor Cyan

# Tag 1001 - Angus steer - typical 2.8 lbs/day ADG
Add-WeightRecord -CattleID 1 -WeightDate (Get-Date "2025-09-12") -Weight 575 -RecordedBy "Ranch Staff" -MeasurementMethod "Scale" -Notes "In-weight from OKC auction"
Add-WeightRecord -CattleID 1 -WeightDate (Get-Date "2025-10-12") -Weight 660 -RecordedBy "Ranch Staff" -MeasurementMethod "Scale" -Notes "30-day weight - good adjustment"
Add-WeightRecord -CattleID 1 -WeightDate (Get-Date "2025-11-12") -Weight 750 -RecordedBy "Ranch Staff" -MeasurementMethod "Scale" -Notes "60-day weight - excellent gains"
Add-WeightRecord -CattleID 1 -WeightDate (Get-Date "2025-12-12") -Weight 840 -RecordedBy "Ranch Staff" -MeasurementMethod "Scale" -Notes "90-day weight - 2.9 ADG"

# Tag 1002 - Angus steer - excellent gainer 3.0 lbs/day
Add-WeightRecord -CattleID 2 -WeightDate (Get-Date "2025-09-12") -Weight 590 -RecordedBy "Ranch Staff" -MeasurementMethod "Scale" -Notes "In-weight from OKC auction"
Add-WeightRecord -CattleID 2 -WeightDate (Get-Date "2025-10-12") -Weight 680 -RecordedBy "Ranch Staff" -MeasurementMethod "Scale" -Notes "30-day weight"
Add-WeightRecord -CattleID 2 -WeightDate (Get-Date "2025-11-12") -Weight 775 -RecordedBy "Ranch Staff" -MeasurementMethod "Scale" -Notes "60-day weight - top performer"
Add-WeightRecord -CattleID 2 -WeightDate (Get-Date "2025-12-12") -Weight 870 -RecordedBy "Ranch Staff" -MeasurementMethod "Scale" -Notes "90-day weight - 3.1 ADG"

# Tag 1003 - Angus steer - solid 2.7 lbs/day
Add-WeightRecord -CattleID 3 -WeightDate (Get-Date "2025-09-12") -Weight 565 -RecordedBy "Ranch Staff" -MeasurementMethod "Scale" -Notes "In-weight from OKC auction"
Add-WeightRecord -CattleID 3 -WeightDate (Get-Date "2025-10-12") -Weight 650 -RecordedBy "Ranch Staff" -MeasurementMethod "Scale" -Notes "30-day weight"
Add-WeightRecord -CattleID 3 -WeightDate (Get-Date "2025-11-12") -Weight 730 -RecordedBy "Ranch Staff" -MeasurementMethod "Scale" -Notes "60-day weight"
Add-WeightRecord -CattleID 3 -WeightDate (Get-Date "2025-12-12") -Weight 815 -RecordedBy "Ranch Staff" -MeasurementMethod "Scale" -Notes "90-day weight - 2.8 ADG"

# Tag 2001 - Angus Cross - backgrounder 2.5 lbs/day
Add-WeightRecord -CattleID 4 -WeightDate (Get-Date "2025-08-28") -Weight 620 -RecordedBy "Ranch Staff" -MeasurementMethod "Scale" -Notes "In-weight Joplin"
Add-WeightRecord -CattleID 4 -WeightDate (Get-Date "2025-09-28") -Weight 695 -RecordedBy "Ranch Staff" -MeasurementMethod "Scale" -Notes "30-day weight"
Add-WeightRecord -CattleID 4 -WeightDate (Get-Date "2025-10-28") -Weight 775 -RecordedBy "Ranch Staff" -MeasurementMethod "Scale" -Notes "60-day weight"
Add-WeightRecord -CattleID 4 -WeightDate (Get-Date "2025-11-28") -Weight 850 -RecordedBy "Ranch Staff" -MeasurementMethod "Scale" -Notes "90-day weight - 2.6 ADG"

# Tag 2002 - Angus Cross - 2.6 lbs/day
Add-WeightRecord -CattleID 5 -WeightDate (Get-Date "2025-08-28") -Weight 605 -RecordedBy "Ranch Staff" -MeasurementMethod "Scale" -Notes "In-weight Joplin"
Add-WeightRecord -CattleID 5 -WeightDate (Get-Date "2025-09-28") -Weight 680 -RecordedBy "Ranch Staff" -MeasurementMethod "Scale" -Notes "30-day weight"
Add-WeightRecord -CattleID 5 -WeightDate (Get-Date "2025-10-28") -Weight 760 -RecordedBy "Ranch Staff" -MeasurementMethod "Scale" -Notes "60-day weight"
Add-WeightRecord -CattleID 5 -WeightDate (Get-Date "2025-11-28") -Weight 840 -RecordedBy "Ranch Staff" -MeasurementMethod "Scale" -Notes "90-day weight - 2.6 ADG"

# Tag 3001 - Heifer - 2.3 lbs/day (lower than steers, typical)
Add-WeightRecord -CattleID 6 -WeightDate (Get-Date "2025-10-15") -Weight 525 -RecordedBy "Ranch Staff" -MeasurementMethod "Scale" -Notes "In-weight Enid"
Add-WeightRecord -CattleID 6 -WeightDate (Get-Date "2025-11-15") -Weight 595 -RecordedBy "Ranch Staff" -MeasurementMethod "Scale" -Notes "30-day weight"
Add-WeightRecord -CattleID 6 -WeightDate (Get-Date "2025-12-15") -Weight 665 -RecordedBy "Ranch Staff" -MeasurementMethod "Scale" -Notes "60-day weight - 2.3 ADG"

# Tag 3002 - Heifer - 2.2 lbs/day
Add-WeightRecord -CattleID 7 -WeightDate (Get-Date "2025-10-15") -Weight 510 -RecordedBy "Ranch Staff" -MeasurementMethod "Scale" -Notes "In-weight Enid"
Add-WeightRecord -CattleID 7 -WeightDate (Get-Date "2025-11-15") -Weight 575 -RecordedBy "Ranch Staff" -MeasurementMethod "Scale" -Notes "30-day weight"
Add-WeightRecord -CattleID 7 -WeightDate (Get-Date "2025-12-15") -Weight 645 -RecordedBy "Ranch Staff" -MeasurementMethod "Scale" -Notes "60-day weight - 2.3 ADG"

# Tag 1004 - Angus steer - 2.9 lbs/day
Add-WeightRecord -CattleID 8 -WeightDate (Get-Date "2025-10-08") -Weight 580 -RecordedBy "Ranch Staff" -MeasurementMethod "Scale" -Notes "In-weight OKC Oct sale"
Add-WeightRecord -CattleID 8 -WeightDate (Get-Date "2025-11-08") -Weight 670 -RecordedBy "Ranch Staff" -MeasurementMethod "Scale" -Notes "30-day weight"
Add-WeightRecord -CattleID 8 -WeightDate (Get-Date "2025-12-08") -Weight 760 -RecordedBy "Ranch Staff" -MeasurementMethod "Scale" -Notes "60-day weight - 3.0 ADG"

# Tag 2003 - Red Angus - 2.7 lbs/day
Add-WeightRecord -CattleID 9 -WeightDate (Get-Date "2025-09-05") -Weight 610 -RecordedBy "Ranch Staff" -MeasurementMethod "Scale" -Notes "In-weight Joplin"
Add-WeightRecord -CattleID 9 -WeightDate (Get-Date "2025-10-05") -Weight 690 -RecordedBy "Ranch Staff" -MeasurementMethod "Scale" -Notes "30-day weight"
Add-WeightRecord -CattleID 9 -WeightDate (Get-Date "2025-11-05") -Weight 775 -RecordedBy "Ranch Staff" -MeasurementMethod "Scale" -Notes "60-day weight"
Add-WeightRecord -CattleID 9 -WeightDate (Get-Date "2025-12-05") -Weight 860 -RecordedBy "Ranch Staff" -MeasurementMethod "Scale" -Notes "90-day weight - 2.8 ADG"

# Tag 1005 - Premium Angus - 3.1 lbs/day (Creekstone premium program)
Add-WeightRecord -CattleID 10 -WeightDate (Get-Date "2025-10-08") -Weight 570 -RecordedBy "Ranch Staff" -MeasurementMethod "Scale" -Notes "In-weight OKC - Creekstone program"
Add-WeightRecord -CattleID 10 -WeightDate (Get-Date "2025-11-08") -Weight 665 -RecordedBy "Ranch Staff" -MeasurementMethod "Scale" -Notes "30-day weight - excellent"
Add-WeightRecord -CattleID 10 -WeightDate (Get-Date "2025-12-08") -Weight 760 -RecordedBy "Ranch Staff" -MeasurementMethod "Scale" -Notes "60-day weight - 3.2 ADG premium genetics"

Write-Host "Realistic weight records added successfully!" -ForegroundColor Green

Write-Host "`nAdding health records..." -ForegroundColor Cyan

# Arrival processing vaccinations - standard feedlot protocol
Add-HealthRecord -CattleID 1 -RecordType "Vaccination" -RecordDate (Get-Date "2025-09-12") -Title "IBR-BVD-PI3-BRSV vaccine" -VeterinarianName "Dr. Sarah Johnson" -Cost 8.50 -Notes "Arrival processing - respiratory vaccine"
Add-HealthRecord -CattleID 1 -RecordType "Vaccination" -RecordDate (Get-Date "2025-09-12") -Title "Clostridial 7-way" -VeterinarianName "Dr. Sarah Johnson" -Cost 6.75 -Notes "Arrival processing - blackleg prevention"

Add-HealthRecord -CattleID 2 -RecordType "Vaccination" -RecordDate (Get-Date "2025-09-12") -Title "IBR-BVD-PI3-BRSV vaccine" -VeterinarianName "Dr. Sarah Johnson" -Cost 8.50 -Notes "Arrival processing"
Add-HealthRecord -CattleID 2 -RecordType "Vaccination" -RecordDate (Get-Date "2025-09-12") -Title "Clostridial 7-way" -VeterinarianName "Dr. Sarah Johnson" -Cost 6.75 -Notes "Arrival processing"

Add-HealthRecord -CattleID 3 -RecordType "Vaccination" -RecordDate (Get-Date "2025-09-12") -Title "IBR-BVD-PI3-BRSV vaccine" -VeterinarianName "Dr. Sarah Johnson" -Cost 8.50 -Notes "Arrival processing"
Add-HealthRecord -CattleID 3 -RecordType "Vaccination" -RecordDate (Get-Date "2025-09-12") -Title "Clostridial 7-way" -VeterinarianName "Dr. Sarah Johnson" -Cost 6.75 -Notes "Arrival processing"

# Backgrounder cattle - arrival processing
Add-HealthRecord -CattleID 4 -RecordType "Vaccination" -RecordDate (Get-Date "2025-08-28") -Title "IBR-BVD-PI3-BRSV vaccine" -VeterinarianName "Dr. Mike Anderson" -Cost 8.50 -Notes "Backgrounding program - arrival"
Add-HealthRecord -CattleID 4 -RecordType "Treatment" -RecordDate (Get-Date "2025-08-28") -Title "Ivermectin pour-on" -Medication "Ivermectin 5cc pour-on" -VeterinarianName "Dr. Mike Anderson" -Cost 4.25 -Notes "Parasite control - deworming"

Add-HealthRecord -CattleID 5 -RecordType "Vaccination" -RecordDate (Get-Date "2025-08-28") -Title "IBR-BVD-PI3-BRSV vaccine" -VeterinarianName "Dr. Mike Anderson" -Cost 8.50 -Notes "Backgrounding program - arrival"
Add-HealthRecord -CattleID 5 -RecordType "Treatment" -RecordDate (Get-Date "2025-08-28") -Title "Ivermectin pour-on" -Medication "Ivermectin 5cc pour-on" -VeterinarianName "Dr. Mike Anderson" -Cost 4.25 -Notes "Parasite control - deworming"

# Treatment example - respiratory issue
Add-HealthRecord -CattleID 5 -RecordType "Treatment" -RecordDate (Get-Date "2025-09-15") -Title "Respiratory Treatment" -Medication "Draxxin (tulathromycin) 2.5cc SQ" -VeterinarianName "Dr. Mike Anderson" -Cost 18.50 -Notes "Treated for respiratory - temp 104.2F, responded well" -FollowUpDate (Get-Date "2025-09-18")
Add-HealthRecord -CattleID 5 -RecordType "Observation" -RecordDate (Get-Date "2025-09-18") -Title "Follow-up check" -VeterinarianName "Dr. Mike Anderson" -Cost 0 -Notes "Follow-up - temp normal, eating well, no further treatment needed"

# Heifer vaccination program
Add-HealthRecord -CattleID 6 -RecordType "Vaccination" -RecordDate (Get-Date "2025-10-15") -Title "IBR-BVD-PI3-BRSV vaccine" -VeterinarianName "Dr. Sarah Johnson" -Cost 8.50 -Notes "Replacement heifer program"
Add-HealthRecord -CattleID 6 -RecordType "Vaccination" -RecordDate (Get-Date "2025-10-15") -Title "Brucellosis (Bangs) vaccine" -VeterinarianName "Dr. Sarah Johnson" -Cost 12.00 -Notes "RB-51 - heifer vaccination"

Add-HealthRecord -CattleID 7 -RecordType "Vaccination" -RecordDate (Get-Date "2025-10-15") -Title "IBR-BVD-PI3-BRSV vaccine" -VeterinarianName "Dr. Sarah Johnson" -Cost 8.50 -Notes "Replacement heifer program"
Add-HealthRecord -CattleID 7 -RecordType "Vaccination" -RecordDate (Get-Date "2025-10-15") -Title "Brucellosis (Bangs) vaccine" -VeterinarianName "Dr. Sarah Johnson" -Cost 12.00 -Notes "RB-51 - heifer vaccination"

# Premium program cattle
Add-HealthRecord -CattleID 8 -RecordType "Vaccination" -RecordDate (Get-Date "2025-10-08") -Title "IBR-BVD-PI3-BRSV vaccine" -VeterinarianName "Dr. Sarah Johnson" -Cost 8.50 -Notes "Premium program - enhanced health protocol"
Add-HealthRecord -CattleID 8 -RecordType "Vaccination" -RecordDate (Get-Date "2025-10-08") -Title "Clostridial 7-way" -VeterinarianName "Dr. Sarah Johnson" -Cost 6.75 -Notes "Premium program protocol"

Add-HealthRecord -CattleID 9 -RecordType "Vaccination" -RecordDate (Get-Date "2025-09-05") -Title "IBR-BVD-PI3-BRSV vaccine" -VeterinarianName "Dr. Mike Anderson" -Cost 8.50 -Notes "Arrival processing"
Add-HealthRecord -CattleID 9 -RecordType "Treatment" -RecordDate (Get-Date "2025-09-05") -Title "Deworming - Safeguard" -Medication "Safeguard (fenbendazole) oral drench" -VeterinarianName "Dr. Mike Anderson" -Cost 5.50 -Notes "Deworming protocol"

Add-HealthRecord -CattleID 10 -RecordType "Vaccination" -RecordDate (Get-Date "2025-10-08") -Title "IBR-BVD-PI3-BRSV vaccine" -VeterinarianName "Dr. Sarah Johnson" -Cost 8.50 -Notes "Creekstone premium program"
Add-HealthRecord -CattleID 10 -RecordType "Vaccination" -RecordDate (Get-Date "2025-10-08") -Title "Clostridial 7-way" -VeterinarianName "Dr. Sarah Johnson" -Cost 6.75 -Notes "Premium genetics - full protocol"
Add-HealthRecord -CattleID 10 -RecordType "Treatment" -RecordDate (Get-Date "2025-10-08") -Title "Cydectin pour-on" -Medication "Cydectin pour-on 10cc" -VeterinarianName "Dr. Sarah Johnson" -Cost 6.25 -Notes "Premium program - broad spectrum parasite control"

Write-Host "Health records added successfully!" -ForegroundColor Green

Write-Host "`nCalculating sample rate of gain..." -ForegroundColor Cyan

# Calculate rate of gain for each animal using actual weight record dates
$rog1 = Calculate-RateOfGain -CattleID 1 -StartDate ([DateTime]"2025-09-12") -EndDate ([DateTime]"2025-12-12")
$rog2 = Calculate-RateOfGain -CattleID 2 -StartDate ([DateTime]"2025-09-12") -EndDate ([DateTime]"2025-12-12")
$rog3 = Calculate-RateOfGain -CattleID 3 -StartDate ([DateTime]"2025-09-12") -EndDate ([DateTime]"2025-12-12")
$rog4 = Calculate-RateOfGain -CattleID 4 -StartDate ([DateTime]"2025-08-28") -EndDate ([DateTime]"2025-11-28")
$rog5 = Calculate-RateOfGain -CattleID 5 -StartDate ([DateTime]"2025-08-28") -EndDate ([DateTime]"2025-11-28")
$rog6 = Calculate-RateOfGain -CattleID 6 -StartDate ([DateTime]"2025-10-15") -EndDate ([DateTime]"2025-12-15")
$rog7 = Calculate-RateOfGain -CattleID 7 -StartDate ([DateTime]"2025-10-15") -EndDate ([DateTime]"2025-12-15")
$rog8 = Calculate-RateOfGain -CattleID 8 -StartDate ([DateTime]"2025-10-08") -EndDate ([DateTime]"2025-12-08")
$rog9 = Calculate-RateOfGain -CattleID 9 -StartDate ([DateTime]"2025-09-05") -EndDate ([DateTime]"2025-12-05")
$rog10 = Calculate-RateOfGain -CattleID 10 -StartDate ([DateTime]"2025-10-08") -EndDate ([DateTime]"2025-12-08")

Write-Host "`nRate of Gain Results:" -ForegroundColor Yellow
Write-Host "===================="
Write-Host "Tag 1001 (Black Angus - OKC): ADG = $($rog1.AverageDailyGain) lbs/day, Total Gain = $($rog1.TotalWeightGain) lbs"
Write-Host "Tag 1002 (Black Angus - OKC): ADG = $($rog2.AverageDailyGain) lbs/day, Total Gain = $($rog2.TotalWeightGain) lbs"
Write-Host "Tag 1003 (Black Angus - OKC): ADG = $($rog3.AverageDailyGain) lbs/day, Total Gain = $($rog3.TotalWeightGain) lbs"
Write-Host "Tag 2001 (Angus Cross - Joplin): ADG = $($rog4.AverageDailyGain) lbs/day, Total Gain = $($rog4.TotalWeightGain) lbs"
Write-Host "Tag 2002 (Red Angus - Joplin): ADG = $($rog5.AverageDailyGain) lbs/day, Total Gain = $($rog5.TotalWeightGain) lbs"
Write-Host "Tag 3001 (Replacement Heifer - Enid): ADG = $($rog6.AverageDailyGain) lbs/day, Total Gain = $($rog6.TotalWeightGain) lbs"
Write-Host "Tag 3002 (Replacement Heifer - Enid): ADG = $($rog7.AverageDailyGain) lbs/day, Total Gain = $($rog7.TotalWeightGain) lbs"
Write-Host "Tag 1004 (Black Angus - OKC): ADG = $($rog8.AverageDailyGain) lbs/day, Total Gain = $($rog8.TotalWeightGain) lbs"
Write-Host "Tag 2003 (Black Baldie - Joplin): ADG = $($rog9.AverageDailyGain) lbs/day, Total Gain = $($rog9.TotalWeightGain) lbs"
Write-Host "Tag 1005 (Premium Angus - OKC): ADG = $($rog10.AverageDailyGain) lbs/day, Total Gain = $($rog10.TotalWeightGain) lbs"

Write-Host "`nAdding sample invoices..." -ForegroundColor Cyan

# Invoice for Pratt Feeders LLC - Pen 1 cattle (Tags 1001-1003) - 90-day feeding period
$prattLineItems = @(
    @{
        CattleID = 1
        StartDate = Get-Date "2025-09-12"
        EndDate = Get-Date "2025-12-11"
        DaysOnFeed = 90
        PricePerDay = 3.85
        FeedingCost = 346.50
        HealthCost = 45.00
        LineItemTotal = 391.50
        Notes = "Tag 1001 - 2.9 ADG - 575 to 840 lbs"
    },
    @{
        CattleID = 2
        StartDate = Get-Date "2025-09-19"
        EndDate = Get-Date "2025-12-18"
        DaysOnFeed = 90
        PricePerDay = 3.95
        FeedingCost = 355.50
        HealthCost = 45.00
        LineItemTotal = 400.50
        Notes = "Tag 1002 - 3.1 ADG - Top performer"
    },
    @{
        CattleID = 3
        StartDate = Get-Date "2025-10-01"
        EndDate = Get-Date "2025-12-30"
        DaysOnFeed = 90
        PricePerDay = 3.90
        FeedingCost = 351.00
        HealthCost = 45.00
        LineItemTotal = 396.00
        Notes = "Tag 1003 - 2.8 ADG - Good frame"
    }
)

Add-Invoice -InvoiceNumber "INV-2025-101" `
    -InvoiceDate (Get-Date "2025-12-30") `
    -LineItems $prattLineItems `
    -TotalCost 1188.00 `
    -Notes "Pratt Feeders - Pen 1 completion - 30,000 head facility" `
    -CreatedBy "Ranch Manager"

# Invoice for Southwest Cattle Company - Backgrounding program (Tags 2001-2003)
$backgroundingLineItems = @(
    @{
        CattleID = 4
        StartDate = Get-Date "2025-08-15"
        EndDate = Get-Date "2025-11-13"
        DaysOnFeed = 90
        PricePerDay = 3.65
        FeedingCost = 328.50
        HealthCost = 40.00
        LineItemTotal = 368.50
        Notes = "Tag 2001 - 2.6 ADG - Backgrounder"
    },
    @{
        CattleID = 5
        StartDate = Get-Date "2025-09-01"
        EndDate = Get-Date "2025-11-30"
        DaysOnFeed = 90
        PricePerDay = 3.70
        FeedingCost = 333.00
        HealthCost = 40.00
        LineItemTotal = 373.00
        Notes = "Tag 2002 - 2.6 ADG - Red baldie cross"
    },
    @{
        CattleID = 9
        StartDate = Get-Date "2025-08-22"
        EndDate = Get-Date "2025-11-20"
        DaysOnFeed = 90
        PricePerDay = 3.65
        FeedingCost = 328.50
        HealthCost = 40.00
        LineItemTotal = 368.50
        Notes = "Tag 2003 - 2.8 ADG - Black baldie"
    }
)

Add-Invoice -InvoiceNumber "INV-2025-102" `
    -InvoiceDate (Get-Date "2025-11-30") `
    -LineItems $backgroundingLineItems `
    -TotalCost 1110.00 `
    -Notes "Southwest Cattle Company - 120-180 day backgrounding program" `
    -CreatedBy "Ranch Manager"

# Invoice for Creekstone Farms - Premium Angus program (Tags 1004, 1005, 3001, 3002)
$creekstoneLineItems = @(
    @{
        CattleID = 8
        StartDate = Get-Date "2025-10-15"
        EndDate = Get-Date "2025-12-14"
        DaysOnFeed = 60
        PricePerDay = 4.10
        FeedingCost = 246.00
        HealthCost = 35.00
        LineItemTotal = 281.00
        Notes = "Tag 1004 - 3.0 ADG - Excellent frame"
    },
    @{
        CattleID = 10
        StartDate = Get-Date "2025-10-08"
        EndDate = Get-Date "2025-12-07"
        DaysOnFeed = 60
        PricePerDay = 4.15
        FeedingCost = 249.00
        HealthCost = 35.00
        LineItemTotal = 284.00
        Notes = "Tag 1005 - 3.2 ADG - Premium genetics"
    },
    @{
        CattleID = 6
        StartDate = Get-Date "2025-10-10"
        EndDate = Get-Date "2025-12-09"
        DaysOnFeed = 60
        PricePerDay = 4.25
        FeedingCost = 255.00
        HealthCost = 35.00
        LineItemTotal = 290.00
        Notes = "Tag 3001 - 2.3 ADG - Replacement heifer"
    },
    @{
        CattleID = 7
        StartDate = Get-Date "2025-10-10"
        EndDate = Get-Date "2025-12-09"
        DaysOnFeed = 60
        PricePerDay = 4.25
        FeedingCost = 255.00
        HealthCost = 35.00
        LineItemTotal = 290.00
        Notes = "Tag 3002 - 2.3 ADG - Registered Angus"
    }
)

Add-Invoice -InvoiceNumber "INV-2025-103" `
    -InvoiceDate (Get-Date "2025-12-09") `
    -LineItems $creekstoneLineItems `
    -TotalCost 1145.00 `
    -Notes "Creekstone Farms - Premium Black Angus program - quality premiums" `
    -CreatedBy "Ranch Manager"

Write-Host "Sample invoices added successfully!" -ForegroundColor Green

Write-Host "`nDatabase setup complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "COMMERCIAL CATTLE OPERATION INITIALIZED" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "`nFarms:" -ForegroundColor Yellow
Write-Host "  Origin Farms (3):" -ForegroundColor White
Write-Host "    - Oklahoma National Stockyards (OKC)" -ForegroundColor Gray
Write-Host "    - Joplin Regional Stockyards (MO)" -ForegroundColor Gray
Write-Host "    - Enid Livestock Auction (OK)" -ForegroundColor Gray
Write-Host "  Customer Farms (3):" -ForegroundColor White
Write-Host "    - Pratt Feeders LLC (30,000 head capacity)" -ForegroundColor Gray
Write-Host "    - Creekstone Farms (premium Black Angus)" -ForegroundColor Gray
Write-Host "    - Southwest Cattle Company (backgrounding)" -ForegroundColor Gray
Write-Host "`nCattle Inventory:" -ForegroundColor Yellow
Write-Host "  10 head total" -ForegroundColor White
Write-Host "    - Tags 1001-1005: Black Angus from OKC (5 head)" -ForegroundColor Gray
Write-Host "    - Tags 2001-2003: Angus Cross from Joplin (3 head)" -ForegroundColor Gray
Write-Host "    - Tags 3001-3002: Replacement heifers from Enid (2 head)" -ForegroundColor Gray
Write-Host "`nPerformance Data:" -ForegroundColor Yellow
Write-Host "  38 weight records tracking ADG" -ForegroundColor White
Write-Host "    - Steers: 2.7-3.2 lbs/day ADG (commercial range)" -ForegroundColor Gray
Write-Host "    - Heifers: 2.2-2.3 lbs/day ADG (typical)" -ForegroundColor Gray
Write-Host "    - Top performer: Tag 1005 @ 3.2 ADG (premium genetics)" -ForegroundColor Gray
Write-Host "`nBilling:" -ForegroundColor Yellow
Write-Host "  3 commercial invoices" -ForegroundColor White
Write-Host "    - INV-2025-101: Pratt Feeders - Pen 1 (3 head, 90 days) = `$1,188" -ForegroundColor Gray
Write-Host "    - INV-2025-102: Southwest Cattle - Backgrounding (3 head, 90 days) = `$1,110" -ForegroundColor Gray
Write-Host "    - INV-2025-103: Creekstone Farms - Premium program (4 head, 60 days) = `$1,145" -ForegroundColor Gray
Write-Host "`nDatabase location: $(Split-Path $modulePath)\data\HerdManager.db" -ForegroundColor Cyan
Write-Host "`nView in PowerShell Universal Dashboard:" -ForegroundColor Cyan
Write-Host "  ✓ Cattle Management - Commercial feedlot tracking" -ForegroundColor Green
Write-Host "  ✓ Rate of Gain Analysis - Industry-standard ADG metrics" -ForegroundColor Green
Write-Host "  ✓ Farm Management - Auction sources & feedlot customers" -ForegroundColor Green
Write-Host "  ✓ Accounting - Multi-cattle invoicing with realistic pricing" -ForegroundColor Green




