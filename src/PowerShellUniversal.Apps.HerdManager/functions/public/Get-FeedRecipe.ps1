function Get-FeedRecipe {
    <#
    .SYNOPSIS
    Retrieves feed recipe information
    
    .DESCRIPTION
    Gets feed recipe data including ingredients. Can retrieve active recipe,
    specific recipe by ID or name, or all recipes.
    
    .PARAMETER RecipeID
    Specific recipe ID to retrieve
    
    .PARAMETER RecipeName
    Specific recipe name to retrieve
    
    .PARAMETER Active
    Get only the active recipe (default behavior if no parameters specified)
    
    .PARAMETER All
    Get all recipes
    
    .PARAMETER IncludeIngredients
    Include ingredient details in the output
    
    .EXAMPLE
    Get-FeedRecipe
    
    Gets the currently active recipe
    
    .EXAMPLE
    Get-FeedRecipe -RecipeName "Standard Feed Mix" -IncludeIngredients
    
    Gets specific recipe with its ingredients
    
    .EXAMPLE
    Get-FeedRecipe -All
    
    Gets all recipes in the system
    #>
    [CmdletBinding(DefaultParameterSetName = 'Active')]
    param(
        [Parameter(ParameterSetName = 'ById')]
        [int]$RecipeID,
        
        [Parameter(ParameterSetName = 'ByName')]
        [string]$RecipeName,
        
        [Parameter(ParameterSetName = 'Active')]
        [switch]$Active,
        
        [Parameter(ParameterSetName = 'All')]
        [switch]$All,
        
        [Parameter()]
        [switch]$IncludeIngredients
    )
    
    $query = "SELECT RecipeID, RecipeName, Description, IsActive, CreatedDate, ModifiedDate FROM FeedRecipes"
    
    switch ($PSCmdlet.ParameterSetName) {
        'ById' {
            $query += " WHERE RecipeID = $RecipeID"
        }
        'ByName' {
            $nameValue = ConvertTo-SqlValue -Value $RecipeName
            $query += " WHERE RecipeName = $nameValue"
        }
        'Active' {
            $query += " WHERE IsActive = 1"
        }
        'All' {
            # No filter
        }
    }
    
    $query += " ORDER BY IsActive DESC, RecipeName ASC"
    
    $recipes = Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $query
    
    if (-not $recipes) {
        Write-Verbose "No recipes found"
        $null
    }
    
    # Add ingredients if requested
    if ($IncludeIngredients -and $recipes) {
        foreach ($recipe in $recipes) {
            $ingredientQuery = @"
SELECT IngredientID, IngredientName, DisplayOrder, MinValue, MaxValue, DefaultValue, Unit
FROM FeedIngredients
WHERE RecipeID = $($recipe.RecipeID)
ORDER BY DisplayOrder
"@
            $ingredients = Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $ingredientQuery
            
            # Add ingredients as a property
            $recipe | Add-Member -MemberType NoteProperty -Name Ingredients -Value $ingredients -Force
        }
    }
    
    $recipes
}
