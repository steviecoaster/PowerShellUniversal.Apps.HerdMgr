# Feed Recipe Management System

## Overview

The Feed Recipe Management system provides flexible configuration of feed ingredients, allowing you to customize what ingredients are tracked and dynamically generate UI sliders based on the active recipe configuration.

## Key Features

- **Dynamic Recipe Configuration**: Define custom feed recipes with any number of ingredients
- **Multiple Recipes**: Store multiple recipe configurations and switch between them
- **Flexible UI**: Dashboard automatically generates sliders based on active recipe
- **Tonnage Reporting**: Query feed consumption by ingredient over time with monthly breakdowns
- **Backward Compatible**: Supports legacy column-based feed records

## Database Schema

### FeedRecipes Table
Stores recipe definitions:
- `RecipeID`: Primary key
- `RecipeName`: Unique name for the recipe
- `Description`: Optional description
- `IsActive`: Boolean flag (only one recipe can be active)
- `CreatedDate`, `ModifiedDate`: Timestamps

### FeedIngredients Table
Stores ingredients for each recipe:
- `IngredientID`: Primary key
- `RecipeID`: Foreign key to FeedRecipes
- `IngredientName`: Name of the ingredient
- `DisplayOrder`: Order to display in UI
- `MinValue`, `MaxValue`: Slider range (default 0-10000)
- `DefaultValue`: Default slider value
- `Unit`: Measurement unit (default 'lbs')

### FeedRecords Updates
Added `IngredientAmounts` column:
- Stores JSON object with ingredient amounts: `{"Corn Silage": 5000, "Supplement": 200}`
- Legacy columns (`HaylagePounds`, `SilagePounds`, `HighMoistureCornPounds`) still supported

## Setup Instructions

### 1. Run the Migration Script

```powershell
# Navigate to the data directory
cd src\PowerShellUniversal.Apps.HerdManager\data

# Run the migration
.\Migrate-AddFeedRecipes.ps1 -DatabasePath "path\to\HerdManager.db"
```

This creates the new tables and seeds a default recipe with five ingredients:
- Corn Silage
- High Moisture Corn
- Supplement
- Dry Hay
- Haylage

### 2. Replace FeedRecords Page

Rename or backup the existing `FeedRecords.ps1`:
```powershell
cd ..\dashboards\HerdManager\pages
Move-Item FeedRecords.ps1 FeedRecords-Legacy.ps1
Move-Item FeedRecords-New.ps1 FeedRecords.ps1
```

### 3. Reload the Dashboard

Restart PowerShell Universal or reload the dashboard to see the new dynamic UI.

## Using the Recipe Management Functions

### Get Active Recipe

```powershell
# Get active recipe (without ingredients)
$recipe = Get-Recipe

# Get active recipe with ingredients
$recipe = Get-Recipe -IncludeIngredients

# View ingredients
$recipe.Ingredients | Format-Table
```

### Get All Recipes

```powershell
# Get all recipes
Get-Recipe -All

# Get specific recipe by name
Get-Recipe -RecipeName "Standard Feed Mix" -IncludeIngredients
```

### Create a New Recipe

```powershell
# Define ingredients
$ingredients = @(
    @{Name = 'Corn Silage'; DisplayOrder = 1; MinValue = 0; MaxValue = 15000; DefaultValue = 0}
    @{Name = 'Grain Mix'; DisplayOrder = 2; MinValue = 0; MaxValue = 5000; DefaultValue = 0}
    @{Name = 'Protein Supplement'; DisplayOrder = 3; MinValue = 0; MaxValue = 2000; DefaultValue = 0}
)

# Create recipe and set as active
Set-Recipe -RecipeName "High Energy Winter Mix" `
           -Description "Increased calories for winter feeding" `
           -Ingredients $ingredients `
           -SetActive
```

### Switch Active Recipe

```powershell
# Get recipe ID
$recipe = Get-Recipe -RecipeName "Standard Feed Mix"

# Set as active
Set-Recipe -RecipeID $recipe.RecipeID -SetActive
```

### Update Recipe Description

```powershell
Set-Recipe -RecipeID 1 -Description "Updated description for standard mix"
```

## Adding Feed Records

### Using Dynamic Ingredients

```powershell
# Add feed record with dynamic recipe
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

### Using Legacy Parameters (Still Supported)

```powershell
Add-FeedRecord -FeedDate (Get-Date) `
               -HaylagePounds 5000 `
               -SilagePounds 8000 `
               -HighMoistureCornPounds 3000 `
               -RecordedBy "Brandon"
```

## Tonnage Reporting

### Get Total Tonnage for Date Range

```powershell
# Get totals from Jan 1 to today
Get-FeedTonnageReport -StartDate "2025-01-01" -EndDate (Get-Date)
```

### Get Monthly Breakdown

```powershell
# Get monthly tonnage breakdown
Get-FeedTonnageReport -StartDate "2025-01-01" -EndDate (Get-Date) -GroupByMonth

# Output includes:
# Period, Ingredient, TotalPounds, TotalTons, MonthName
```

### Filter by Specific Ingredient

```powershell
# Get tonnage for corn silage only
Get-FeedTonnageReport -StartDate "2025-01-01" `
                      -IngredientName "Corn Silage" `
                      -GroupByMonth
```

### Export Report to CSV

```powershell
# Generate and export report
Get-FeedTonnageReport -StartDate "2025-01-01" -GroupByMonth |
    Export-Csv -Path "FeedTonnageReport_$(Get-Date -Format 'yyyy-MM').csv" -NoTypeInformation
```

## Dashboard UI Features

### Dynamic Slider Generation

The new FeedRecords page automatically generates sliders for each ingredient in the active recipe:
- Reads `IngredientName`, `MinValue`, `MaxValue`, and `DefaultValue` from the database
- Creates labeled sliders in display order
- Shows units (e.g., "Corn Silage (lbs)")

### Tonnage Report Card

Interactive reporting interface allows:
- Date range selection with pickers
- "Group by Month" checkbox
- Summary statistics (total tonnage, ingredients tracked)
- Detailed table with sorting and searching
- Auto-refresh when feed records are added/deleted

### Feed Records Table

Dynamically displays columns based on active recipe:
- Shows current recipe ingredients as columns
- Falls back to legacy columns if no active recipe
- Parses JSON ingredient amounts for display
- Formatted numbers with thousand separators

## Migration Path for Existing Data

### Existing Records

Legacy feed records (using `HaylagePounds`, `SilagePounds`, `HighMoistureCornPounds`) are fully supported:
- The tonnage report function reads both formats
- The table view displays both formats correctly
- No data loss or conversion required

### Gradual Transition

You can use both systems simultaneously:
1. Legacy column-based records continue to work
2. New records can use `IngredientAmounts` JSON format
3. Reports aggregate both formats correctly

### Future Deprecation (Optional)

If you want to fully migrate to the new system:
1. Write a script to convert legacy records to JSON format
2. Update old records' `IngredientAmounts` column
3. Keep legacy columns for audit trail

## Troubleshooting

### No Active Recipe Warning

If you see "No active recipe found":
```powershell
# Check existing recipes
Get-Recipe -All

# Set one as active
Set-Recipe -RecipeID 1 -SetActive
```

### Sliders Not Appearing

Ensure:
1. Migration script ran successfully
2. Active recipe has ingredients
3. Dashboard was reloaded after migration

### Tonnage Report Shows No Data

Check:
1. Feed records exist in date range
2. Records have either legacy columns or `IngredientAmounts` populated
3. Ingredient names match between recipe and records

## Best Practices

### Recipe Naming

Use descriptive names that indicate season or purpose:
- "Standard Feed Mix"
- "Winter High Energy"
- "Summer Maintenance"
- "Finishing Ration"

### Ingredient Naming

Be consistent with ingredient names:
- Use proper capitalization
- Avoid abbreviations unless standard
- Match names exactly in recipes and custom code

### Slider Ranges

Set realistic `MaxValue` for each ingredient:
- Consider typical daily herd consumption
- Allow some overhead for growth or weather events
- Default values can be non-zero for common amounts

### Recipe Changes

When changing recipes:
1. Create new recipe first (don't modify active)
2. Test with sample feed record
3. Switch active recipe only after validation
4. Keep old recipes for historical reference

## API Reference

### Functions

| Function | Purpose |
|----------|---------|
| `Get-Recipe` | Retrieve recipe(s) and ingredients |
| `Set-Recipe` | Create or update recipes |
| `Add-FeedRecord` | Add daily feed records (supports dynamic ingredients) |
| `Get-FeedTonnageReport` | Generate tonnage reports by ingredient |

### Common Parameters

- `-IncludeIngredients`: Add ingredient details to recipe objects
- `-SetActive`: Make a recipe the active one
- `-GroupByMonth`: Break down reports by month
- `-IngredientAmounts`: Hashtable of ingredient amounts (new format)

## Future Enhancements

Potential improvements:
- Recipe versioning and change history
- Cost tracking per ingredient
- Nutritional analysis (protein, energy, etc.)
- Ingredient inventory management
- Forecasting and trend analysis
- Mobile app support for field data entry

## Support

For questions or issues:
1. Check function help: `Get-Help Get-Recipe -Full`
2. Verify migration completed: Check for `FeedRecipes` and `FeedIngredients` tables
3. Review error messages in dashboard toast notifications
4. Check PowerShell Universal logs for detailed errors
