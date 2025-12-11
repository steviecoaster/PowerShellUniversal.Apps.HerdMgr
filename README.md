# 🐄 Gundy Ridge Herd Manager

A comprehensive cattle management application built with PowerShell Universal, designed to streamline livestock tracking, weight monitoring, health records, and performance analytics for cattle operations.

## 📋 Overview

Gundy Ridge Herd Manager is a web-based application that provides ranchers and livestock managers with powerful tools to track and analyze their cattle herd. Built on PowerShell Universal Dashboard, it offers an intuitive interface for managing all aspects of cattle operations from a single platform.

## ✨ Key Features

### 🐮 Cattle Management

- **Comprehensive Animal Profiles**: Track individual animals with tag numbers, names, breed, gender, birth dates, origin farm, and current location
- **Farm Integration**: Link cattle to farm records for origin and ownership tracking
- **Location Tracking**: Manage cattle across 6 pens, quarantine area, and pasture
- **Status Tracking**: Monitor animal status (Active, Sold, Deceased, Transferred)
- **CSV Import**: Bulk import cattle records from CSV files
- **Searchable Database**: Quick search and filter capabilities across all cattle records
- **Dynamic Dropdowns**: Smart form fields that adapt based on available farm data

### 🏡 Farm Management

- **Farm Registry**: Maintain complete farm/ranch contact information
- **Origin Tracking**: Mark farms as cattle origins for specialized filtering
- **Contact Management**: Store addresses, phone numbers, emails, and contact persons
- **Owner Tracking**: All farms available for cattle ownership assignment
- **Smart Dropdowns**: Origin Farm dropdown shows only origin farms; Owner dropdown shows all farms
- **Active/Inactive Status**: Manage farm lifecycle without data loss
- **Edit Capabilities**: Update farm information including origin status anytime

### ⚖️ Weight Management

- **Weight Recording**: Log weight measurements with dates and measurement methods
- **Weight History**: View complete weight history for each animal with trend visualization
- **Automatic Calculations**: Track weight gain over time
- **Multiple Units**: Support for pounds (lbs) and kilograms (kg)

### 📈 Rate of Gain Analysis

- **Average Daily Gain (ADG)**: Calculate and track ADG between any two weight measurements
- **Historical Tracking**: View complete ROG calculation history for performance analysis
- **Period Comparisons**: Compare performance across different time periods
- **Automated Calculations**: Compute total gain, days between measurements, and daily averages

### 🏥 Health Records

- **Medical History**: Track vaccinations, treatments, veterinary visits, and observations
- **Medication Tracking**: Record medications, dosages, and administration dates
- **Cost Tracking**: Monitor veterinary and treatment expenses
- **Due Date Reminders**: Track next vaccination or treatment due dates
- **Overdue Alerts**: Automatic notifications for overdue health events

### 🍽️ Feed Records

- **Daily Feed Tracking**: Record daily feed mix quantities (haylage, silage, high moisture corn)
- **Feed History**: View complete feeding history with searchable records
- **Total Calculations**: Automatic calculation of total feed pounds per day
- **Notes Support**: Add contextual notes for each feeding record

### 📊 Reporting & Analytics

- **Individual Animal Reports**: Comprehensive per-animal reports with complete history
- **Performance Summaries**: Current weight, starting weight, total gain, and average ADG
- **Print-Friendly Reports**: Generate printable reports for record-keeping
- **Data Visualization**: Charts and graphs for weight trends and performance metrics

### 🔔 Notifications Dashboard

- **Centralized Alerts**: View all important notifications in one place
- **Overdue Health Events**: Immediate visibility of past-due vaccinations and treatments
- **Weight Check Reminders**: Alerts for cattle needing weight measurements
- **Upcoming Events**: Color-coded display of events by urgency (red: ≤7 days, orange: ≤14 days, blue: >14 days)

### 💰 Accounting & Invoicing

- **Multi-Cattle Invoicing**: Create invoices for single or multiple cattle on one invoice
- **Invoice Generation**: Create professional invoices with automatic cost calculations
- **Cost Tracking**: Combine feeding costs (days × daily rate) and health costs (veterinary expenses)
- **Line Item Detail**: Each animal on multi-cattle invoices shows individual costs and subtotals
- **Invoice Management**: Search, view, and print invoices in a clean, professional format
- **Payment Terms**: NET 30 payment terms with automatic due date calculation
- **Print-Ready Invoices**: Professional invoice layout with company branding and contact information
- **Cost Breakdown**: Detailed itemization of feeding costs and health/veterinary expenses per animal
- **Owner Billing**: Associate cattle with farm owners for accurate billing

## 🛠️ Technical Stack

- **Platform**: PowerShell Universal Dashboard v5
- **Database**: SQLite with optimized schema and indexes
- **Language**: PowerShell 7
- **UI Framework**: Material-UI components via Universal Dashboard
- **Data Access**: PSSQLite module for database operations

## 📁 Project Structure

```text
GundyRidgeHerdManager/
├── src/
│   └── PowerShellUniversal.Apps.HerdManager/
│       ├── dashboards/
│       │   └── HerdManager/
│       │       ├── HerdManager.ps1              # Main dashboard configuration
│       │       └── pages/
│       │           ├── Homepage.ps1             # Dashboard home page
│       │           ├── Notifications.ps1        # Alerts and reminders
│       │           ├── CattleManagement.ps1     # Cattle CRUD operations
│       │           ├── WeightManagement.ps1     # Weight recording and history
│       │           ├── HealthRecords.ps1        # Health tracking
│       │           ├── FeedRecords.ps1          # Daily feed tracking
│       │           ├── Farms.ps1                # Farm management
│       │           ├── RateOfGain.ps1           # ROG calculations
│       │           ├── AnimalReport.ps1         # Individual animal reports
│       │           ├── Accounting.ps1           # Invoice management
│       │           ├── Invoice.ps1              # Invoice display page
│       │           └── Reports.ps1              # Herd-wide analytics
│       ├── functions/
│       │   └── public/
│       │       ├── Add-CattleRecord.ps1
│       │       ├── Add-WeightRecord.ps1
│       │       ├── Add-Invoice.ps1
│       │       ├── Add-Farm.ps1
│       │       ├── Get-Farm.ps1
│       │       ├── Update-Farm.ps1
│       │       ├── Calculate-RateOfGain.ps1
│       │       ├── Get-AllCattle.ps1
│       │       ├── Get-CattleById.ps1
│       │       ├── Get-Invoice.ps1
│       │       ├── Get-RateOfGainHistory.ps1
│       │       ├── Get-WeightHistory.ps1
│       │       ├── Initialize-HerdDatabase.ps1
│       │       ├── New-UDHerdManagerApp.ps1
│       │       └── Update-CattleRecord.ps1
│       ├── data/
│       │   ├── Database-Schema.sql              # Complete database schema
│       │   └── HerdManager.db                   # SQLite database
│       ├── PowerShellUniversal.Apps.HerdManager.psm1
│       ├── PowerShellUniversal.Apps.HerdManager.psd1
│       └── .universal/
│           └── dashboards.ps1                   # PSU dashboard registration
└── tests/                                       # Test files (if applicable)
```

## 🗄️ Database Schema

### Core Tables

- **Cattle**: Animal profiles with demographics, location, status, owner, and daily feeding rate
- **WeightRecords**: Complete weight measurement history
- **RateOfGainCalculations**: Computed performance metrics
- **HealthRecords**: Medical history, treatments, and associated costs
- **FeedRecords**: Daily feed mix recordings
- **Invoices**: Invoice tracking with feeding costs, health costs, and payment terms

### Views

- **CattleWithLatestWeight**: Quick access to current animal weights
- **RecentRateOfGain**: Latest performance calculations

### Indexes

Optimized indexes on frequently queried fields for fast performance

## 🚀 Installation

### Prerequisites

- PowerShell 7 or later
- PowerShell Universal (licensed or trial)
- PSSQLite PowerShell module

### Setup Steps

1. **Clone the Repository**

   ```powershell
   git clone https://github.com/steviecoaster/HerdManager.git
   cd HerdManager
   ```

2. **Install Required Modules**

   ```powershell
   Install-Module -Name PSSQLite -Scope CurrentUser
   ```

3. **Import the Module**

   ```powershell
   Import-Module .\src\PowerShellUniversal.Apps.HerdManager\PowerShellUniversal.Apps.HerdManager.psd1
   ```

4. **Initialize Database** (if starting fresh)

   ```powershell
   Initialize-HerdDatabase
   ```

5. **Register with PowerShell Universal**

   - Copy the module to your PSU modules directory, or
   - Use the `.universal\dashboards.ps1` configuration
   - Restart PowerShell Universal service

6. **Access the Dashboard**

   - Navigate to: `http://localhost:5000/herdmanager` (or your PSU URL)

## 🎨 Features in Detail

### Smart Date Handling

- Automatic date format conversion (MM/dd/yyyy HH:mm:ss)
- CAST AS TEXT in SQL queries prevents parsing errors
- Consistent date storage across all tables

### Location Management

- 8 location options: Pen 1-6, Quarantine, Pasture
- Track animal movements over time
- Filter and sort by location
- Quick location updates via edit modal

### Print Functionality

- CSS `@media print` rules for clean printouts
- Hides navigation and buttons
- Optimized layout for paper
- Professional-looking reports

### Responsive UI

- Material-UI design system
- Color-coded status indicators
- Sortable and searchable tables
- Modal dialogs for forms
- Toast notifications for feedback

### Data Validation

- Required field enforcement
- Type validation (dates, numbers, enums)
- Unique constraints (tag numbers, feed dates)
- SQL parameter binding prevents injection

### Accounting & Billing Workflow

1. **Setup**: Add Owner and PricePerDay to cattle records
2. **Track Costs**: Record health events with associated costs in HealthRecords
3. **Generate Invoice**: 
   - Select animal from dropdown
   - Set start and end dates (defaults to purchase date and current date)
   - System automatically calculates:
     - Days on feed
     - Feeding costs (Days × Price per day)
     - Health costs (Sum of all health record costs)
     - Total cost
4. **Search Invoices**: Find invoices by invoice number
5. **View/Print**: Open invoices in new tab with professional print-ready layout
6. **Payment Terms**: NET 30 with automatic due date calculation

## 🔧 Configuration

### Database Path

Configured in module: `$script:DatabasePath = Join-Path $PSScriptRoot 'data\HerdManager.db'`

### PowerShell Universal Settings

Edit `.universal\dashboards.ps1`:

```powershell
$app = @{
    Name        = "Herd Manager"
    BaseUrl     = '/herdmanager'
    Module      = 'PowerShellUniversal.Apps.HerdManager'
    Command     = 'New-UDHerdManagerApp'
    AutoDeploy  = $true
    Environment = 'PowerShell 7'
}
```

## 🧪 Development

### Adding New Features

1. Create function in `functions\public\` or `functions\private\`
2. Export public functions in `.psd1` manifest
3. Add page in `dashboards\HerdManager\pages\`
4. Register page in `HerdManager.ps1` pages array
5. Add navigation menu item if needed

### Database Changes

1. Update `data\Database-Schema.sql`
2. Run ALTER TABLE commands on existing database
3. Update affected views and functions
4. Test data migration on sample data

### Testing

- Test all CRUD operations after changes
- Verify date handling in forms and tables
- Check calculated fields (ADG, totals)
- Validate print layouts
- Ensure modal dialogs function correctly

## 📝 Notes

### Date Format Considerations

- SQLite stores dates as TEXT
- Application uses MM/dd/yyyy HH:mm:ss format
- CAST AS TEXT in queries prevents PSSQLite auto-conversion errors
- Always use -As PSObject with Invoke-SqliteQuery

### Performance Tips

- Indexes on CattleID, TagNumber, dates
- Views pre-calculate common joins
- Pagination on large tables (15-20 items per page)
- Dynamic loading with New-UDDynamic for data refresh

### Common Issues

- **Dates not displaying**: Add CAST AS TEXT to SQL query
- **Location not showing**: Check view includes Location column
- **Form not saving**: Verify SqlParameters match @Param names in query
- **Modal not opening**: Check Show-UDModal syntax and element IDs

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📞 Support

For issues, questions, or suggestions:

- Open an issue on GitHub
- Check existing documentation
- Review PowerShell Universal docs

---
