$feedTonnageReportPage = New-UDPage -Name "Feed Tonnage Report" -Url "/feed-tonnage-report/:startDate/:endDate/:groupByMonth" -Blank -Content {
    $startDateParam  = $StartDate
    $endDateParam    = $EndDate
    $groupByMonthParam = $GroupByMonth

    # Parse route parameters
    $startDateValue = try { [DateTime]::ParseExact($startDateParam, 'yyyy-MM-dd', $null) } catch { (Get-Date).AddMonths(-3) }
    $endDateValue   = try { [DateTime]::ParseExact($endDateParam,   'yyyy-MM-dd', $null) } catch { Get-Date }
    $groupByMonth   = ($groupByMonthParam -eq 'true')

    # Fetch report data
    $reportParams = @{
        StartDate = $startDateValue
        EndDate   = $endDateValue
    }
    if ($groupByMonth) {
        $reportParams['GroupByMonth'] = $true
    }

    $data = Get-FeedTonnageReport @reportParams

    # Print-friendly styles
    New-UDStyle -Style (ConvertTo-CssString $HerdStyles.PrintCSS.TonnageReport) -Content {
        New-UDElement -Tag 'div' -Attributes @{ class = 'report-container' } -Content {

            # Resolve farm/company info
            $system = Get-SystemInfo
            $companyName     = if ($system -and $system.FarmName)   { $system.FarmName }   else { 'Acme Fictitious Ranch' }
            $companyAddress1 = if ($system -and $system.Address)     { $system.Address }    else { '42 Imaginary Way' }
            $companyCityStateZip = if ($system -and ($system.City -or $system.State -or $system.ZipCode)) {
                "$($system.City) $($system.State) $($system.ZipCode)".Trim()
            } else { 'Nowhere, ZZ 00000' }
            $companyPhone = if ($system -and $system.PhoneNumber) { $system.PhoneNumber } else { '(000) 000-0000' }

            $startLabel = $startDateValue.ToString('MMMM dd, yyyy')
            $endLabel   = $endDateValue.ToString('MMMM dd, yyyy')
            $groupLabel = if ($groupByMonth) { 'Monthly Breakdown' } else { 'Totals Only' }
            $printedOn  = (Get-Date).ToString('MMMM dd, yyyy')

            $headerHtml = @"
<div class="report-header">
    <div style="display: flex; justify-content: space-between; align-items: flex-start;">
        <div>
            <h2 style="color: #2e7d32; font-weight: bold; margin: 0;">$companyName</h2>
            <h3 style="color: #2e7d32; margin: 4px 0 0 0;">🌾 Feed Tonnage Report</h3>
        </div>
        <div style="text-align: right; font-size: 0.9em;">
            <p style="margin: 2px 0;">$companyAddress1</p>
            <p style="margin: 2px 0;">$companyCityStateZip</p>
            <p style="margin: 2px 0;">Phone: $companyPhone</p>
        </div>
    </div>
    <div style="display: flex; justify-content: space-between; margin-top: 18px; font-size: 0.95em;">
        <div>
            <p style="margin: 3px 0;"><strong>Period:</strong> $startLabel &mdash; $endLabel</p>
            <p style="margin: 3px 0;"><strong>Grouping:</strong> $groupLabel</p>
        </div>
        <div style="text-align: right;">
            <p style="margin: 3px 0; color: #666;">Printed: $printedOn</p>
        </div>
    </div>
</div>
"@
            New-UDHtml -Markup $headerHtml

            if ($data) {
                $totalTons      = ($data | Measure-Object -Property TotalTons   -Sum).Sum
                $totalPounds    = ($data | Measure-Object -Property TotalPounds -Sum).Sum
                $uniqueIngredients = ($data | Select-Object -Property Ingredient -Unique).Count

                $summaryHtml = @"
<div class="summary-grid">
    <div class="summary-card">
        <div class="label">Total Tonnage</div>
        <div class="value">$("{0:N2}" -f $totalTons) tons</div>
    </div>
    <div class="summary-card">
        <div class="label">Total Pounds</div>
        <div class="value">$("{0:N0}" -f $totalPounds) lbs</div>
    </div>
    <div class="summary-card">
        <div class="label">Ingredients Tracked</div>
        <div class="value">$uniqueIngredients</div>
    </div>
</div>
"@
                New-UDHtml -Markup $summaryHtml

                # Determine columns based on data shape
                $hasMonth  = $data[0].PSObject.Properties.Name -contains 'MonthName'
                $hasPeriod = $data[0].PSObject.Properties.Name -contains 'Period'

                # Build table HTML
                $tableHtml = '<table class="report-table"><thead><tr>'
                if ($hasMonth)  { $tableHtml += '<th>Month</th>' }
                elseif ($hasPeriod) { $tableHtml += '<th>Period</th>' }
                $tableHtml += '<th>Ingredient</th><th class="num">Total Pounds</th><th class="num">Total Tons</th></tr></thead><tbody>'

                foreach ($row in $data) {
                    $tableHtml += '<tr>'
                    if ($hasMonth)       { $tableHtml += "<td>$($row.MonthName)</td>" }
                    elseif ($hasPeriod)  { $tableHtml += "<td>$($row.Period)</td>" }
                    $tableHtml += "<td>$($row.Ingredient)</td>"
                    $tableHtml += "<td class='num'>$("{0:N0}" -f [decimal]$row.TotalPounds)</td>"
                    $tableHtml += "<td class='num'><strong>$("{0:N2}" -f [decimal]$row.TotalTons)</strong></td>"
                    $tableHtml += '</tr>'
                }

                $tableHtml += '</tbody></table>'
                New-UDHtml -Markup $tableHtml

                New-UDHtml -Markup "<div class='report-total'>TOTAL: $("{0:N2}" -f $totalTons) tons &nbsp;|&nbsp; $("{0:N0}" -f $totalPounds) lbs</div>"
            }
            else {
                New-UDHtml -Markup "<p style='color:#888; font-style:italic; margin-top:30px;'>No feed records found for the selected date range.</p>"
            }

            # Print button (hidden when printing)
            New-UDElement -Tag 'div' -Attributes @{ class = 'no-print'; style = 'text-align: center; margin-top: 30px;' } -Content {
                New-UDButton -Text "🖨️ Print Report" -Variant contained -OnClick {
                    Invoke-UDJavaScript -JavaScript "window.print();"
                } -Style @{
                    backgroundColor = '#2e7d32'
                    color           = 'white'
                    padding         = '12px 30px'
                    fontSize        = '1.1em'
                }
            }
        }
    }
}
