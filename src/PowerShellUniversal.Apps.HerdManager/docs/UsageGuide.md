<!-- Copy of Usage Guide for in-app help -->
<!-- This file is intended to be displayed inside the dashboard Help page -->

# 📖 Gundy Ridge Herd Manager - Usage Guide

A comprehensive guide to using all features of the Herd Manager application.

---

## Table of Contents

- [Getting Started](#getting-started)
- [System Settings](#system-settings)
- [Cattle Management](#cattle-management)
- [Farm Management](#farm-management)
- [Weight Management](#weight-management)
- [Health Records](#health-records)
- [Feed Records](#feed-records)
- [Rate of Gain Tracking](#rate-of-gain-tracking)
- [Animal Reports](#animal-reports)
- [Accounting & Invoicing](#accounting--invoicing)
- [Notifications Dashboard](#notifications-dashboard)
- [Reports & Analytics](#reports--analytics)
- [Tips & Best Practices](#tips--best-practices)

---

## Getting Started

### Accessing the Application

1. Open your web browser
2. Navigate to your PowerShell Universal server URL followed by `/herdmanager`
   - Example: `http://localhost:5000/herdmanager`
3. The dashboard will load with the navigation menu on the left

### Navigation Overview

The application has 9 main sections accessible from the side navigation:

- **Home**: Dashboard overview with quick stats
- **🔔 Notifications**: Alerts for overdue health events and weight checks
- **Settings**: System configuration (Farm info, currency/culture, Established)
- **Cattle Management**: Add, edit, and view all cattle records
- **Weight Management**: Record and track weight measurements
- **Health Records**: Track medical history and upcoming treatments
- **Feed Records**: Log daily feed mix quantities
- **Rate of Gain**: Calculate and analyze performance metrics
- **Animal Report**: Generate comprehensive individual animal reports
- **Accounting**: Generate and manage invoices for cattle billing
- **Reports**: View herd-wide analytics and summaries

---

## System Settings

The application includes a System Settings page where you can store farm-level metadata used throughout the app (Farm name, address, phone/email, default currency/culture, notes, and an "Established" year).

### Accessing System Settings

1. From the side navigation, open **Settings** → **System Settings**
2. Edit values in the form and click Save

### Established field behavior

- The UI asks for a simple 4-digit year (e.g. `2000`) for the Established field to keep things simple.
- You may also set the value from the CLI using `Set-SystemInfo` with a year, a date string (e.g. `2000-05-06`), or a DateTime object. A year is stored as January 1st of that year (`2000` → `2000-01-01`).

Examples:

```powershell
# Set by year
Set-SystemInfo -Established 2000

# Set by date string
Set-SystemInfo -Established '2000-05-06'

# The UI may send array-wrapped values; Set-SystemInfo accepts arrays and will normalize them
Set-SystemInfo -Established @('2001')
```

### Migrations and deployment notes

- If your database is missing the `SystemInfo` table or `Established` column you can run the provided migrations:
  - `src\PowerShellUniversal.Apps.HerdManager\data\Migrate-AddSystemInfo.ps1`
  - `src\PowerShellUniversal.Apps.HerdManager\data\Migrate-AddSystemInfoEstablished.ps1`
- After running migrations or changing function signatures, restart the PowerShell Universal service so the dashboard runspace picks up the updated code, or copy the module files into the installed module path and restart the service.
  - A helper is provided to copy the module to the installed location and optionally restart the service: `src\tools\Sync-InstalledModule.ps1`.
    - Example (requires Admin): `\path\to\repo\src\tools\Sync-InstalledModule.ps1 -RestartService`

### Troubleshooting

- Error "Cannot convert the System.Object[] value ... to type System.DateTime" when saving Established: this was caused by a DatePicker control returning an array. The System Settings UI now uses a simple year textbox and `Set-SystemInfo` unwraps arrays and normalizes values so this error should no longer occur.

---

## Cattle Management

### Adding a New Animal

1. Navigate to **Cattle Management** from the side menu
2. Click the **➕ Add New Cattle** button at the top of the page
3. Fill in the required fields in the modal dialog:
  - **Tag Number** (required): Unique identifier for the animal (e.g., "BR-2924")
  - **Origin Farm** (required): Farm where the animal was purchased or born
4. Fill in optional fields:
  - **Name**: A friendly name for the animal (optional but recommended)
  - **Breed**: Animal's breed (e.g., "Angus", "Hereford", "Charolais")
  - **Gender**: Select "Steer" or "Heifer" from dropdown
  - **Location**: Select from Pen 1-6, Quarantine, or Pasture
  - **Birth Date**: Use date picker to select birth date
  - **Purchase Date**: Date the animal was acquired
  - **Notes**: Any additional information or special considerations
5. Click **Add Cattle** to save the record
6. A success toast notification will appear confirming the addition

### Viewing Cattle Records

The cattle table displays all active animals with the following information:

- Tag Number
- Origin Farm
- Name
- Gender
- Location
- Status (Active, Sold, Deceased, Transferred)
- Birth Date

**Table Features**:

- **Search**: Use the search box at the top to filter by any field
- **Sort**: Click column headers to sort ascending or descending
- **Pagination**: Navigate through pages if you have many animals

### Editing an Existing Animal

1. Locate the animal in the cattle table
2. Click the **✏️ Edit** button in the Actions column
3. The edit modal will open with current values pre-filled
4. Modify any fields as needed:
  - Update location when moving animals between pens
  - Change status when selling or transferring animals
  - Update notes with new information
5. Click **Update** to save changes
6. The table will refresh automatically with updated information

### Importing Cattle from CSV

For bulk additions, you can import cattle records from a CSV file:

1. Click the **📂 Import from CSV** button
2. Review the CSV format requirements shown in the modal:
  - **Required columns**: TagNumber, OriginFarm
  - **Optional columns**: Name, Breed, Gender, BirthDate, PurchaseDate, Location, Notes
  - **Gender values**: Must be "Steer" or "Heifer"
  - **Location values**: Must be one of: Pen 1, Pen 2, Pen 3, Pen 4, Pen 5, Pen 6, Quarantine, Pasture
  - **Date format**: MM/dd/yyyy or yyyy-MM-dd
3. Prepare your CSV file following these requirements
4. Click or drag your CSV file to the upload area
5. The system will process and import valid records
6. A summary will show successful imports and any errors

**Example CSV**:

```csv
TagNumber,OriginFarm,Name,Breed,Gender,Location,BirthDate,PurchaseDate,Notes
BR-1001,Smith Farm,Duke,Angus,Steer,Pen 1,01/15/2024,03/20/2024,Good temperament
BR-1002,Jones Ranch,Bessie,Hereford,Heifer,Pen 2,02/10/2024,04/01/2024,
```

### Managing Animal Status

Change an animal's status to track their lifecycle:

1. Edit the animal record
2. Select new status from dropdown:
  - **Active**: Currently in your herd
  - **Sold**: Animal has been sold
  - **Deceased**: Animal has died (removed from active management)
  - **Transferred**: Moved to another location/operation
3. Click **Update**

> **Note**: Changing status to Sold, Deceased, or Transferred will remove the animal from active lists but retain all historical data.

---

## Farm Management

The Farms page lets you register and manage farms/ranches used as origins and owners for cattle records. Use it to keep contact information, mark origins for cattle, and manage active/inactive farm status.

### Accessing the Farms Page

1. From the side navigation, click **Farms** (🚜) or open `/farms`
2. The page includes a form to add new farms and a table listing all existing farms

### Adding a New Farm

1. Fill in the **Add New Farm** form:
   - **Farm Name** (required)
   - Contact Person
   - Street Address, City, State, Zip Code
   - Phone Number, Email
   - Notes
   - **Is Origin** checkbox — mark this when the farm supplies cattle (it will then appear in the Origin Farm selection when adding cattle)
2. Click **➕ Add Farm** to save
3. A success toast will confirm the farm was added and the farms table will refresh

### Editing a Farm

1. In the **All Farms** table, click **✏️ Edit** for the farm you want to change
2. Modify any fields in the modal, including toggling **This farm is a cattle origin** and **Active** flags
3. Click **Save Changes** to persist updates

### Farms Table Features

- Columns: Farm Name, Contact, City, State, Phone, Email, Is Origin, Active, Actions
- **Is Origin** and **Active** are shown as chips for quick visual scanning
- Sorting, searching, pagination (10 rows per page)

### Integration with Cattle Management

- **Origin Farm** (required when adding cattle) only shows farms marked with **Is Origin**. Start typing to autocomplete.
- **Owner** field shows all active farms in a dropdown; if no farms exist, a textbox is shown instead to allow manual entry.
- When a farm is edited it updates linked cattle records for display and reporting — historical links are preserved.

### CLI: Farm Commands

```powershell
# Add a farm
Add-Farm -FarmName "Smith Ranch" -Address "123 Farm Road" -City "Anytown" -State "TX" -ZipCode "12345" -PhoneNumber "555-1234" -Email "smith@ranch.com" -ContactPerson "John Smith"

# Add a farm and mark it as an origin
Add-Farm -FarmName "Jones Cattle Co" -PhoneNumber "555-5678" -IsOrigin

# Query farms
Get-Farm -ActiveOnly
Get-Farm -OriginOnly
Get-Farm -FarmID 1
Get-Farm -FarmName "Smith Ranch"

# Update a farm
Update-Farm -FarmID 2 -IsOrigin 1
Update-Farm -FarmID 3 -IsActive 0  # deactivate
```

### Database & Migrations

- The repository provides migration scripts to add the Farms table and link cattle to farms:
  - `src\Add-FarmsTable.ps1` — add Farms table
  - `src\Add-OriginFarmIDColumn.ps1` — add OriginFarmID to Cattle table
  - `src\Add-IsOriginColumn.ps1` — add IsOrigin boolean to Farms table
- After running migrations, restart the dashboard runspace or copy the updated module into the installed modules path and restart PowerShell Universal so the UI picks up the changes.

### Best Practices

- Mark origin farms correctly so imports and cattle additions use the correct Origin Farm
- Keep farm names unique for easier search and autocomplete
- Keep contact info up to date for invoices and owner communications
- Deactivate farms you no longer use instead of deleting them to preserve historical data


## Weight Management

### Recording a Weight Measurement

1. Navigate to **Weight Management**
2. Click **➕ Add Weight Record** button
3. In the modal that opens:
  - **Select Cattle**: Use the autocomplete dropdown to find the animal
    - Type tag number or name to search
    - Only active animals appear in the list
  - **Weight Date**: Select the date the measurement was taken
  - **Weight**: Enter the weight value (numbers only)
  - **Weight Unit**: Select "lbs" (pounds) or "kg" (kilograms)
  - **Measurement Method**: Optional - specify how weight was obtained
    - Examples: "Scale", "Visual Estimate", "Tape Measure"
  - **Notes**: Optional - add context like "Before feeding" or "After transport"
  - **Recorded By**: Optional - name of person who took the measurement
4. Click **Add Weight Record** to save
5. The weight history table will update automatically

### Viewing Weight History

The Weight Management page shows all weight records in a sortable, searchable table:

**Table Columns**:

- **Tag #**: Animal's tag number (clickable link to view details)
- **Name**: Animal's name
- **Weight Date**: When the measurement was taken
- **Weight**: Value with unit (e.g., "850.00 lbs")
- **Method**: How the weight was obtained
- **Recorded By**: Who took the measurement
- **Actions**: Delete button for removing erroneous records

**Using the Table**:

- **Search**: Filter by tag number, name, or any text field
- **Sort**: Click column headers to sort by that field
- **Pagination**: Shows 15 records per page by default
- **Delete Records**: Click trash icon to remove a weight record (requires confirmation)

### Deleting a Weight Record

If a weight was recorded incorrectly:

1. Locate the record in the weight history table
2. Click the **🗑️ trash icon** in the Actions column
3. A confirmation modal will appear showing the record details
4. Click **Delete** to confirm removal
5. Click **Cancel** to keep the record

> **Warning**: Deleting a weight record will also remove any Rate of Gain calculations that used that measurement.

### Weight Tracking Best Practices

- **Consistency**: Weigh at the same time of day (preferably before feeding)
- **Frequency**: Record weights every 30-60 days for accurate gain tracking
- **Method**: Note measurement method for context
- **Validation**: Double-check extreme values before saving
- **Notes**: Add context like weather conditions, animal health status, or recent activity

---

## Health Records

### Adding a Health Record

1. Navigate to **Health Records**
2. Click **➕ Add Health Record** button
3. Fill in the health record form:

**Required Fields**:

- **Select Cattle**: Choose the animal from the dropdown
- **Record Date**: Date of the health event
- **Record Type**: Select from:
  - Vaccination
  - Treatment
  - Observation
  - Veterinary Visit
  - Other
- **Title**: Brief description (e.g., "Spring Vaccination", "Pink Eye Treatment")

**Optional Fields**:

- **Description**: Detailed notes about the event
- **Veterinarian Name**: Name of the vet if applicable
- **Medication**: Name of medication or vaccine administered
- **Dosage**: Amount and units (e.g., "5 ml", "2 tablets")
- **Cost**: Expense for the treatment or visit
- **Next Due Date**: When follow-up is needed (important for tracking!)
- **Notes**: Additional context or observations
- **Recorded By**: Person who administered treatment or recorded the event

4. Click **Add Health Record** to save
5. The health records table will refresh with the new entry

### Viewing Health Records

The health records table shows all medical history:

**Table Columns**:

- **Tag #**: Animal identifier
- **Name**: Animal name
- **Date**: Date of the health event
- **Type**: Record type with color-coded badge
- **Title**: Brief description
- **Medication**: Drug or vaccine used
- **Cost**: Associated expense
- **Next Due**: Follow-up date (if applicable)
- **Actions**: View details or delete

### Viewing Upcoming Health Events

Below the add form, you'll see a table of upcoming health events:

**Color Coding**:

- 🔴 **Red (≤7 days)**: Urgent - due very soon
- 🟠 **Orange (≤14 days)**: Approaching - due within 2 weeks
- 🔵 **Blue (>14 days)**: Scheduled - more than 2 weeks away

**Actions**:

- Click **Details** button to view complete event information in a modal
- The modal shows cattle info and all health event details

### Health Record Management

**Editing Records**: Currently, edit the animal's record and add a new health entry with updated information.

**Deleting Records**:

1. Find the record in the health records table
2. Click the trash icon
3. Confirm deletion in the modal
4. Record is permanently removed

### Using Health Records Effectively

**Vaccination Tracking**:

- Record all vaccinations with specific dates
- Always set Next Due Date for boosters
- Note lot numbers in Description field
- Track costs for budgeting

**Treatment Documentation**:

- Record symptoms in Description
- Document all medications and dosages
- Note treatment duration in Notes
- Set Next Due Date if follow-up needed

**Veterinary Visits**:

- Record vet's name and contact
- Document diagnosis in Description
- Note all prescribed treatments
- Track visit costs

**Observations**:

- Document unusual behavior
- Note changes in appetite or activity
- Record environmental factors
- Track resolution in follow-up notes

---

## Feed Records

### Recording Daily Feed

1. Navigate to **Feed Records**
2. The add form is at the top of the page
3. Fill in the daily feed information:
  - **Feed Date**: Defaults to today, change if recording past dates
  - **Haylage (lbs)**: Pounds of haylage in the mix
  - **Silage (lbs)**: Pounds of silage in the mix
  - **High Moisture Corn (lbs)**: Pounds of high moisture corn in the mix
  - **Notes**: Optional - weather, herd behavior, or special circumstances
  - **Recorded By**: Your name or initials (required)
4. Click **Submit**
5. Total pounds are calculated automatically
6. A success notification confirms the record was saved

