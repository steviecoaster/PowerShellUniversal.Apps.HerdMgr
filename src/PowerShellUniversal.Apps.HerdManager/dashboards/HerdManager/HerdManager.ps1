[CmdletBinding()]
Param()

begin {
    # Load centralized styles
    . "$PSScriptRoot/Styles.ps1"
    
    function Invoke-UniversalSQLiteQuery {
        <#
    .SYNOPSIS
    Execute SQLite queries using the sqlite3 command-line tool
    
    .DESCRIPTION
    A wrapper function that executes SQLite queries using the native sqlite3 CLI.
    This provides cross-platform compatibility without requiring PowerShell modules.
    
    .PARAMETER Path
    Path to the SQLite database file
    
    .PARAMETER Query
    SQL query to execute
    
    .EXAMPLE
    Invoke-UniversalSQLiteQuery -Path "./data/HerdManager.db" -Query "SELECT * FROM Cattle"
    
    .NOTES
    Requires sqlite3 to be installed and available in PATH
    #>
        [CmdletBinding()]
        param(
            [Parameter(Mandatory)]
            [string]$Path,
        
            [Parameter(Mandatory)]
            [string]$Query
        )
    
        # Verify sqlite3 is available
        if (-not (Get-Command sqlite3 -ErrorAction SilentlyContinue)) {
            throw "sqlite3 command not found. Please install SQLite."
        }
    
        # Verify database exists
        if (-not (Test-Path $Path)) {
            throw "Database file not found: $Path"
        }
    
        # Resolve full path
        $dbPath = Resolve-Path $Path | Select-Object -ExpandProperty Path
    
        # Try JSON output first (best for structured data)
        $output = sqlite3 $dbPath -json $Query 2>&1
    
        # Check for errors
        if ($LASTEXITCODE -ne 0) {
            throw "SQLite query failed: $output"
        }
    
        # Parse output
        if ($output) {
            try {
                # Try to parse as JSON
                $result = $output | ConvertFrom-Json
                return $result
            }
            catch {
                # JSON parsing failed, try CSV mode for better compatibility
                $csvOutput = sqlite3 $dbPath -csv -header $Query 2>&1
            
                if ($LASTEXITCODE -eq 0 -and $csvOutput) {
                    try {
                        # Convert CSV to objects
                        $result = $csvOutput | ConvertFrom-Csv
                        return $result
                    }
                    catch {
                        # If CSV also fails, return raw output
                        return $csvOutput
                    }
                }
            
                # Fallback to raw output
                return $output
            }
        }
    
        return $null
    }

}

end {
    $Navigation = New-UDList -Content {
        New-UDListItem -Label "Home" -Icon (New-UDIcon -Icon Home) -OnClick { Invoke-UDRedirect -Url '/Home' }
        New-UDListItem -Label "Notifications" -Icon (New-UDIcon -Icon Bell) -OnClick { Invoke-UDRedirect -Url '/notifications' }
        New-UDListItem -Label "Cattle Management" -Icon (New-UDIcon -Icon Cow) -OnClick { Invoke-UDRedirect -Url '/cattle' }
        New-UDListItem -Label "Weight Management" -Icon (New-UDIcon -Icon Weight) -OnClick { Invoke-UDRedirect -Url '/weights' }
        New-UDListItem -Label "Health Records" -Icon (New-UDIcon -Icon Heartbeat) -OnClick { Invoke-UDRedirect -Url '/health' }
        New-UDListItem -Label "Feed Records" -Icon (New-UDIcon -Icon Seedling) -OnClick { Invoke-UDRedirect -Url '/feedrecords' }
        New-UDListItem -Label "Farms" -Icon (New-UDIcon -Icon Tractor) -OnClick { Invoke-UDRedirect -Url '/farms' }
        New-UDListItem -Label "Rate of Gain" -Icon (New-UDIcon -Icon ChartLine) -OnClick { Invoke-UDRedirect -Url '/rog' }
        New-UDListItem -Label "Animal Report" -Icon (New-UDIcon -Icon FileAlt) -OnClick { Invoke-UDRedirect -Url '/animal-report' }
        New-UDListItem -Label "Accounting" -Icon (New-UDIcon -Icon Calculator) -OnClick { Invoke-UDRedirect -Url '/accounting' }
        New-UDListItem -Label "Reports" -Icon (New-UDIcon -Icon ChartBar) -OnClick { Invoke-UDRedirect -Url '/reports' }
        New-UDListItem -Label "Help" -Icon (New-UDIcon -Icon QuestionCircle) -OnClick { Invoke-UDRedirect -Url '/help' }
        New-UDListItem -Label "Setup" -Icon (New-UDIcon -Icon Tools) -OnClick { Invoke-UDRedirect -Url '/settings' }
    }

    $HeaderContent = {
        # Cross-platform path to database
        $moduleBase = (Get-Module PowerShellUniversal.Apps.HerdManager).ModuleBase
        $dbPath = Join-Path $moduleBase 'data' 'HerdManager.db'
    
        # Notification bell with badge
        New-UDDynamic -Content {
            $overdueQuery = "SELECT COUNT(*) as Count FROM HealthRecords hr INNER JOIN Cattle c ON hr.CattleID = c.CattleID WHERE hr.NextDueDate IS NOT NULL AND hr.NextDueDate < DATE('now') AND c.Status = 'Active'"
            $overdueCount = (Invoke-UniversalSQLiteQuery -Path $dbPath -Query $overdueQuery).Count
        
            if ($overdueCount -gt 0) {
                New-UDBadge -BadgeContent { $overdueCount } -Color error -Content {
                    New-UDIconButton -Icon (New-UDIcon -Icon Bell -Size lg) -OnClick { Invoke-UDRedirect -Url '/notifications' }
                }
            }
            else {
                New-UDIconButton -Icon (New-UDIcon -Icon Bell -Size lg) -OnClick { Invoke-UDRedirect -Url '/notifications' }
            }
        } -AutoRefresh -AutoRefreshInterval 300
        # First-run redirect: if SystemInfo is not configured, redirect users to the setup page using server-driven redirect
        try { $sysCheck = Get-SystemInfo } catch { $sysCheck = $null }
        # No forced redirect here — first-run banner is shown on the Home page instead
        # Delegated click handler for in-page help TOC links (data-toc-target)
        New-UDHtml -Markup "<script>(function(){function __herd_toc_handler(e){var el=e.target; while(el && el!==document){ try{ if(el.matches && el.matches('[data-toc-target]')){ e.preventDefault(); e.stopPropagation(); if (e.stopImmediatePropagation) { e.stopImmediatePropagation(); } var id=el.getAttribute('data-toc-target') || (el.dataset && el.dataset.tocTarget); if(!id && el.hasAttribute('href')){ var href=el.getAttribute('href'); if(href && href.indexOf('#')===0){ id=href.substring(1); } } if(id){ var t=document.getElementById(id); if(t){ t.scrollIntoView({behavior:'smooth', block:'start'}); try{ history.pushState(null, '', window.location.pathname + '#' + id); }catch(e){} } } break; } } catch(err){ console && console.debug && console.debug('TOC handler error', err); } el=el.parentNode;} }
    try{ document.addEventListener('pointerdown', __herd_toc_handler, true); document.addEventListener('click', __herd_toc_handler, true); window.__herd_toc_handler_attached = true; console && console.debug && console.debug('HerdManager TOC handler attached'); }catch(err){ console && console.debug && console.debug('Failed to attach TOC handler', err); }
    try{ window.addEventListener('hashchange', function(){ try{ var id = (window.location.hash && window.location.hash.length>1) ? window.location.hash.substring(1) : null; if(id){ var t = document.getElementById(id); if(t){ t.scrollIntoView({behavior:'smooth', block:'start'}); } } }catch(e){ console && console.debug && console.debug('hashchange handler error', e); } }, false); }catch(err){ console && console.debug && console.debug('Failed to attach hashchange handler', err); }
    try{ setTimeout(function(){ try{ var id = (window.location.hash && window.location.hash.length>1) ? window.location.hash.substring(1) : null; if(id){ var t = document.getElementById(id); if(t){ t.scrollIntoView({behavior:'smooth', block:'start'}); } } }catch(e){ console && console.debug && console.debug('initial hash scroll error', e); } }, 250); }catch(e){ console && console.debug && console.debug('Failed to schedule initial hash check', e); }
    })();</script>"
    }.GetNewClosure()

    $app = @{
        Title            = '🐄 Herd Manager'
        Pages            = @($homepage, $notifications, $cattleMgmt, $weightMgmt, $healthMgmt, $feedRecords, $farmsPage, $rog, $reports, $animalreport, $accounting, $invoicePage, $systemSettings, $helpPage)
        Navigation       = $Navigation
        NavigationLayout = 'Temporary'
        HeaderContent    = $HeaderContent
    }

    New-UDApp @app

}



