[CmdletBinding()]
param(
    [string]$RepositoryRoot = (Split-Path -Parent $PSScriptRoot),

    # Regenerates documentation/README.md from the manifest instead of checking it.
    [switch]$Update,

    # Also checks that every linked guide and canonical document exists on its repository's main branch.
    [switch]$VerifyReferences,

    # Also scans each surface's first-contact pages for current-version claims about other projects that disagree with
    # the compatibility matrix. Requires network access for the other repositories; set GITHUB_TOKEN to raise the API
    # rate limit.
    [switch]$ScanVersionClaims,

    [ValidateRange(1, 5)]
    [int]$MaximumAttempts = 3,

    [switch]$SelfTest
)

# Validates the canonical documentation-ownership map (documentation/ownership.json), renders the human-readable map
# (documentation/README.md) from it, and fails when the committed map differs from the rendering (AsiBackbone/.github#27).
# The default mode is offline and deterministic. -VerifyReferences and -ScanVersionClaims read public GitHub files only
# and never write to any repository.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$manifestRelativePath = 'documentation/ownership.json'
$mapRelativePath = 'documentation/README.md'
$compatibilityRelativePath = 'compatibility/ecosystem-compatibility.json'
$organizationRepository = 'AsiBackbone/.github'

# Canonical surface order (LANDING-PAGE-STANDARD.md): Learn → Framework → Template → Reference, then the organization.
# Product is the compatibility-matrix component whose current version the surface owns.
$surfaceDefinitions = [ordered]@{
    learning = [pscustomobject]@{ Repository = 'AsiBackbone/Learning'; Column = 'Learning'; Product = 'learning' }
    asibackbone = [pscustomobject]@{ Repository = 'AsiBackbone/AsiBackbone'; Column = 'AsiBackbone'; Product = 'asiBackbone' }
    ncat = [pscustomobject]@{ Repository = 'AsiBackbone/NetCoreApplicationTemplate'; Column = 'NCAT'; Product = 'netCoreApplicationTemplate' }
    'reference-application' = [pscustomobject]@{ Repository = 'AsiBackbone/ReferenceApplication'; Column = 'Reference Application'; Product = 'referenceApplication' }
    organization = [pscustomobject]@{ Repository = $organizationRepository; Column = 'Organization'; Product = $null }
}
$knownRepositories = @($surfaceDefinitions.Values | ForEach-Object Repository)

$kinds = [ordered]@{
    'education' = 'Reusable education'
    'implementation-contract' = 'Implementation and runtime contract'
    'integration-evidence' = 'Integration evidence'
    'routing' = 'Routing and positioning'
}

$patterns = [ordered]@{
    'link-only' = [pscustomobject]@{ Label = 'Link only'; Rule = 'Do not restate the contract. Link to the canonical source.' }
    'summary-link' = [pscustomobject]@{ Label = 'Summary + link'; Rule = 'A short orientation summary for first-contact context, with a link to the canonical detail. Keep it short enough that it cannot become a second contract.' }
    'pinned-snapshot' = [pscustomobject]@{ Label = 'Pinned snapshot'; Rule = 'A statement tied to a named release or tag, for historical or reproducible evidence. Say which release it describes, and do not update it as current guidance when the owner moves on.' }
}

$currencies = [ordered]@{
    'current' = [pscustomobject]@{ Label = 'Current'; Meaning = 'Mutable current guidance. The owner keeps it up to date; other repositories link to it rather than copying it.' }
    'pinned' = [pscustomobject]@{ Label = 'Pinned'; Meaning = 'Version-pinned historical evidence. Each entry describes a released state and does not change afterwards.' }
}

# Topics required by AsiBackbone/.github#27. Further topics may be added.
$requiredTopics = @(
    'product-fit', 'asibackbone-api-runtime', 'ncat-template-contracts', 'reference-integration', 'architecture-education',
    'compatibility-matrix', 'security-control-ownership', 'asibackbone-releases', 'ncat-releases', 'reference-releases',
    'learning-releases', 'organization-navigation'
)

# Current-version claim review. A claim names a project with a version in a clause that asserts currency and does not
# mark itself as a pinned snapshot.
$claimPatterns = [ordered]@{
    learning = '\b(?:AsiBackbone )?Learning v?(?<version>\d+\.\d+(?:\.\d+)?)\b'
    asiBackbone = '\bAsiBackbone v?(?<version>\d+\.\d+(?:\.\d+)?)\b'
    netCoreApplicationTemplate = '(?<![\w.])(?:NCAT|NetCoreApplicationTemplate|\.NET Core Application Template) v?(?<version>\d+\.\d+(?:\.\d+)?)\b'
    referenceApplication = '\b(?:AsiBackbone )?Reference ?Application v?(?<version>\d+\.\d+\.\d+(?:-[0-9A-Za-z]+(?:\.[0-9A-Za-z]+)*)?)'
}
$productNames = @{
    learning = 'AsiBackbone Learning'
    asiBackbone = 'AsiBackbone'
    netCoreApplicationTemplate = '.NET Core Application Template'
    referenceApplication = 'AsiBackbone Reference Application'
}
$currencyWords = '(?i)\b(current|currently|latest|newest|newer|now)\b'
$snapshotWords = '(?i)\b(reviewed|pinned|baseline|snapshot|historical|history|archival|archived|immutable|originally|earlier|previous|was|were)\b'

$idPattern = '^[a-z0-9][a-z0-9-]*$'

function Get-Value {
    param($Object, [string]$Name)

    if ($null -eq $Object -or $Object -isnot [System.Collections.IDictionary] -or -not $Object.Contains($Name)) {
        return $null
    }

    # The comma keeps arrays, including single-element and empty arrays, from being unrolled.
    return , $Object[$Name]
}

function Get-Items {
    param($Value)

    # Emits each element so callers can collect with @(); a single object, including a dictionary, is emitted once.
    if ($null -eq $Value) {
        return
    }

    foreach ($item in $Value) {
        $item
    }
}

function Test-NonEmptyString {
    param($Value)

    return $Value -is [string] -and -not [string]::IsNullOrWhiteSpace($Value)
}

function Test-RelativePath {
    param($Path)

    return (Test-NonEmptyString $Path) -and -not $Path.StartsWith('/') -and $Path -notmatch '(^|/)\.\.(/|$)' -and $Path -notmatch '[\s?#]'
}

function Test-Link {
    param($Link, [string]$Source, [System.Collections.Generic.List[string]]$Errors)

    $repository = Get-Value $Link 'repository'
    if ($knownRepositories -notcontains $repository) {
        $Errors.Add("$Source links to an unknown repository: '$repository'.")
    }
    if (-not (Test-RelativePath (Get-Value $Link 'path'))) {
        $Errors.Add("$Source must link to a repository-relative file path: '$(Get-Value $Link 'path')'.")
    }
}

function Test-Manifest {
    param($Manifest, [System.Collections.Generic.List[string]]$Errors)

    if ($Manifest -isnot [System.Collections.IDictionary]) {
        $Errors.Add('The manifest must be a JSON object.')
        return
    }

    if ((Get-Value $Manifest 'schemaVersion') -ne 1) {
        $Errors.Add('schemaVersion must be 1.')
    }
    $reviewed = Get-Value $Manifest 'reviewed'
    $parsed = [datetime]::MinValue
    if ($reviewed -isnot [string] -or $reviewed -notmatch '^\d{4}-\d{2}-\d{2}$' -or
        -not [datetime]::TryParseExact($reviewed, 'yyyy-MM-dd', [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::None, [ref]$parsed)) {
        $Errors.Add("reviewed must be a yyyy-MM-dd date: '$reviewed'.")
    }

    $surfaceIds = [System.Collections.Generic.HashSet[string]]::new()
    foreach ($surface in @(Get-Items (Get-Value $Manifest 'surfaces'))) {
        $id = Get-Value $surface 'id'
        $source = "surfaces[$id]"
        if (-not $surfaceDefinitions.Contains([string]$id)) {
            $Errors.Add("surfaces names an unknown surface: '$id'.")
            continue
        }
        if (-not $surfaceIds.Add($id)) {
            $Errors.Add("$source is listed more than once.")
        }
        if ((Get-Value $surface 'repository') -ne $surfaceDefinitions[$id].Repository) {
            $Errors.Add("$source.repository must be $($surfaceDefinitions[$id].Repository).")
        }
        if (-not $kinds.Contains([string](Get-Value $surface 'kind'))) {
            $Errors.Add("$source.kind must be one of $($kinds.Keys -join ', ').")
        }
        foreach ($field in @('name', 'owns')) {
            if (-not (Test-NonEmptyString (Get-Value $surface $field))) {
                $Errors.Add("$source.$field is required.")
            }
        }
        if ((Get-Value $surface 'site') -notmatch '^https://') {
            $Errors.Add("$source.site must be an https URL.")
        }
        $guide = Get-Value $surface 'guide'
        if ($null -eq $guide) {
            $Errors.Add("$source.guide must link to the surface's own contribution or ownership guidance.")
        }
        else {
            Test-Link -Link $guide -Source "$source.guide" -Errors $Errors
        }
        $firstContact = @(Get-Items (Get-Value $surface 'firstContact'))
        if ($firstContact.Count -eq 0) {
            $Errors.Add("$source.firstContact must list the pages the current-version claim review scans.")
        }
        foreach ($path in $firstContact) {
            if (-not (Test-RelativePath $path)) {
                $Errors.Add("$source.firstContact contains an invalid path: '$path'.")
            }
        }
    }
    foreach ($id in $surfaceDefinitions.Keys) {
        if (-not $surfaceIds.Contains($id)) {
            $Errors.Add("surfaces must describe '$id'.")
        }
    }

    $topicIds = [System.Collections.Generic.HashSet[string]]::new()
    $owned = [System.Collections.Generic.HashSet[string]]::new()
    $usedCurrencies = [System.Collections.Generic.HashSet[string]]::new()
    foreach ($topic in @(Get-Items (Get-Value $Manifest 'topics'))) {
        $id = Get-Value $topic 'id'
        $source = "topics[$id]"
        if (-not (Test-NonEmptyString $id) -or $id -notmatch $idPattern) {
            $Errors.Add("Topic id must be lowercase letters, digits, and hyphens: '$id'.")
        }
        elseif (-not $topicIds.Add($id)) {
            $Errors.Add("Topic id '$id' is used more than once.")
        }
        foreach ($field in @('title', 'note')) {
            if (-not (Test-NonEmptyString (Get-Value $topic $field))) {
                $Errors.Add("$source.$field is required.")
            }
        }

        $owner = Get-Value $topic 'owner'
        if (-not $surfaceDefinitions.Contains([string]$owner)) {
            $Errors.Add("$source.owner must name exactly one surface: '$owner'.")
        }
        else {
            $null = $owned.Add($owner)
        }

        $currency = Get-Value $topic 'currency'
        if (-not $currencies.Contains([string]$currency)) {
            $Errors.Add("$source.currency must be one of $($currencies.Keys -join ', '): '$currency'.")
        }
        else {
            $null = $usedCurrencies.Add($currency)
        }

        $canonical = @(Get-Items (Get-Value $topic 'canonical'))
        if ($canonical.Count -eq 0) {
            $Errors.Add("$source must link to at least one canonical source.")
        }
        foreach ($link in $canonical) {
            Test-Link -Link $link -Source "$source.canonical" -Errors $Errors
            if ($surfaceDefinitions.Contains([string]$owner) -and (Get-Value $link 'repository') -ne $surfaceDefinitions[$owner].Repository) {
                $Errors.Add("$source.canonical must link to the owner's repository, $($surfaceDefinitions[$owner].Repository).")
            }
        }

        $reuse = Get-Value $topic 'reuse'
        if ($reuse -isnot [System.Collections.IDictionary]) {
            $Errors.Add("$source.reuse must say how each other surface references the topic.")
            continue
        }
        foreach ($surfaceId in $reuse.Keys) {
            if (-not $surfaceDefinitions.Contains($surfaceId)) {
                $Errors.Add("$source.reuse names an unknown surface: '$surfaceId'.")
            }
            elseif ($surfaceId -eq $owner) {
                $Errors.Add("$source.reuse must not include the owner, $owner.")
            }
            $entry = $reuse[$surfaceId]
            if (-not $patterns.Contains([string](Get-Value $entry 'pattern'))) {
                $Errors.Add("$source.reuse.$surfaceId.pattern must be one of $($patterns.Keys -join ', ').")
            }
            if (-not (Test-NonEmptyString (Get-Value $entry 'note'))) {
                $Errors.Add("$source.reuse.$surfaceId.note is required.")
            }
        }
        foreach ($surfaceId in $surfaceDefinitions.Keys) {
            if ($surfaceId -ne $owner -and -not $reuse.Contains($surfaceId)) {
                $Errors.Add("$source.reuse must say how '$surfaceId' references the topic.")
            }
        }
    }

    foreach ($required in $requiredTopics) {
        if (-not $topicIds.Contains($required)) {
            $Errors.Add("The required topic '$required' is missing.")
        }
    }
    foreach ($surfaceId in $surfaceDefinitions.Keys) {
        if (-not $owned.Contains($surfaceId)) {
            $Errors.Add("Surface '$surfaceId' owns no topic; give it an explicit content responsibility.")
        }
    }
    foreach ($currency in $currencies.Keys) {
        if (-not $usedCurrencies.Contains($currency)) {
            $Errors.Add("No topic is marked '$currency'; the map must distinguish current guidance from pinned evidence.")
        }
    }
}

function Get-LinkUrl {
    param($Link)

    return "https://github.com/$($Link['repository'])/blob/main/$($Link['path'])"
}

function Format-Link {
    param($Link)

    $repository = $Link['repository'] -replace '^AsiBackbone/', ''
    return "[$repository ``$($Link['path'])``]($(Get-LinkUrl $Link))"
}

function Format-Text {
    param([string]$Value)

    return $Value.Replace('|', '\|').Replace("`r", '').Replace("`n", ' ')
}

function ConvertTo-OwnershipMarkdown {
    param($Manifest)

    $surfaces = @($Manifest['surfaces'] | Sort-Object -Stable { @($surfaceDefinitions.Keys).IndexOf($_['id']) })
    $surfaceById = @{}
    foreach ($surface in $surfaces) {
        $surfaceById[$surface['id']] = $surface
    }
    $topics = @($Manifest['topics'])
    $lines = [System.Collections.Generic.List[string]]::new()

    $lines.Add('# AsiBackbone Documentation Ownership Map')
    $lines.Add('')
    $lines.Add('<!-- Generated from ownership.json by scripts/Test-DocumentationOwnership.ps1 -Update. Do not edit by hand. -->')
    $lines.Add('')
    $lines.Add('The ecosystem has several legitimate documentation surfaces, and the same concepts appear on more than one of them. Repetition helps people find things; duplicated technical truth drifts when versions, APIs, support boundaries, or terminology change. This map names one canonical owner for each recurring cross-repository topic and says how every other surface should reference it.')
    $lines.Add('')
    $lines.Add('> **Boundary:** This map routes ownership; it does not move or delete content. Existing useful summaries stay, linked to their canonical detail. Each repository''s own documentation-ownership or contribution guide stays authoritative for how that repository classifies its own pages. The machine-readable source is [`ownership.json`](ownership.json).')
    $lines.Add('')

    $lines.Add('## Surfaces')
    $lines.Add('')
    $lines.Add('| Surface | Content kind | Owns | Repository guide |')
    $lines.Add('| --- | --- | --- | --- |')
    foreach ($surface in $surfaces) {
        $lines.Add("| [$(Format-Text $surface['name'])]($($surface['site'])) | $($kinds[$surface['kind']]) | $(Format-Text $surface['owns']) | $(Format-Link $surface['guide']) |")
    }
    $lines.Add('')
    $lines.Add('Reusable education explains ideas that stay useful without any one package. Implementation and runtime contracts state what a released package or template actually does. Integration evidence records what one host did with specific versions. Routing surfaces position the projects and send readers to the owner.')
    $lines.Add('')

    $lines.Add('## Reuse patterns')
    $lines.Add('')
    $lines.Add('| Pattern | Rule |')
    $lines.Add('| --- | --- |')
    foreach ($pattern in $patterns.GetEnumerator()) {
        $lines.Add("| $($pattern.Value.Label) | $($pattern.Value.Rule) |")
    }
    $lines.Add('')

    $lines.Add('## Current guidance and pinned evidence')
    $lines.Add('')
    $lines.Add('| Currency | Meaning |')
    $lines.Add('| --- | --- |')
    foreach ($currency in $currencies.GetEnumerator()) {
        $lines.Add("| $($currency.Value.Label) | $($currency.Value.Meaning) |")
    }
    $lines.Add('')

    $lines.Add('## Ownership')
    $lines.Add('')
    $header = '| Topic | Owner | Currency | Canonical source | ' + ((@($surfaceDefinitions.Values | ForEach-Object Column)) -join ' | ') + ' |'
    $lines.Add($header)
    $lines.Add('| ' + ((@(1..(4 + $surfaceDefinitions.Count) | ForEach-Object { '---' })) -join ' | ') + ' |')
    foreach ($topic in $topics) {
        $cells = foreach ($surfaceId in $surfaceDefinitions.Keys) {
            if ($surfaceId -eq $topic['owner']) { '**Owner**' } else { $patterns[$topic['reuse'][$surfaceId]['pattern']].Label }
        }
        $canonical = (@(Get-Items $topic['canonical'] | ForEach-Object { Format-Link $_ })) -join '<br>'
        $currencyLabel = $currencies[$topic['currency']].Label
        $lines.Add("| [$(Format-Text $topic['title'])](#$($topic['id'])) | $($surfaceDefinitions[$topic['owner']].Column) | $currencyLabel | $canonical | $($cells -join ' | ') |")
    }
    $lines.Add('')

    $lines.Add('## Topic notes')
    foreach ($topic in $topics) {
        $lines.Add('')
        $lines.Add("<a id=""$($topic['id'])""></a>")
        $lines.Add('')
        $lines.Add("### $(Format-Text $topic['title'])")
        $lines.Add('')
        $lines.Add("$(Format-Text $topic['note'])")
        $lines.Add('')
        foreach ($surfaceId in $surfaceDefinitions.Keys) {
            if ($surfaceId -eq $topic['owner']) {
                continue
            }
            $entry = $topic['reuse'][$surfaceId]
            $lines.Add("- **$(Format-Text $surfaceById[$surfaceId]['name'])** ($($patterns[$entry['pattern']].Label)): $(Format-Text $entry['note'])")
        }
    }
    $lines.Add('')

    $lines.Add('## Review rule for new documentation')
    $lines.Add('')
    $lines.Add('Before adding or expanding documentation, answer:')
    $lines.Add('')
    $lines.Add('1. Does it state behavior, an option, an API, a version, or a support boundary? If this repository is not the topic''s owner above, link to the owner, or add at most a short summary with a canonical link.')
    $lines.Add('2. Does it state another project''s current version or compatibility? Link the [compatibility matrix](../compatibility/README.md) instead, or tie the statement to a named release as a pinned snapshot, for example "reviewed against AsiBackbone 7.0.0".')
    $lines.Add('3. Is it a historical or reproducible record? Pin it to a release tag, say so, and do not update it as current guidance.')
    $lines.Add('4. Does it teach an idea that stays useful without the AsiBackbone packages? It belongs in Learning.')
    $lines.Add('5. Is there an existing summary? Keep it if it helps readers, and make sure it links its canonical source rather than removing it for symmetry.')
    $lines.Add('')

    $lines.Add('## Current-version claim review')
    $lines.Add('')
    $lines.Add('The weekly `Documentation ownership review` workflow runs `scripts/Test-DocumentationOwnership.ps1 -ScanVersionClaims`. It reads each surface''s first-contact pages on `main` and reports a sentence or clause that:')
    $lines.Add('')
    $lines.Add('- names another project with a version, such as "AsiBackbone 7.1.0";')
    $lines.Add('- asserts that it is current, using words such as current, latest, newest, newer, or now;')
    $lines.Add('- does not mark itself as a pinned snapshot, with words such as reviewed, pinned, baseline, snapshot, or historical; and')
    $lines.Add('- disagrees with the current release in the compatibility matrix.')
    $lines.Add('')
    $lines.Add('Claims about a surface''s own project are not checked, because that surface owns them. Changelogs and release notes are not scanned, because they are pinned history. Resolve a finding in the owning repository by linking the compatibility matrix or rewording the statement as a pinned snapshot.')
    $lines.Add('')
    $lines.Add('| Surface | Scanned pages |')
    $lines.Add('| --- | --- |')
    foreach ($surface in $surfaces) {
        $scannedPages = (@(Get-Items $surface['firstContact'] | ForEach-Object { '`' + $_ + '`' })) -join ', '
        $lines.Add("| $(Format-Text $surface['name']) | $scannedPages |")
    }
    $lines.Add('')

    $lines.Add('## Updating the map')
    $lines.Add('')
    $lines.Add('1. Edit [`ownership.json`](ownership.json). Give each topic exactly one owner and canonical source, and say how every other surface references it.')
    $lines.Add('2. Run `./scripts/Test-DocumentationOwnership.ps1 -Update` to regenerate this page, then `./scripts/Test-DocumentationOwnership.ps1 -VerifyReferences -ScanVersionClaims` to confirm every link resolves and see current-version findings.')
    $lines.Add('3. Open a pull request. The `Validate organization profile` check fails when the manifest is malformed, a required topic or reuse entry is missing, a surface owns nothing, or this page does not match the manifest.')

    return (($lines -join "`n") + "`n")
}

function Get-VersionClaimFindings {
    param([string]$Content, [string]$SurfaceProduct, $CurrentVersions, [string]$Location)

    $text = [regex]::Replace($Content, '(?s)```.*?```', ' ')
    $text = [regex]::Replace($text, '(?s)<!--.*?-->', ' ')
    $text = [regex]::Replace($text, '\s+', ' ')
    foreach ($clause in [regex]::Split($text, '(?<=[.!?;])\s+')) {
        if ($clause -notmatch $currencyWords -or $clause -match $snapshotWords) {
            continue
        }

        foreach ($product in $claimPatterns.Keys) {
            if ($product -eq $SurfaceProduct -or -not $CurrentVersions.Contains($product)) {
                continue
            }

            $current = [string]$CurrentVersions[$product]
            foreach ($match in [regex]::Matches($clause, $claimPatterns[$product])) {
                $claimed = $match.Groups['version'].Value
                if ($current -eq $claimed -or $current.StartsWith("$claimed.", [StringComparison]::Ordinal)) {
                    continue
                }

                $excerpt = $clause.Trim()
                if ($excerpt.Length -gt 160) {
                    $excerpt = $excerpt.Substring(0, 157) + '...'
                }
                "${Location}: treats $($productNames[$product]) $claimed as current, but the compatibility matrix lists $current. ""$excerpt"""
            }
        }
    }
}

function Get-CurrentVersions {
    param($Compatibility)

    $versions = @{}
    foreach ($line in @(Get-Items (Get-Value $Compatibility 'supportLines'))) {
        $product = Get-Value $line 'product'
        $current = Get-Value $line 'current'
        if ((Test-NonEmptyString $product) -and (Test-NonEmptyString $current)) {
            $versions[$product] = $current
        }
    }

    return $versions
}

# Set by the self-test to answer requests offline; $null in normal runs.
$script:GitHubResponder = $null

function Invoke-GitHubRequest {
    param([string]$Uri, [switch]$Raw)

    if ($script:GitHubResponder) {
        return & $script:GitHubResponder $Uri
    }

    $headers = @{
        'Accept' = if ($Raw) { 'application/vnd.github.raw+json' } else { 'application/vnd.github+json' }
        'User-Agent' = 'AsiBackbone-documentation-ownership-validation'
        'X-GitHub-Api-Version' = '2022-11-28'
    }
    if ($env:GITHUB_TOKEN) {
        $headers['Authorization'] = "Bearer $env:GITHUB_TOKEN"
    }

    for ($attempt = 1; $attempt -le $MaximumAttempts; $attempt++) {
        try {
            $response = Invoke-WebRequest -Uri $Uri -Headers $headers -Method Get -TimeoutSec 30 -SkipHttpErrorCheck
            $code = [int]$response.StatusCode
            if ($code -eq 404) {
                return $null
            }
            if ($code -ge 200 -and $code -lt 300) {
                return $response
            }
            throw "GET $Uri returned HTTP $code."
        }
        catch {
            if ($attempt -eq $MaximumAttempts) {
                throw
            }

            Start-Sleep -Seconds (5 * $attempt)
        }
    }
}

function Get-ContentsUri {
    param([string]$Repository, [string]$Path)

    $escapedPath = (($Path -split '/') | ForEach-Object { [uri]::EscapeDataString($_) }) -join '/'
    return "https://api.github.com/repos/$Repository/contents/${escapedPath}?ref=main"
}

function Get-RepositoryFile {
    param([string]$Repository, [string]$Path)

    # The organization's own pages are read from the working tree so a pull request is scanned as proposed.
    if ($Repository -eq $organizationRepository -and -not $script:GitHubResponder) {
        $localPath = Join-Path $RepositoryRoot $Path
        if (Test-Path -LiteralPath $localPath -PathType Leaf) {
            return Get-Content -LiteralPath $localPath -Raw
        }
        return $null
    }

    $response = Invoke-GitHubRequest -Uri (Get-ContentsUri -Repository $Repository -Path $Path) -Raw
    if ($null -eq $response) {
        return $null
    }

    return [string]$response.Content
}

function Test-References {
    param($Manifest, [System.Collections.Generic.List[string]]$Errors)

    $files = [ordered]@{}
    foreach ($surface in @($Manifest['surfaces'])) {
        $files["$($surface['guide']['repository']):$($surface['guide']['path'])"] = [pscustomobject]@{ Link = $surface['guide']; Source = "surfaces[$($surface['id'])].guide" }
    }
    foreach ($topic in @($Manifest['topics'])) {
        foreach ($link in @(Get-Items $topic['canonical'])) {
            $key = "$($link['repository']):$($link['path'])"
            if (-not $files.Contains($key)) {
                $files[$key] = [pscustomobject]@{ Link = $link; Source = "topics[$($topic['id'])].canonical" }
            }
        }
    }

    foreach ($file in $files.Values) {
        if ($null -eq (Invoke-GitHubRequest -Uri (Get-ContentsUri -Repository $file.Link['repository'] -Path $file.Link['path']))) {
            $Errors.Add("$($file.Source) links to $($file.Link['path']) in $($file.Link['repository']), which does not exist on main.")
        }
    }

    return $files.Count
}

function Invoke-VersionClaimScan {
    param($Manifest, $CurrentVersions, [System.Collections.Generic.List[string]]$Findings)

    $scanned = 0
    foreach ($surface in @($Manifest['surfaces'])) {
        $definition = $surfaceDefinitions[$surface['id']]
        foreach ($path in @(Get-Items $surface['firstContact'])) {
            $content = Get-RepositoryFile -Repository $definition.Repository -Path $path
            if ($null -eq $content) {
                $Findings.Add("$($definition.Repository) ${path}: first-contact page not found on main.")
                continue
            }

            $scanned++
            foreach ($finding in @(Get-VersionClaimFindings -Content $content -SurfaceProduct $definition.Product -CurrentVersions $CurrentVersions -Location "$($definition.Repository) $path")) {
                $Findings.Add($finding)
            }
        }
    }

    return $scanned
}

function Read-JsonFile {
    param([string]$Path, [string]$RelativePath)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "$RelativePath is required."
    }

    return (Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json -AsHashtable -Depth 20)
}

function Invoke-SelfTest {
    $link = { param($Repository, $Path) [ordered]@{ repository = $Repository; path = $Path } }
    $surfaces = @(
        foreach ($entry in $surfaceDefinitions.GetEnumerator()) {
            [ordered]@{
                id = $entry.Key; name = "Surface $($entry.Key)"; repository = $entry.Value.Repository; site = 'https://example.org/'
                kind = 'education'; owns = 'Its own topics.'; guide = (& $link $entry.Value.Repository 'CONTRIBUTING.md'); firstContact = @('README.md')
            }
        }
    )
    $owners = @($surfaceDefinitions.Keys)
    $topics = @(
        for ($index = 0; $index -lt $requiredTopics.Count; $index++) {
            $owner = $owners[$index % $owners.Count]
            $reuse = [ordered]@{}
            foreach ($surfaceId in $owners) {
                if ($surfaceId -ne $owner) {
                    $reuse[$surfaceId] = [ordered]@{ pattern = 'link-only'; note = 'Links the owner.' }
                }
            }
            [ordered]@{
                id = $requiredTopics[$index]; title = "Topic $index"; owner = $owner
                currency = if ($index % 2 -eq 0) { 'current' } else { 'pinned' }
                canonical = @((& $link $surfaceDefinitions[$owner].Repository 'docs/index.md'))
                reuse = $reuse; note = 'Owned here.'
            }
        }
    )
    $valid = [ordered]@{ schemaVersion = 1; reviewed = '2026-10-23'; surfaces = $surfaces; topics = $topics }

    $clone = { ($valid | ConvertTo-Json -Depth 20 | ConvertFrom-Json -AsHashtable -Depth 20) }
    $mutate = {
        param([scriptblock]$Change)
        $copy = & $clone
        & $Change $copy
        return $copy
    }

    $cases = @(
        @{ Name = 'valid manifest'; Manifest = (& $clone); Pass = $true }
        @{ Name = 'missing surface'; Manifest = (& $mutate { param($m) $m['surfaces'] = @($m['surfaces'] | Where-Object { $_['id'] -ne 'reference-application' }) }); Pass = $false }
        @{ Name = 'surface pointed at the wrong repository'; Manifest = (& $mutate { param($m) $m['surfaces'][0]['repository'] = 'AsiBackbone/AsiBackbone' }); Pass = $false }
        @{ Name = 'unknown content kind'; Manifest = (& $mutate { param($m) $m['surfaces'][0]['kind'] = 'marketing' }); Pass = $false }
        @{ Name = 'missing required topic'; Manifest = (& $mutate { param($m) $m['topics'] = @($m['topics'] | Where-Object { $_['id'] -ne 'compatibility-matrix' }) }); Pass = $false }
        @{ Name = 'topic with two owners'; Manifest = (& $mutate { param($m) $m['topics'][0]['owner'] = 'learning, ncat' }); Pass = $false }
        @{ Name = 'reuse entry missing for a surface'; Manifest = (& $mutate { param($m) $m['topics'][0]['reuse'].Remove('ncat') }); Pass = $false }
        @{ Name = 'reuse entry for the owner'; Manifest = (& $mutate { param($m) $m['topics'][0]['reuse'][$m['topics'][0]['owner']] = [ordered]@{ pattern = 'link-only'; note = 'x' } }); Pass = $false }
        @{ Name = 'unknown reuse pattern'; Manifest = (& $mutate { param($m) $m['topics'][1]['reuse']['learning']['pattern'] = 'copy' }); Pass = $false }
        @{ Name = 'canonical source outside the owner'; Manifest = (& $mutate { param($m) $m['topics'][1]['canonical'][0]['repository'] = 'AsiBackbone/.github' }); Pass = $false }
        @{ Name = 'no pinned topic'; Manifest = (& $mutate { param($m) foreach ($t in $m['topics']) { $t['currency'] = 'current' } }); Pass = $false }
        @{ Name = 'surface that owns nothing'; Manifest = (& $mutate { param($m) foreach ($t in $m['topics']) { if ($t['owner'] -eq 'learning') { $t['owner'] = 'organization'; $t['reuse'].Remove('organization'); $t['reuse']['learning'] = [ordered]@{ pattern = 'link-only'; note = 'x' }; $t['canonical'][0]['repository'] = 'AsiBackbone/.github' } } }); Pass = $false }
        @{ Name = 'path escaping the repository'; Manifest = (& $mutate { param($m) $m['surfaces'][0]['firstContact'] = @('../README.md') }); Pass = $false }
    )

    $failures = [System.Collections.Generic.List[string]]::new()
    foreach ($case in $cases) {
        $caseErrors = [System.Collections.Generic.List[string]]::new()
        Test-Manifest -Manifest $case.Manifest -Errors $caseErrors
        if (($caseErrors.Count -eq 0) -ne $case.Pass) {
            $expected = if ($case.Pass) { 'success' } else { 'failure' }
            $failures.Add("Self-test '$($case.Name)' expected $expected but got $($caseErrors.Count) error(s): $($caseErrors -join ' ')")
        }
    }

    $rendered = ConvertTo-OwnershipMarkdown (& $clone)
    if ($rendered -ne (ConvertTo-OwnershipMarkdown (& $clone))) {
        $failures.Add('Rendering is not deterministic.')
    }
    foreach ($expected in @('## Review rule for new documentation', '## Current-version claim review', '| Link only |', '**Owner**', '<a id="compatibility-matrix"></a>', 'does not move or delete content')) {
        if (-not $rendered.Contains($expected, [StringComparison]::Ordinal)) {
            $failures.Add("Rendered map is missing: $expected")
        }
    }

    $current = @{ learning = '1.3.0'; asiBackbone = '7.5.0'; netCoreApplicationTemplate = '2.11.5'; referenceApplication = '0.1.0-alpha.11' }
    $claimCases = @(
        @{ Name = 'stale newer-release claim'; Text = 'AsiBackbone 7.1.0 is the owning repository''s newer stable release; Learning keeps its baseline.'; Product = 'learning'; Count = 1 }
        @{ Name = 'pinned review baseline'; Text = 'Learning 1.3 is the current documentation baseline aligned with the reviewed AsiBackbone 7.0.0 boundary.'; Product = 'learning'; Count = 0 }
        @{ Name = 'matching current claim'; Text = 'The current release is AsiBackbone 7.5.0.'; Product = 'learning'; Count = 0 }
        @{ Name = 'matching major and minor'; Text = 'The latest line is AsiBackbone 7.5.'; Product = 'learning'; Count = 0 }
        @{ Name = 'own project not checked'; Text = 'The current release is AsiBackbone 7.1.0.'; Product = 'asiBackbone'; Count = 0 }
        @{ Name = 'no currency word'; Text = 'AsiBackbone 7.1.0 added analyzers.'; Product = 'learning'; Count = 0 }
        @{ Name = 'stale prerelease claim'; Text = 'The latest Reference Application 0.1.0-alpha.9 shows the explorer.'; Product = 'learning'; Count = 1 }
        @{ Name = 'stale template claim'; Text = 'Generate the host from the latest .NET Core Application Template 2.10.0.'; Product = 'asiBackbone'; Count = 1 }
        @{ Name = 'Learning name is not AsiBackbone'; Text = 'The current AsiBackbone Learning 1.3.0 release is archived.'; Product = 'ncat'; Count = 0 }
        @{ Name = 'code blocks are ignored'; Text = "Example:`n```````ntext`nThe current AsiBackbone 7.1.0 package.`n```````n"; Product = 'learning'; Count = 0 }
    )
    foreach ($case in $claimCases) {
        $found = @(Get-VersionClaimFindings -Content $case.Text -SurfaceProduct $case.Product -CurrentVersions $current -Location 'test')
        if ($found.Count -ne $case.Count) {
            $failures.Add("Self-test '$($case.Name)' expected $($case.Count) finding(s) but got $($found.Count): $($found -join ' ')")
        }
    }

    # Drive the real request functions against an offline responder that answers like the GitHub REST API.
    $pages = @{
        'AsiBackbone/Learning:README.md' = 'AsiBackbone 7.1.0 is the newer stable release.'
        'AsiBackbone/AsiBackbone:README.md' = 'Start with the current docs.'
        'AsiBackbone/NetCoreApplicationTemplate:README.md' = 'A template.'
        'AsiBackbone/ReferenceApplication:README.md' = 'The current NCAT baseline is 2.11.5.'
        'AsiBackbone/.github:README.md' = 'The latest AsiBackbone 7.5.0 release.'
    }
    $script:GitHubResponder = {
        param($Uri)
        if ($Uri -match '/repos/(?<repo>[^/]+/[^/]+)/contents/(?<path>[^?]+)\?ref=main$') {
            $key = "$($Matches.repo):$([uri]::UnescapeDataString($Matches.path))"
            if ($pages.ContainsKey($key)) { return [pscustomobject]@{ StatusCode = 200; Content = $pages[$key] } }
            return $null
        }
        throw "Unexpected request: $Uri"
    }.GetNewClosure()
    try {
        $scanFindings = [System.Collections.Generic.List[string]]::new()
        $null = Invoke-VersionClaimScan -Manifest (& $clone) -CurrentVersions $current -Findings $scanFindings
        if ($scanFindings.Count -ne 1 -or $scanFindings[0] -notmatch '^AsiBackbone/Learning README\.md: treats AsiBackbone 7\.1\.0 as current') {
            $failures.Add("Self-test 'GitHub API: version claim scan' expected one Learning finding but got: $($scanFindings -join ' ')")
        }

        $missing = & $mutate { param($m) $m['surfaces'][0]['firstContact'] = @('MISSING.md') }
        $scanFindings = [System.Collections.Generic.List[string]]::new()
        $null = Invoke-VersionClaimScan -Manifest $missing -CurrentVersions $current -Findings $scanFindings
        if (@($scanFindings | Where-Object { $_ -match 'MISSING\.md: first-contact page not found' }).Count -ne 1) {
            $failures.Add("Self-test 'GitHub API: missing first-contact page' was not reported: $($scanFindings -join ' ')")
        }

        $pages['AsiBackbone/Learning:CONTRIBUTING.md'] = 'x'
        $pages['AsiBackbone/Learning:docs/index.md'] = 'x'
        $referenceErrors = [System.Collections.Generic.List[string]]::new()
        $null = Test-References -Manifest (& $clone) -Errors $referenceErrors
        if (@($referenceErrors | Where-Object { $_ -match 'AsiBackbone/Learning' }).Count -ne 0 -or @($referenceErrors | Where-Object { $_ -match 'CONTRIBUTING\.md in AsiBackbone/AsiBackbone' }).Count -ne 1) {
            $failures.Add("Self-test 'GitHub API: reference check' reported the wrong links: $($referenceErrors -join ' ')")
        }
    }
    finally {
        $script:GitHubResponder = $null
    }

    if ($failures.Count -gt 0) {
        $failures | ForEach-Object { Write-Error $_ -ErrorAction Continue }
        exit 1
    }

    Write-Host 'Documentation ownership validator self-test passed.'
}

if ($MyInvocation.InvocationName -eq '.') {
    return
}

if ($SelfTest) {
    Invoke-SelfTest
    exit 0
}

$manifestPath = Join-Path $RepositoryRoot $manifestRelativePath
$mapPath = Join-Path $RepositoryRoot $mapRelativePath
$errors = [System.Collections.Generic.List[string]]::new()

try {
    $manifest = Read-JsonFile -Path $manifestPath -RelativePath $manifestRelativePath
}
catch {
    Write-Error "The documentation ownership map could not be read: $($_.Exception.Message)" -ErrorAction Continue
    exit 1
}

Test-Manifest -Manifest $manifest -Errors $errors
if ($errors.Count -gt 0) {
    $errors | ForEach-Object { Write-Error $_ -ErrorAction Continue }
    exit 1
}

$rendered = ConvertTo-OwnershipMarkdown $manifest
if ($Update) {
    [System.IO.File]::WriteAllText($mapPath, $rendered, [System.Text.UTF8Encoding]::new($false))
    Write-Host "Regenerated $mapRelativePath."
}
else {
    $committed = if (Test-Path -LiteralPath $mapPath -PathType Leaf) { (Get-Content -LiteralPath $mapPath -Raw).Replace("`r`n", "`n") } else { '' }
    if ($committed -ne $rendered) {
        Write-Error "$mapRelativePath does not match $manifestRelativePath. Run ./scripts/Test-DocumentationOwnership.ps1 -Update and commit the result." -ErrorAction Continue
        exit 1
    }
}

$summary = [System.Collections.Generic.List[string]]::new()
if ($VerifyReferences) {
    try {
        $checked = Test-References -Manifest $manifest -Errors $errors
        $summary.Add("Checked $checked linked guides and canonical documents on main.")
    }
    catch {
        $errors.Add("References could not be verified: $($_.Exception.Message)")
    }
}

if ($ScanVersionClaims) {
    try {
        $compatibility = Read-JsonFile -Path (Join-Path $RepositoryRoot $compatibilityRelativePath) -RelativePath $compatibilityRelativePath
        $scanned = Invoke-VersionClaimScan -Manifest $manifest -CurrentVersions (Get-CurrentVersions $compatibility) -Findings $errors
        $summary.Add("Scanned $scanned first-contact pages for current-version claims.")
    }
    catch {
        $errors.Add("Current-version claims could not be scanned: $($_.Exception.Message)")
    }
}

if ($env:GITHUB_STEP_SUMMARY -and ($VerifyReferences -or $ScanVersionClaims)) {
    $lines = @('## Documentation ownership review', '') + @($summary)
    if ($errors.Count -gt 0) {
        $lines += @('', 'Fix these in the repository named in each finding.', '', '| Finding |', '| --- |') + @($errors | ForEach-Object { "| $($_.Replace('|', '\|')) |" })
    }
    $lines | Add-Content -LiteralPath $env:GITHUB_STEP_SUMMARY -Encoding utf8
}

if ($errors.Count -gt 0) {
    $errors | ForEach-Object { Write-Error $_ -ErrorAction Continue }
    exit 1
}

$summary | ForEach-Object { Write-Host $_ }
Write-Host 'Documentation ownership map is valid and the rendered map is current.'
