# Multi-Cattle Invoice Feature

## Overview

The Herd Manager now supports creating invoices with multiple cattle on a single invoice. This is useful when billing a single owner for multiple animals.

## Features

- **Select Multiple Cattle**: Use the cattle selector in the Accounting page to choose one or more animals
- **Automatic Calculations**: Each animal's feeding costs and health costs are calculated separately
- **Detailed Breakdown**: Multi-cattle invoices show individual line items for each animal with subtotals
- **Backward Compatible**: Existing single-cattle invoices continue to work without any changes
- **Professional Layout**: Print-friendly invoice format that scales properly

## How to Use

### Creating a Multi-Cattle Invoice

1. Navigate to the **Accounting** page in the Herd Manager dashboard
2. In the "Generate Invoice" section, select **multiple cattle** from the dropdown
   - Click on the dropdown and select as many animals as you need
   - Each selected animal will appear as a chip/tag
3. Click **Generate Invoice**
4. Review the invoice details:
   - See a summary of all selected cattle and their individual costs
   - Total invoice amount is automatically calculated
5. Enter:
   - Invoice Number (e.g., INV-2025-003)
   - Invoice Date
   - Created By (your name)
   - Optional notes
6. Click **Create Invoice**

### Viewing & Printing Multi-Cattle Invoices

Multi-cattle invoices display with:
- **Header**: Company info, invoice number, date, payment terms (NET 30)
- **Bill To**: Customer/owner name
- **Line Items**: Each animal shown separately with:
  - Animal identification (Tag Number, Name, Breed, Origin Farm)
  - Feeding costs breakdown (period, days, rate, subtotal)
  - Health & veterinary costs table (if any)
  - Animal total
- **Grand Total**: Sum of all animal line items
- **Notes**: Any additional information

The print layout is optimized to fit standard 8.5" × 11" paper at 100% scaling.

## Database Changes

### New Table: InvoiceLineItems

```sql
CREATE TABLE InvoiceLineItems (
    LineItemID INTEGER PRIMARY KEY AUTOINCREMENT,
    InvoiceID INTEGER NOT NULL,
    CattleID INTEGER NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    DaysOnFeed INTEGER NOT NULL,
    PricePerDay DECIMAL(10,2) NOT NULL,
    FeedingCost DECIMAL(10,2) NOT NULL,
    HealthCost DECIMAL(10,2) DEFAULT 0,
    LineItemTotal DECIMAL(10,2) NOT NULL,
    Notes TEXT,
    FOREIGN KEY (InvoiceID) REFERENCES Invoices(InvoiceID) ON DELETE CASCADE,
    FOREIGN KEY (CattleID) REFERENCES Cattle(CattleID)
);
```

### Existing Table Updates

The `Invoices` table legacy fields (CattleID, StartDate, EndDate, etc.) are now optional and only populated for single-cattle invoices. Multi-cattle invoices store details in the `InvoiceLineItems` table.

## Migration for Existing Databases

If you have an existing Herd Manager database, run the migration script:

```powershell
.\Migrate-MultiCattleInvoices.ps1 -DatabasePath "C:\Path\To\Your\HerdManager.db"
```

This script:
- Creates the `InvoiceLineItems` table
- Adds necessary indexes
- Is safe to run multiple times
- **Does not modify existing invoice data**

## Technical Details

### API Changes

**Add-Invoice** function now supports two parameter sets:

1. **Single** (legacy): All existing code continues to work
   ```powershell
   Add-Invoice -InvoiceNumber "INV-001" -CattleID 1 -InvoiceDate (Get-Date) `
       -StartDate $startDate -EndDate $endDate -DaysOnFeed 30 `
       -PricePerDay 5.00 -FeedingCost 150.00 -HealthCost 25.00 `
       -TotalCost 175.00 -Notes "..." -CreatedBy "Brandon"
   ```

2. **Multi** (new): For multiple cattle
   ```powershell
   $lineItems = @(
       @{CattleID=1; StartDate=$date1; EndDate=$date2; DaysOnFeed=30; 
         PricePerDay=5.00; FeedingCost=150.00; HealthCost=25.00; LineItemTotal=175.00}
       @{CattleID=2; StartDate=$date1; EndDate=$date2; DaysOnFeed=25; 
         PricePerDay=5.50; FeedingCost=137.50; HealthCost=15.00; LineItemTotal=152.50}
   )
   Add-Invoice -InvoiceNumber "INV-002" -InvoiceDate (Get-Date) `
       -LineItems $lineItems -TotalCost 327.50 -Notes "..." -CreatedBy "Brandon"
   ```

**Get-Invoice** function now returns:
- `IsMultiCattle` property (true/false)
- `LineItems` property (array of line items for multi-cattle invoices)
- Legacy properties still available for single-cattle invoices

### Files Modified

1. **Database-Schema.sql**: Updated schema with InvoiceLineItems table
2. **Add-Invoice.ps1**: Added multi-cattle support with parameter sets
3. **Get-Invoice.ps1**: Enhanced to retrieve line items and identify invoice type
4. **Accounting.ps1**: Updated UI with multi-select capability
5. **Invoice.ps1**: Redesigned display to handle both single and multi-cattle formats

### Files Created

1. **Migrate-MultiCattleInvoices.ps1**: Database migration script

## Troubleshooting

### Invoice table shows "Multiple" for TagNumber/Name

This is correct for multi-cattle invoices. Open the invoice to see individual animals.

### Migration script fails

Ensure you have:
- PSSQLite module installed: `Install-Module PSSQLite`
- Correct database path
- Database is not locked by another process

### Invoice doesn't display properly

- Ensure you've restarted PowerShell Universal after updating code
- Check that your database has been migrated
- Verify invoice was created after migration

## Future Enhancements

Potential improvements:
- Bulk invoice generation (select date range, automatically create invoices for all cattle)
- Invoice templates with customizable layouts
- Email invoice directly to customer
- Export to PDF
- Payment tracking
