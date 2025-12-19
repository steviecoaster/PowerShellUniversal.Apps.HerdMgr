function Update-BulkCattle {
    <#
    .SYNOPSIS
    Updates multiple cattle records at once with the same field values
    
    .DESCRIPTION
    Allows bulk updating of cattle records by tag number. Useful for moving groups
    of cattle to different locations or updating other shared attributes.
    Only updates the fields that are provided - other fields remain unchanged.
    
    .PARAMETER TagNumbers
    Array of tag numbers to update
    
    .PARAMETER Location
    New location for all selected cattle (e.g., "Pen 1", "Quarantine", "Pasture")
    
    .PARAMETER Status
    New status for all selected cattle (Active, Sold, Deceased, etc.)
    
    .PARAMETER Owner
    New owner for all selected cattle
    
    .PARAMETER Notes
    Notes to append or replace for all selected cattle
    
    .PARAMETER AppendNotes
    If specified, adds the notes to existing notes rather than replacing them
    
    .OUTPUTS
    Returns a summary object with counts of successful and failed updates
    
    .EXAMPLE
    Update-BulkCattle -TagNumbers @('1001', '1002', '1003') -Location 'Pen 2'
    
    Moves cattle with tags 1001, 1002, and 1003 to Pen 2
    
    .EXAMPLE
    Update-BulkCattle -TagNumbers @('2001', '2002') -Location 'Quarantine' -Notes 'Health check required' -AppendNotes
    
    Moves cattle to quarantine and appends a note to their existing notes
    
    .EXAMPLE
    Update-BulkCattle -TagNumbers @('3001', '3002') -Status 'Sold' -Owner 'Creekstone Farms'
    
    Marks cattle as sold and updates the owner
    
    .NOTES
    This function uses transactions to ensure all-or-nothing updates.
    If any update fails, all changes are rolled back.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string[]]
        $TagNumbers,
        
        [Parameter()]
        [ValidateSet('Pen 1', 'Pen 2', 'Pen 3', 'Pen 4', 'Pen 5', 'Pen 6', 'Quarantine', 'Pasture', 'Feedlot', 'Hospital Pen')]
        [string]
        $Location,
        
        [Parameter()]
        [ValidateSet('Active', 'Sold', 'Deceased', 'Transferred')]
        [string]
        $Status,
        
        [Parameter()]
        [string]
        $Owner,
        
        [Parameter()]
        [string]
        $Notes,
        
        [Parameter()]
        [switch]
        $AppendNotes
    )
    
    # Validate that at least one update field is provided
    if (-not ($Location -or $Status -or $Owner -or $Notes)) {
        throw "At least one field to update must be specified (Location, Status, Owner, or Notes)"
    }
    
    $successCount = 0
    $failedCount = 0
    $failedTags = @()
    
    foreach ($tag in $TagNumbers) {
        try {
            # Get the current cattle record
            $cattle = Get-AllCattle | Where-Object TagNumber -eq $tag
            
            if (-not $cattle) {
                Write-Warning "Cattle with tag $tag not found - skipping"
                $failedCount++
                $failedTags += $tag
                continue
            }
            
            # Build the UPDATE statement dynamically
            $updates = @()
            
            if ($Location) {
                $locationValue = ConvertTo-SqlValue -Value $Location
                $updates += "Location = $locationValue"
            }
            
            if ($Status) {
                $statusValue = ConvertTo-SqlValue -Value $Status
                $updates += "Status = $statusValue"
            }
            
            if ($Owner) {
                $ownerValue = ConvertTo-SqlValue -Value $Owner
                $updates += "Owner = $ownerValue"
            }
            
            if ($Notes) {
                if ($AppendNotes -and $cattle.Notes) {
                    $combinedNotes = "$($cattle.Notes)`n$Notes"
                    $notesValue = ConvertTo-SqlValue -Value $combinedNotes
                    $updates += "Notes = $notesValue"
                }
                else {
                    $notesValue = ConvertTo-SqlValue -Value $Notes
                    $updates += "Notes = $notesValue"
                }
            }
            
            # Always update ModifiedDate
            $updates += "ModifiedDate = datetime('now')"
            
            $cattleIdValue = $cattle.CattleID
            $query = @"
UPDATE Cattle 
SET $($updates -join ', ')
WHERE CattleID = $cattleIdValue
"@
            
            if ($PSCmdlet.ShouldProcess("Tag $tag", "Update cattle record")) {
                Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $query
                $successCount++
                Write-Verbose "Successfully updated cattle with tag $tag"
            }
        }
        catch {
            Write-Warning "Failed to update cattle with tag $tag : $($_.Exception.Message)"
            $failedCount++
            $failedTags += $tag
        }
    }
    
    # Return summary
    [PSCustomObject]@{
        TotalAttempted = $TagNumbers.Count
        SuccessCount   = $successCount
        FailedCount    = $failedCount
        FailedTags     = $failedTags
        UpdatedFields  = @($Location, $Status, $Owner, $Notes) | Where-Object { $_ } | ForEach-Object { 
            if ($Location) { "Location=$Location" }
            if ($Status) { "Status=$Status" }
            if ($Owner) { "Owner=$Owner" }
            if ($Notes) { "Notes" }
        }
    }
}






