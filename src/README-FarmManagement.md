# Farm Management Feature

## Overview
The Farm Management feature allows you to track and organize information about farms/ranches where cattle originate and who owns them. Each cattle record can now be linked to a Farm record for better organization and contact management.

**Key Features:**
- **Origin Farms** - Mark farms as cattle origins for the "Origin Farm" dropdown when adding cattle
- **Owner Tracking** - All farms available in the "Owner" dropdown for ownership tracking
- **Contact Management** - Store complete contact information for each farm
- **Dynamic Dropdowns** - Owner field automatically switches between dropdown (when farms exist) and textbox (when no farms exist)

## Database Updates Required

### Step 1: Add Farms Table
Run this script to add the Farms table to your database:

```powershell
.\src\Add-FarmsTable.ps1 -DatabasePath "C:\ProgramData\UniversalAutomation\Repository\Modules\PowerShellUniversal.Apps.HerdManager\data\HerdManager.db"
```

### Step 2: Add OriginFarmID Column to Cattle Table
Run this script to link cattle to farms:

```powershell
.\src\Add-OriginFarmIDColumn.ps1 -DatabasePath "C:\ProgramData\UniversalAutomation\Repository\Modules\PowerShellUniversal.Apps.HerdManager\data\HerdManager.db"
```

### Step 3: Add IsOrigin Column to Farms Table
Run this script to enable origin farm filtering:

```powershell
.\src\Add-IsOriginColumn.ps1 -DatabasePath "C:\ProgramData\UniversalAutomation\Repository\Modules\PowerShellUniversal.Apps.HerdManager\data\HerdManager.db"
```

## Features

### Farms Page

Access the Farms page from the main navigation menu (🚜 icon).

**Add New Farm:**

- Farm Name (required)
- Contact Person
- Street Address
- City, State, Zip Code
- Phone Number
- Email Address
- Notes
- **Is Origin** checkbox - Mark farm as a cattle origin

**Farm Table:**

- View all farms in a sortable, searchable table
- **Is Origin** column shows which farms are cattle origins
- Edit farm details
- See active/inactive status
- 10 farms per page with pagination

### Cattle Integration

**When Adding Cattle:**

- **Origin Farm** field is an autocomplete dropdown showing ONLY farms marked as origins
- Start typing to search for existing origin farms
- The OriginFarmID is automatically saved
- **Owner** field dynamically adapts:
  - **Dropdown** when farms exist - shows ALL active farms
  - **Textbox** when no farms exist - manual entry

**When Editing Cattle:**

- **Origin Farm** dropdown shows current farm (origins only)
- Change origin by selecting a different origin farm
- **Owner** dropdown shows all active farms
- Farm links are preserved in database

### PowerShell Functions

#### Add-Farm

```powershell
# Add a basic farm
Add-Farm -FarmName "Smith Ranch" -Address "123 Farm Road" -City "Anytown" -State "TX" -ZipCode "12345" -PhoneNumber "555-1234" -Email "smith@ranch.com" -ContactPerson "John Smith"

# Add a farm marked as a cattle origin
Add-Farm -FarmName "Jones Cattle Co" -PhoneNumber "555-5678" -IsOrigin
```

#### Get-Farm

```powershell
# Get all active farms
Get-Farm -ActiveOnly

# Get only origin farms (for Origin Farm dropdown)
Get-Farm -OriginOnly

# Get farm by ID
Get-Farm -FarmID 1

# Get farm by name
Get-Farm -FarmName "Smith Ranch"

# Get all farms (including inactive)
Get-Farm -All
```

#### Update-Farm

```powershell
# Update contact info
Update-Farm -FarmID 1 -PhoneNumber "555-9999" -Email "newemail@ranch.com"

# Mark a farm as an origin
Update-Farm -FarmID 2 -IsOrigin 1

# Deactivate a farm
Update-Farm -FarmID 3 -IsActive 0
```

## Data Model

### Farms Table Fields

- **FarmID** - Primary key (auto-increment)
- **FarmName** - Name of the farm/ranch
- **Address** - Street address
- **City** - City name
- **State** - State abbreviation
- **ZipCode** - Postal code
- **PhoneNumber** - Contact phone
- **Email** - Contact email
- **ContactPerson** - Primary contact name
- **Notes** - Additional information
- **IsOrigin** - Cattle origin flag (1 = origin farm, 0 = not an origin)
- **IsActive** - Active status (1 = active, 0 = inactive)
- **CreatedDate** - Creation timestamp
- **ModifiedDate** - Last modification timestamp

### Cattle Table Additions

- **OriginFarmID** - Foreign key to Farms table (optional)
- **OriginFarm** - Text field (kept for backward compatibility)

## Benefits

1. **Organized Contact Info** - Keep all farm contact details in one place
2. **Easy Updates** - Update farm info once, applies to all linked cattle
3. **Better Reporting** - Group and analyze cattle by farm
4. **Historical Data** - Maintain farm records even after cattle are sold
5. **Flexible Dropdowns**:
   - Origin farms only shown for cattle origin selection
   - All farms available for ownership tracking
   - Automatic fallback to textbox when no farms exist
6. **Clear Categorization** - Distinguish between origin farms and owner farms

## Backward Compatibility

- Existing cattle records continue to work
- OriginFarm text field is still supported
- New cattle can use either farm dropdown or text entry
- No data loss during migration
- Farms without IsOrigin flag can still be used as owners
