$feedRecords = New-UDPage -Name 'Feed Records' -Url '/feedrecords' -Content {
    
    New-UDGrid -Container -Content {
        New-UDGrid -Item -ExtraSmallSize 12 -MediumSize 8 -Content {
            New-UDTypography -Text "Feed Records" -Variant h4 -Style @{marginBottom = '20px' }
        }
        New-UDGrid -Item -ExtraSmallSize 12 -MediumSize 4 -Content {
            New-UDButton -Text "Manage Recipe" -Icon (New-UDIcon -Icon Cog) -Variant outlined -OnClick {
                Show-UDModal -Content {
                    New-UDDynamic -Id 'recipe-modal-content' -Content {
                        # Get active recipe
                        $activeRecipe = Get-FeedRecipe -Active -IncludeIngredients
                        
                        if ($activeRecipe) {
                            New-UDAlert -Severity info -Text "Current Recipe: $($activeRecipe.RecipeName)"
                            
                            New-UDForm -Content {
                                New-UDTextbox -Id 'recipe-name' -Label 'Recipe Name' -Value $activeRecipe.RecipeName
                                
                                # Simple ingredient list - one per line
                                $ingredientNames = ($activeRecipe.Ingredients | ForEach-Object { $_.IngredientName }) -join "`n"
                                
                                New-UDTextbox -Id 'ingredients-list' -Label 'Ingredients (one per line)' -Multiline -Rows 8 -Value $ingredientNames
                                
                            } -OnSubmit {
                                try {
                                    $recipeName = $EventData.'recipe-name'
                                    $ingredientsList = $EventData.'ingredients-list'
                                    
                                    if ([string]::IsNullOrWhiteSpace($recipeName)) {
                                        throw "Recipe name cannot be empty"
                                    }
                                    
                                    # Parse ingredients - just names, use sensible defaults for everything else
                                    $ingredientArray = @()
                                    $lines = $ingredientsList -split "`n" | Where-Object { $_.Trim() }
                                    $order = 1
                                    
                                    foreach ($line in $lines) {
                                        $name = $line.Trim()
                                        if ($name) {
                                            $ingredientArray += @{
                                                Name = $name
                                                Unit = 'lbs'
                                                MinValue = 0
                                                MaxValue = 10000
                                                DefaultValue = 1000
                                                DisplayOrder = $order
                                            }
                                            $order++
                                        }
                                    }
                                    
                                    if ($ingredientArray.Count -eq 0) {
                                        throw "At least one ingredient is required"
                                    }
                                    
                                    # Get the current active recipe to update it by ID
                                    $currentRecipe = Get-FeedRecipe -Active
                                    if ($currentRecipe) {
                                        # Update existing recipe by ID
                                        Set-FeedRecipe -RecipeID $currentRecipe.RecipeID -Ingredients $ingredientArray -SetActive -Confirm:$false
                                    }
                                    else {
                                        # Create new recipe
                                        Set-FeedRecipe -RecipeName $recipeName -Ingredients $ingredientArray -SetActive -Confirm:$false
                                    }
                                    
                                    Show-UDToast -Message "Recipe updated successfully!" -MessageColor green -Duration 3000
                                    Sync-UDElement -Id 'recipe-modal-content'
                                    Sync-UDElement -Id 'feed-form-card'
                                    Sync-UDElement -Id 'feed-records-table'
                                    Hide-UDModal
                                    
                                }
                                catch {
                                    Show-UDToast -Message "Error updating recipe: $($_.Exception.Message)" -MessageColor red -Duration 5000
                                }
                            } -SubmitText "Update Recipe"
                        }
                        else {
                            New-UDAlert -Severity warning -Text "No active recipe found."
                            
                            New-UDForm -Content {
                                New-UDTextbox -Id 'new-recipe-name' -Label 'Recipe Name' -Value 'Standard Feed Mix'
                                
                                $defaultIngredients = @"
Corn Silage
High Moisture Corn
Supplement
Dry Hay
Haylage
"@
                                
                                New-UDTextbox -Id 'new-ingredients-list' -Label 'Ingredients (one per line)' -Multiline -Rows 8 -Value $defaultIngredients
                                
                            } -OnSubmit {
                                try {
                                    $recipeName = $EventData.'new-recipe-name'
                                    $ingredientsList = $EventData.'new-ingredients-list'
                                    
                                    if ([string]::IsNullOrWhiteSpace($recipeName)) {
                                        throw "Recipe name cannot be empty"
                                    }
                                    
                                    # Parse ingredients - just names, use sensible defaults
                                    $ingredientArray = @()
                                    $lines = $ingredientsList -split "`n" | Where-Object { $_.Trim() }
                                    $order = 1
                                    
                                    foreach ($line in $lines) {
                                        $name = $line.Trim()
                                        if ($name) {
                                            $ingredientArray += @{
                                                Name = $name
                                                Unit = 'lbs'
                                                MinValue = 0
                                                MaxValue = 10000
                                                DefaultValue = 1000
                                                DisplayOrder = $order
                                            }
                                            $order++
                                        }
                                    }
                                    
                                    if ($ingredientArray.Count -eq 0) {
                                        throw "At least one ingredient is required"
                                    }
                                    
                                    # Create the recipe
                                    Set-FeedRecipe -RecipeName $recipeName -Ingredients $ingredientArray -SetActive -Confirm:$false
                                    
                                    Show-UDToast -Message "Recipe created successfully!" -MessageColor green -Duration 3000
                                    Sync-UDElement -Id 'recipe-modal-content'
                                    Sync-UDElement -Id 'feed-form-card'
                                    Hide-UDModal
                                    
                                }
                                catch {
                                    Show-UDToast -Message "Error creating recipe: $($_.Exception.Message)" -MessageColor red -Duration 5000
                                }
                            } -SubmitText "Create Recipe"
                        }
                    }
                } -Header {
                    New-UDTypography -Text "🍽️ Manage Feed Recipe" -Variant h5 -Style @{
                        padding = '20px'
                        background = 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)'
                        color = 'white'
                        margin = '-20px -20px 20px -20px'
                        borderRadius = '8px 8px 0 0'
                    }
                } -Footer {
                    New-UDButton -Text "Close" -OnClick { Hide-UDModal } -Variant outlined
                } -FullWidth -MaxWidth 'md' -Persistent -Style @{
                    borderRadius = '8px'
                    boxShadow = '0 8px 32px rgba(0,0,0,0.3)'
                }
            } -Style @{float = 'right' }
        }
    }
    
    # Add Feed Record Section with Dynamic Sliders
    New-UDCard -Title "➕ Add Daily Feed Record" -Content {
        New-UDDynamic -Id 'feed-form-card' -Content {
            # Get active recipe and ingredients
            $activeRecipe = Get-FeedRecipe -Active -IncludeIngredients
            
            if (-not $activeRecipe) {
                New-UDAlert -Severity warning -Text "No active recipe found. Please configure a recipe using Set-FeedRecipe."
                
            }
            
            $ingredients = $activeRecipe.Ingredients
            
            New-UDForm -Content {
                New-UDDatePicker -Id 'feed-date' -Label 'Feed Date' -Value (Get-Date).ToString('yyyy-MM-dd')
                
                # Dynamically generate sliders for each ingredient
                foreach ($ingredient in $ingredients) {
                    $sliderId = "ingredient-$($ingredient.IngredientID)"
                    $min = [int]$ingredient.MinValue
                    $max = [int]$ingredient.MaxValue
                    $default = [int]$ingredient.DefaultValue
                    
                    New-UDSlider -Id $sliderId -Min $min -Max $max -Value $default -ValueLabelDisplay 'on'
                    New-UDTypography -Text "$($ingredient.IngredientName) ($($ingredient.Unit))" -Variant body2 -Style @{marginBottom = '10px'; color = '#666' }
                }
                
                New-UDTextbox -Id 'feed-notes' -Label 'Notes (Optional)' -Multiline -Rows 3
                
                New-UDSelect -Id 'recorded-by' -Label 'Recorded By' -DefaultValue 'Brandon' -Option {
                    New-UDSelectOption -Name 'Brandon' -Value 'Brandon'
                    New-UDSelectOption -Name 'Jerry' -Value 'Jerry'
                    New-UDSelectOption -Name 'Stephanie' -Value 'Stephanie'
                }
                
            } -OnSubmit {
                try {
                    # Get active recipe ingredients
                    $activeRecipe = Get-FeedRecipe -Active -IncludeIngredients
                    $ingredients = $activeRecipe.Ingredients
                    
                    # Parse feed date
                    $rawDate = $EventData.'feed-date'
                    try { $feedDate = Parse-Date $rawDate } catch { throw "Invalid date format for Feed Date: $rawDate" }

                    # Build ingredient amounts hashtable from slider values
                    $ingredientAmounts = @{}
                    $totalPounds = 0
                    
                    foreach ($ingredient in $ingredients) {
                        $sliderId = "ingredient-$($ingredient.IngredientID)"
                        $amount = [decimal]$EventData.$sliderId
                        $ingredientAmounts[$ingredient.IngredientName] = $amount
                        $totalPounds += $amount
                    }
                    
                    $notes = $EventData.'feed-notes'
                    $recordedBy = $EventData.'recorded-by'

                    # Use the public API function with dynamic ingredients
                    Add-FeedRecord -FeedDate $feedDate -IngredientAmounts $ingredientAmounts -TotalPounds $totalPounds -Notes $notes -RecordedBy $recordedBy

                    Show-UDToast -Message ("Feed record added successfully for {0}" -f (Format-Date $feedDate)) -MessageColor green -Duration 3000
                    
                    # Sync both the form and the table
                    Sync-UDElement -Id 'feed-form-card'
                    Sync-UDElement -Id 'feed-records-table'
                }
                catch {
                    Show-UDToast -Message "Error adding feed record: $($_.Exception.Message)" -MessageColor red -Duration 5000
                    Write-Error "Feed record error: $_"
                }
            }
        }
    } -Style @{
        marginBottom = '30px'
        borderRadius = '16px'
        boxShadow = '0 4px 12px rgba(0,0,0,0.15)'
        border = '1px solid #e3f2fd'
    }
    
    # Feed Records Table
    New-UDCard -Title "📋 Recent Feed Records" -Content {
        New-UDDynamic -Id 'feed-records-table' -Content {
            
            # Get active recipe to determine column display
            $activeRecipe = Get-FeedRecipe -Active -IncludeIngredients
            $ingredients = if ($activeRecipe) { $activeRecipe.Ingredients } else { @() }
            
            $query = "SELECT FeedRecordID, FeedDate, HaylagePounds, SilagePounds, HighMoistureCornPounds, IngredientAmounts, TotalPounds, Notes, RecordedBy, CreatedDate FROM FeedRecords ORDER BY FeedDate DESC LIMIT 50"
            
            $feedRecords = Invoke-UniversalSQLiteQuery -Path (Get-DatabasePath) -Query $query
            
            if ($feedRecords.Count -eq 0) {
                New-UDAlert -Severity info -Text "No feed records found. Add your first daily feed record above."
            }
            else {
                # Build columns dynamically
                $columns = @(
                    New-UDTableColumn -Property FeedDate -Title "Feed Date" -ShowSort -Render {
                        $fd = Format-Date $EventData.FeedDate
                        if ($fd -ne '-') { $fd } else { ($EventData.FeedDate -split ' ')[0] }
                    }
                )
                
                # Add ingredient columns if using new format
                if ($ingredients.Count -gt 0) {
                    foreach ($ingredient in $ingredients) {
                        $ingName = $ingredient.IngredientName
                        $columns += New-UDTableColumn -Property "Ing_$($ingredient.IngredientID)" -Title "$ingName ($($ingredient.Unit))" -Render {
                            try {
                                if ($EventData.IngredientAmounts) {
                                    $amounts = $EventData.IngredientAmounts | ConvertFrom-Json
                                    $value = $amounts.$ingName
                                    if ($value) {
                                        "{0:N0}" -f [decimal]$value
                                    }
                                    else {
                                        "-"
                                    }
                                }
                                else {
                                    "-"
                                }
                            }
                            catch {
                                "-"
                            }
                        }
                    }
                }
                else {
                    # Fall back to legacy columns
                    $columns += New-UDTableColumn -Property HaylagePounds -Title "Haylage (lbs)" -ShowSort -Render {
                        "{0:N0}" -f [decimal]$EventData.HaylagePounds
                    }
                    $columns += New-UDTableColumn -Property SilagePounds -Title "Silage (lbs)" -ShowSort -Render {
                        "{0:N0}" -f [decimal]$EventData.SilagePounds
                    }
                    $columns += New-UDTableColumn -Property HighMoistureCornPounds -Title "High Moisture Corn (lbs)" -ShowSort -Render {
                        "{0:N0}" -f [decimal]$EventData.HighMoistureCornPounds
                    }
                }
                
                $columns += New-UDTableColumn -Property TotalPounds -Title "Total (lbs)" -ShowSort -Render {
                    New-UDElement -Tag 'strong' -Content {
                        "{0:N0}" -f [decimal]$EventData.TotalPounds
                    }
                }
                $columns += New-UDTableColumn -Property RecordedBy -Title "Recorded By" -ShowSort
                $columns += New-UDTableColumn -Property FeedRecordID -Title "Actions" -Render {
                    New-UDButton -Icon (New-UDIcon -Icon Trash) -Size small -OnClick {
                        Show-UDModal -Content {
                            New-UDTypography -Text "Are you sure you want to delete this feed record?" -Variant body1
                        } -Header {
                            New-UDTypography -Text "⚠️ Confirm Delete" -Variant h6
                        } -Footer {
                            New-UDButton -Text "Cancel" -OnClick { Hide-UDModal } -Variant outlined
                            New-UDButton -Text "Delete" -OnClick {
                                try {
                                    $recordId = $EventData.FeedRecordID
                                    Remove-FeedRecord -FeedRecordID $recordId -Force
                                    Hide-UDModal
                                    Show-UDToast -Message "Feed record deleted successfully" -MessageColor green -Duration 3000
                                    Sync-UDElement -Id 'feed-records-table'
                                }
                                catch {
                                    Show-UDToast -Message "Error deleting feed record: $($_.Exception.Message)" -MessageColor red -Duration 5000
                                }
                            } -Style @{backgroundColor = '#d32f2f'; color = 'white'; marginLeft = '10px' }
                        } -FullWidth -MaxWidth 'sm'
                    }
                }
                
                New-UDTable -Data $feedRecords -Columns $columns -Sort -ShowPagination -PageSize 15 -Dense -ShowSearch
            }
        }
    } -Style @{
        borderRadius = '16px'
        boxShadow = '0 4px 12px rgba(0,0,0,0.15)'
        border = '1px solid #e3f2fd'
    }
}