[CmdletBinding()]
param(
    [ValidateSet('Learning', 'Framework', 'Template')]
    [string[]]$Site = @('Learning', 'Framework', 'Template'),

    [ValidateRange(1, 5)]
    [int]$MaximumAttempts = 3,

    [switch]$SelfTest
)

# Checks the published DocFX documentation sites against the discoverability, homepage-layout, and
# accessibility requirements in LANDING-PAGE-STANDARD.md (AsiBackbone/.github#21). The checks read
# public pages only and assert served markup; they do not replace the human visual review.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$siteDefinitions = [ordered]@{
    Learning = [pscustomobject]@{
        Url = 'https://asibackbone.github.io/Learning/'
        SiteName = 'AsiBackbone Learning'
        Repository = 'AsiBackbone/Learning'
    }
    Framework = [pscustomobject]@{
        Url = 'https://asibackbone.github.io/AsiBackbone/'
        SiteName = 'AsiBackbone'
        Repository = 'AsiBackbone/AsiBackbone'
    }
    Template = [pscustomobject]@{
        Url = 'https://asibackbone.github.io/NetCoreApplicationTemplate/'
        SiteName = '.NET Core Application Template'
        Repository = 'AsiBackbone/NetCoreApplicationTemplate'
    }
}

$legacyBrandSpelling = 'ASI Backbone'
$maximumTitleLength = 80
$regexOptions = [System.Text.RegularExpressions.RegexOptions]::IgnoreCase

function ConvertTo-PlainText {
    param([string]$Value)

    $decoded = [System.Net.WebUtility]::HtmlDecode([regex]::Replace($Value, '<[^>]+>', ' '))
    return [regex]::Replace($decoded, '\s+', ' ').Trim()
}

function Get-TagAttribute {
    param([string]$Html, [string]$TagPattern, [string]$Attribute)

    $tag = [regex]::Match($Html, $TagPattern, $regexOptions)
    if (-not $tag.Success) {
        return $null
    }

    $value = [regex]::Match($tag.Value, "\b$Attribute\s*=\s*`"(?<value>[^`"]*)`"", $regexOptions)
    if (-not $value.Success) {
        return $null
    }

    return [System.Net.WebUtility]::HtmlDecode($value.Groups['value'].Value).Trim()
}

function Get-MetaContent {
    param([string]$Html, [string]$Key, [string]$Value)

    $pattern = '<meta\b(?=[^>]*\b{0}\s*=\s*"{1}")[^>]*>' -f $Key, [regex]::Escape($Value)
    return Get-TagAttribute -Html $Html -TagPattern $pattern -Attribute 'content'
}

function Test-PublishedHomepage {
    param(
        [Parameter(Mandatory = $true)][string]$Html,
        [Parameter(Mandatory = $true)][pscustomobject]$Definition,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][System.Collections.Generic.List[string]]$Errors
    )

    $url = $Definition.Url
    $siteName = $Definition.SiteName

    if ($Html -notmatch '(?i)<html\b[^>]*\blang\s*=\s*"en(?:-[a-z]{2})?"') {
        $Errors.Add('The <html> element does not declare lang="en".')
    }

    $titleMatch = [regex]::Match($Html, '<title\b[^>]*>(?<value>[\s\S]*?)</title>', $regexOptions)
    $title = if ($titleMatch.Success) { ConvertTo-PlainText $titleMatch.Groups['value'].Value } else { '' }
    $suffix = " | $siteName"
    if ([string]::IsNullOrWhiteSpace($title)) {
        $Errors.Add('The homepage has no <title>.')
    }
    elseif (-not $title.EndsWith($suffix, [StringComparison]::Ordinal)) {
        $Errors.Add("The homepage title '$title' must end with '$suffix'.")
    }
    else {
        $pageTitle = $title.Substring(0, $title.Length - $suffix.Length).Trim()
        if ([string]::IsNullOrWhiteSpace($pageTitle) -or
            $pageTitle.Contains(' | ', [StringComparison]::Ordinal) -or
            $pageTitle.StartsWith($siteName, [StringComparison]::OrdinalIgnoreCase)) {
            $Errors.Add("The homepage title '$title' repeats the site name; give the homepage its own concise title.")
        }
    }

    if ($title.Length -gt $maximumTitleLength) {
        $Errors.Add("The homepage title is $($title.Length) characters; keep it to $maximumTitleLength or fewer.")
    }

    $brandText = @(
        $title
        (Get-MetaContent -Html $Html -Key 'property' -Value 'og:site_name')
        (ConvertTo-PlainText ([regex]::Match($Html, '<a\b[^>]*class="navbar-brand"[^>]*>(?<value>[\s\S]*?)</a>', $regexOptions).Groups['value'].Value))
    ) -join "`n"
    if ($brandText.Contains($legacyBrandSpelling, [StringComparison]::Ordinal)) {
        $Errors.Add("The title, site name, or navbar brand uses the legacy '$legacyBrandSpelling' spelling.")
    }

    if ([string]::IsNullOrWhiteSpace((Get-MetaContent -Html $Html -Key 'name' -Value 'description'))) {
        $Errors.Add('The homepage has no meta description.')
    }

    $canonical = Get-TagAttribute -Html $Html -TagPattern '<link\b(?=[^>]*\brel\s*=\s*"canonical")[^>]*>' -Attribute 'href'
    if ($canonical -ne $url) {
        $Errors.Add("The canonical URL is '$canonical'; expected '$url'.")
    }

    $ogUrl = Get-MetaContent -Html $Html -Key 'property' -Value 'og:url'
    if ($ogUrl -ne $url) {
        $Errors.Add("The og:url is '$ogUrl'; expected '$url'.")
    }

    $socialImage = Get-MetaContent -Html $Html -Key 'property' -Value 'og:image'
    if ([string]::IsNullOrWhiteSpace($socialImage) -or -not $socialImage.StartsWith($url, [StringComparison]::Ordinal)) {
        $Errors.Add("The og:image '$socialImage' must be an absolute URL owned by the site ($url).")
    }

    if ([string]::IsNullOrWhiteSpace((Get-MetaContent -Html $Html -Key 'property' -Value 'og:image:alt'))) {
        $Errors.Add('The social image has no og:image:alt text.')
    }

    $structuredData = [regex]::Match($Html, '<script\b[^>]*type\s*=\s*"application/ld\+json"[^>]*>(?<value>[\s\S]*?)</script>', $regexOptions)
    if (-not $structuredData.Success) {
        $Errors.Add('The homepage has no JSON-LD structured data.')
    }
    else {
        $nodes = $null
        try {
            $document = ConvertFrom-Json -InputObject $structuredData.Groups['value'].Value
            if ($document.PSObject.Properties.Name -contains '@graph') {
                $nodes = @($document.'@graph')
            }
        }
        catch {
            $nodes = $null
        }

        if ($null -eq $nodes) {
            $Errors.Add('The JSON-LD structured data is not valid JSON with an @graph.')
        }
        else {
            foreach ($type in @('WebSite', 'WebPage')) {
                $node = $nodes | Where-Object { $_.PSObject.Properties.Name -contains '@type' -and $_.'@type' -eq $type } | Select-Object -First 1
                if ($null -eq $node) {
                    $Errors.Add("The JSON-LD structured data has no $type node.")
                }
                elseif (-not ($node.PSObject.Properties.Name -contains 'url') -or $node.url -ne $url) {
                    $Errors.Add("The JSON-LD $type node must use url '$url'.")
                }
            }
        }
    }

    $skipLink = [regex]::Match($Html, '<a\b(?=[^>]*\bclass\s*=\s*"[^"]*\bskip-link\b)[^>]*\bhref\s*=\s*"#(?<target>[^"]+)"[^>]*>', $regexOptions)
    if (-not $skipLink.Success) {
        $Errors.Add('The served HTML has no skip link; it must be rendered in template markup, not injected by JavaScript.')
    }
    else {
        $target = [regex]::Escape($skipLink.Groups['target'].Value)
        if ($Html -notmatch "(?i)<main\b[^>]*\bid\s*=\s*`"$target`"") {
            $Errors.Add("The skip link target '#$($skipLink.Groups['target'].Value)' is not the <main> element.")
        }

        $header = [regex]::Match($Html, '<header\b', $regexOptions)
        if ($header.Success -and $header.Index -lt $skipLink.Index) {
            $Errors.Add('The skip link must come before the header so it is the first focusable element.')
        }
    }

    if ($Html -match '(?i)<meta\b[^>]*\bname\s*=\s*"docfx:tocrel"' -or $Html -match '(?i)\bid\s*=\s*"tocOffcanvas"') {
        $Errors.Add('The homepage renders the table-of-contents sidebar; set _disableToc: true so the hero uses the full width.')
    }

    return $socialImage
}

function Invoke-PublishedRequest {
    param([string]$Uri, [string]$Method = 'Get')

    for ($attempt = 1; $attempt -le $MaximumAttempts; $attempt++) {
        try {
            $response = Invoke-WebRequest -Uri $Uri -Method $Method -MaximumRedirection 5 -TimeoutSec 30 -SkipHttpErrorCheck -UserAgent 'AsiBackbone-published-site-validation'
            if ([int]$response.StatusCode -lt 500 -or $attempt -eq $MaximumAttempts) {
                return $response
            }
        }
        catch {
            if ($attempt -eq $MaximumAttempts) {
                throw
            }
        }

        Start-Sleep -Seconds (5 * $attempt)
    }
}

function Test-PublishedSite {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][pscustomobject]$Definition,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][System.Collections.Generic.List[string]]$Errors
    )

    try {
        $homepage = Invoke-PublishedRequest -Uri $Definition.Url
    }
    catch {
        $Errors.Add("The homepage could not be fetched: $($_.Exception.Message)")
        return
    }

    if ([int]$homepage.StatusCode -ne 200) {
        $Errors.Add("The homepage returned HTTP $([int]$homepage.StatusCode).")
        return
    }

    $socialImage = Test-PublishedHomepage -Html ([string]$homepage.Content) -Definition $Definition -Errors $Errors

    if (-not [string]::IsNullOrWhiteSpace($socialImage) -and $socialImage.StartsWith($Definition.Url, [StringComparison]::Ordinal)) {
        try {
            $image = Invoke-PublishedRequest -Uri $socialImage -Method 'Head'
            if ([int]$image.StatusCode -ne 200) {
                $Errors.Add("The social image $socialImage returned HTTP $([int]$image.StatusCode).")
            }
        }
        catch {
            $Errors.Add("The social image $socialImage could not be fetched: $($_.Exception.Message)")
        }
    }

    $manifestUrl = "$($Definition.Url)manifest.json"
    try {
        $manifest = Invoke-PublishedRequest -Uri $manifestUrl -Method 'Head'
        if ([int]$manifest.StatusCode -ne 404) {
            $Errors.Add("$manifestUrl returned HTTP $([int]$manifest.StatusCode); the internal DocFX build manifest must not be deployed.")
        }
    }
    catch {
        $Errors.Add("$manifestUrl could not be checked: $($_.Exception.Message)")
    }
}

function New-FixtureHomepage {
    param([pscustomobject]$Definition)

    $url = $Definition.Url
    $graph = '{"@context":"https://schema.org","@graph":[' +
        "{`"@type`":`"WebSite`",`"@id`":`"$($url)#website`",`"url`":`"$url`",`"name`":`"$($Definition.SiteName)`"}," +
        "{`"@type`":`"WebPage`",`"@id`":`"$($url)#webpage`",`"url`":`"$url`",`"name`":`"Practical Architecture &amp; Tutorials`"}]}"

    return @(
        '<!DOCTYPE html>'
        '<html lang="en">'
        '  <head>'
        "    <title>Practical Architecture &amp; Tutorials | $($Definition.SiteName)</title>"
        '    <meta name="description" content="A concise homepage description.">'
        "    <link rel=`"canonical`" href=`"$url`">"
        "    <meta property=`"og:site_name`" content=`"$($Definition.SiteName)`">"
        "    <meta property=`"og:url`" content=`"$url`">"
        "    <meta property=`"og:image`" content=`"$($url)images/social-preview.png`">"
        '    <meta property="og:image:alt" content="Social preview">'
        "    <script type=`"application/ld+json`">$graph</script>"
        '    <meta name="docfx:navrel" content="toc.html">'
        '  </head>'
        '  <body>'
        '    <a class="skip-link" href="#main-content">Skip to content</a>'
        '    <header class="bg-body border-bottom">'
        "      <a class=`"navbar-brand`" href=`"index.html`"><img src=`"logo.png`" alt=`"`"> $($Definition.SiteName)</a>"
        '    </header>'
        '    <main class="container-xxl" id="main-content" tabindex="-1"><div class="content"></div></main>'
        '  </body>'
        '</html>'
    ) -join "`n"
}

function Invoke-SelfTest {
    $definition = $siteDefinitions['Template']
    $valid = New-FixtureHomepage $definition
    $title = "Practical Architecture &amp; Tutorials | $($definition.SiteName)"

    $cases = @(
        @{ Name = 'valid homepage'; Html = $valid; Pass = $true }
        @{ Name = 'valid homepage for every site'; Html = $null; Pass = $true }
        @{ Name = 'missing lang'; Html = $valid.Replace('<html lang="en">', '<html>'); Pass = $false }
        @{ Name = 'site name repeated in title'; Html = $valid.Replace($title, "$($definition.SiteName) Documentation | $($definition.SiteName)"); Pass = $false }
        @{ Name = 'title without site name'; Html = $valid.Replace($title, 'Practical Architecture'); Pass = $false }
        @{ Name = 'overlong title'; Html = $valid.Replace($title, "$('x' * $maximumTitleLength) | $($definition.SiteName)"); Pass = $false }
        @{ Name = 'legacy brand in navbar'; Html = $valid.Replace("`"> $($definition.SiteName)</a>", "`"> $legacyBrandSpelling</a>"); Pass = $false }
        @{ Name = 'missing description'; Html = $valid.Replace('<meta name="description" content="A concise homepage description.">', ''); Pass = $false }
        @{ Name = 'missing canonical'; Html = $valid.Replace("<link rel=`"canonical`" href=`"$($definition.Url)`">", ''); Pass = $false }
        @{ Name = 'foreign social image'; Html = $valid.Replace("content=`"$($definition.Url)images/social-preview.png`"", 'content="https://example.com/social.png"'); Pass = $false }
        @{ Name = 'missing structured data'; Html = [regex]::Replace($valid, '<script type="application/ld\+json">.*</script>', ''); Pass = $false }
        @{ Name = 'invalid structured data'; Html = $valid.Replace('{"@context"', '{"@context":'); Pass = $false }
        @{ Name = 'structured data for another page'; Html = $valid.Replace("`"url`":`"$($definition.Url)`",`"name`":`"Practical", '"url":"https://example.com/","name":"Practical'); Pass = $false }
        @{ Name = 'script-only skip link'; Html = $valid.Replace('<a class="skip-link" href="#main-content">Skip to content</a>', ''); Pass = $false }
        @{ Name = 'skip link after header'; Html = $valid.Replace("    <a class=`"skip-link`" href=`"#main-content`">Skip to content</a>`n    <header class=`"bg-body border-bottom`">", "    <header class=`"bg-body border-bottom`">`n    <a class=`"skip-link`" href=`"#main-content`">Skip to content</a>"); Pass = $false }
        @{ Name = 'skip link without main target'; Html = $valid.Replace('id="main-content"', 'id="content"'); Pass = $false }
        @{ Name = 'homepage with sidebar'; Html = $valid.Replace('<meta name="docfx:navrel" content="toc.html">', '<meta name="docfx:tocrel" content="toc.html">'); Pass = $false }
    )

    $failures = [System.Collections.Generic.List[string]]::new()
    foreach ($case in $cases) {
        $caseErrors = [System.Collections.Generic.List[string]]::new()
        if ($null -eq $case.Html) {
            foreach ($entry in $siteDefinitions.GetEnumerator()) {
                $null = Test-PublishedHomepage -Html (New-FixtureHomepage $entry.Value) -Definition $entry.Value -Errors $caseErrors
            }
        }
        else {
            $null = Test-PublishedHomepage -Html $case.Html -Definition $definition -Errors $caseErrors
        }

        if (($caseErrors.Count -eq 0) -ne $case.Pass) {
            $expected = if ($case.Pass) { 'success' } else { 'failure' }
            $failures.Add("Self-test '$($case.Name)' expected $expected but got $($caseErrors.Count) error(s): $($caseErrors -join ' ')")
        }
    }

    if ($failures.Count -gt 0) {
        $failures | ForEach-Object { Write-Error $_ -ErrorAction Continue }
        exit 1
    }

    Write-Host 'Published-site validator self-test passed.'
}

if ($MyInvocation.InvocationName -eq '.') {
    return
}

if ($SelfTest) {
    Invoke-SelfTest
    exit 0
}

$failedSites = 0
$summary = [System.Collections.Generic.List[string]]::new()
$summary.Add('| Site | URL | Result |')
$summary.Add('| --- | --- | --- |')

foreach ($name in $Site) {
    $definition = $siteDefinitions[$name]
    $siteErrors = [System.Collections.Generic.List[string]]::new()
    Test-PublishedSite -Name $name -Definition $definition -Errors $siteErrors

    if ($siteErrors.Count -eq 0) {
        Write-Host "$name ($($definition.Url)) satisfies the published-site checks."
        $summary.Add("| $name | $($definition.Url) | Passed |")
        continue
    }

    $failedSites++
    $summary.Add("| $name | $($definition.Url) | $($siteErrors.Count) finding(s); fix in [$($definition.Repository)](https://github.com/$($definition.Repository)) |")
    foreach ($siteError in $siteErrors) {
        Write-Error "${name}: $siteError" -ErrorAction Continue
        $summary.Add("|  |  | $($siteError.Replace('|', '\|')) |")
    }
}

if ($env:GITHUB_STEP_SUMMARY) {
    @('## Published documentation sites', '') + $summary | Add-Content -LiteralPath $env:GITHUB_STEP_SUMMARY -Encoding utf8
}

if ($failedSites -gt 0) {
    exit 1
}

Write-Host 'All published documentation sites satisfy the published-site checks.'
