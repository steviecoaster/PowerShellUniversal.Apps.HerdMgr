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

### Viewing Feed History

The feed records table shows all daily feeding records:

**Table Columns**:

- **Feed Date**: Date of feeding
- **Haylage (lbs)**: Formatted with thousand separators
- **Silage (lbs)**: Formatted with thousand separators
- **High Moisture Corn (lbs)**: Formatted with thousand separators
- **Total (lbs)**: Sum of all ingredients (bold for emphasis)
- **Recorded By**: Who logged the record
- **Actions**: Delete button

**Table Features**:

- **Search**: Filter by date or recorded by name
- **Sort**: Click headers to sort by any column
- **Pagination**: 15 records per page

### Managing Feed Records

**Editing**: To correct a record, delete the incorrect entry and add a new one with correct values.

**Deleting**:

1. Click the trash icon for the record
2. Review the date in the confirmation modal
3. Click **Delete** to remove
4. Click **Cancel** to keep the record

### Feed Tracking Tips

- **Daily Recording**: Record feed immediately after mixing for accuracy
- **Consistency**: Try to feed at the same time each day
- **Weather Notes**: Note weather in Notes field as it affects consumption
- **Adjustments**: Document why feed amounts changed (new animals, sold animals, etc.)
- **One Record Per Day**: System enforces one feed record per date
- **Backup**: If you need to record multiple mixes per day, use Notes field

---

## Rate of Gain Tracking

### Calculating Rate of Gain

Rate of Gain (ROG) calculates Average Daily Gain (ADG) between any two weight measurements.

1. Navigate to **Rate of Gain** page
2. **Select Animal**: Use the dropdown to choose the animal
   - Type to search by tag number or name
   - Only animals with at least 2 weight records appear
3. **Select Start Weight**: Choose the earlier weight measurement
   - Shows date and weight value
   - Typically select the earliest weight in the period
4. **Select End Weight**: Choose the later weight measurement
   - Must be after the start weight date
   - Shows date and weight value
5. Click **Calculate Rate of Gain**
6. Results display in a card showing:
   - **Start Weight**: Beginning weight and date
   - **End Weight**: Ending weight and date
   - **Total Weight Gain**: Difference in pounds
   - **Days Between**: Number of days in the period
   - **Average Daily Gain (ADG)**: Pounds per day
   - **Monthly Gain**: Projected gain per 30 days

### Understanding the Results

**Average Daily Gain (ADG)**:

- Most important metric for cattle performance
- Shows pounds gained per day on average
- Industry targets vary by breed and feeding program:
  - Growing cattle: 1.5-3.0 lbs/day typical
  - Finishing cattle: 3.0-4.5 lbs/day typical
  - Poor gain: < 1.5 lbs/day may indicate issues

**Using ROG Data**:

- Compare animals to identify top performers
- Evaluate feeding program effectiveness
- Identify animals needing attention (low ADG)
- Make culling or selection decisions
- Estimate finish dates based on target weights

### Viewing ROG History

The ROG History table shows all previous calculations:

**Table Columns**:

- **Start Date**: Beginning of measurement period
- **End Date**: End of measurement period
- **Start Weight**: Initial weight in lbs
- **End Weight**: Final weight in lbs
- **Total Gain**: Weight gained during period
- **Days**: Duration of measurement period
- **ADG**: Average daily gain in lbs/day
- **Monthly Gain**: Projected gain per 30 days

**Analysis Tips**:

- Look for consistent ADG across periods
- Investigate sudden drops in gain
- Seasonal patterns may emerge
- Compare periods with same duration for fairness

---

## ROG Analytics - Advanced Rate of Gain Analysis

### Overview

The ROG Analytics page provides comprehensive, actionable insights into your cattle's weight gain performance across multiple dimensions. Unlike the standard Rate of Gain calculator which analyzes individual animals, this advanced analytics system allows you to:

- **Group Analysis**: Compare performance across locations, breeds, genders, or origin farms
- **Statistical Insights**: View average, median, minimum, and maximum ADG values
- **Visual Analysis**: Interactive charts showing distribution and comparisons
- **Performance Tracking**: Identify top and bottom performers at a glance
- **Flexible Date Ranges**: Analyze 30, 60, 90, 120-day periods or custom ranges

### Features

#### 1. Group-Based Analysis

**Location Analysis**

- Compare ADG across different pens (Pen 1-6, Quarantine, Pasture)
- Identify which locations produce the best weight gains
- Optimize pen assignments based on performance data

**Breed Analysis**

- Compare performance across different cattle breeds
- Make informed purchasing decisions based on breed performance
- Identify which breeds thrive in your conditions

**Gender Analysis**

- Compare steer vs heifer performance
- Track expected differences in ADG
- Optimize feeding strategies by gender

**Origin Farm Analysis**

- Track performance by cattle source
- Identify reliable suppliers producing high-gaining cattle
- Make data-driven sourcing decisions

**Individual Analysis**

- Detailed view of each animal's performance
- Sort and filter by ADG
- Drill down to specific animals

#### 2. Statistical Summary

The analytics page provides comprehensive statistics for each analysis:

- **Overall Average ADG**: Mean weight gain across all animals
- **Median ADG**: Middle value (less affected by outliers)
- **Min/Max ADG**: Range of performance
- **Total Animals Analyzed**: Sample size for the analysis
- **Date Range**: Clear indication of analysis period

#### 3. Visual Analytics

**Group Comparison Chart**

- Bar chart showing average ADG for each group
- Sorted by performance for easy comparison
- Top 15 groups displayed (for large datasets)

**ADG Distribution Histogram**

- Shows how many animals fall into each ADG range
- Ranges: <1.0, 1.0-1.5, 1.5-2.0, 2.0-2.5, 2.5-3.0, 3.0-3.5, 3.5-4.0, >4.0 lbs/day
- Helps identify if most cattle are performing well or if there's high variance

#### 4. Detailed Results Table

The interactive table includes:

- Group name (location, breed, etc.)
- Number of animals in group
- Average ADG with color coding
- Total weight gain for the group

**Color-Coded ADG Values**:

- 🟢 Green: ADG > 3.0 lbs/day (Excellent)
- 🟠 Orange: ADG 2.0-3.0 lbs/day (Good)
- 🔴 Red: ADG < 2.0 lbs/day (Needs attention)

#### 5. Performance Tracking

**Top 5 Performers**

- Green-highlighted card showing best-gaining animals
- Includes tag number, name, ADG, and total gain
- Useful for identifying genetics or management practices to replicate

**Bottom 5 Performers**

- Red-highlighted card showing lowest-gaining animals
- Helps identify animals that may need health checks or different feeding
- Early warning system for performance issues

### Using ROG Analytics

#### Basic Workflow

1. **Navigate to ROG Analytics**

   - Click "ROG Analytics" in the sidebar menu

2. **Configure Analysis**

   - **Group By**: Select how to group your data (Location, Breed, Gender, Origin Farm, Individual)
   - **Date Range**: Choose preset (30/60/90/120 days) or custom range
   - **Status Filter**: Active animals only or all status

3. **Run Analysis**

   - Click "Run Analysis" button
   - Results load dynamically (typically 1-2 seconds)

4. **Review Results**

   - Check summary statistics at the top
   - Review the group comparison chart
   - Examine detailed results table
   - Check top/bottom performers
   - Analyze ADG distribution

#### Example Use Cases

**Use Case 1: Comparing Pen Performance**

*Goal: Determine if Pen 1 or Pen 2 produces better weight gains*

1. Set "Group By" to "Location"
2. Choose "Last 90 Days"
3. Run Analysis
4. Compare Pen 1 vs Pen 2 average ADG in the chart and table
5. If one pen significantly outperforms, investigate differences (feed access, shelter, etc.)

**Use Case 2: Evaluating a New Feed Strategy**

*Goal: Compare weight gains before and after implementing new feed*

1. Run analysis with "Last 90 Days" (includes new feed period)
2. Note the overall average ADG
3. Change date range to custom: 180-90 days ago (before new feed)
4. Compare the two periods' average ADG
5. Determine if new feed strategy is working

**Use Case 3: Breed Performance Analysis**

*Goal: Decide which breed to purchase more of*

1. Set "Group By" to "Breed"
2. Choose "Last 120 Days" for long-term trends
3. Run Analysis
4. Review average ADG for each breed
5. Consider purchasing more of the breed(s) with highest ADG

**Use Case 4: Identifying Problem Animals**

*Goal: Find animals that need health attention*

1. Set "Group By" to "Individual"
2. Choose "Last 60 Days"
3. Run Analysis
4. Check "Bottom 5 Performers" card
5. Review animals with very low ADG (<1.5 lbs/day)
6. Schedule health checks for these animals

### Data Requirements

#### Minimum Data Needed

For meaningful analysis, each animal needs:

- ✅ At least **2 weight records** within the selected date range
- ✅ Weight records should be **at least 14 days apart** for reliable ADG calculation
- ✅ Animals should have **Status = 'Active'** (or include all status in filter)

#### Best Practices

1. **Regular Weighing**: Weigh cattle every 2-4 weeks for best trend data
2. **Consistent Timing**: Weigh at the same time of day to minimize variation
3. **Accurate Data**: Ensure weight measurements are accurate (use calibrated scales)
4. **Complete Records**: Fill in breed, location, and origin farm fields for better grouping
5. **Date Range Selection**: Use 60-90 day ranges for most analyses (balances recency with statistical reliability)

### Interpreting Results

#### What's a Good ADG?

General guidelines (varies by breed, age, and feed program):

- **Excellent**: > 3.0 lbs/day - Premium performance
- **Good**: 2.5-3.0 lbs/day - Above average, profitable
- **Average**: 2.0-2.5 lbs/day - Acceptable performance
- **Below Average**: 1.5-2.0 lbs/day - May need investigation
- **Poor**: < 1.5 lbs/day - Likely indicates problems

#### Understanding the Statistics

**Average vs Median**:

- **Average (Mean)**: Sum of all ADG values divided by count. Can be skewed by outliers.
- **Median**: Middle value when sorted. Better represents "typical" performance.
- If average and median are similar = consistent performance across the group
- If average is much higher/lower than median = outliers are affecting the average

### Troubleshooting

**"No rate of gain data available"**

*Cause*: No animals have sufficient weight records in the date range

*Solutions*:

- Add more weight records
- Expand the date range
- Check that animals have Status = 'Active' (or change filter to "All Status")

**Groups Showing Zero Animals**

*Cause*: No animals meet the criteria (e.g., no cattle in "Pasture" location)

*Solution*: This is informational - shows you don't have cattle in that category

**Calculation Seems Wrong**

*Possible Causes*:

1. Weight records are in kg instead of lbs (check WeightUnit field)
2. Weight entry errors (typo: 85 instead of 850)
3. Date issues (weight recorded on wrong date)

*Solutions*:

- Review weight records for the animal
- Check the unit of measurement
- Correct any erroneous data

---

## Animal Reports

### Generating a Comprehensive Report

The Animal Report provides a complete overview of an individual animal's data.

1. Navigate to **Animal Report**
2. **Select Animal**: Choose from the dropdown
   - All animals with records appear in the list
   - Search by tag number or name
3. The report generates automatically and displays:

### Report Sections

**1. Animal Profile**

- Tag Number
- Name
- Breed
- Gender
- Age (calculated from birth date)
  - Shows days if < 30 days old
  - Shows months if < 1 year old
  - Shows years and months if older
- Origin Farm
- Days in Herd (calculated from purchase date)
- Current Location
- Status

**2. Performance Summary**

- **Current Weight**: Most recent weight measurement
- **Starting Weight**: First weight measurement
- **Total Weight Gain**: Difference between first and last weight
- **Average ADG**: Average daily gain across entire time in herd

**3. Weight History**

- **Interactive Chart**: Line graph showing weight trend over time
  - X-axis: Dates
  - Y-axis: Weight in pounds
  - Hover for exact values
- **Weight Table**: All weight records with dates and values

**4. Rate of Gain History**

Complete table of all ROG calculations showing:

- Date ranges
- Start and end weights
- Total gain
- Days between measurements
- ADG for each period

**5. Health Records**

All medical history including:

- Dates
- Record types
- Descriptions
- Medications and dosages
- Costs
- Next due dates for follow-ups

### Printing Reports

1. Review the complete report on screen
2. Click **🖨️ Print Report** button at the top
3. The browser print dialog opens
4. Print settings:
   - **Print-friendly formatting**: Navigation and buttons are hidden
   - **Portrait orientation**: Recommended for best layout
   - **Color**: Recommended to preserve chart and status colors
5. Print or save as PDF for records

### Report Use Cases

- **Sale Records**: Provide buyers with complete animal history
- **Veterinary Visits**: Bring printed report for vet review
- **Performance Reviews**: Analyze individual animal trends
- **Record Keeping**: Archive paper copies for compliance
- **Breeding Decisions**: Evaluate genetics and performance

---

## Accounting & Invoicing

The Accounting module allows you to generate professional invoices for cattle billing, combining feeding costs and health expenses.

### Setting Up for Invoicing

Before generating invoices, ensure cattle records have the necessary billing information:

1. Navigate to **Cattle Management**
2. Edit each animal that will be invoiced
3. Add required billing fields:
   - **Owner**: The name of the customer/owner being billed
   - **Price Per Day**: Daily feeding rate (e.g., $3.50, $4.00)
4. Ensure health records with costs are entered in **Health Records**

### Searching for Invoices

1. Navigate to **Accounting** from the side menu
2. In the **Search Invoice** section:
   - Enter the **Invoice Number** (e.g., INV-2025-001)
   - Click **🔍 Search**
3. The invoice will open in a new tab with complete details

### Generating a New Invoice

1. Navigate to **Accounting**
2. In the **Generate Invoice** section:
   - **Select Cattle**: Use the dropdown to choose an animal with Owner set
   - **Invoice Number**: Enter a unique invoice number (e.g., INV-2025-003)
   - **Start Date**: Defaults to animal's purchase date (can be modified)
   - **End Date**: Defaults to current date (can be modified)
   - **Created By**: Your name for invoice attribution
   - **Notes**: Optional notes about the invoice (e.g., "Final billing for contract")
3. Review automatic calculations:
   - **Days on Feed**: Automatically calculated from date range
   - **Feeding Cost**: Days × Price Per Day
   - **Health Cost**: Sum of all health record costs for the animal
   - **Total Cost**: Feeding Cost + Health Cost
4. Click **Generate Invoice**
5. Success message confirms invoice creation

### Viewing All Invoices

The **All Invoices** table displays:

- **Invoice #**: Unique invoice identifier
- **Tag #**: Animal tag number
- **Name**: Animal name
- **Owner**: Customer being billed
- **Invoice Date**: Date invoice was generated
- **Days on Feed**: Number of days billed
- **Total Cost**: Complete amount due

**Table Features**:

- **Search**: Filter invoices by any field
- **Sort**: Click column headers to sort
- **Actions**: 
  - **👁️ View**: Open invoice in new tab
  - **🖨️ Print**: Open invoice for printing

### Invoice Details

Invoices display in a professional format with:

**Header Section**:

- Company name: Farm Name
- Company address and contact information
- Invoice number and date
- Payment terms (NET 30)
- Due date (30 days from invoice date)
- Created by information

**Animal Information**:

- Tag number
- Animal name
- Owner name
- Breed
- Origin farm

**Feeding Costs**:

- Start date (when billing period began)
- End date (when billing period ended)
- Days on feed
- Price per day rate
- **Total Feeding Cost**

**Health & Veterinary Costs**:

- Table of all health events with costs:
  - Date
  - Type (Vaccination, Treatment, Veterinary Visit)
  - Description
  - Cost (with $ and 2 decimal places)
- **Total Health Cost**

**Total Cost**:

- Prominent display of total amount due
- Combines feeding and health costs
- Formatted as currency

### Printing Invoices

1. Open an invoice using Search or View button
2. Click **🖨️ Print Invoice** button at the bottom
3. Browser print dialog opens with optimized layout:
   - Navigation hidden
   - Print button hidden
   - Clean professional appearance
4. Print or save as PDF for:
   - Customer delivery
   - Record keeping
   - Accounting records

### Invoice Best Practices

- **Unique Numbers**: Use sequential invoice numbers (INV-2025-001, INV-2025-002...)
- **Accurate Dates**: Verify start/end dates match actual feeding period
- **Cost Documentation**: Enter all health costs in Health Records before invoicing
- **Owner Information**: Ensure owner names are consistent across cattle
- **Timely Generation**: Generate invoices at end of billing period or upon sale
- **Record Keeping**: Save or print invoices for tax and audit purposes

---

## Notifications Dashboard

The Notifications page provides a centralized view of important alerts and reminders.

### Viewing Notifications

Navigate to **🔔 Notifications** from the side menu.

### Notification Types

**1. Overdue Health Events** (Red Alert Section)

Shows health records where Next Due Date has passed:

- Animal tag and name
- Record type and title
- Original due date
- How many days overdue
- Actions to view details

**2. Upcoming Health Events** (Table Format)

Shows future health events with color-coded urgency:

- 🔴 **Red (≤7 days)**: Immediate attention needed
- 🟠 **Orange (≤14 days)**: Plan ahead
- 🔵 **Blue (>14 days)**: Future events

**Table Columns**:

- Tag #
- Name
- Record Type
- Title
- Next Due Date
- Days Until Due (color-coded)
- Details button

**3. Cattle Needing Weight Checks**

Shows animals that haven't been weighed recently:

- Animal tag and name
- Last weight date
- How many days since last weight
- Link to Weight Management page

### Using Notifications Effectively

**Daily Routine**:

1. Check notifications each morning
2. Address red (overdue) items immediately
3. Plan for orange (approaching) items
4. Schedule appointments for upcoming events

**Weekly Planning**:

- Review upcoming events for next 2 weeks
- Schedule veterinary visits if needed
- Order medications before they're needed
- Plan weight days for animals needing checks

**Badge Counter**:

- The bell icon in the navigation shows count of overdue items
- Red badge indicates action needed
- Click bell icon to go directly to notifications

---

## Reports & Analytics

### Herd-Wide Reports

Navigate to **Reports** for comprehensive herd analytics.

### Available Report Types

**1. Herd Summary**

- Total active cattle count
- Average herd weight
- Total herd value
- Distribution by gender
- Distribution by location

**2. Performance Analytics**

- Average ADG across herd
- Top performers (highest ADG)
- Bottom performers (lowest ADG)
- Performance by location/pen
- Performance trends over time

**3. Health Summary**

- Upcoming vaccinations count
- Recent treatments summary
- Health costs by month
- Most common treatment types
- Animals with overdue events

**4. Weight Trends**

- Average weight gain by month
- Seasonal performance patterns
- Group comparisons
- Feed efficiency metrics

### Generating Reports

1. Select report type from dropdown
2. Set date range if applicable
3. Click **Generate Report**
4. View results in tables and charts
5. Print or export as needed

---

## Tips & Best Practices

### Data Entry

**Consistency is Key**:

- Use consistent naming conventions for animals
- Enter data at regular intervals (daily, weekly, monthly)
- Record data immediately rather than retrospectively
- Use the same person for similar tasks when possible

**Required Fields**:

- Always fill out required fields (marked with *)
- Provide optional fields when available for better tracking
- Use Notes fields for context and special circumstances

**Date Handling**:

- The system uses MM/dd/yyyy HH:mm:ss format
- Use date pickers rather than typing dates
- Double-check dates before submitting

### Performance Monitoring

**Regular Weighing**:

- Weigh animals every 30-60 days minimum
- Weigh at consistent times (before feeding)
- Use the same scale for accuracy
- Record method for context

**Health Tracking**:

- Set Next Due Date for all vaccinations
- Track all treatments, even minor ones
- Note behavioral changes in observations
- Keep costs updated for budgeting

**Feed Management**:

- Record feed daily for accurate totals
- Note weather and herd behavior
- Track adjustments and reasons
- Monitor feed costs over time

### Using Location Tracking

**Pen Management**:

- Update location immediately when moving animals
- Use Quarantine for new arrivals or sick animals
- Track performance by location to optimize pen assignments
- Consider grouping by size, gender, or performance

**Quarantine Protocol**:

- Move new animals to Quarantine location
- Record arrival health check
- Set vaccination schedule
- Move to appropriate pen after quarantine period

### Troubleshooting

**Data Not Appearing**:

- Refresh the page
- Check that you're viewing the correct status filter (Active vs All)
- Verify data was saved (look for success toast)

**Can't Edit Record**:

- Ensure you have proper permissions
- Try closing and reopening the edit modal
- Refresh the page and try again

**Print Not Working**:

- Ensure browser allows pop-ups
- Try a different browser
- Use browser's File > Print as alternative

**Need Help**:

- Check this usage guide
- Review the README.md for technical details
- Contact your system administrator
- Open an issue on GitHub if you found a bug

---

## Keyboard Shortcuts

- **Tab**: Move between form fields
- **Enter**: Submit forms
- **Esc**: Close modal dialogs
- **Ctrl+P**: Print current page

---

## Support & Feedback

For questions, issues, or feature requests:

- Check this usage guide first
- Review the project README
- Open an issue on GitHub
- Contact your system administrator

---

**Version**: 1.0.0  
**Last Updated**: December 2025