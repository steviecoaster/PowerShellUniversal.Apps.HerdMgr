$homepage = New-UDPage -Name 'Home' -Url '/Home' -Content {
    
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
                New-UDTypography -Text "🐂 Gundy Ridge Herd Manager" -Variant h2 -Style @{
                    fontWeight = 'bold'
                    textAlign = 'center'
                    marginBottom = '15px'
                }
                New-UDTypography -Text "Since 1942" -Variant h5 -Style @{
                    textAlign = 'center'
                    opacity = '0.9'
                    marginBottom = '10px'
                }
                New-UDTypography -Text "Quality over quantity - mostly because we don't have room for more" -Variant body1 -Style @{
                    textAlign = 'center'
                    opacity = '0.85'
                }
            }
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
                            $weightCount = (Invoke-SqliteQuery -DataSource $script:DatabasePath -Query $weightQuery).Count
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
                            $avgADG = (Invoke-SqliteQuery -DataSource $script:DatabasePath -Query $rogQuery).AvgADG
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
                            $healthCount = (Invoke-SqliteQuery -DataSource $script:DatabasePath -Query $healthQuery).Count
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
    }
    
    New-UDElement -Tag 'br'
    New-UDElement -Tag 'br'
    
    # Footer
    New-UDCard -Style @{
        textAlign = 'center'
        padding = '20px'
        marginTop = '30px'
        opacity = 0.6
    } -Content {
        New-UDTypography -Text "🌾 Gundy Ridge Herd Manager 🌾" -Variant body2 -Style @{
            color = '#666'
            marginBottom = '5px'
        }
        New-UDTypography -Text "Empowering farmers with modern herd management tools" -Variant body2 -Style @{
            color = '#999'
            fontSize = '0.875rem'
        }
    }
}
