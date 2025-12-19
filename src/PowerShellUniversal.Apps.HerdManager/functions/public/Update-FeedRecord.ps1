function Update-FeedRecord {
    <#
    .SYNOPSIS
    Updates an existing feed record
    
    .DESCRIPTION
    Modifies an existing daily feed record for the herd.
    Can update feed quantities, notes, or other details.
    Only the specified parameters will be updated; others remain unchanged.
    
    .PARAMETER FeedRecordID
    ID of the feed record to update (required)
    
    .PARAMETER FeedDate
    New date for the feed record
    
    .PARAMETER HaylagePounds
    Updated pounds of haylage fed
    
    .PARAMETER SilagePounds
    Updated pounds of silage fed
    
    .PARAMETER HighMoistureCornPounds
    Updated pounds of high moisture corn fed
    
    .PARAMETER TotalPounds
    Updated total pounds of feed
    If not provided and individual feeds are updated, will be recalculated
    
    .PARAMETER Notes
    Updated notes
    
    .PARAMETER RecordedBy
    Updated recorder name
    
    .OUTPUTS
    None
    
    .EXAMPLE
    Update-FeedRecord -FeedRecordID 5 -TotalPounds 16500 -Notes "Corrected total"
    
    Updates the total pounds and notes for feed record #5
    
    .EXAMPLE
    Update-FeedRecord -FeedRecordID 10 -HaylagePounds 5500 -SilagePounds 8200
    
    Updates individual feed types (total will be recalculated to 13,700)
    
    .EXAMPLE
    Update-FeedRecord -FeedRecordID 8 -RecordedBy "Jane Doe" -Notes "Updated by supervisor"
    
    Updates the recorder and adds notes
    
    .NOTES
    Only provided parameters will be updated. To recalculate total based on individual feeds,
    provide the individual feed amounts without specifying TotalPounds.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [int]$FeedRecordID,
        
        [Parameter()]
        [DateTime]$FeedDate,
        
        [Parameter()]
        [decimal]$HaylagePounds,
        
        [Parameter()]
        [decimal]$SilagePounds,
        
        [Parameter()]
        [decimal]$HighMoistureCornPounds,
        
        [Parameter()]
        [decimal]$TotalPounds,
        
        [Parameter()]
        [string]$Notes,
        
        [Parameter()]
        [string]$RecordedBy
    )
    
    # Verify record exists
    $existingRecord = Get-FeedRecord -FeedRecordID $FeedRecordID
    if (-not $existingRecord) {
        throw "Feed record with ID $FeedRecordID not found"
    }
    
    # Build dynamic update query based on provided parameters
    $updates = @()
    
    if ($PSBoundParameters.ContainsKey('FeedDate')) {
        $feedDateValue = ConvertTo-SqlValue -Value ($FeedDate.ToString('yyyy-MM-dd HH:mm:ss'))
        $updates += "FeedDate = $feedDateValue"
    }
    
    if ($PSBoundParameters.ContainsKey('HaylagePounds')) {
        $updates += "HaylagePounds = $HaylagePounds"
    }
    
    if ($PSBoundParameters.ContainsKey('SilagePounds')) {
        $updates += "SilagePounds = $SilagePounds"
    }
    
    if ($PSBoundParameters.ContainsKey('HighMoistureCornPounds')) {
        $updates += "HighMoistureCornPounds = $HighMoistureCornPounds"
    }
    
    # If individual feeds were updated but total wasn't specified, recalculate total
    if (($PSBoundParameters.ContainsKey('HaylagePounds') -or 
         $PSBoundParameters.ContainsKey('SilagePounds') -or 
         $PSBoundParameters.ContainsKey('HighMoistureCornPounds')) -and 
        -not $PSBoundParameters.ContainsKey('TotalPounds')) {
        
        $newHaylage = if ($PSBoundParameters.ContainsKey('HaylagePounds')) { $HaylagePounds } else { $existingRecord.HaylagePounds }
        $newSilage = if ($PSBoundParameters.ContainsKey('SilagePounds')) { $SilagePounds } else { $existingRecord.SilagePounds }
        $newHMC = if ($PSBoundParameters.ContainsKey('HighMoistureCornPounds')) { $HighMoistureCornPounds } else { $existingRecord.HighMoistureCornPounds }
        
        $TotalPounds = $newHaylage + $newSilage + $newHMC
        $updates += "TotalPounds = $TotalPounds"
    }
    elseif ($PSBoundParameters.ContainsKey('TotalPounds')) {
        $updates += "TotalPounds = $TotalPounds"
    }
    
    if ($PSBoundParameters.ContainsKey('Notes')) {
        $notesValue = ConvertTo-SqlValue -Value $Notes
        $updates += "Notes = $notesValue"
    }
    
    if ($PSBoundParameters.ContainsKey('RecordedBy')) {
        $recordedByValue = ConvertTo-SqlValue -Value $RecordedBy
        $updates += "RecordedBy = $recordedByValue"
    }
    
    if ($updates.Count -eq 0) {
        Write-Warning "No updates specified"
        return
    }
    
    $query = @"
UPDATE FeedRecords
SET $($updates -join ', ')
WHERE FeedRecordID = $FeedRecordID
"@
    
    if ($PSCmdlet.ShouldProcess("Feed Record ID $FeedRecordID", "Update feed record")) {
        try {
            Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $query
            Write-Verbose "Feed record $FeedRecordID updated successfully"
        }
        catch {
            throw "Failed to update feed record: $_"
        }
    }
}






