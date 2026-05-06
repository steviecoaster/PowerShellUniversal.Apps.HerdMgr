# HerdManager Dashboard Styles
# Centralized styling system that works well in both light and dark modes

# Color Palette - Using CSS variables for theme-aware colors
# Using Global scope so it's accessible in Universal Dashboard page contexts
$Global:HerdStyles = @{
    
    # Primary Colors (using transparency and theme-aware colors)
    Colors = @{
        Primary      = '#4CAF50'  # Green
        PrimaryLight = '#81C784'
        PrimaryDark  = '#388E3C'
        Secondary    = '#2196F3'  # Blue
        Accent       = '#FF9800'  # Orange
        Success      = '#4CAF50'
        Warning      = '#FF9800'
        Error        = '#F44336'
        Info         = '#2196F3'
    }
    
    # Card Styles - Theme-aware with proper contrast
    Card = @{
        Default = @{
            borderRadius = '12px'
            boxShadow    = '0 2px 8px rgba(0,0,0,0.1)'
            border       = '1px solid rgba(0,0,0,0.08)'
            marginBottom = '20px'
        }
        
        Elevated = @{
            borderRadius = '16px'
            boxShadow    = '0 4px 12px rgba(0,0,0,0.15)'
            border       = '1px solid rgba(0,0,0,0.06)'
            marginBottom = '30px'
        }
        
        Accent = @{
            borderRadius = '12px'
            boxShadow    = '0 3px 10px rgba(76, 175, 80, 0.2)'
            border       = '2px solid rgba(76, 175, 80, 0.3)'
            marginBottom = '20px'
        }
    }
    
    # Page Header Styles
    PageHeader = @{
        Hero = @{
            borderRadius = '12px'
            padding      = '24px'
            marginBottom = '24px'
            boxShadow    = '0 4px 6px rgba(0,0,0,0.1)'
        }
        
        Title = @{
            marginBottom = '8px'
            fontWeight   = '600'
        }
        
        Subtitle = @{
            opacity = '0.8'
        }
    }
    
    # Button Styles
    Button = @{
        Primary = @{
            backgroundColor = '#4CAF50'
            color           = 'white'
            borderRadius    = '8px'
            textTransform   = 'none'
            fontWeight      = '500'
            padding         = '8px 16px'
        }
        
        Secondary = @{
            borderRadius  = '8px'
            textTransform = 'none'
            fontWeight    = '500'
            padding       = '8px 16px'
        }
        
        Danger = @{
            backgroundColor = '#d32f2f'
            color           = 'white'
            borderRadius    = '8px'
            textTransform   = 'none'
        }
    }
    
    # Modal/Dialog Styles
    Modal = @{
        Container = @{
            borderRadius = '12px'
            boxShadow    = '0 8px 32px rgba(0,0,0,0.3)'
        }
        
        Header = @{
            padding      = '20px'
            margin       = '-20px -20px 20px -20px'
            borderRadius = '12px 12px 0 0'
        }
        
        HeaderGradient = @{
            padding    = '20px'
            background = 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)'
            color      = 'white'
            margin     = '-20px -20px 20px -20px'
            borderRadius = '12px 12px 0 0'
        }
        
        HeaderSuccess = @{
            padding         = '20px'
            backgroundColor = '#4CAF50'
            color           = 'white'
            margin          = '-20px -20px 20px -20px'
            borderRadius    = '12px 12px 0 0'
        }
        
        HeaderWarning = @{
            padding         = '20px'
            backgroundColor = '#FF9800'
            color           = 'white'
            margin          = '-20px -20px 20px -20px'
            borderRadius    = '12px 12px 0 0'
        }
    }
    
    # Form Styles
    Form = @{
        Container = @{
            padding = '16px'
        }
        
        Section = @{
            marginBottom = '24px'
        }
        
        FieldSpacing = @{
            marginBottom = '16px'
        }
    }
    
    # Grid/Layout Styles
    Layout = @{
        Container = @{
            marginBottom = '20px'
        }
        
        Section = @{
            marginBottom = '32px'
        }
        
        Spacer = @{
            marginTop    = '16px'
            marginBottom = '16px'
        }
    }
    
    # Table Styles - Works with Universal Dashboard's built-in dark mode
    Table = @{
        Container = @{
            borderRadius = '8px'
            overflow     = 'hidden'
        }
    }
    
    # Typography Styles
    Typography = @{
        PageTitle = @{
            marginBottom = '20px'
            fontWeight   = '600'
        }
        
        SectionTitle = @{
            marginBottom = '16px'
            marginTop    = '8px'
            fontWeight   = '500'
        }
        
        Muted = @{
            opacity = '0.7'
        }
        
        Emphasis = @{
            fontWeight = '600'
        }
    }
    
    # Alert/Banner Styles
    Alert = @{
        Default = @{
            borderRadius = '8px'
            marginBottom = '16px'
        }
    }
    
    # Code Block Styles - Theme-aware for examples and snippets
    CodeBlock = @{
        Default = @{
            background   = 'rgba(0, 0, 0, 0.05)'
            padding      = '10px'
            borderRadius = '4px'
            overflow     = 'auto'
            fontSize     = '12px'
            border       = '1px solid rgba(0, 0, 0, 0.12)'
            color        = 'inherit'
            fontFamily   = 'monospace'
        }
    }
    
    # Skeleton Loading Styles - CSS classes for loading states
    Skeleton = @{
        # Standard spacing between skeleton elements
        Spaced = 'herd-skeleton-spaced'
        # Larger spacing for sections
        SpacedLarge = 'herd-skeleton-spaced-lg'
    }
    
    # Stat/Metric Card Styles
    StatCard = @{
        Default = @{
            borderRadius = '12px'
            padding      = '20px'
            textAlign    = 'center'
            boxShadow    = '0 2px 8px rgba(0,0,0,0.1)'
            border       = '1px solid rgba(0,0,0,0.06)'
        }
        
        Success = @{
            borderRadius = '12px'
            padding      = '20px'
            textAlign    = 'center'
            boxShadow    = '0 2px 8px rgba(76, 175, 80, 0.2)'
            border       = '2px solid rgba(76, 175, 80, 0.3)'
        }
        
        Warning = @{
            borderRadius = '12px'
            padding      = '20px'
            textAlign    = 'center'
            boxShadow    = '0 2px 8px rgba(255, 152, 0, 0.2)'
            border       = '2px solid rgba(255, 152, 0, 0.3)'
        }
    }

    # CSS rules for blank print-preview pages, stored as structured data.
    # Serialize with: ConvertTo-CssString $HerdStyles.PrintCSS.Invoice
    PrintCSS = @{

        Invoice = [ordered]@{
            '@media print' = [ordered]@{
                '.MuiAppBar-root, .MuiDrawer-root, button, .no-print' = [ordered]@{ display = 'none !important' }
                'body'                        = [ordered]@{ margin = '0'; padding = '10px'; 'font-size' = '11pt' }
                '.invoice-container'          = [ordered]@{ 'max-width' = '100% !important'; margin = '0 !important'; padding = '15px !important'; 'box-shadow' = 'none !important' }
                '.invoice-header'             = [ordered]@{ 'padding-bottom' = '10px'; 'margin-bottom' = '15px' }
                '.invoice-header h2'          = [ordered]@{ 'font-size' = '18pt'; margin = '0' }
                '.invoice-header h3'          = [ordered]@{ 'font-size' = '14pt' }
                '.invoice-header p'           = [ordered]@{ 'font-size' = '9pt'; margin = '1px 0' }
                '.invoice-section'            = [ordered]@{ 'margin-bottom' = '15px' }
                '.invoice-section h6'         = [ordered]@{ 'font-size' = '12pt'; 'margin-bottom' = '8px' }
                '.invoice-info-row'           = [ordered]@{ 'margin-bottom' = '5px' }
                '.invoice-info-row p, .invoice-info-row span' = [ordered]@{ 'font-size' = '10pt' }
                '.invoice-table'              = [ordered]@{ 'font-size' = '9pt'; 'margin-top' = '8px' }
                '.invoice-table th'           = [ordered]@{ padding = '6px' }
                '.invoice-table td'           = [ordered]@{ padding = '5px' }
                '.invoice-total'              = [ordered]@{ padding = '10px'; 'margin-top' = '15px'; 'font-size' = '14pt' }
            }
            '.invoice-container'              = [ordered]@{ 'max-width' = '900px'; margin = '20px auto'; padding = '30px'; background = 'white'; 'box-shadow' = '0 2px 10px rgba(0,0,0,0.1)' }
            '.invoice-header'                 = [ordered]@{ 'border-bottom' = '3px solid #2e7d32'; 'padding-bottom' = '20px'; 'margin-bottom' = '30px' }
            '.invoice-section'                = [ordered]@{ 'margin-bottom' = '25px' }
            '.invoice-table'                  = [ordered]@{ width = '100%'; 'border-collapse' = 'collapse'; 'margin-top' = '15px'; 'table-layout' = 'fixed' }
            '.invoice-table th'               = [ordered]@{ 'background-color' = '#2e7d32'; color = 'white'; padding = '10px'; 'text-align' = 'left' }
            '.invoice-table th:nth-child(1)'  = [ordered]@{ width = '15%' }
            '.invoice-table th:nth-child(2)'  = [ordered]@{ width = '20%' }
            '.invoice-table th:nth-child(3)'  = [ordered]@{ width = '50%' }
            '.invoice-table th:nth-child(4)'  = [ordered]@{ width = '15%'; 'text-align' = 'right' }
            '.invoice-table td'               = [ordered]@{ padding = '8px'; 'border-bottom' = '1px solid #ddd'; 'word-wrap' = 'break-word' }
            '.invoice-total'                  = [ordered]@{ 'background-color' = '#e8f5e9'; padding = '15px'; 'margin-top' = '20px'; 'text-align' = 'right'; 'font-size' = '1.3em'; 'font-weight' = 'bold'; color = '#2e7d32' }
            '.invoice-info-row'               = [ordered]@{ display = 'flex'; 'justify-content' = 'space-between'; 'margin-bottom' = '10px' }
            '.invoice-label'                  = [ordered]@{ 'font-weight' = 'bold'; color = '#555' }
        }

        TonnageReport = [ordered]@{
            '@media print' = [ordered]@{
                '.MuiAppBar-root, .MuiDrawer-root, button, .no-print' = [ordered]@{ display = 'none !important' }
                'body'                        = [ordered]@{ margin = '0'; padding = '10px'; 'font-size' = '11pt' }
                '.report-container'           = [ordered]@{ 'max-width' = '100% !important'; margin = '0 !important'; padding = '15px !important'; 'box-shadow' = 'none !important' }
                '.report-header'              = [ordered]@{ 'padding-bottom' = '10px'; 'margin-bottom' = '15px' }
                '.report-header h2'           = [ordered]@{ 'font-size' = '18pt'; margin = '0' }
                '.report-header h3'           = [ordered]@{ 'font-size' = '14pt' }
                '.report-table'               = [ordered]@{ 'font-size' = '9pt'; 'margin-top' = '8px' }
                '.report-table th, .report-table td' = [ordered]@{ padding = '5px 8px' }
                '.report-summary'             = [ordered]@{ 'font-size' = '10pt'; 'margin-bottom' = '12px' }
            }
            '.report-container'               = [ordered]@{ 'max-width' = '900px'; margin = '20px auto'; padding = '30px'; background = 'white'; 'box-shadow' = '0 2px 10px rgba(0,0,0,0.1)' }
            '.report-header'                  = [ordered]@{ 'border-bottom' = '3px solid #2e7d32'; 'padding-bottom' = '20px'; 'margin-bottom' = '30px' }
            '.report-table'                   = [ordered]@{ width = '100%'; 'border-collapse' = 'collapse'; 'margin-top' = '15px' }
            '.report-table th'                = [ordered]@{ 'background-color' = '#2e7d32'; color = 'white'; padding = '10px'; 'text-align' = 'left' }
            '.report-table td'                = [ordered]@{ padding = '8px 10px'; 'border-bottom' = '1px solid #ddd' }
            '.report-table tr:nth-child(even) td' = [ordered]@{ 'background-color' = '#f9f9f9' }
            '.report-table td.num'            = [ordered]@{ 'text-align' = 'right' }
            '.report-table th.num'            = [ordered]@{ 'text-align' = 'right' }
            '.report-total'                   = [ordered]@{ 'background-color' = '#e8f5e9'; padding = '15px'; 'margin-top' = '20px'; 'text-align' = 'right'; 'font-size' = '1.2em'; 'font-weight' = 'bold'; color = '#2e7d32' }
            '.summary-grid'                   = [ordered]@{ display = 'flex'; gap = '20px'; 'margin-bottom' = '25px' }
            '.summary-card'                   = [ordered]@{ flex = '1'; border = '1px solid #c8e6c9'; 'border-radius' = '6px'; padding = '12px 18px'; 'background-color' = '#f1f8e9' }
            '.summary-card .label'            = [ordered]@{ 'font-size' = '0.85em'; color = '#555'; 'margin-bottom' = '4px' }
            '.summary-card .value'            = [ordered]@{ 'font-size' = '1.4em'; 'font-weight' = 'bold'; color = '#2e7d32' }
        }
    }
}
