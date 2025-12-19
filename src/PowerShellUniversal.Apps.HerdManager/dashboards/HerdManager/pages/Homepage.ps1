$homepage = New-UDPage -Name 'Home' -Url '/Home' -Content {
    $session:system = Get-SystemInfo -DbPath $script:DatabasePath
    # Hero Section with Farm Theme
    New-UDCard -Style @{
        backgroundColor = '#2e7d32'
        color = 'white'
        padding = '40px'
        marginBottom = '30px'
        borderRadius = '8px'
        backgroundImage = 'linear-gradient(135deg, #2e7d32 0%, #66bb6a 100%)'
        boxShadow = '0 4px 6px rgba(0,0,0,0.1)'
    } -Content {
        New-UDGrid -Container -Content {
            New-UDGrid -Item -ExtraSmallSize 12 -Content {
                $headerTypography = if($session:system -and $session:system.FarmName){
                    '🐂 {0}' -f $session:system.FarmName
                }
                else {
                    "🐂 Herd Management Platform"
                }

                New-UDTypography -Text $headerTypography -Variant h2 -Style @{
                    fontWeight = 'bold'
                    textAlign = 'center'
                    marginBottom = '15px'
                }

                $establishedTypography = if($session:system -and $session:system.Established) {
                    'Since {0}' -f ((Parse-Date $session:system.Established).Year)
                }
                else {
                    'Copyright 2025'
                }

                New-UDTypography -Text $establishedTypography -Variant h5 -Style @{
                    textAlign = 'center'
                    opacity = '0.9'
                    marginBottom = '10px'
                }

                $missionTypography = if($session:system -and $session:system.MissionStatement){
                    '{0}' -f $session:system.MissionStatement
                }
                else {
                    'Quality cattle, even better management'
                }

                New-UDTypography -Text $missionTypography -Variant body1 -Style @{
                    textAlign = 'center'
                    opacity = '0.85'
                }
            }
        }
    }
    
    # First-run banner: prompt to run Setup if system settings are not configured
    
    if (-not $session:system -or -not $session:system.FarmName) {
        New-UDCard -Style @{backgroundColor = '#fff3f3'; borderLeft = '4px solid #d32f2f'; marginBottom = '20px'} -Content {
            New-UDTypography -Text '⚠️ Setup required' -Variant h6 -Style @{color = '#d32f2f'; fontWeight = 'bold'}
            New-UDTypography -Text 'This Herd Manager instance is not yet configured. Please run the setup wizard to configure farm name, currency, and preferences.' -Variant body2 -Style @{marginBottom = '12px'}
            New-UDButton -Text 'Run Setup' -Variant contained -Style @{backgroundColor = '#d32f2f'; color = 'white'} -OnClick { Invoke-UDRedirect -Url '/settings' }
        }
    }

    # Quick Stats Dashboard (Dynamic - can be populated with real data)
    New-UDDynamic -Id 'quick-stats' -Content {
        New-UDGrid -Container -Spacing 3 -Content {
            
            # Total Cattle Card
            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -MediumSize 3 -Content {
                New-UDCard -Style @{
                    backgroundColor = '#fff3e0'
                    borderLeft = '4px solid #ff6f00'
                    height = '100%'
                } -Content {
                    New-UDElement -Tag 'div' -Content {
                        New-UDTypography -Text "🐂" -Variant h3 -Style @{textAlign = 'center'}
                        New-UDTypography -Text "Total Cattle" -Variant body2 -Style @{
                            textAlign = 'center'
                            color = '#666'
                            marginTop = '5px'
                        }
                        try {
                            $totalCattle = (Get-AllCattle -Status 'Active').Count
                            New-UDTypography -Text $totalCattle -Variant h4 -Style @{
                                textAlign = 'center'
                                fontWeight = 'bold'
                                color = '#ff6f00'
                                marginTop = '10px'
                            }
                        } catch {
                            New-UDTypography -Text "N/A" -Variant h4 -Style @{
                                textAlign = 'center'
                                fontWeight = 'bold'
                                color = '#ff6f00'
                                marginTop = '10px'
                            }
                        }
                    }
                }
            }
            
            # Weight Records Card
            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -MediumSize 3 -Content {
                New-UDCard -Style @{
                    backgroundColor = '#e8f5e9'
                    borderLeft = '4px solid #2e7d32'
                    height = '100%'
                } -Content {
                    New-UDElement -Tag 'div' -Content {
                        New-UDTypography -Text "⚖️" -Variant h3 -Style @{textAlign = 'center'}
                        New-UDTypography -Text "Weight Records (30d)" -Variant body2 -Style @{
                            textAlign = 'center'
                            color = '#666'
                            marginTop = '5px'
                        }
                        try {
                            $weightQuery = "SELECT COUNT(*) as Count FROM WeightRecords WHERE WeightDate >= DATE('now', '-30 days')"
                            $weightCount = (Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $weightQuery).Count
                            New-UDTypography -Text $weightCount -Variant h4 -Style @{
                                textAlign = 'center'
                                fontWeight = 'bold'
                                color = '#2e7d32'
                                marginTop = '10px'
                            }
                        } catch {
                            New-UDTypography -Text "N/A" -Variant h4 -Style @{
                                textAlign = 'center'
                                fontWeight = 'bold'
                                color = '#2e7d32'
                                marginTop = '10px'
                            }
                        }
                    }
                }
            }
            
            # Rate of Gain Card
            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -MediumSize 3 -Content {
                New-UDCard -Style @{
                    backgroundColor = '#e3f2fd'
                    borderLeft = '4px solid #1565c0'
                    height = '100%'
                } -Content {
                    New-UDElement -Tag 'div' -Content {
                        New-UDTypography -Text "📈" -Variant h3 -Style @{textAlign = 'center'}
                        New-UDTypography -Text "Avg Daily Gain" -Variant body2 -Style @{
                            textAlign = 'center'
                            color = '#666'
                            marginTop = '5px'
                        }
                        try {
                            $rogQuery = @"
SELECT AVG(AverageDailyGain) as AvgADG 
FROM RateOfGainCalculations rog
INNER JOIN Cattle c ON rog.CattleID = c.CattleID
WHERE c.Status = 'Active'
"@
                            $avgADG = (Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $rogQuery).AvgADG
                            if ($avgADG) {
                                New-UDTypography -Text "$([Math]::Round($avgADG, 2)) lbs" -Variant h4 -Style @{
                                    textAlign = 'center'
                                    fontWeight = 'bold'
                                    color = '#1565c0'
                                    marginTop = '10px'
                                }
                            } else {
                                New-UDTypography -Text "No data" -Variant h6 -Style @{
                                    textAlign = 'center'
                                    fontWeight = 'bold'
                                    color = '#1565c0'
                                    marginTop = '10px'
                                }
                            }
                        } catch {
                            New-UDTypography -Text "N/A" -Variant h4 -Style @{
                                textAlign = 'center'
                                fontWeight = 'bold'
                                color = '#1565c0'
                                marginTop = '10px'
                            }
                        }
                    }
                }
            }
            
            # Health & Records Card
            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -MediumSize 3 -Content {
                New-UDCard -Style @{
                    backgroundColor = '#fce4ec'
                    borderLeft = '4px solid #c2185b'
                    height = '100%'
                } -Content {
                    New-UDElement -Tag 'div' -Content {
                        New-UDTypography -Text "🩺" -Variant h3 -Style @{textAlign = 'center'}
                        New-UDTypography -Text "Health Events (30d)" -Variant body2 -Style @{
                            textAlign = 'center'
                            color = '#666'
                            marginTop = '5px'
                        }
                        try {
                            $healthQuery = "SELECT COUNT(*) as Count FROM HealthRecords WHERE RecordDate >= DATE('now', '-30 days')"
                            $healthCount = (Invoke-UniversalSQLiteQuery -Path $script:DatabasePath -Query $healthQuery).Count
                            New-UDTypography -Text $healthCount -Variant h4 -Style @{
                                textAlign = 'center'
                                fontWeight = 'bold'
                                color = '#c2185b'
                                marginTop = '10px'
                            }
                        } catch {
                            New-UDTypography -Text "N/A" -Variant h4 -Style @{
                                textAlign = 'center'
                                fontWeight = 'bold'
                                color = '#c2185b'
                                marginTop = '10px'
                            }
                        }
                    }
                }
            }
        }
    }
    
    New-UDElement -Tag 'br'
    
    # Main Feature Navigation Cards
    New-UDTypography -Text "📋 Management Tools" -Variant h4 -Style @{
        marginBottom = '20px'
        marginTop = '20px'
        color = '#2e7d32'
        fontWeight = 'bold'
    }
    
    New-UDGrid -Container -Spacing 3 -Content {
        
        # Rate of Gain Feature Card
        New-UDGrid -Item -ExtraSmallSize 12 -MediumSize 6 -LargeSize 4 -Content {
            New-UDCard -Style @{
                height = '100%'
                borderRadius = '8px'
                boxShadow = '0 2px 8px rgba(0,0,0,0.1)'
                transition = 'transform 0.2s'
                cursor = 'pointer'
            } -Content {
                New-UDElement -Tag 'div' -Content {
                    New-UDTypography -Text "📊 Rate of Gain Calculator" -Variant h5 -Style @{
                        color = '#2e7d32'
                        fontWeight = 'bold'
                        marginBottom = '15px'
                    }
                    New-UDElement -Tag 'br'
                    New-UDElement -Tag 'div' -Content {
                        New-UDTypography -Text "Calculate Average Daily Gain (ADG) for your cattle between weight measurements." -Variant body1 -Style @{
                            marginBottom = '15px'
                            color = '#555'
                        }
                        
                        New-UDElement -Tag 'ul' -Content {
                            New-UDElement -Tag 'li' -Content { "📈 Track weight gain over time" }
                            New-UDElement -Tag 'li' -Content { "📅 Analyze performance by date range" }
                            New-UDElement -Tag 'li' -Content { "💰 Optimize feeding strategies" }
                            New-UDElement -Tag 'li' -Content { "📉 Identify slow-gaining animals" }
                        } -Attributes @{style = 'color: #666; margin-bottom: 20px;'}
                        
                        New-UDButton -Text "Open Rate of Gain" -Variant contained -Style @{
                            backgroundColor = '#2e7d32'
                            color = 'white'
                            width = '100%'
                        } -OnClick {
                            Invoke-UDRedirect -Url '/rog'
                        }
                    }
                }
            }
        }
        
        # Cattle Management
        New-UDGrid -Item -ExtraSmallSize 12 -MediumSize 6 -LargeSize 4 -Content {
            New-UDCard -Style @{
                height = '100%'
                borderRadius = '8px'
                boxShadow = '0 2px 8px rgba(0,0,0,0.1)'
            } -Content {
                New-UDElement -Tag 'div' -Content {
                    New-UDTypography -Text "🐂 Cattle Management" -Variant h5 -Style @{
                        color = '#2e7d32'
                        fontWeight = 'bold'
                        marginBottom = '15px'
                    }
                    New-UDElement -Tag 'br'
                    New-UDElement -Tag 'div' -Content {
                        New-UDTypography -Text "Add, edit, and manage individual cattle records including tag numbers, breeds, and lineage." -Variant body1 -Style @{
                            marginBottom = '15px'
                            color = '#555'
                        }
                        
                        New-UDElement -Tag 'ul' -Content {
                            New-UDElement -Tag 'li' -Content { "➕ Add new cattle to herd" }
                            New-UDElement -Tag 'li' -Content { "✏️ Edit animal information" }
                            New-UDElement -Tag 'li' -Content { "🔍 Search and filter cattle" }
                            New-UDElement -Tag 'li' -Content { "📋 View detailed records" }
                        } -Attributes @{style = 'color: #666; margin-bottom: 20px;'}
                        
                        New-UDButton -Text "Manage Cattle" -Variant contained -Style @{
                            backgroundColor = '#2e7d32'
                            color = 'white'
                            width = '100%'
                        } -OnClick {
                            Invoke-UDRedirect -Url '/cattle'
                        }
                    }
                }
            }
        }
        
        # Health Tracking
        New-UDGrid -Item -ExtraSmallSize 12 -MediumSize 6 -LargeSize 4 -Content {
            New-UDCard -Style @{
                height = '100%'
                borderRadius = '8px'
                boxShadow = '0 2px 8px rgba(0,0,0,0.1)'
            } -Content {
                New-UDElement -Tag 'div' -Content {
                    New-UDTypography -Text "🩺 Health & Treatments" -Variant h5 -Style @{
                        color = '#2e7d32'
                        fontWeight = 'bold'
                        marginBottom = '15px'
                    }
                    New-UDElement -Tag 'br'
                    New-UDElement -Tag 'div' -Content {
                        New-UDTypography -Text "Track veterinary visits, vaccinations, treatments, and health observations for your herd." -Variant body1 -Style @{
                            marginBottom = '15px'
                            color = '#555'
                        }
                        
                        New-UDElement -Tag 'ul' -Content {
                            New-UDElement -Tag 'li' -Content { "💉 Vaccination schedules" }
                            New-UDElement -Tag 'li' -Content { "🏥 Treatment history" }
                            New-UDElement -Tag 'li' -Content { "📝 Health observations" }
                            New-UDElement -Tag 'li' -Content { "🔔 Upcoming reminders" }
                        } -Attributes @{style = 'color: #666; margin-bottom: 20px;'}
                        
                        New-UDButton -Text "Manage Health" -Variant contained -Style @{
                            backgroundColor = '#2e7d32'
                            color = 'white'
                            width = '100%'
                        } -OnClick {
                            Invoke-UDRedirect -Url '/health'
                        }
                    }
                }
            }
        }
        
        # Weight Records
        New-UDGrid -Item -ExtraSmallSize 12 -MediumSize 6 -LargeSize 4 -Content {
            New-UDCard -Style @{
                height = '100%'
                borderRadius = '8px'
                boxShadow = '0 2px 8px rgba(0,0,0,0.1)'
            } -Content {
                New-UDElement -Tag 'div' -Content {
                    New-UDTypography -Text "⚖️ Weight Management" -Variant h5 -Style @{
                        color = '#2e7d32'
                        fontWeight = 'bold'
                        marginBottom = '15px'
                    }
                    New-UDElement -Tag 'br'
                    New-UDElement -Tag 'div' -Content {
                        New-UDTypography -Text "Record and track weight measurements for your cattle over time." -Variant body1 -Style @{
                            marginBottom = '15px'
                            color = '#555'
                        }
                        
                        New-UDElement -Tag 'ul' -Content {
                            New-UDElement -Tag 'li' -Content { "➕ Add weight records" }
                            New-UDElement -Tag 'li' -Content { "📊 View weight history" }
                            New-UDElement -Tag 'li' -Content { "📈 Track weight trends" }
                            New-UDElement -Tag 'li' -Content { "🔍 Search by cattle" }
                        } -Attributes @{style = 'color: #666; margin-bottom: 20px;'}
                        
                        New-UDButton -Text "Manage Weights" -Variant contained -Style @{
                            backgroundColor = '#2e7d32'
                            color = 'white'
                            width = '100%'
                        } -OnClick {
                            Invoke-UDRedirect -Url '/weights'
                        }
                    }
                }
            }
        }
        
        # Feed Management
        New-UDGrid -Item -ExtraSmallSize 12 -MediumSize 6 -LargeSize 4 -Content {
            New-UDCard -Style @{
                height = '100%'
                borderRadius = '8px'
                boxShadow = '0 2px 8px rgba(0,0,0,0.1)'
            } -Content {
                New-UDElement -Tag 'div' -Content {
                    New-UDTypography -Text "🌾 Feed Management" -Variant h5 -Style @{
                        color = '#2e7d32'
                        fontWeight = 'bold'
                        marginBottom = '15px'
                    }
                    New-UDElement -Tag 'br'
                    New-UDElement -Tag 'div' -Content {
                        New-UDTypography -Text "Track daily feed records and monitor haylage, silage, and high moisture corn usage." -Variant body1 -Style @{
                            marginBottom = '15px'
                            color = '#555'
                        }
                        
                        New-UDElement -Tag 'ul' -Content {
                            New-UDElement -Tag 'li' -Content { "� Daily feed recording" }
                            New-UDElement -Tag 'li' -Content { "� Feed history tracking" }
                            New-UDElement -Tag 'li' -Content { "� Usage trends" }
                            New-UDElement -Tag 'li' -Content { "🔍 Search and filter" }
                        } -Attributes @{style = 'color: #666; margin-bottom: 20px;'}
                        
                        New-UDButton -Text "Manage Feed" -Variant contained -Style @{
                            backgroundColor = '#2e7d32'
                            color = 'white'
                            width = '100%'
                        } -OnClick {
                            Invoke-UDRedirect -Url '/feedrecords'
                        }
                    }
                }
            }
        }
        
        # Accounting & Invoices
        New-UDGrid -Item -ExtraSmallSize 12 -MediumSize 6 -LargeSize 4 -Content {
            New-UDCard -Style @{
                height = '100%'
                borderRadius = '8px'
                boxShadow = '0 2px 8px rgba(0,0,0,0.1)'
            } -Content {
                New-UDElement -Tag 'div' -Content {
                    New-UDTypography -Text "💰 Accounting & Invoices" -Variant h5 -Style @{
                        color = '#2e7d32'
                        fontWeight = 'bold'
                        marginBottom = '15px'
                    }
                    New-UDElement -Tag 'br'
                    New-UDElement -Tag 'div' -Content {
                        New-UDTypography -Text "Generate invoices and track costs for cattle including feeding and health expenses." -Variant body1 -Style @{
                            marginBottom = '15px'
                            color = '#555'
                        }
                        
                        New-UDElement -Tag 'ul' -Content {
                            New-UDElement -Tag 'li' -Content { "📄 Generate invoices" }
                            New-UDElement -Tag 'li' -Content { "🔍 Search invoices" }
                            New-UDElement -Tag 'li' -Content { "💵 Cost tracking" }
                            New-UDElement -Tag 'li' -Content { "📊 Billing reports" }
                        } -Attributes @{style = 'color: #666; margin-bottom: 20px;'}
                        
                        New-UDButton -Text "Manage Accounting" -Variant contained -Style @{
                            backgroundColor = '#2e7d32'
                            color = 'white'
                            width = '100%'
                        } -OnClick {
                            Invoke-UDRedirect -Url '/accounting'
                        }
                    }
                }
            }
        }
        
        # Reports & Analytics
        New-UDGrid -Item -ExtraSmallSize 12 -MediumSize 6 -LargeSize 4 -Content {
            New-UDCard -Style @{
                height = '100%'
                borderRadius = '8px'
                boxShadow = '0 2px 8px rgba(0,0,0,0.1)'
            } -Content {
                New-UDElement -Tag 'div' -Content {
                    New-UDTypography -Text "📊 Reports & Analytics" -Variant h5 -Style @{
                        color = '#2e7d32'
                        fontWeight = 'bold'
                        marginBottom = '15px'
                    }
                    New-UDElement -Tag 'br'
                    New-UDElement -Tag 'div' -Content {
                        New-UDTypography -Text "Generate comprehensive reports and gain insights into your herd's performance." -Variant body1 -Style @{
                            marginBottom = '15px'
                            color = '#555'
                        }
                        
                        New-UDElement -Tag 'ul' -Content {
                            New-UDElement -Tag 'li' -Content { "📈 Herd overview & status" }
                            New-UDElement -Tag 'li' -Content { "💰 Cost analysis" }
                            New-UDElement -Tag 'li' -Content { "� Performance metrics" }
                            New-UDElement -Tag 'li' -Content { "🩺 Health summaries" }
                        } -Attributes @{style = 'color: #666; margin-bottom: 20px;'}
                        
                        New-UDButton -Text "View Reports" -Variant contained -Style @{
                            backgroundColor = '#2e7d32'
                            color = 'white'
                            width = '100%'
                        } -OnClick {
                            Invoke-UDRedirect -Url '/reports'
                        }
                    }
                }
            }
        }

        # Farm Management
        New-UDGrid -Item -ExtraSmallSize 12 -MediumSize 6 -LargeSize 4 -Content {
            New-UDCard -Style @{
                height = '100%'
                borderRadius = '8px'
                boxShadow = '0 2px 8px rgba(0,0,0,0.1)'
            } -Content {
                New-UDElement -Tag 'div' -Content {
                    New-UDTypography -Text "🚜 Farm Management" -Variant h5 -Style @{
                        color = '#2e7d32'
                        fontWeight = 'bold'
                        marginBottom = '15px'
                    }
                    New-UDElement -Tag 'br'
                    New-UDElement -Tag 'div' -Content {
                        New-UDTypography -Text "Manage cattle origin and owner farm information" -Variant body1 -Style @{
                            marginBottom = '15px'
                            color = '#555'
                        }
                        
                        New-UDElement -Tag 'ul' -Content {
                            New-UDElement -Tag 'li' -Content { "📈 Herd overview & status" }
                            New-UDElement -Tag 'li' -Content { "💰 Cost analysis" }
                            New-UDElement -Tag 'li' -Content { "� Performance metrics" }
                            New-UDElement -Tag 'li' -Content { "🩺 Health summaries" }
                        } -Attributes @{style = 'color: #666; margin-bottom: 20px;'}
                        
                        New-UDButton -Text "Manage Farms" -Variant contained -Style @{
                            backgroundColor = '#2e7d32'
                            color = 'white'
                            width = '100%'
                        } -OnClick {
                            Invoke-UDRedirect -Url '/farms'
                        }
                    }
                }
            }
        }
    }
    
    New-UDElement -Tag 'br'
}






