function Initialize-HerdData {
    [CmdletBinding()]
    param()

    # Stable paths (must already be set by your psm1)
    if (-not $Script:RecipeDbPath) {
        throw "Initialize-CookbookData: `$Script:RecipeDbPath is not set."
    }

    if (-not $Script:RecipeSchemaSql) {
        throw "Initialize-CookbookData: `$Script:RecipeSchemaSql is not set."
    }

    # Ensure DB file exists
    Initialize-HerdDbFile -Database $Script:RecipeDbPath

    # Apply schema FROM Schema.sql
    Initialize-HerdDatabase -Schema $Script:RecipeSchemaSql -Database $Script:RecipeDbPath
}