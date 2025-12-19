$helpPage = New-UDPage -Name 'Help' -Url '/help' -Content {
    New-UDCard -Title 'Usage Guide' -Content {
        $moduleBase = (Get-Module PowerShellUniversal.Apps.HerdManager).ModuleBase
        $mdPath = Join-Path $moduleBase 'docs' 'UsageGuide.md'

        if (Test-Path $mdPath) {
            try {
                $md = Get-Content -Path $mdPath -Raw
                # Convert markdown to HTML for in-app rendering (some PS versions return an object with .Html)
                $mdInfo = ConvertFrom-Markdown -InputObject $md
                $html = if ($mdInfo.Html) { $mdInfo.Html } else { [string]$mdInfo }

                # Ensure heading elements have id attributes so fragment links can target them.
                # We slugify the heading text to produce stable ids (lowercase, hyphens, alphanumerics) and avoid duplicates.
                $ids = @{}
                $sb = New-Object System.Text.StringBuilder
                $pos = 0
                $hRegex = [regex]::new('<h([1-6])([^>]*)>(.*?)</h\1>', [System.Text.RegularExpressions.RegexOptions]::Singleline -bor [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
                $hMatches = $hRegex.Matches($html)
                foreach ($m in $hMatches) {
                    $start = $m.Index
                    $len = $m.Length
                    $level = $m.Groups[1].Value
                    $attrs = $m.Groups[2].Value
                    $inner = $m.Groups[3].Value

                    # Append HTML before this heading
                    $sb.Append($html.Substring($pos, $start - $pos)) | Out-Null
                    $pos = $start + $len

                    if ($attrs -match '\bid\s*=') {
                        # Heading already has an id; leave it as-is
                        $sb.Append($m.Value) | Out-Null
                    }
                    else {
                        # Get plain text from inner HTML
                        $text = [regex]::Replace($inner, '<[^>]+>', '') -replace '^[\s\r\n]+|[\s\r\n]+$',''
                        $slug = $text.ToLowerInvariant()
                        # Remove characters we don't want, keep letters, numbers, spaces, and hyphens
                        $slug = [regex]::Replace($slug, '[^\p{L}\p{Nd}\s-]', '')
                        $slug = [regex]::Replace($slug, '\s+', '-')
                        $slug = [regex]::Replace($slug, '-+', '-')
                        $slug = $slug.Trim('-')
                        if ([string]::IsNullOrEmpty($slug)) { $slug = 'section' }
                        $base = $slug
                        $i = 1
                        while ($ids.ContainsKey($slug)) { $slug = "$base-$i"; $i++ }
                        $ids[$slug] = $true

                        $newTag = "<h$level id=`"$slug`"$attrs>$inner</h$level>"
                        $sb.Append($newTag) | Out-Null
                    }
                }
                $sb.Append($html.Substring($pos)) | Out-Null
                $html = $sb.ToString()

                                # Replace fragment links (href="#..." or href="/help#...") with button elements that use data-toc-target
                                # Buttons avoid triggering route navigation and let us handle scrolling in-page via a small script
                                $pattern = @'
<a\b[^>]*\bhref\s*=\s*["'][^"']*#([^"']+)["'][^>]*>(.*?)</a>
'@
                                $replacement = @'
<button class="toc-link" data-toc-target="$1" type="button" role="link" tabindex="0" style="background:none;border:none;color:#1a73e8;text-decoration:underline;cursor:pointer;padding:0;margin:0">$2</button>
'@
                                $html = [regex]::Replace($html, $pattern, $replacement, [System.Text.RegularExpressions.RegexOptions]::Singleline -bor [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

                                New-UDHtml -Markup $html

                                # In-page delegated handler: listen for clicks on .toc-link and scroll to the matching heading id.
                                # Also handle direct navigation via hashchange or initial page load hash.
                                $script = @'
<script>
(function(){
    function scrollHash(){
        try{
            var id = window.location.hash && window.location.hash.length>1 ? window.location.hash.substring(1) : null;
            if(!id) return;
            var t = document.getElementById(id);
            if(t){ t.scrollIntoView({behavior:'smooth', block:'start'}); }
        }catch(e){}
    }

    document.addEventListener('click', function(e){
        var el = e.target;
        while(el && el !== document){
            try{
                if(el.matches && el.matches('.toc-link')){
                    e.preventDefault();
                    var id = el.getAttribute('data-toc-target');
                    if(id){ var t = document.getElementById(id); if(t){ t.scrollIntoView({behavior:'smooth', block:'start'}); try{ history.replaceState(null,'','#'+id); }catch(e){} } }
                    return;
                }
            }catch(err){}
            el = el.parentNode;
        }
    }, true);

    window.addEventListener('hashchange', scrollHash, false);
    setTimeout(scrollHash, 250);
})();
</script>
'@

                                New-UDHtml -Markup $script
            }
            catch {
                New-UDTypography -Text "Unable to render Usage Guide: $($_.Exception.Message)" -Variant body1
                New-UDLink -Text 'Open raw Usage Guide on GitHub' -Url 'https://github.com/steviecoaster/HerdManager/blob/main/Usage%20Guide.md'
            }
        }
        else {
            New-UDTypography -Text 'Usage Guide not found in module.' -Variant body1
            New-UDLink -Text 'Open the Usage Guide on GitHub' -Url 'https://github.com/steviecoaster/HerdManager/blob/main/Usage%20Guide.md'
        }
    }
}
