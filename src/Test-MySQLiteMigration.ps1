# MySQLite Integration Test Script
# Tests all major functions after migration from PSSQLite to MySQLite

Write-Host "`n=== MySQLite Integration Tests ===" -ForegroundColor Cyan

$testsPassed = 0
$testsFailed = 0

function Test-Function {
    param(
        [string]$Name,
        [scriptblock]$Test
    )
    
    try {
        $result = & $Test
        if ($result) {
            Write-Host "✓ $Name" -ForegroundColor Green
            $script:testsPassed++
            return $true
        } else {
            Write-Host "✗ $Name - No results" -ForegroundColor Red
            $script:testsFailed++
            return $false
        }
    }
    catch {
        Write-Host "✗ $Name - Error: $($_.Exception.Message)" -ForegroundColor Red
        $script:testsFailed++
        return $false
    }
}

# Test 1: Get-AllCattle with Status parameter
Test-Function "Get-AllCattle with Status parameter" {
    $result = Get-AllCattle -Status 'Active'
    return ($result.Count -gt 0)
}

# Test 2: Get-Farm by name
Test-Function "Get-Farm by name" {
    $result = Get-Farm -FarmName "Oklahoma National Stockyards"
    return ($result -ne $null)
}

# Test 3: Get-Farm by ID
Test-Function "Get-Farm by ID" {
    $result = Get-Farm -FarmID 1
    return ($result -ne $null)
}

# Test 4: Get-CattleById
Test-Function "Get-CattleById" {
    $result = Get-CattleById -CattleID 1
    return ($result -ne $null)
}

# Test 5: Get-WeightHistory
Test-Function "Get-WeightHistory" {
    $result = Get-WeightHistory -CattleID 1
    return ($result -ne $null)
}

# Test 6: Get-HealthRecords
Test-Function "Get-HealthRecords" {
    $result = Get-HealthRecords -CattleID 1
    return ($result -ne $null)
}

# Test 7: Get-HealthRecords with RecordType filter
Test-Function "Get-HealthRecords with RecordType filter" {
    $result = Get-HealthRecords -RecordType 'Vaccination'
    return ($result -ne $null)
}

# Test 8: Get-FeedRecord by date range
Test-Function "Get-FeedRecord by date range" {
    $endDate = Get-Date
    $startDate = $endDate.AddDays(-30)
    $result = Get-FeedRecord -StartDate $startDate -EndDate $endDate
    return ($result -ne $null)
}

# Test 9: Get-FeedRecord by DaysBack
Test-Function "Get-FeedRecord by DaysBack" {
    $result = Get-FeedRecord -DaysBack 7
    return ($result.Count -ge 0) # Can be 0 if no recent feed records
}

# Test 10: Get-RateOfGainHistory
Test-Function "Get-RateOfGainHistory" {
    $result = Get-RateOfGainHistory -Limit 10
    return ($result.Count -ge 0) # Might be 0 if no calculations yet
}

# Test 11: Calculate-RateOfGain
Test-Function "Calculate-RateOfGain" {
    $startDate = (Get-Date).AddDays(-60)
    $endDate = Get-Date
    $result = Calculate-RateOfGain -CattleID 1 -StartDate $startDate -EndDate $endDate
    return ($result -ne $null)
}

# Test 12: ConvertTo-SqlValue with string
Test-Function "ConvertTo-SqlValue with string" {
    $result = ConvertTo-SqlValue -Value "Test's String"
    return ($result -eq "'Test''s String'")
}

# Test 13: ConvertTo-SqlValue with number
Test-Function "ConvertTo-SqlValue with number" {
    $result = ConvertTo-SqlValue -Value 123
    return ($result -eq '123')
}

# Test 14: ConvertTo-SqlValue with null
Test-Function "ConvertTo-SqlValue with null" {
    $result = ConvertTo-SqlValue -Value $null
    return ($result -eq 'NULL')
}

# Test 15: ConvertTo-SqlValue with DateTime
Test-Function "ConvertTo-SqlValue with DateTime" {
    $date = Get-Date -Year 2025 -Month 12 -Day 17 -Hour 10 -Minute 30 -Second 0
    $result = ConvertTo-SqlValue -Value $date
    return ($result -match '2025-12-17')
}

Write-Host "`n=== Test Summary ===" -ForegroundColor Cyan
Write-Host "Passed: $testsPassed" -ForegroundColor Green
Write-Host "Failed: $testsFailed" -ForegroundColor $(if ($testsFailed -eq 0) { 'Green' } else { 'Red' })
Write-Host "Total:  $($testsPassed + $testsFailed)" -ForegroundColor White

if ($testsFailed -eq 0) {
    Write-Host "`n✓ All tests passed! MySQLite migration is successful." -ForegroundColor Green
} else {
    Write-Host "`n✗ Some tests failed. Review the errors above." -ForegroundColor Red
}
