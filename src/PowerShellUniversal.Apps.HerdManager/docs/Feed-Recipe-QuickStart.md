# Feed Recipe Management - Quick Start Guide

## Step 1: Run the Migration

```powershell
# Import the module
Import-Module .\PowerShellUniversal.Apps.HerdManager.psd1 -Force

# Run migration (adjust path to your database)
.\data\Migrate-AddFeedRecipes.ps1 -DatabasePath "C:\Path\To\Your\HerdManager.db"
```

Expected output:
```
Starting Feed Recipe Migration...
Creating FeedRecipes table...
Creating FeedIngredients table...
Creating indexes...
Seeding default recipe...
  Created 'Standard Feed Mix' recipe
  Added ingredient: Corn Silage
  Added ingredient: High Moisture Corn
  Added ingredient: Supplement
  Added ingredient: Dry Hay
  Added ingredient: Haylage
Checking FeedRecords table structure...
Adding IngredientAmounts column to FeedRecords...
  Column added successfully

Migration completed successfully!
```

## Step 2: Verify the Setup

```powershell
# Check active recipe
Get-Recipe -IncludeIngredients

# Should show:
# RecipeName        : Standard Feed Mix
# Description       : Default recipe with five ingredients
# IsActive          : 1
# Ingredients       : {Corn Silage, High Moisture Corn, Supplement, Dry Hay, Haylage}
```

## Step 3: Update the Dashboard Page

### Option A: Rename Files (Recommended)

```powershell
cd dashboards\HerdManager\pages

# Backup old version
Move-Item FeedRecords.ps1 FeedRecords-Legacy.ps1

# Activate new version
Move-Item FeedRecords-New.ps1 FeedRecords.ps1
```

### Option B: Copy Content

Replace the contents of `FeedRecords.ps1` with `FeedRecords-New.ps1`

## Step 4: Restart PowerShell Universal

Reload your dashboard or restart PSU to see the changes.

## Step 5: Test the New UI

1. Navigate to Feed Records page
2. You should see 5 sliders (one for each ingredient)
3. Add a test feed record
4. Check the tonnage report section

## Quick Recipe Management Examples

### View All Recipes

```powershell
Get-Recipe -All | Format-Table RecipeID, RecipeName, IsActive
```

### Create a Custom Recipe

```powershell
$customIngredients = @(
    @{Name = 'Corn Silage'; DisplayOrder = 1; MaxValue = 20000}
    @{Name = 'Protein Pellets'; DisplayOrder = 2; MaxValue = 3000}
    @{Name = 'Mineral Mix'; DisplayOrder = 3; MaxValue = 500}
)

Set-Recipe -RecipeName "Custom Mix" `
           -Description "My custom feed recipe" `
           -Ingredients $customIngredients `
           -SetActive
```

### Switch Between Recipes

```powershell
# List recipes
Get-Recipe -All | Format-Table RecipeID, RecipeName

# Set recipe 1 as active
Set-Recipe -RecipeID 1 -SetActive
```

## Test Feed Record Entry

### Add Record with New Format

```powershell
Add-FeedRecord -FeedDate (Get-Date) `
               -IngredientAmounts @{
                   'Corn Silage' = 5000
                   'High Moisture Corn' = 3000
                   'Supplement' = 200
                   'Dry Hay' = 1500
                   'Haylage' = 4000
               } `
               -RecordedBy "Brandon"
```

### Generate Test Report

```powershell
# Get last 30 days tonnage by month
Get-FeedTonnageReport -StartDate (Get-Date).AddDays(-30) `
                      -GroupByMonth |
    Format-Table Period, Ingredient, TotalTons
```

## Troubleshooting

### "No active recipe found"

```powershell
# Set the default recipe as active
$recipe = Get-Recipe -RecipeName "Standard Feed Mix"
Set-Recipe -RecipeID $recipe.RecipeID -SetActive
```

### Sliders not showing

1. Verify migration ran: `Get-Recipe -All`
2. Check active recipe has ingredients: `Get-Recipe -IncludeIngredients`
3. Restart PSU dashboard
4. Check browser console for JS errors

### Database path issues

```powershell
# Check current database path
Get-DatabasePath

# Verify file exists
Test-Path (Get-DatabasePath)
```

## Next Steps

- Read full documentation: `docs\Feed-Recipe-Management.md`
- Create seasonal recipes for different feed strategies
- Set up regular tonnage reports (monthly/quarterly)
- Export tonnage data for cost analysis

## Rollback (If Needed)

If you need to revert to the old system:

```powershell
cd dashboards\HerdManager\pages

# Restore old page
Move-Item FeedRecords.ps1 FeedRecords-New.ps1
Move-Item FeedRecords-Legacy.ps1 FeedRecords.ps1

# Restart PSU
```

The new database tables won't affect old functionality.
