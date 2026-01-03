function Set-FeedRecipe {
    <#
    .SYNOPSIS
    Creates or updates a feed recipe
    
    .DESCRIPTION
    Manages feed recipes including creating new recipes, updating existing ones,
    and setting the active recipe. Can also manage ingredients for a recipe.
    
    .PARAMETER RecipeName
    Name of the recipe (required for new recipes)
    
    .PARAMETER RecipeID
    ID of existing recipe to update
    
    .PARAMETER Description
    Description of the recipe
    
    .PARAMETER Ingredients
    Array of ingredient definitions. Each ingredient should be a hashtable with:
    - Name (required)
    - DisplayOrder (required)
    - MinValue (optional, default 0)
    - MaxValue (optional, default 10000)
    - DefaultValue (optional, default 0)
    - Unit (optional, default 'lbs')
    
    .PARAMETER SetActive
    Set this recipe as the active recipe (deactivates others)
    
    .EXAMPLE
    Set-FeedRecipe -RecipeName "Winter Feed Mix" -Description "High energy winter recipe" -SetActive
    
    Creates a new recipe and sets it as active
    
    .EXAMPLE
    $ingredients = @(
        @{Name = 'Corn Silage'; DisplayOrder = 1; MaxValue = 15000}
        @{Name = 'Grain Mix'; DisplayOrder = 2; MaxValue = 5000}
    )
    Set-FeedRecipe -RecipeName "Simple Mix" -Ingredients $ingredients -SetActive
    
    Creates a recipe with specific ingredients
    
    .EXAMPLE
    Set-FeedRecipe -RecipeID 2 -SetActive
    
    Sets recipe ID 2 as the active recipe
    #>
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Create')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'Create')]
        [string]$RecipeName,
        
        [Parameter(Mandatory, ParameterSetName = 'Update')]
        [int]$RecipeID,
        
        [Parameter()]
        [string]$Description,
        
        [Parameter()]
        [hashtable[]]$Ingredients,
        
        [Parameter()]
        [switch]$SetActive
    )
    
    if ($PSCmdlet.ParameterSetName -eq 'Create') {
        # Create new recipe
        $nameValue = ConvertTo-SqlValue -Value $RecipeName
        $descValue = ConvertTo-SqlValue -Value $Description
        $isActive = if ($SetActive) { 1 } else { 0 }
        
        if ($PSCmdlet.ShouldProcess($RecipeName, "Create new recipe")) {
            # Deactivate other recipes if setting this one active
            if ($SetActive) {
                $deactivateQuery = "UPDATE FeedRecipes SET IsActive = 0"
                Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $deactivateQuery
            }
            
            $insertQuery = "INSERT INTO FeedRecipes (RecipeName, Description, IsActive) VALUES ($nameValue, $descValue, $isActive)"
            
            try {
                Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $insertQuery
                Write-Verbose "Created recipe: $RecipeName"
                
                # Get the new recipe ID
                $getIDQuery = "SELECT RecipeID FROM FeedRecipes WHERE RecipeName = $nameValue"
                $result = Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $getIDQuery
                $newRecipeID = $result.RecipeID
                
                # Add ingredients if provided
                if ($Ingredients) {
                    foreach ($ingredient in $Ingredients) {
                        $ingName = ConvertTo-SqlValue -Value $ingredient.Name
                        $order = $ingredient.DisplayOrder
                        $min = if ($ingredient.MinValue) { $ingredient.MinValue } else { 0 }
                        $max = if ($ingredient.MaxValue) { $ingredient.MaxValue } else { 10000 }
                        $default = if ($ingredient.DefaultValue) { $ingredient.DefaultValue } else { 0 }
                        $unit = if ($ingredient.Unit) { ConvertTo-SqlValue -Value $ingredient.Unit } else { "'lbs'" }
                        
                        $insertIngredient = @"
INSERT INTO FeedIngredients (RecipeID, IngredientName, DisplayOrder, MinValue, MaxValue, DefaultValue, Unit)
VALUES ($newRecipeID, $ingName, $order, $min, $max, $default, $unit)
"@
                        Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $insertIngredient
                        Write-Verbose "  Added ingredient: $($ingredient.Name)"
                    }
                }
                
                Write-Output "Recipe created successfully with ID: $newRecipeID"
            }
            catch {
                if ($_.Exception.Message -like "*UNIQUE constraint*") {
                    throw "A recipe with the name '$RecipeName' already exists."
                }
                else {
                    throw $_
                }
            }
        }
    }
    else {
        # Update existing recipe
        if ($PSCmdlet.ShouldProcess("Recipe ID $RecipeID", "Update recipe")) {
            # Build update query
            $updates = @()
            
            if ($Description) {
                $descValue = ConvertTo-SqlValue -Value $Description
                $updates += "Description = $descValue"
            }
            
            if ($SetActive) {
                # Deactivate all other recipes first
                $deactivateQuery = "UPDATE FeedRecipes SET IsActive = 0"
                Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $deactivateQuery
                $updates += "IsActive = 1"
            }
            
            $updates += "ModifiedDate = CURRENT_TIMESTAMP"
            
            if ($updates.Count -gt 0) {
                $updateQuery = "UPDATE FeedRecipes SET $($updates -join ', ') WHERE RecipeID = $RecipeID"
                Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $updateQuery
                Write-Verbose "Updated recipe ID: $RecipeID"
            }
            
            # Update ingredients if provided (replaces existing)
            if ($Ingredients) {
                # Delete existing ingredients
                $deleteQuery = "DELETE FROM FeedIngredients WHERE RecipeID = $RecipeID"
                Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $deleteQuery
                
                # Insert new ingredients
                foreach ($ingredient in $Ingredients) {
                    $ingName = ConvertTo-SqlValue -Value $ingredient.Name
                    $order = $ingredient.DisplayOrder
                    $min = if ($ingredient.MinValue) { $ingredient.MinValue } else { 0 }
                    $max = if ($ingredient.MaxValue) { $ingredient.MaxValue } else { 10000 }
                    $default = if ($ingredient.DefaultValue) { $ingredient.DefaultValue } else { 0 }
                    $unit = if ($ingredient.Unit) { ConvertTo-SqlValue -Value $ingredient.Unit } else { "'lbs'" }
                    
                    $insertIngredient = @"
INSERT INTO FeedIngredients (RecipeID, IngredientName, DisplayOrder, MinValue, MaxValue, DefaultValue, Unit)
VALUES ($RecipeID, $ingName, $order, $min, $max, $default, $unit)
"@
                    Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $insertIngredient
                    Write-Verbose "  Added ingredient: $($ingredient.Name)"
                }
            }
            
            Write-Output "Recipe updated successfully"
        }
    }
}
