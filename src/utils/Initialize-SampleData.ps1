# Sample Data Script for Gundy Ridge Herd Manager
# This script creates sample cattle and weight records for testing

# Import the database helpers
Import-Module "$PSScriptRoot\DatabaseHelpers.psm1" -Force

Write-Host "Initializing database..." -ForegroundColor Cyan
Initialize-HerdDatabase

Write-Host "`nAdding sample cattle..." -ForegroundColor Cyan

# Add some sample cattle
$cattle1 = @{
    TagNumber = "001"
    Name = "Bessie"
    Breed = "Angus"
    Gender = "Heifer"
    BirthDate = (Get-Date).AddYears(-2)
    PurchaseDate = (Get-Date).AddYears(-1).AddMonths(-6)
    Notes = "Good disposition, excellent genetics"
}
Add-CattleRecord @cattle1

$cattle2 = @{
    TagNumber = "002"
    Name = "Charlie"
    Breed = "Hereford"
    Gender = "Steer"
    BirthDate = (Get-Date).AddYears(-1).AddMonths(-8)
    PurchaseDate = (Get-Date).AddYears(-1).AddMonths(-2)
    Notes = "Fast grower"
}
Add-CattleRecord @cattle2

$cattle3 = @{
    TagNumber = "003"
    Name = "Daisy"
    Breed = "Angus"
    Gender = "Cow"
    BirthDate = (Get-Date).AddYears(-4)
    PurchaseDate = (Get-Date).AddYears(-3)
    Notes = "Mature breeding cow"
}
Add-CattleRecord @cattle3

Write-Host "Sample cattle added successfully!" -ForegroundColor Green

Write-Host "`nAdding sample weight records..." -ForegroundColor Cyan

# Add weight records for cattle #1 (showing good rate of gain)
Add-WeightRecord -CattleID 1 -WeightDate (Get-Date).AddDays(-120) -Weight 650 -RecordedBy "Stephen"
Add-WeightRecord -CattleID 1 -WeightDate (Get-Date).AddDays(-90) -Weight 700 -RecordedBy "Stephen"
Add-WeightRecord -CattleID 1 -WeightDate (Get-Date).AddDays(-60) -Weight 755 -RecordedBy "Stephen"
Add-WeightRecord -CattleID 1 -WeightDate (Get-Date).AddDays(-30) -Weight 810 -RecordedBy "Stephen"
Add-WeightRecord -CattleID 1 -WeightDate (Get-Date) -Weight 865 -RecordedBy "Stephen"

# Add weight records for cattle #2 (showing excellent rate of gain)
Add-WeightRecord -CattleID 2 -WeightDate (Get-Date).AddDays(-120) -Weight 580 -RecordedBy "Stephen"
Add-WeightRecord -CattleID 2 -WeightDate (Get-Date).AddDays(-90) -Weight 650 -RecordedBy "Stephen"
Add-WeightRecord -CattleID 2 -WeightDate (Get-Date).AddDays(-60) -Weight 725 -RecordedBy "Stephen"
Add-WeightRecord -CattleID 2 -WeightDate (Get-Date).AddDays(-30) -Weight 805 -RecordedBy "Stephen"
Add-WeightRecord -CattleID 2 -WeightDate (Get-Date) -Weight 890 -RecordedBy "Stephen"

# Add weight records for cattle #3 (mature cow, slower gain)
Add-WeightRecord -CattleID 3 -WeightDate (Get-Date).AddDays(-120) -Weight 1100 -RecordedBy "Stephen"
Add-WeightRecord -CattleID 3 -WeightDate (Get-Date).AddDays(-90) -Weight 1115 -RecordedBy "Stephen"
Add-WeightRecord -CattleID 3 -WeightDate (Get-Date).AddDays(-60) -Weight 1125 -RecordedBy "Stephen"
Add-WeightRecord -CattleID 3 -WeightDate (Get-Date).AddDays(-30) -Weight 1140 -RecordedBy "Stephen"
Add-WeightRecord -CattleID 3 -WeightDate (Get-Date) -Weight 1150 -RecordedBy "Stephen"

Write-Host "Sample weight records added successfully!" -ForegroundColor Green

Write-Host "`nCalculating sample rate of gain..." -ForegroundColor Cyan

# Calculate rate of gain for each animal
$rog1 = Calculate-RateOfGain -CattleID 1 -StartDate (Get-Date).AddDays(-120) -EndDate (Get-Date)
$rog2 = Calculate-RateOfGain -CattleID 2 -StartDate (Get-Date).AddDays(-120) -EndDate (Get-Date)
$rog3 = Calculate-RateOfGain -CattleID 3 -StartDate (Get-Date).AddDays(-120) -EndDate (Get-Date)

Write-Host "`nRate of Gain Results:" -ForegroundColor Yellow
Write-Host "===================="
Write-Host "Bessie (001): ADG = $($rog1.AverageDailyGain) lbs/day, Total Gain = $($rog1.TotalWeightGain) lbs"
Write-Host "Charlie (002): ADG = $($rog2.AverageDailyGain) lbs/day, Total Gain = $($rog2.TotalWeightGain) lbs"
Write-Host "Daisy (003): ADG = $($rog3.AverageDailyGain) lbs/day, Total Gain = $($rog3.TotalWeightGain) lbs"

Write-Host "`nDatabase setup complete!" -ForegroundColor Green
Write-Host "Database location: $PSScriptRoot\HerdManager.db" -ForegroundColor Cyan
Write-Host "`nYou can now view the Rate of Gain page in your PowerShell Universal dashboard." -ForegroundColor Cyan
