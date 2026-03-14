[CmdletBinding()]
Param()

begin {
    # Load centralized styles
    . "$PSScriptRoot/Styles.ps1"
    
    function Invoke-UniversalSQLiteQuery {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory)]
            [string]$Path,

            [Parameter(Mandatory)]
            [string]$Query
        )

        if (-not (Test-Path $Path)) {
            throw "Database file not found: $Path"
        }

        Invoke-SqliteQuery -DataSource $Path -Query $Query
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
        New-UDListItem -Label "ROG Analytics" -Icon (New-UDIcon -Icon ChartArea) -OnClick { Invoke-UDRedirect -Url '/rog-analytics' }
        New-UDListItem -Label "Animal Report" -Icon (New-UDIcon -Icon FileAlt) -OnClick { Invoke-UDRedirect -Url '/animal-report' }
        New-UDListItem -Label "Accounting" -Icon (New-UDIcon -Icon Calculator) -OnClick { Invoke-UDRedirect -Url '/accounting' }
        New-UDListItem -Label "Reports" -Icon (New-UDIcon -Icon ChartBar) -OnClick { Invoke-UDRedirect -Url '/reports' }
        New-UDListItem -Label "Help" -Icon (New-UDIcon -Icon QuestionCircle) -OnClick { Invoke-UDRedirect -Url '/help' }
        New-UDListItem -Label "Setup" -Icon (New-UDIcon -Icon Tools) -OnClick { Invoke-UDRedirect -Url '/settings' }
    }

    $HeaderContent = {
        # Notification bell with badge (only query DB if ready)
        if ($script:DatabaseReady) {
            $dbPath = Get-DatabasePath
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
        }
        else {
            New-UDIconButton -Icon (New-UDIcon -Icon Bell -Size lg) -OnClick { Invoke-UDRedirect -Url '/notifications' }
        }
        # First-run redirect: if SystemInfo is not configured, redirect users to the setup page using server-driven redirect
        try { $sysCheck = if ($script:DatabaseReady) { Get-SystemInfo } else { $null } } catch { $sysCheck = $null }
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
        Pages            = @($homepage, $notifications, $cattleMgmt, $weightMgmt, $healthMgmt, $feedRecords, $farmsPage, $rog, $rogAnalytics, $reports, $animalreport, $accounting, $invoicePage, $systemSettings, $helpPage)
        Navigation       = $Navigation
        NavigationLayout = 'Temporary'
        HeaderContent    = $HeaderContent
    }

    New-UDApp @app

}



