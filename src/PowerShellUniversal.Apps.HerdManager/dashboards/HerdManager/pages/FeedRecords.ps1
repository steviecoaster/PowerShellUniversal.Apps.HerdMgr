$feedRecords = New-UDPage -Name 'Feed Records' -Url '/feedrecords' -Content {
    
    New-UDTypography -Text "Feed Records" -Variant h4 -Style @{marginBottom = '20px'}
    
    # Add Feed Record Section
    New-UDCard -Title "➕ Add Daily Feed Record" -Content {
        New-UDForm -Content {
            
            New-UDDatePicker -Id 'feed-date' -Label 'Feed Date' -Value (Get-Date).ToString('yyyy-MM-dd')
            
            New-UDSlider -Id 'haylage-pounds' -Min 0 -Max 1000 -Value 0 -ValueLabelDisplay 'on'
            New-UDTypography -Text "Haylage (lbs)" -Variant body2 -Style @{marginBottom = '10px'; color = '#666'}
            
            New-UDSlider -Id 'silage-pounds' -Min 0 -Max 1000 -Value 0 -ValueLabelDisplay 'on'
            New-UDTypography -Text "Silage (lbs)" -Variant body2 -Style @{marginBottom = '10px'; color = '#666'}
            
            New-UDSlider -Id 'high-moisture-corn-pounds' -Min 0 -Max 1000 -Value 0 -ValueLabelDisplay 'on'
            New-UDTypography -Text "High Moisture Corn (lbs)" -Variant body2 -Style @{marginBottom = '10px'; color = '#666'}
            
            New-UDTextbox -Id 'feed-notes' -Label 'Notes (Optional)' -Multiline -Rows 3
            
            New-UDSelect -Id 'recorded-by' -Label 'Recorded By' -DefaultValue 'Brandon' -Option {
                New-UDSelectOption -Name 'Brandon' -Value 'Brandon'
                New-UDSelectOption -Name 'Jerry' -Value 'Jerry'
                New-UDSelectOption -Name 'Stephanie' -Value 'Stephanie'
            }
            
        } -OnSubmit {
            
            try {
                $feedDate = [DateTime]::Parse($EventData.'feed-date').ToString('MM/dd/yyyy')
                $haylagePounds = [decimal]$EventData.'haylage-pounds'
                $silagePounds = [decimal]$EventData.'silage-pounds'
                $highMoistureCornPounds = [decimal]$EventData.'high-moisture-corn-pounds'
                $totalPounds = $haylagePounds + $silagePounds + $highMoistureCornPounds
                $notes = $EventData.'feed-notes'
                $recordedBy = $EventData.'recorded-by'
                
                # Check if a record already exists for this date
                $existingQuery = "SELECT FeedRecordID FROM FeedRecords WHERE FeedDate = @FeedDate"
                $existingRecord = Invoke-SqliteQuery -DataSource $script:DatabasePath -Query $existingQuery -SqlParameters @{
                    FeedDate = $feedDate
                } -As PSObject
                
                if ($existingRecord) {
                    Show-UDToast -Message "A feed record already exists for $feedDate. Please edit or delete that record first." -MessageColor red -Duration 5000
                    return
                }
                
                # Insert new feed record
                $query = @"
INSERT INTO FeedRecords (FeedDate, HaylagePounds, SilagePounds, HighMoistureCornPounds, TotalPounds, Notes, RecordedBy, CreatedDate)
VALUES (@FeedDate, @HaylagePounds, @SilagePounds, @HighMoistureCornPounds, @TotalPounds, @Notes, @RecordedBy, @CreatedDate)
"@
                
                Invoke-SqliteQuery -DataSource $script:DatabasePath -Query $query -SqlParameters @{
                    FeedDate = $feedDate
                    HaylagePounds = $haylagePounds
                    SilagePounds = $silagePounds
                    HighMoistureCornPounds = $highMoistureCornPounds
                    TotalPounds = $totalPounds
                    Notes = $notes
                    RecordedBy = $recordedBy
                    CreatedDate = (Get-Date).ToString('MM/dd/yyyy HH:mm:ss')
                }
                
                Show-UDToast -Message "Feed record added successfully for $feedDate" -MessageColor green -Duration 3000
                Sync-UDElement -Id 'feed-records-table'
                
            } catch {
                Show-UDToast -Message "Error adding feed record: $($_.Exception.Message)" -MessageColor red -Duration 5000
            }
            
        }
    } -Style @{marginBottom = '30px'}
    
    # Feed Records Table
    New-UDDynamic -Id 'feed-records-table' -Content {
        
        $query = @"
SELECT 
    FeedRecordID,
    CAST(FeedDate AS TEXT) as FeedDate,
    HaylagePounds,
    SilagePounds,
    HighMoistureCornPounds,
    TotalPounds,
    Notes,
    RecordedBy,
    CAST(CreatedDate AS TEXT) as CreatedDate
FROM FeedRecords
ORDER BY FeedDate DESC
"@
        
        $feedRecords = Invoke-SqliteQuery -DataSource $script:DatabasePath -Query $query -As PSObject
        
        if ($feedRecords.Count -eq 0) {
            New-UDAlert -Severity info -Text "No feed records found. Add your first daily feed record above."
        } else {
            
            $columns = @(
                New-UDTableColumn -Property FeedDate -Title "Feed Date" -ShowSort -Render {
                    try {
                        ([DateTime]::Parse($EventData.FeedDate)).ToString('MM/dd/yyyy')
                    } catch {
                        $EventData.FeedDate -replace ' \d{2}:\d{2}:\d{2}.*$', ''
                    }
                }
                New-UDTableColumn -Property HaylagePounds -Title "Haylage (lbs)" -ShowSort -Render {
                    "{0:N0}" -f [decimal]$EventData.HaylagePounds
                }
                New-UDTableColumn -Property SilagePounds -Title "Silage (lbs)" -ShowSort -Render {
                    "{0:N0}" -f [decimal]$EventData.SilagePounds
                }
                New-UDTableColumn -Property HighMoistureCornPounds -Title "High Moisture Corn (lbs)" -ShowSort -Render {
                    "{0:N0}" -f [decimal]$EventData.HighMoistureCornPounds
                }
                New-UDTableColumn -Property TotalPounds -Title "Total (lbs)" -ShowSort -Render {
                    New-UDElement -Tag 'strong' -Content {
                        "{0:N0}" -f [decimal]$EventData.TotalPounds
                    }
                }
                New-UDTableColumn -Property RecordedBy -Title "Recorded By" -ShowSort
                New-UDTableColumn -Property FeedRecordID -Title "Actions" -Render {
                    New-UDButton -Icon (New-UDIcon -Icon Trash) -Size small -OnClick {
                        Show-UDModal -Content {
                            New-UDTypography -Text "Are you sure you want to delete this feed record?" -Variant body1
                            New-UDTypography -Text "Date: $(([DateTime]::Parse($EventData.FeedDate)).ToString('MM/dd/yyyy'))" -Variant body2 -Style @{marginTop = '10px'}
                        } -Header {
                            New-UDTypography -Text "⚠️ Confirm Delete" -Variant h6
                        } -Footer {
                            New-UDButton -Text "Cancel" -OnClick { Hide-UDModal } -Variant outlined
                            New-UDButton -Text "Delete" -OnClick {
                                try {
                                    $deleteQuery = "DELETE FROM FeedRecords WHERE FeedRecordID = @FeedRecordID"
                                    Invoke-SqliteQuery -DataSource $script:DatabasePath -Query $deleteQuery -SqlParameters @{
                                        FeedRecordID = $EventData.FeedRecordID
                                    }
                                    Hide-UDModal
                                    Show-UDToast -Message "Feed record deleted successfully" -MessageColor green -Duration 3000
                                    Sync-UDElement -Id 'feed-records-table'
                                } catch {
                                    Show-UDToast -Message "Error deleting feed record: $($_.Exception.Message)" -MessageColor red -Duration 5000
                                }
                            } -Style @{backgroundColor = '#d32f2f'; color = 'white'; marginLeft = '10px'}
                        } -FullWidth -MaxWidth 'sm'
                    }
                }
            )
            
            New-UDTable -Data $feedRecords -Columns $columns -Sort -ShowPagination -PageSize 15 -Dense -ShowSearch
        }
    }
}
