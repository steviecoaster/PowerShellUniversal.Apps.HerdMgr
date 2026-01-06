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
}
