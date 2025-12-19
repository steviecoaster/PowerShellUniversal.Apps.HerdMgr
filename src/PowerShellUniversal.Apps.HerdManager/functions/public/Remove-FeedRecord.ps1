function Remove-FeedRecord {
    <#
    .SYNOPSIS
    Removes a feed record from the database
    
    .DESCRIPTION
    Permanently deletes a daily feed record from the database.
    This action cannot be undone.
    
    .PARAMETER FeedRecordID
    ID of the feed record to remove (required)
    
    .PARAMETER Force
    Skip confirmation prompt
    
    .OUTPUTS
    None
    
    .EXAMPLE
    Remove-FeedRecord -FeedRecordID 5
    
    Removes feed record #5 (with confirmation prompt)
    
    .EXAMPLE
    Remove-FeedRecord -FeedRecordID 10 -Force
    
    Removes feed record #10 without confirmation
    
    .EXAMPLE
    Get-FeedRecord -FeedDate "2024-11-15" | ForEach-Object { Remove-FeedRecord -FeedRecordID $_.FeedRecordID -Force }
    
    Removes the feed record for a specific date
    
    .NOTES
    This permanently deletes the record. Use with caution.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [int]$FeedRecordID,
        
        [Parameter()]
        [switch]$Force
    )
    
    process {
        # Verify record exists
        $record = Get-FeedRecord -FeedRecordID $FeedRecordID
        if (-not $record) {
            Write-Warning "Feed record with ID $FeedRecordID not found"
            return
        }
        
    $recordDate = Format-Date $record.FeedDate
        $recordTotal = $record.TotalPounds
        
        if ($Force -or $PSCmdlet.ShouldProcess(
            "Feed record for $recordDate ($recordTotal lbs total)", 
            "Permanently delete feed record"
        )) {
            # Prepare to delete the feed record
            
            try {
                # Use SQL-safe value for ID and run deletion
                $idValue = ConvertTo-SqlValue -Value $FeedRecordID
                $deleteQuery = "DELETE FROM FeedRecords WHERE FeedRecordID = $idValue"
                Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $deleteQuery
                Write-Verbose "Feed record $FeedRecordID deleted successfully"
            }
            catch {
                throw "Failed to delete feed record: $_"
            }
        }
    }
}






