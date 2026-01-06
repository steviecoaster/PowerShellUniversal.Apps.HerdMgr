# Style Guide Page - Reference for all HerdManager styles

$styleGuide = New-UDPage -Name 'Style Guide' -Url '/style-guide' -Content {
    
    # Page Header
    New-UDCard -Style (Merge-HerdStyle -BaseStyle $HerdStyles.PageHeader.Hero -CustomStyle @{
        backgroundColor = '#667eea'
        color           = 'white'
        padding         = '30px'
        backgroundImage = 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)'
    }) -Content {
        New-UDTypography -Text "🎨 HerdManager Style Guide" -Variant h4 -Style $HerdStyles.PageHeader.Title
        New-UDTypography -Text "Centralized styling system for consistent UI across light and dark modes" -Variant body1 -Style $HerdStyles.PageHeader.Subtitle
    }
    
    # Cards Section
    New-UDTypography -Text "Card Styles" -Variant h5 -Style $HerdStyles.Typography.SectionTitle
    
    New-UDGrid -Container -Spacing 2 -Content {
        New-UDGrid -Item -ExtraSmallSize 12 -MediumSize 4 -Content {
            New-UDCard -Title "Default Card" -Content {
                New-UDTypography -Text "Standard card with subtle shadow and border" -Variant body2
            } -Style $HerdStyles.Card.Default
        }
        
        New-UDGrid -Item -ExtraSmallSize 12 -MediumSize 4 -Content {
            New-UDCard -Title "Elevated Card" -Content {
                New-UDTypography -Text "Elevated card with more prominent shadow" -Variant body2
            } -Style $HerdStyles.Card.Elevated
        }
        
        New-UDGrid -Item -ExtraSmallSize 12 -MediumSize 4 -Content {
            New-UDCard -Title "Accent Card" -Content {
                New-UDTypography -Text "Accent card with colored border" -Variant body2
            } -Style $HerdStyles.Card.Accent
        }
    }
    
    # Buttons Section
    New-UDTypography -Text "Button Styles" -Variant h5 -Style $HerdStyles.Typography.SectionTitle
    
    New-UDCard -Content {
        New-UDStack -Direction row -Spacing 2 -Content {
            New-UDButton -Text "Primary Button" -Style $HerdStyles.Button.Primary
            New-UDButton -Text "Secondary Button" -Variant outlined -Style $HerdStyles.Button.Secondary
            New-UDButton -Text "Danger Button" -Style $HerdStyles.Button.Danger
        }
    } -Style $HerdStyles.Card.Default
    
    # Modal Examples
    New-UDTypography -Text "Modal Header Styles" -Variant h5 -Style $HerdStyles.Typography.SectionTitle
    
    New-UDCard -Content {
        New-UDStack -Direction row -Spacing 2 -Content {
            New-UDButton -Text "Gradient Modal" -OnClick {
                Show-UDModal -Header {
                    New-UDTypography -Text "Gradient Header" -Variant h5 -Style $HerdStyles.Modal.HeaderGradient
                } -Content {
                    New-UDTypography -Text "Modal with gradient header" -Variant body1
                } -Footer {
                    New-UDButton -Text "Close" -OnClick { Hide-UDModal }
                } -Style $HerdStyles.Modal.Container
            }
            
            New-UDButton -Text "Success Modal" -OnClick {
                Show-UDModal -Header {
                    New-UDTypography -Text "Success Header" -Variant h5 -Style $HerdStyles.Modal.HeaderSuccess
                } -Content {
                    New-UDTypography -Text "Modal with success header" -Variant body1
                } -Footer {
                    New-UDButton -Text "Close" -OnClick { Hide-UDModal }
                } -Style $HerdStyles.Modal.Container
            }
            
            New-UDButton -Text "Warning Modal" -OnClick {
                Show-UDModal -Header {
                    New-UDTypography -Text "Warning Header" -Variant h5 -Style $HerdStyles.Modal.HeaderWarning
                } -Content {
                    New-UDTypography -Text "Modal with warning header" -Variant body1
                } -Footer {
                    New-UDButton -Text "Close" -OnClick { Hide-UDModal }
                } -Style $HerdStyles.Modal.Container
            }
        }
    } -Style $HerdStyles.Card.Default
    
    # Stat Cards
    New-UDTypography -Text "Stat Card Styles" -Variant h5 -Style $HerdStyles.Typography.SectionTitle
    
    New-UDGrid -Container -Spacing 2 -Content {
        New-UDGrid -Item -ExtraSmallSize 12 -MediumSize 4 -Content {
            New-UDCard -Content {
                New-UDTypography -Text "125" -Variant h3 -Style @{fontWeight = 'bold'; marginBottom = '8px'}
                New-UDTypography -Text "Default Stat" -Variant body2 -Style $HerdStyles.Typography.Muted
            } -Style $HerdStyles.StatCard.Default
        }
        
        New-UDGrid -Item -ExtraSmallSize 12 -MediumSize 4 -Content {
            New-UDCard -Content {
                New-UDTypography -Text "98%" -Variant h3 -Style @{fontWeight = 'bold'; marginBottom = '8px'; color = '#4CAF50'}
                New-UDTypography -Text "Success Stat" -Variant body2 -Style $HerdStyles.Typography.Muted
            } -Style $HerdStyles.StatCard.Success
        }
        
        New-UDGrid -Item -ExtraSmallSize 12 -MediumSize 4 -Content {
            New-UDCard -Content {
                New-UDTypography -Text "3" -Variant h3 -Style @{fontWeight = 'bold'; marginBottom = '8px'; color = '#FF9800'}
                New-UDTypography -Text "Warning Stat" -Variant body2 -Style $HerdStyles.Typography.Muted
            } -Style $HerdStyles.StatCard.Warning
        }
    }
    
    # Typography
    New-UDTypography -Text "Typography Styles" -Variant h5 -Style $HerdStyles.Typography.SectionTitle
    
    New-UDCard -Content {
        New-UDTypography -Text "Page Title" -Variant h4 -Style $HerdStyles.Typography.PageTitle
        New-UDTypography -Text "Section Title" -Variant h5 -Style $HerdStyles.Typography.SectionTitle
        New-UDTypography -Text "Regular body text with normal styling" -Variant body1
        New-UDTypography -Text "Muted text for less important information" -Variant body2 -Style $HerdStyles.Typography.Muted
        New-UDTypography -Text "Emphasized text for important content" -Variant body1 -Style $HerdStyles.Typography.Emphasis
    } -Style $HerdStyles.Card.Default
    
    # Color Palette
    New-UDTypography -Text "Color Palette" -Variant h5 -Style $HerdStyles.Typography.SectionTitle
    
    New-UDCard -Content {
        New-UDGrid -Container -Spacing 2 -Content {
            foreach ($colorName in $HerdStyles.Colors.Keys) {
                $colorValue = $HerdStyles.Colors[$colorName]
                New-UDGrid -Item -ExtraSmallSize 6 -MediumSize 3 -Content {
                    New-UDCard -Content {
                        New-UDElement -Tag 'div' -Attributes @{
                            style = @{
                                backgroundColor = $colorValue
                                height = '60px'
                                borderRadius = '8px'
                                marginBottom = '8px'
                            }
                        }
                        New-UDTypography -Text $colorName -Variant body2 -Style @{fontWeight = 'bold'; marginBottom = '4px'}
                        New-UDTypography -Text $colorValue -Variant caption -Style $HerdStyles.Typography.Muted
                    } -Style @{borderRadius = '8px'; padding = '12px'}
                }
            }
        }
    } -Style $HerdStyles.Card.Default
    
    # Usage Instructions
    New-UDTypography -Text "Usage Instructions" -Variant h5 -Style $HerdStyles.Typography.SectionTitle
    
    New-UDCard -Content {
        New-UDTypography -Text "Using Predefined Styles:" -Variant h6 -Style @{marginBottom = '12px'}
        New-UDElement -Tag 'pre' -Content {
            'New-UDCard -Style $HerdStyles.Card.Elevated'
        } -Attributes @{
            style = @{
                backgroundColor = 'rgba(0,0,0,0.05)'
                padding = '12px'
                borderRadius = '6px'
                fontFamily = 'monospace'
                fontSize = '14px'
            }
        }
        
        New-UDTypography -Text "Merging Custom Styles with Base Styles:" -Variant h6 -Style @{marginTop = '20px'; marginBottom = '12px'}
        New-UDElement -Tag 'pre' -Content {
@'
New-UDCard -Style (Merge-HerdStyle `
    -BaseStyle $HerdStyles.Card.Default `
    -CustomStyle @{
        backgroundColor = '#e3f2fd'
    })
'@
        } -Attributes @{
            style = @{
                backgroundColor = 'rgba(0,0,0,0.05)'
                padding = '12px'
                borderRadius = '6px'
                fontFamily = 'monospace'
                fontSize = '14px'
                whiteSpace = 'pre'
            }
        }
    } -Style $HerdStyles.Card.Default
}
