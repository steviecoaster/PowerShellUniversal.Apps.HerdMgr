# Sample Data Script for Gundy Ridge Herd Manager
# This script creates comprehensive sample data including:
# - Origin and owner farms
# - Cattle with farm associations
# - Weight records
# - Single and multi-cattle invoices

# Import the database helpers
$modulePath = Join-Path $PSScriptRoot '..\PowerShellUniversal.Apps.HerdManager\PowerShellUniversal.Apps.HerdManager.psm1'
Import-Module $modulePath -Force

Write-Host "Initializing database..." -ForegroundColor Cyan
Initialize-HerdDatabase

Write-Host "`nClearing existing sample data..." -ForegroundColor Cyan
# Clear tables in correct order (respecting foreign keys)
$dbPath = Join-Path (Split-Path $modulePath) 'data\HerdManager.db'
Invoke-SqliteQuery -DataSource $dbPath -Query "DELETE FROM InvoiceLineItems"
Invoke-SqliteQuery -DataSource $dbPath -Query "DELETE FROM Invoices"
Invoke-SqliteQuery -DataSource $dbPath -Query "DELETE FROM WeightRecords"
Invoke-SqliteQuery -DataSource $dbPath -Query "DELETE FROM Cattle"
Invoke-SqliteQuery -DataSource $dbPath -Query "DELETE FROM Farms"
Write-Host "Existing data cleared!" -ForegroundColor Green

Write-Host "`nAdding sample farms..." -ForegroundColor Cyan

# Add origin farms (where we buy cattle from)
Add-Farm -FarmName "Whispering Pines Ranch" -Address "1234 County Road 45" -City "Stillwater" -State "OK" -ZipCode "74074" -PhoneNumber "405-555-0101" -Email "contact@whisperingpines.com" -ContactPerson "John Davidson" -Notes "Premium Angus cattle source" -IsOrigin

Add-Farm -FarmName "Red River Cattle Co" -Address "5678 Highway 51" -City "Enid" -State "OK" -ZipCode "73701" -PhoneNumber "580-555-0202" -Email "sales@redrivercattle.com" -ContactPerson "Sarah Martinez" -Notes "Quality Hereford and crossbreeds" -IsOrigin

Add-Farm -FarmName "Prairie View Livestock" -Address "9012 State Highway 33" -City "Guthrie" -State "OK" -ZipCode "73044" -PhoneNumber "405-555-0303" -Email "info@prairieviewlivestock.com" -ContactPerson "Mike Thompson" -Notes "Certified organic cattle operation" -IsOrigin

# Add owner farms (where we sell/send cattle to)
Add-Farm -FarmName "Smith Family Farms" -Address "456 Oak Street" -City "Tulsa" -State "OK" -ZipCode "74105" -PhoneNumber "918-555-1001" -Email "smithfarms@example.com" -ContactPerson "Robert Smith" -Notes "Long-time customer, prefers grass-fed cattle"

Add-Farm -FarmName "Johnson Ranch & Feedlot" -Address "789 Ranch Road" -City "Oklahoma City" -State "OK" -ZipCode "73102" -PhoneNumber "405-555-2002" -Email "johnson.ranch@example.com" -ContactPerson "Lisa Johnson" -Notes "Large-scale operation"

Add-Farm -FarmName "Heritage Beef Company" -Address "321 Industrial Parkway" -City "Norman" -State "OK" -ZipCode "73069" -PhoneNumber "405-555-3003" -Email "sales@heritagebeef.com" -ContactPerson "David Chen" -Notes "Premium beef processor"

Write-Host "Sample farms added successfully!" -ForegroundColor Green

Write-Host "`nAdding sample cattle..." -ForegroundColor Cyan

# Add cattle with farm associations
$cattle1 = @{
    TagNumber = "A001"
    Name = "Bessie"
    Breed = "Angus"
    Gender = "Heifer"
    BirthDate = (Get-Date).AddYears(-2)
    PurchaseDate = (Get-Date).AddYears(-1).AddMonths(-6)
    OriginFarm = "Whispering Pines Ranch"
    OriginFarmID = 1
    Owner = "Smith Family Farms"
    Notes = "Good disposition, excellent genetics. Premium Angus from Whispering Pines."
}
Add-CattleRecord @cattle1

$cattle2 = @{
    TagNumber = "H002"
    Name = "Charlie"
    Breed = "Hereford"
    Gender = "Steer"
    BirthDate = (Get-Date).AddYears(-1).AddMonths(-8)
    PurchaseDate = (Get-Date).AddYears(-1).AddMonths(-2)
    OriginFarm = "Red River Cattle Co"
    OriginFarmID = 2
    Owner = "Smith Family Farms"
    Notes = "Fast grower, excellent feed conversion"
}
Add-CattleRecord @cattle2

$cattle3 = @{
    TagNumber = "A003"
    Name = "Daisy"
    Breed = "Angus"
    Gender = "Heifer"
    BirthDate = (Get-Date).AddYears(-4)
    PurchaseDate = (Get-Date).AddYears(-3)
    OriginFarm = "Whispering Pines Ranch"
    OriginFarmID = 1
    Owner = "Johnson Ranch & Feedlot"
    Notes = "Mature heifer, proven bloodline"
}
Add-CattleRecord @cattle3

$cattle4 = @{
    TagNumber = "O004"
    Name = "Duke"
    Breed = "Angus Cross"
    Gender = "Steer"
    BirthDate = (Get-Date).AddYears(-1).AddMonths(-6)
    PurchaseDate = (Get-Date).AddMonths(-9)
    OriginFarm = "Prairie View Livestock"
    OriginFarmID = 3
    Owner = "Heritage Beef Company"
    Notes = "Organic certified, excellent marbling potential"
}
Add-CattleRecord @cattle4

$cattle5 = @{
    TagNumber = "H005"
    Name = "Rusty"
    Breed = "Hereford"
    Gender = "Steer"
    BirthDate = (Get-Date).AddYears(-1).AddMonths(-10)
    PurchaseDate = (Get-Date).AddMonths(-8)
    OriginFarm = "Red River Cattle Co"
    OriginFarmID = 2
    Owner = "Heritage Beef Company"
    Notes = "Good frame, consistent daily gains"
}
Add-CattleRecord @cattle5

$cattle6 = @{
    TagNumber = "A006"
    Name = "Bella"
    Breed = "Angus"
    Gender = "Heifer"
    BirthDate = (Get-Date).AddYears(-1).AddMonths(-4)
    PurchaseDate = (Get-Date).AddMonths(-6)
    OriginFarm = "Whispering Pines Ranch"
    OriginFarmID = 1
    Owner = "Johnson Ranch & Feedlot"
    Notes = "Replacement heifer prospect"
}
Add-CattleRecord @cattle6

Write-Host "Sample cattle added successfully!" -ForegroundColor Green

Write-Host "`nAdding sample weight records..." -ForegroundColor Cyan

# Add weight records for cattle #1 - Bessie (showing good rate of gain)
Add-WeightRecord -CattleID 1 -WeightDate (Get-Date).AddDays(-120) -Weight 650 -RecordedBy "Stephen"
Add-WeightRecord -CattleID 1 -WeightDate (Get-Date).AddDays(-90) -Weight 700 -RecordedBy "Stephen"
Add-WeightRecord -CattleID 1 -WeightDate (Get-Date).AddDays(-60) -Weight 755 -RecordedBy "Stephen"
Add-WeightRecord -CattleID 1 -WeightDate (Get-Date).AddDays(-30) -Weight 810 -RecordedBy "Stephen"
Add-WeightRecord -CattleID 1 -WeightDate (Get-Date) -Weight 865 -RecordedBy "Stephen"

# Add weight records for cattle #2 - Charlie (showing excellent rate of gain)
Add-WeightRecord -CattleID 2 -WeightDate (Get-Date).AddDays(-120) -Weight 580 -RecordedBy "Stephen"
Add-WeightRecord -CattleID 2 -WeightDate (Get-Date).AddDays(-90) -Weight 650 -RecordedBy "Stephen"
Add-WeightRecord -CattleID 2 -WeightDate (Get-Date).AddDays(-60) -Weight 725 -RecordedBy "Stephen"
Add-WeightRecord -CattleID 2 -WeightDate (Get-Date).AddDays(-30) -Weight 805 -RecordedBy "Stephen"
Add-WeightRecord -CattleID 2 -WeightDate (Get-Date) -Weight 890 -RecordedBy "Stephen"

# Add weight records for cattle #3 - Daisy (mature cow, slower gain)
Add-WeightRecord -CattleID 3 -WeightDate (Get-Date).AddDays(-120) -Weight 1100 -RecordedBy "Stephen"
Add-WeightRecord -CattleID 3 -WeightDate (Get-Date).AddDays(-90) -Weight 1115 -RecordedBy "Stephen"
Add-WeightRecord -CattleID 3 -WeightDate (Get-Date).AddDays(-60) -Weight 1125 -RecordedBy "Stephen"
Add-WeightRecord -CattleID 3 -WeightDate (Get-Date).AddDays(-30) -Weight 1140 -RecordedBy "Stephen"
Add-WeightRecord -CattleID 3 -WeightDate (Get-Date) -Weight 1150 -RecordedBy "Stephen"

# Add weight records for cattle #4 - Duke (organic, consistent gains)
Add-WeightRecord -CattleID 4 -WeightDate (Get-Date).AddDays(-90) -Weight 620 -RecordedBy "Stephen"
Add-WeightRecord -CattleID 4 -WeightDate (Get-Date).AddDays(-60) -Weight 680 -RecordedBy "Stephen"
Add-WeightRecord -CattleID 4 -WeightDate (Get-Date).AddDays(-30) -Weight 745 -RecordedBy "Stephen"
Add-WeightRecord -CattleID 4 -WeightDate (Get-Date) -Weight 810 -RecordedBy "Stephen"

# Add weight records for cattle #5 - Rusty (steady grower)
Add-WeightRecord -CattleID 5 -WeightDate (Get-Date).AddDays(-90) -Weight 595 -RecordedBy "Stephen"
Add-WeightRecord -CattleID 5 -WeightDate (Get-Date).AddDays(-60) -Weight 655 -RecordedBy "Stephen"
Add-WeightRecord -CattleID 5 -WeightDate (Get-Date).AddDays(-30) -Weight 720 -RecordedBy "Stephen"
Add-WeightRecord -CattleID 5 -WeightDate (Get-Date) -Weight 785 -RecordedBy "Stephen"

# Add weight records for cattle #6 - Bella (heifer, moderate gains)
Add-WeightRecord -CattleID 6 -WeightDate (Get-Date).AddDays(-60) -Weight 550 -RecordedBy "Stephen"
Add-WeightRecord -CattleID 6 -WeightDate (Get-Date).AddDays(-30) -Weight 595 -RecordedBy "Stephen"
Add-WeightRecord -CattleID 6 -WeightDate (Get-Date) -Weight 640 -RecordedBy "Stephen"

Write-Host "Sample weight records added successfully!" -ForegroundColor Green

Write-Host "`nCalculating sample rate of gain..." -ForegroundColor Cyan

# Calculate rate of gain for each animal
$rog1 = Calculate-RateOfGain -CattleID 1 -StartDate (Get-Date).AddDays(-120) -EndDate (Get-Date)
$rog2 = Calculate-RateOfGain -CattleID 2 -StartDate (Get-Date).AddDays(-120) -EndDate (Get-Date)
$rog3 = Calculate-RateOfGain -CattleID 3 -StartDate (Get-Date).AddDays(-120) -EndDate (Get-Date)
$rog4 = Calculate-RateOfGain -CattleID 4 -StartDate (Get-Date).AddDays(-90) -EndDate (Get-Date)
$rog5 = Calculate-RateOfGain -CattleID 5 -StartDate (Get-Date).AddDays(-90) -EndDate (Get-Date)
$rog6 = Calculate-RateOfGain -CattleID 6 -StartDate (Get-Date).AddDays(-60) -EndDate (Get-Date)

Write-Host "`nRate of Gain Results:" -ForegroundColor Yellow
Write-Host "===================="
Write-Host "Bessie (A001): ADG = $($rog1.AverageDailyGain) lbs/day, Total Gain = $($rog1.TotalWeightGain) lbs"
Write-Host "Charlie (H002): ADG = $($rog2.AverageDailyGain) lbs/day, Total Gain = $($rog2.TotalWeightGain) lbs"
Write-Host "Daisy (A003): ADG = $($rog3.AverageDailyGain) lbs/day, Total Gain = $($rog3.TotalWeightGain) lbs"
Write-Host "Duke (O004): ADG = $($rog4.AverageDailyGain) lbs/day, Total Gain = $($rog4.TotalWeightGain) lbs"
Write-Host "Rusty (H005): ADG = $($rog5.AverageDailyGain) lbs/day, Total Gain = $($rog5.TotalWeightGain) lbs"
Write-Host "Bella (A006): ADG = $($rog6.AverageDailyGain) lbs/day, Total Gain = $($rog6.TotalWeightGain) lbs"

Write-Host "`nAdding sample invoices..." -ForegroundColor Cyan

# Single cattle invoice for Bessie
Add-Invoice -InvoiceNumber "INV-2024-001" `
    -CattleID 1 `
    -InvoiceDate (Get-Date).AddDays(-5) `
    -StartDate (Get-Date).AddDays(-120) `
    -EndDate (Get-Date).AddDays(-5) `
    -DaysOnFeed 115 `
    -PricePerDay 5.50 `
    -FeedingCost 632.50 `
    -HealthCost 75.00 `
    -TotalCost 707.50 `
    -Notes "Premium Angus heifer - excellent gains" `
    -CreatedBy "Stephen"

# Multi-cattle invoice for Heritage Beef Company (Duke and Rusty)
$lineItems = @(
    @{
        CattleID = 4
        StartDate = (Get-Date).AddDays(-90)
        EndDate = (Get-Date).AddDays(-2)
        DaysOnFeed = 88
        PricePerDay = 6.00
        FeedingCost = 528.00
        HealthCost = 85.00
        LineItemTotal = 613.00
        Notes = "Organic certified - premium pricing"
    },
    @{
        CattleID = 5
        StartDate = (Get-Date).AddDays(-90)
        EndDate = (Get-Date).AddDays(-2)
        DaysOnFeed = 88
        PricePerDay = 5.75
        FeedingCost = 506.00
        HealthCost = 65.00
        LineItemTotal = 571.00
        Notes = "Excellent feed conversion"
    }
)

Add-Invoice -InvoiceNumber "INV-2024-002" `
    -InvoiceDate (Get-Date).AddDays(-2) `
    -LineItems $lineItems `
    -TotalCost 1184.00 `
    -Notes "Bulk order - 2 head ready for processing" `
    -CreatedBy "Stephen"

# Multi-cattle invoice for Smith Family Farms (Bessie and Charlie - completed feeding period)
$lineItems2 = @(
    @{
        CattleID = 1
        StartDate = (Get-Date).AddDays(-120)
        EndDate = (Get-Date)
        DaysOnFeed = 120
        PricePerDay = 5.50
        FeedingCost = 660.00
        HealthCost = 85.00
        LineItemTotal = 745.00
        Notes = "Completed full feeding cycle"
    },
    @{
        CattleID = 2
        StartDate = (Get-Date).AddDays(-120)
        EndDate = (Get-Date)
        DaysOnFeed = 120
        PricePerDay = 5.25
        FeedingCost = 630.00
        HealthCost = 70.00
        LineItemTotal = 700.00
        Notes = "Outstanding daily gains"
    }
)

Add-Invoice -InvoiceNumber "INV-2024-003" `
    -InvoiceDate (Get-Date) `
    -LineItems $lineItems2 `
    -TotalCost 1445.00 `
    -Notes "Full feeding program completed - ready for market" `
    -CreatedBy "Stephen"

Write-Host "Sample invoices added successfully!" -ForegroundColor Green

Write-Host "`nDatabase setup complete!" -ForegroundColor Green
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  - 6 farms (3 origin, 3 owner)" -ForegroundColor White
Write-Host "  - 6 cattle with farm associations" -ForegroundColor White
Write-Host "  - 23 weight records" -ForegroundColor White
Write-Host "  - 3 invoices (1 single, 2 multi-cattle)" -ForegroundColor White
Write-Host "`nDatabase location: $(Split-Path $modulePath)\data\HerdManager.db" -ForegroundColor Cyan
Write-Host "`nYou can now view all features in your PowerShell Universal dashboard:" -ForegroundColor Cyan
Write-Host "  - Farm Management page" -ForegroundColor White
Write-Host "  - Cattle Management with origin/owner farms" -ForegroundColor White
Write-Host "  - Rate of Gain analysis" -ForegroundColor White
Write-Host "  - Invoice display with farm billing details" -ForegroundColor White
