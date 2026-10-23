[CmdletBinding()]
param(
    [string]$RepositoryRoot = (Split-Path -Parent $PSScriptRoot),

    # Regenerates compatibility/README.md from the manifest instead of checking it.
    [switch]$Update,

    # Also checks every referenced tag and evidence file against GitHub, and that every Reference Application release
    # is recorded. Requires network access; set GITHUB_TOKEN to raise the API rate limit.
    [switch]$VerifyReferences,

    [ValidateRange(1, 5)]
    [int]$MaximumAttempts = 3,

    [switch]$SelfTest
)

# Validates the ecosystem compatibility manifest (compatibility/ecosystem-compatibility.json), renders the
# human-readable matrix (compatibility/README.md) from it, and fails when the committed matrix differs from the
# rendering (AsiBackbone/.github#25). The default mode is offline and deterministic. -VerifyReferences reads public
# GitHub tags and files only and never writes to any repository.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$manifestRelativePath = 'compatibility/ecosystem-compatibility.json'
$matrixRelativePath = 'compatibility/README.md'

# Canonical project order (LANDING-PAGE-STANDARD.md): Learn → Framework → Template → Reference.
$products = [ordered]@{
    learning = [pscustomobject]@{ Name = 'AsiBackbone Learning'; Short = 'Learning'; Repository = 'AsiBackbone/Learning' }
    asiBackbone = [pscustomobject]@{ Name = 'AsiBackbone'; Short = 'AsiBackbone'; Repository = 'AsiBackbone/AsiBackbone' }
    netCoreApplicationTemplate = [pscustomobject]@{ Name = '.NET Core Application Template'; Short = 'NCAT'; Repository = 'AsiBackbone/NetCoreApplicationTemplate' }
    referenceApplication = [pscustomobject]@{ Name = 'AsiBackbone Reference Application'; Short = 'Reference Application'; Repository = 'AsiBackbone/ReferenceApplication' }
}

$statuses = [ordered]@{
    reviewed = [pscustomobject]@{ Label = 'Reviewed together'; Meaning = 'Built, tested, or reviewed together, with the evidence linked in the row. This is the strongest status the matrix records.' }
    independent = [pscustomobject]@{ Label = 'Independently supported'; Meaning = 'Each component is on a supported line, but the combination has not been integration-reviewed. It is likely to work and is not known to be broken.' }
    historical = [pscustomobject]@{ Label = 'Historical'; Meaning = 'Was reviewed together and has since been superseded. Kept for reproducibility; not a current recommendation.' }
    incompatible = [pscustomobject]@{ Label = 'Incompatible'; Meaning = 'Known not to work together, with the reason in the notes.' }
}

$kinds = @('integration', 'learning-review')
$semVerPattern = '^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(-[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*)?$'
$idPattern = '^[a-z0-9][a-z0-9.-]*$'
$targetFrameworkPattern = '^net\d+\.\d+$'
$knownRepositories = @($products.Values | ForEach-Object Repository)

function Get-Value {
    param($Object, [string]$Name)

    if ($null -eq $Object -or $Object -isnot [System.Collections.IDictionary] -or -not $Object.Contains($Name)) {
        return $null
    }

    # The comma keeps arrays, including single-element and empty arrays, from being unrolled.
    return , $Object[$Name]
}

function Test-IsoDate {
    param($Value)

    if ($Value -isnot [string] -or $Value -notmatch '^\d{4}-\d{2}-\d{2}$') {
        return $false
    }

    $parsed = [datetime]::MinValue
    return [datetime]::TryParseExact($Value, 'yyyy-MM-dd', [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::None, [ref]$parsed)
}

function Test-NonEmptyString {
    param($Value)

    return $Value -is [string] -and -not [string]::IsNullOrWhiteSpace($Value)
}

function Get-StringList {
    param($Value)

    # Emits each element so callers can collect with @(); a single object, including a dictionary, is emitted once.
    if ($null -eq $Value) {
        return
    }

    foreach ($item in $Value) {
        $item
    }
}

function Test-Evidence {
    param($Evidence, [string]$Source, [System.Collections.Generic.List[string]]$Errors)

    $items = @(Get-StringList $Evidence)
    if ($items.Count -eq 0) {
        $Errors.Add("$Source must list at least one evidence reference.")
        return
    }

    foreach ($item in $items) {
        $repository = Get-Value $item 'repository'
        $tag = Get-Value $item 'tag'
        $path = Get-Value $item 'path'
        if ($knownRepositories -notcontains $repository) {
            $Errors.Add("$Source evidence names an unknown repository: '$repository'.")
        }
        if (-not (Test-NonEmptyString $tag) -or $tag -notmatch '^v' -or $tag.Substring(1) -notmatch $semVerPattern) {
            $Errors.Add("$Source evidence must name a release tag of the form v<semver>: '$tag'.")
        }
        if ($null -ne $path -and (-not (Test-NonEmptyString $path) -or $path.StartsWith('/') -or $path -match '(^|/)\.\.(/|$)' -or $path -match '[\s?#]')) {
            $Errors.Add("$Source evidence path must be a repository-relative file path: '$path'.")
        }
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

    $updated = Get-Value $Manifest 'updated'
    if (-not (Test-IsoDate $updated)) {
        $Errors.Add("updated must be a yyyy-MM-dd date: '$updated'.")
        $updated = $null
    }

    $dotnet = Get-Value $Manifest 'dotnet'
    foreach ($field in @('line', 'targetFramework', 'sdk', 'releaseType', 'endOfSupport', 'policy')) {
        if (-not (Test-NonEmptyString (Get-Value $dotnet $field))) {
            $Errors.Add("dotnet.$field is required.")
        }
    }
    $dotnetTarget = Get-Value $dotnet 'targetFramework'
    if ((Test-NonEmptyString $dotnetTarget) -and $dotnetTarget -notmatch $targetFrameworkPattern) {
        $Errors.Add("dotnet.targetFramework must look like net10.0: '$dotnetTarget'.")
    }
    $endOfSupport = Get-Value $dotnet 'endOfSupport'
    if ((Test-NonEmptyString $endOfSupport) -and -not (Test-IsoDate $endOfSupport)) {
        $Errors.Add("dotnet.endOfSupport must be a yyyy-MM-dd date: '$endOfSupport'.")
    }
    $policy = Get-Value $dotnet 'policy'
    if ((Test-NonEmptyString $policy) -and $policy -notmatch '^https://') {
        $Errors.Add('dotnet.policy must be an https URL.')
    }

    $seenProducts = [System.Collections.Generic.HashSet[string]]::new()
    foreach ($line in @(Get-StringList (Get-Value $Manifest 'supportLines'))) {
        $product = Get-Value $line 'product'
        $source = "supportLines[$product]"
        if (-not $products.Contains([string]$product)) {
            $Errors.Add("supportLines names an unknown product: '$product'.")
            continue
        }
        if (-not $seenProducts.Add($product)) {
            $Errors.Add("$source is listed more than once.")
        }
        foreach ($field in @('line', 'notes')) {
            if (-not (Test-NonEmptyString (Get-Value $line $field))) {
                $Errors.Add("$source.$field is required.")
            }
        }
        $current = Get-Value $line 'current'
        if (-not (Test-NonEmptyString $current) -or $current -notmatch $semVerPattern) {
            $Errors.Add("$source.current must be a semantic version: '$current'.")
        }
        $frameworks = @(Get-StringList (Get-Value $line 'targetFrameworks'))
        if ($frameworks.Count -eq 0 -or @($frameworks | Where-Object { $_ -isnot [string] -or $_ -notmatch '^(net\d+\.\d+|netstandard\d+\.\d+)$' }).Count -gt 0) {
            $Errors.Add("$source.targetFrameworks must list target framework monikers.")
        }
        Test-Evidence -Evidence (Get-Value $line 'evidence') -Source $source -Errors $Errors
    }
    foreach ($product in $products.Keys) {
        if (-not $seenProducts.Contains($product)) {
            $Errors.Add("supportLines must describe '$product'.")
        }
    }

    $combinations = @(Get-StringList (Get-Value $Manifest 'combinations'))
    if ($combinations.Count -eq 0) {
        $Errors.Add('combinations must list at least one entry.')
    }

    $ids = [System.Collections.Generic.HashSet[string]]::new()
    $referenceReleases = @{}
    $learningReleases = @{}
    $currentIntegration = 0
    foreach ($combination in $combinations) {
        $id = Get-Value $combination 'id'
        $source = "combinations[$id]"
        if (-not (Test-NonEmptyString $id) -or $id -notmatch $idPattern) {
            $Errors.Add("Combination id must be lowercase letters, digits, dots, and hyphens: '$id'.")
        }
        elseif (-not $ids.Add($id)) {
            $Errors.Add("Combination id '$id' is used more than once.")
        }

        $kind = Get-Value $combination 'kind'
        if ($kinds -notcontains $kind) {
            $Errors.Add("$source.kind must be one of $($kinds -join ', '): '$kind'.")
        }
        $status = Get-Value $combination 'status'
        if (-not $statuses.Contains([string]$status)) {
            $Errors.Add("$source.status must be one of $($statuses.Keys -join ', '): '$status'.")
        }

        $components = Get-Value $combination 'components'
        if ($components -isnot [System.Collections.IDictionary]) {
            $Errors.Add("$source.components must be an object.")
            continue
        }
        foreach ($name in $components.Keys) {
            if (-not $products.Contains($name)) {
                $Errors.Add("$source.components names an unknown product: '$name'.")
            }
        }

        foreach ($single in @('netCoreApplicationTemplate', 'asiBackbone')) {
            $version = Get-Value $components $single
            if ($null -ne $version -and ($version -isnot [string] -or $version -notmatch $semVerPattern)) {
                $Errors.Add("$source.components.$single must be a semantic version or null: '$version'.")
            }
        }
        foreach ($list in @('referenceApplication', 'learning')) {
            $value = Get-Value $components $list
            if ($null -ne $value -and $value -isnot [array]) {
                $Errors.Add("$source.components.$list must be an array of versions.")
                continue
            }
            foreach ($version in @(Get-StringList $value)) {
                if ($version -isnot [string] -or $version -notmatch $semVerPattern) {
                    $Errors.Add("$source.components.$list contains a malformed version: '$version'.")
                }
            }
        }

        $template = Get-Value $components 'netCoreApplicationTemplate'
        $framework = Get-Value $components 'asiBackbone'
        $reference = @(Get-StringList (Get-Value $components 'referenceApplication'))
        $learning = @(Get-StringList (Get-Value $components 'learning'))

        if ($kind -eq 'integration') {
            if ($null -eq $template -or $reference.Count -eq 0) {
                $Errors.Add("$source is an integration entry and must name the NCAT version and at least one Reference Application release.")
            }
            if ($learning.Count -gt 0) {
                $Errors.Add("$source is an integration entry and must not list Learning releases; record Learning reviews as learning-review entries.")
            }
            if ($status -eq 'reviewed' -and $null -eq $framework) {
                $Errors.Add("$source is a reviewed integration entry and must name the AsiBackbone version it qualifies.")
            }
            if ($status -eq 'reviewed') {
                $currentIntegration++
            }
        }
        elseif ($kind -eq 'learning-review') {
            if ($learning.Count -eq 0) {
                $Errors.Add("$source is a learning-review entry and must list at least one Learning release.")
            }
            if ($reference.Count -gt 0) {
                $Errors.Add("$source is a learning-review entry and must not list Reference Application releases.")
            }
            if ($null -eq $template -and $null -eq $framework) {
                $Errors.Add("$source must name the AsiBackbone or NCAT version that Learning reviewed.")
            }
        }

        foreach ($version in $reference) {
            if ($referenceReleases.ContainsKey($version)) {
                $Errors.Add("Reference Application $version is listed by both $($referenceReleases[$version]) and $id; each release qualifies exactly one combination.")
            }
            else {
                $referenceReleases[$version] = $id
            }
        }
        foreach ($version in $learning) {
            if ($learningReleases.ContainsKey($version)) {
                $Errors.Add("Learning $version is listed by both $($learningReleases[$version]) and $id.")
            }
            else {
                $learningReleases[$version] = $id
            }
        }

        $target = Get-Value $combination 'targetFramework'
        if (-not (Test-NonEmptyString $target) -or $target -notmatch $targetFrameworkPattern) {
            $Errors.Add("$source.targetFramework must look like net10.0: '$target'.")
        }
        $sdk = Get-Value $combination 'sdk'
        if (-not (Test-NonEmptyString $sdk) -or $sdk -notmatch '^\d+\.\d+\.\d{3}$') {
            $Errors.Add("$source.sdk must be a .NET SDK version such as 10.0.400: '$sdk'.")
        }

        $reviewed = Get-Value $combination 'reviewed'
        if (-not (Test-IsoDate $reviewed)) {
            $Errors.Add("$source.reviewed must be a yyyy-MM-dd date: '$reviewed'.")
        }
        elseif ($null -ne $updated -and [string]::CompareOrdinal($reviewed, $updated) -gt 0) {
            $Errors.Add("$source.reviewed ($reviewed) is later than the manifest's updated date ($updated).")
        }

        if (-not (Test-NonEmptyString (Get-Value $combination 'notes'))) {
            $Errors.Add("$source.notes is required.")
        }
        Test-Evidence -Evidence (Get-Value $combination 'evidence') -Source $source -Errors $Errors
    }

    if ($currentIntegration -eq 0) {
        $Errors.Add('At least one integration entry must have status reviewed, so the matrix names a current combination.')
    }
}

function Get-ReleaseUrl {
    param([string]$Repository, [string]$Tag)

    return "https://github.com/$Repository/releases/tag/$Tag"
}

function Get-EvidenceUrl {
    param($Evidence)

    $repository = Get-Value $Evidence 'repository'
    $tag = Get-Value $Evidence 'tag'
    $path = Get-Value $Evidence 'path'
    if ($path) {
        return "https://github.com/$repository/blob/$tag/$path"
    }

    return "https://github.com/$repository/tree/$tag"
}

function Format-Version {
    param([string]$Product, $Version)

    if ($null -eq $Version) {
        return '—'
    }

    return "[$Version]($(Get-ReleaseUrl -Repository $products[$Product].Repository -Tag "v$Version"))"
}

function Format-VersionList {
    param([string]$Product, $Versions)

    $items = @(Get-StringList $Versions)
    if ($items.Count -eq 0) {
        return '—'
    }

    return (@($items | ForEach-Object { Format-Version -Product $Product -Version $_ }) -join ', ')
}

function Format-Evidence {
    param($Evidence)

    $links = foreach ($item in @(Get-StringList $Evidence)) {
        $repository = (Get-Value $item 'repository') -replace '^AsiBackbone/', ''
        $label = "$repository@$(Get-Value $item 'tag')"
        $path = Get-Value $item 'path'
        if ($path) {
            $label += " $path"
        }
        "[$label]($(Get-EvidenceUrl $item))"
    }

    return ($links -join '<br>')
}

function Format-Cell {
    param([string]$Value)

    return $Value.Replace('|', '\|').Replace("`r", '').Replace("`n", ' ')
}

function Get-StatusRank {
    param([string]$Status)

    return @($statuses.Keys).IndexOf($Status)
}

function ConvertTo-MatrixMarkdown {
    param($Manifest)

    $dotnet = $Manifest['dotnet']
    $combinations = @($Manifest['combinations'])
    $lines = [System.Collections.Generic.List[string]]::new()

    $lines.Add('# AsiBackbone Ecosystem Compatibility Matrix')
    $lines.Add('')
    $lines.Add("<!-- Generated from ecosystem-compatibility.json by scripts/Test-CompatibilityMatrix.ps1 -Update. Do not edit by hand. -->")
    $lines.Add('')
    $lines.Add("This matrix records which versions of [AsiBackbone Learning](https://github.com/AsiBackbone/Learning), [AsiBackbone](https://github.com/AsiBackbone/AsiBackbone), the [.NET Core Application Template](https://github.com/AsiBackbone/NetCoreApplicationTemplate) (NCAT), and the [AsiBackbone Reference Application](https://github.com/AsiBackbone/ReferenceApplication) have been reviewed together, and on which .NET line. It is the organization's single source for that information; owning repositories link here rather than keeping their own copies.")
    $lines.Add('')
    $lines.Add("The machine-readable source is [``ecosystem-compatibility.json``](ecosystem-compatibility.json). This page is generated from it and checked against it on every pull request. Last updated: $($Manifest['updated']).")
    $lines.Add('')
    $lines.Add('> **Boundary:** The matrix records reviewed compatibility evidence. A combination that is not listed is untested, not known to be broken. A listed combination is not a certification, a compliance statement, or a security guarantee; each consuming application remains responsible for its own configuration, threat analysis, deployment controls, testing, and security review.')
    $lines.Add('')

    $lines.Add('## Status definitions')
    $lines.Add('')
    $lines.Add('| Status | Meaning |')
    $lines.Add('| --- | --- |')
    foreach ($status in $statuses.GetEnumerator()) {
        $lines.Add("| $($status.Value.Label) | $($status.Value.Meaning) |")
    }
    $lines.Add('')

    $integrationHeader = @('| Status | NCAT | AsiBackbone | Reference Application | .NET | Reviewed | Evidence | Notes |', '| --- | --- | --- | --- | --- | --- | --- | --- |')
    $learningHeader = @('| Status | Learning | Reviewed against AsiBackbone | Reviewed against NCAT | .NET | Reviewed | Evidence | Notes |', '| --- | --- | --- | --- | --- | --- | --- | --- |')

    $integrationRow = {
        param($c)
        $components = $c['components']
        "| $($statuses[$c['status']].Label) | $(Format-Version 'netCoreApplicationTemplate' $components['netCoreApplicationTemplate']) | $(Format-Version 'asiBackbone' $components['asiBackbone']) | $(Format-VersionList 'referenceApplication' $components['referenceApplication']) | ``$($c['targetFramework'])`` (SDK $($c['sdk'])) | $($c['reviewed']) | $(Format-Evidence $c['evidence']) | $(Format-Cell $c['notes']) |"
    }
    $learningRow = {
        param($c)
        $components = $c['components']
        "| $($statuses[$c['status']].Label) | $(Format-VersionList 'learning' $components['learning']) | $(Format-Version 'asiBackbone' $components['asiBackbone']) | $(Format-Version 'netCoreApplicationTemplate' $components['netCoreApplicationTemplate']) | ``$($c['targetFramework'])`` (SDK $($c['sdk'])) | $($c['reviewed']) | $(Format-Evidence $c['evidence']) | $(Format-Cell $c['notes']) |"
    }

    $sorted = @($combinations | Sort-Object -Stable -Property @{ Expression = { Get-StatusRank $_['status'] } }, @{ Expression = { $_['reviewed'] }; Descending = $true })
    $current = @($sorted | Where-Object { $_['status'] -ne 'historical' })
    $historical = @($sorted | Where-Object { $_['status'] -eq 'historical' })

    $lines.Add('## Current integration')
    $lines.Add('')
    $lines.Add('Each Reference Application release qualifies exactly one NCAT and AsiBackbone combination. The Reference Application is an example host generated from NCAT; its releases are pre-releases and do not declare a stable public contract.')
    $lines.Add('')
    $currentIntegration = @($current | Where-Object { $_['kind'] -eq 'integration' })
    $lines.AddRange([string[]]$integrationHeader)
    foreach ($c in $currentIntegration) {
        $lines.Add((& $integrationRow $c))
    }
    $lines.Add('')

    $lines.Add('## Learning review baselines')
    $lines.Add('')
    $lines.Add('Learning is educational material, not a package dependency. These rows record which implementation versions a Learning release was reviewed against; they do not make a Learning release a runtime requirement or recommend the reviewed package version over a newer release.')
    $lines.Add('')
    $currentLearning = @($current | Where-Object { $_['kind'] -eq 'learning-review' })
    $lines.AddRange([string[]]$learningHeader)
    foreach ($c in $currentLearning) {
        $lines.Add((& $learningRow $c))
    }
    $lines.Add('')

    $lines.Add('## Supported lines')
    $lines.Add('')
    $lines.Add('Each product is supported independently on the line below. A combination of supported lines that has no row above is independently supported but not integration-reviewed.')
    $lines.Add('')
    $lines.Add('| Product | Line | Current release | Target frameworks | Notes |')
    $lines.Add('| --- | --- | --- | --- | --- |')
    foreach ($line in @($Manifest['supportLines'] | Sort-Object { @($products.Keys).IndexOf($_['product']) })) {
        $product = $products[$line['product']]
        $frameworks = (@($line['targetFrameworks']) | ForEach-Object { "``$_``" }) -join ', '
        $lines.Add("| [$($product.Name)](https://github.com/$($product.Repository)) | $(Format-Cell $line['line']) | $(Format-Version $line['product'] $line['current']) | $frameworks | $(Format-Cell $line['notes']) |")
    }
    $lines.Add("| [$($dotnet['line'])]($($dotnet['policy'])) | $($dotnet['releaseType']) | SDK $($dotnet['sdk']) | ``$($dotnet['targetFramework'])`` | Microsoft support ends $($dotnet['endOfSupport']). |")
    $lines.Add('')

    $lines.Add('## Historical combinations')
    $lines.Add('')
    $lines.Add('These combinations were reviewed together and have since been superseded. They remain for reproducibility of earlier releases and are not current recommendations.')
    $lines.Add('')
    $historicalIntegration = @($historical | Where-Object { $_['kind'] -eq 'integration' })
    if ($historicalIntegration.Count -gt 0) {
        $lines.AddRange([string[]]$integrationHeader)
        foreach ($c in $historicalIntegration) {
            $lines.Add((& $integrationRow $c))
        }
        $lines.Add('')
    }
    $historicalLearning = @($historical | Where-Object { $_['kind'] -eq 'learning-review' })
    if ($historicalLearning.Count -gt 0) {
        $lines.AddRange([string[]]$learningHeader)
        foreach ($c in $historicalLearning) {
            $lines.Add((& $learningRow $c))
        }
        $lines.Add('')
    }

    $lines.Add('## Known incompatibilities')
    $lines.Add('')
    if (@($combinations | Where-Object { $_['status'] -eq 'incompatible' }).Count -eq 0) {
        $lines.Add('None recorded. Incompatible combinations appear in the tables above with the Incompatible status and the reason in their notes.')
    }
    else {
        $lines.Add('Combinations with the Incompatible status appear in the tables above, with the reason in their notes.')
    }
    $lines.Add('')

    $lines.Add('## Updating the matrix')
    $lines.Add('')
    $lines.Add('1. Edit [`ecosystem-compatibility.json`](ecosystem-compatibility.json). Record a new Reference Application release in exactly one integration entry, mark the entry it supersedes `historical`, and link the release evidence by tag.')
    $lines.Add('2. Run `./scripts/Test-CompatibilityMatrix.ps1 -Update` to regenerate this page, then `./scripts/Test-CompatibilityMatrix.ps1 -VerifyReferences` to confirm that every referenced tag and evidence file exists and that every Reference Application release is recorded.')
    $lines.Add('3. Open a pull request. The `Validate organization profile` check fails when the manifest is malformed or this page does not match it, and the `Compatibility matrix validation` workflow repeats the reference check on the pull request and every week.')

    return (($lines -join "`n") + "`n")
}

# Set by the self-test to answer requests offline; $null in normal runs.
$script:GitHubResponder = $null

function Invoke-GitHubRequest {
    param([string]$Uri)

    if ($script:GitHubResponder) {
        return & $script:GitHubResponder $Uri
    }

    $headers = @{
        'Accept' = 'application/vnd.github+json'
        'User-Agent' = 'AsiBackbone-compatibility-matrix-validation'
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

function Test-GitHubTag {
    param([string]$Repository, [string]$Tag)

    return $null -ne (Invoke-GitHubRequest -Uri "https://api.github.com/repos/$Repository/git/ref/tags/$([uri]::EscapeDataString($Tag))")
}

function Test-GitHubFile {
    param([string]$Repository, [string]$Tag, [string]$Path)

    $escapedPath = (($Path -split '/') | ForEach-Object { [uri]::EscapeDataString($_) }) -join '/'
    return $null -ne (Invoke-GitHubRequest -Uri "https://api.github.com/repos/$Repository/contents/${escapedPath}?ref=$([uri]::EscapeDataString($Tag))")
}

function Get-GitHubTags {
    param([string]$Repository)

    $names = [System.Collections.Generic.List[string]]::new()
    for ($page = 1; $page -le 20; $page++) {
        $response = Invoke-GitHubRequest -Uri "https://api.github.com/repos/$Repository/tags?per_page=100&page=$page"
        if ($null -eq $response) {
            throw "Tags for $Repository could not be listed."
        }
        $batch = @($response.Content | ConvertFrom-Json)
        foreach ($tag in $batch) {
            $names.Add([string]$tag.name)
        }
        if ($batch.Count -lt 100) {
            break
        }
    }

    # Emit the names individually; callers collect them with @().
    return $names.ToArray()
}

function Test-References {
    param(
        $Manifest,
        [System.Collections.Generic.List[string]]$Errors,
        [scriptblock]$TagExists = { param($Repository, $Tag) Test-GitHubTag -Repository $Repository -Tag $Tag },
        [scriptblock]$FileExists = { param($Repository, $Tag, $Path) Test-GitHubFile -Repository $Repository -Tag $Tag -Path $Path },
        [scriptblock]$ListTags = { param($Repository) Get-GitHubTags -Repository $Repository }
    )

    $tags = [ordered]@{}
    $files = [ordered]@{}
    $addTag = {
        param($Repository, $Tag, $Source)
        $key = "$Repository@$Tag"
        if (-not $tags.Contains($key)) {
            $tags[$key] = [pscustomobject]@{ Repository = $Repository; Tag = $Tag; Source = $Source }
        }
    }
    $addEvidence = {
        param($Evidence, $Source)
        foreach ($item in @(Get-StringList $Evidence)) {
            & $addTag $item['repository'] $item['tag'] $Source
            if ($item['path']) {
                $key = "$($item['repository'])@$($item['tag']):$($item['path'])"
                if (-not $files.Contains($key)) {
                    $files[$key] = [pscustomobject]@{ Repository = $item['repository']; Tag = $item['tag']; Path = $item['path']; Source = $Source }
                }
            }
        }
    }

    foreach ($line in @($Manifest['supportLines'])) {
        & $addTag $products[$line['product']].Repository "v$($line['current'])" "supportLines[$($line['product'])]"
        & $addEvidence $line['evidence'] "supportLines[$($line['product'])]"
    }

    $recordedReferenceReleases = [System.Collections.Generic.HashSet[string]]::new()
    foreach ($combination in @($Manifest['combinations'])) {
        $source = "combinations[$($combination['id'])]"
        $components = $combination['components']
        foreach ($single in @('netCoreApplicationTemplate', 'asiBackbone')) {
            if ($null -ne $components[$single]) {
                & $addTag $products[$single].Repository "v$($components[$single])" $source
            }
        }
        foreach ($list in @('referenceApplication', 'learning')) {
            foreach ($version in @(Get-StringList $components[$list])) {
                & $addTag $products[$list].Repository "v$version" $source
                if ($list -eq 'referenceApplication') {
                    $null = $recordedReferenceReleases.Add("v$version")
                }
            }
        }
        & $addEvidence $combination['evidence'] $source
    }

    foreach ($reference in $tags.Values) {
        if (-not (& $TagExists $reference.Repository $reference.Tag)) {
            $Errors.Add("$($reference.Source) references $($reference.Repository) tag $($reference.Tag), which does not exist.")
        }
    }
    foreach ($file in $files.Values) {
        if (-not (& $FileExists $file.Repository $file.Tag $file.Path)) {
            $Errors.Add("$($file.Source) cites $($file.Path) at $($file.Repository) $($file.Tag), which does not exist.")
        }
    }

    # ForEach-Object flattens a list that arrives as one array object, so each tag is checked on its own.
    $releaseTags = @(& $ListTags $products['referenceApplication'].Repository | ForEach-Object { $_ } | ForEach-Object { [string]$_ })
    foreach ($tag in $releaseTags) {
        if ($tag -match '^v' -and $tag.Substring(1) -match $semVerPattern -and -not $recordedReferenceReleases.Contains($tag)) {
            $Errors.Add("Reference Application release $tag is not recorded in any integration entry.")
        }
    }

    return $tags.Count + $files.Count
}

function Read-Manifest {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "$manifestRelativePath is required."
    }

    return (Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json -AsHashtable -Depth 20)
}

function Invoke-SelfTest {
    $valid = [ordered]@{
        schemaVersion = 1
        updated = '2026-10-23'
        dotnet = [ordered]@{ line = '.NET 10'; targetFramework = 'net10.0'; sdk = '10.0.400'; releaseType = 'LTS'; endOfSupport = '2028-11-14'; policy = 'https://dotnet.microsoft.com/platform/support/policy/dotnet-core' }
        supportLines = @(
            foreach ($product in $products.GetEnumerator()) {
                [ordered]@{ product = $product.Key; line = '1.x'; current = '1.0.0'; targetFrameworks = @('net10.0'); notes = 'Supported.'; evidence = @([ordered]@{ repository = $product.Value.Repository; tag = 'v1.0.0' }) }
            }
        )
        combinations = @(
            [ordered]@{
                id = 'reference-1.0.0'; kind = 'integration'; status = 'reviewed'
                components = [ordered]@{ netCoreApplicationTemplate = '2.11.5'; asiBackbone = '7.5.0'; referenceApplication = @('1.0.0'); learning = @() }
                targetFramework = 'net10.0'; sdk = '10.0.400'; reviewed = '2026-10-22'
                evidence = @([ordered]@{ repository = 'AsiBackbone/ReferenceApplication'; tag = 'v1.0.0'; path = 'CHANGELOG.md' })
                notes = 'Current.'
            }
            [ordered]@{
                id = 'learning-1.0.0'; kind = 'learning-review'; status = 'historical'
                components = [ordered]@{ netCoreApplicationTemplate = $null; asiBackbone = '7.0.0'; referenceApplication = @(); learning = @('1.0.0') }
                targetFramework = 'net10.0'; sdk = '10.0.400'; reviewed = '2026-10-10'
                evidence = @([ordered]@{ repository = 'AsiBackbone/Learning'; tag = 'v1.0.0' })
                notes = 'Earlier review.'
            }
        )
    }

    $clone = { ($valid | ConvertTo-Json -Depth 20 | ConvertFrom-Json -AsHashtable -Depth 20) }
    $mutate = {
        param([scriptblock]$Change)
        $copy = & $clone
        & $Change $copy
        return $copy
    }

    $cases = @(
        @{ Name = 'valid manifest'; Manifest = (& $clone); Pass = $true }
        @{ Name = 'unknown status'; Manifest = (& $mutate { param($m) $m['combinations'][0]['status'] = 'certified' }); Pass = $false }
        @{ Name = 'malformed version'; Manifest = (& $mutate { param($m) $m['combinations'][0]['components']['asiBackbone'] = '7.5' }); Pass = $false }
        @{ Name = 'malformed Reference Application version'; Manifest = (& $mutate { param($m) $m['combinations'][0]['components']['referenceApplication'] = @('v1.0.0') }); Pass = $false }
        @{ Name = 'duplicate id'; Manifest = (& $mutate { param($m) $m['combinations'][1]['id'] = 'reference-1.0.0' }); Pass = $false }
        @{ Name = 'reviewed integration without AsiBackbone'; Manifest = (& $mutate { param($m) $m['combinations'][0]['components']['asiBackbone'] = $null }); Pass = $false }
        @{ Name = 'integration entry listing Learning'; Manifest = (& $mutate { param($m) $m['combinations'][0]['components']['learning'] = @('1.0.0') }); Pass = $false }
        @{ Name = 'learning review listing a Reference Application release'; Manifest = (& $mutate { param($m) $m['combinations'][1]['components']['referenceApplication'] = @('2.0.0') }); Pass = $false }
        @{ Name = 'Reference Application release in two entries'; Manifest = (& $mutate { param($m) $m['combinations'][1]['kind'] = 'integration'; $m['combinations'][1]['components']['learning'] = @(); $m['combinations'][1]['components']['netCoreApplicationTemplate'] = '2.11.4'; $m['combinations'][1]['components']['referenceApplication'] = @('1.0.0') }); Pass = $false }
        @{ Name = 'no current integration'; Manifest = (& $mutate { param($m) $m['combinations'][0]['status'] = 'historical' }); Pass = $false }
        @{ Name = 'invalid reviewed date'; Manifest = (& $mutate { param($m) $m['combinations'][0]['reviewed'] = '2026-13-01' }); Pass = $false }
        @{ Name = 'reviewed after updated'; Manifest = (& $mutate { param($m) $m['combinations'][0]['reviewed'] = '2026-10-24' }); Pass = $false }
        @{ Name = 'missing evidence'; Manifest = (& $mutate { param($m) $m['combinations'][0]['evidence'] = @() }); Pass = $false }
        @{ Name = 'evidence outside the ecosystem'; Manifest = (& $mutate { param($m) $m['combinations'][0]['evidence'][0]['repository'] = 'example/other' }); Pass = $false }
        @{ Name = 'evidence path escaping the repository'; Manifest = (& $mutate { param($m) $m['combinations'][0]['evidence'][0]['path'] = '../secrets.txt' }); Pass = $false }
        @{ Name = 'evidence with a branch instead of a tag'; Manifest = (& $mutate { param($m) $m['combinations'][0]['evidence'][0]['tag'] = 'main' }); Pass = $false }
        @{ Name = 'missing support line'; Manifest = (& $mutate { param($m) $m['supportLines'] = @($m['supportLines'] | Select-Object -First 3) }); Pass = $false }
        @{ Name = 'malformed target framework'; Manifest = (& $mutate { param($m) $m['combinations'][0]['targetFramework'] = '.NET 10' }); Pass = $false }
        @{ Name = 'unknown component'; Manifest = (& $mutate { param($m) $m['combinations'][0]['components']['other'] = '1.0.0' }); Pass = $false }
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

    $rendered = ConvertTo-MatrixMarkdown (& $clone)
    if ($rendered -ne (ConvertTo-MatrixMarkdown (& $clone))) {
        $failures.Add('Rendering is not deterministic.')
    }
    foreach ($expected in @(
        '## Current integration'
        '## Learning review baselines'
        '## Supported lines'
        '## Historical combinations'
        'not known to be broken'
        'not a certification'
        'not a package dependency'
        '[7.5.0](https://github.com/AsiBackbone/AsiBackbone/releases/tag/v7.5.0)'
        '[ReferenceApplication@v1.0.0 CHANGELOG.md](https://github.com/AsiBackbone/ReferenceApplication/blob/v1.0.0/CHANGELOG.md)'
    )) {
        if (-not $rendered.Contains($expected, [StringComparison]::Ordinal)) {
            $failures.Add("Rendered matrix is missing: $expected")
        }
    }
    $historicalIndex = $rendered.IndexOf('## Historical combinations', [StringComparison]::Ordinal)
    if ($rendered.IndexOf('Earlier review.', [StringComparison]::Ordinal) -lt $historicalIndex) {
        $failures.Add('A historical entry was rendered outside the Historical combinations section.')
    }
    $piped = & $mutate { param($m) $m['combinations'][0]['notes'] = 'a | b' }
    if (-not (ConvertTo-MatrixMarkdown $piped).Contains('a \| b', [StringComparison]::Ordinal)) {
        $failures.Add('Pipes in notes are not escaped in rendered tables.')
    }

    $existingTags = @('AsiBackbone/NetCoreApplicationTemplate@v2.11.5', 'AsiBackbone/AsiBackbone@v7.5.0', 'AsiBackbone/AsiBackbone@v7.0.0', 'AsiBackbone/ReferenceApplication@v1.0.0', 'AsiBackbone/Learning@v1.0.0', 'AsiBackbone/NetCoreApplicationTemplate@v1.0.0', 'AsiBackbone/AsiBackbone@v1.0.0')
    $tagExists = { param($Repository, $Tag) $existingTags -contains "$Repository@$Tag" }
    $fileExists = { param($Repository, $Tag, $Path) "$Repository@${Tag}:$Path" -eq 'AsiBackbone/ReferenceApplication@v1.0.0:CHANGELOG.md' }
    $referenceCases = @(
        @{ Name = 'all references exist'; Manifest = (& $clone); Releases = @('v1.0.0', 'ncat-v2.11.5'); Pass = $true }
        @{ Name = 'nonexistent component tag'; Manifest = (& $mutate { param($m) $m['combinations'][0]['components']['asiBackbone'] = '7.9.0' }); Releases = @('v1.0.0'); Pass = $false }
        @{ Name = 'nonexistent evidence file'; Manifest = (& $mutate { param($m) $m['combinations'][0]['evidence'][0]['path'] = 'MISSING.md' }); Releases = @('v1.0.0'); Pass = $false }
        @{ Name = 'unrecorded Reference Application release'; Manifest = (& $clone); Releases = @('v1.0.0', 'v1.1.0'); Pass = $false }
        @{ Name = 'tag list returned as one array object'; Manifest = (& $clone); Releases = @('v1.0.0', 'ncat-v2.11.5'); Wrapped = $true; Pass = $true }
    )
    foreach ($case in $referenceCases) {
        $caseErrors = [System.Collections.Generic.List[string]]::new()
        $releases = [string[]]$case.Releases
        $listTags = if ($case.ContainsKey('Wrapped')) { { param($Repository) , $releases }.GetNewClosure() } else { { param($Repository) $releases }.GetNewClosure() }
        $null = Test-References -Manifest $case.Manifest -Errors $caseErrors -TagExists $tagExists -FileExists $fileExists -ListTags $listTags
        if (($caseErrors.Count -eq 0) -ne $case.Pass) {
            $expected = if ($case.Pass) { 'success' } else { 'failure' }
            $failures.Add("Self-test '$($case.Name)' expected $expected but got $($caseErrors.Count) error(s): $($caseErrors -join ' ')")
        }
    }

    # Drive the real GitHub request, tag-listing, and lookup functions against an offline responder that answers
    # the way the GitHub REST API does: 404 for a missing ref or file, and a JSON array for the tag listing.
    $httpCases = @(
        @{ Name = 'GitHub API: all references exist'; Tags = @('v1.0.0', 'ncat-v2.11.5', 'ncat-v2.11.4'); Pass = $true }
        @{ Name = 'GitHub API: unrecorded Reference Application release'; Tags = @('v1.0.0', 'v1.1.0'); Pass = $false }
    )
    foreach ($case in $httpCases) {
        $listed = $case.Tags
        $script:GitHubResponder = {
            param($Uri)
            $ok = { param($Content) [pscustomobject]@{ StatusCode = 200; Content = $Content } }
            if ($Uri -match '/repos/(?<repo>[^/]+/[^/]+)/git/ref/tags/(?<tag>[^/?]+)$') {
                if ($existingTags -contains "$($Matches.repo)@$([uri]::UnescapeDataString($Matches.tag))") { return & $ok '{}' }
                return $null
            }
            if ($Uri -match '/repos/(?<repo>[^/]+/[^/]+)/contents/(?<path>[^?]+)\?ref=(?<tag>.+)$') {
                if (& $fileExists $Matches.repo ([uri]::UnescapeDataString($Matches.tag)) ([uri]::UnescapeDataString($Matches.path))) { return & $ok '{}' }
                return $null
            }
            if ($Uri -match '/repos/AsiBackbone/ReferenceApplication/tags\?') {
                return & $ok (ConvertTo-Json -InputObject @($listed | ForEach-Object { @{ name = $_ } }) -Depth 3)
            }
            throw "Unexpected request: $Uri"
        }.GetNewClosure()

        $caseErrors = [System.Collections.Generic.List[string]]::new()
        try {
            $null = Test-References -Manifest (& $clone) -Errors $caseErrors
        }
        finally {
            $script:GitHubResponder = $null
        }
        if (($caseErrors.Count -eq 0) -ne $case.Pass) {
            $expected = if ($case.Pass) { 'success' } else { 'failure' }
            $failures.Add("Self-test '$($case.Name)' expected $expected but got $($caseErrors.Count) error(s): $($caseErrors -join ' ')")
        }
        elseif (-not $case.Pass -and ($caseErrors -join ' ') -notmatch 'release v1\.1\.0 is not recorded') {
            $failures.Add("Self-test '$($case.Name)' reported the wrong finding: $($caseErrors -join ' ')")
        }
    }

    if ($failures.Count -gt 0) {
        $failures | ForEach-Object { Write-Error $_ -ErrorAction Continue }
        exit 1
    }

    Write-Host 'Compatibility matrix validator self-test passed.'
}

if ($MyInvocation.InvocationName -eq '.') {
    return
}

if ($SelfTest) {
    Invoke-SelfTest
    exit 0
}

$manifestPath = Join-Path $RepositoryRoot $manifestRelativePath
$matrixPath = Join-Path $RepositoryRoot $matrixRelativePath
$errors = [System.Collections.Generic.List[string]]::new()

try {
    $manifest = Read-Manifest -Path $manifestPath
}
catch {
    Write-Error "$manifestRelativePath could not be read: $($_.Exception.Message)" -ErrorAction Continue
    exit 1
}

Test-Manifest -Manifest $manifest -Errors $errors
if ($errors.Count -gt 0) {
    $errors | ForEach-Object { Write-Error $_ -ErrorAction Continue }
    exit 1
}

$rendered = ConvertTo-MatrixMarkdown $manifest
if ($Update) {
    [System.IO.File]::WriteAllText($matrixPath, $rendered, [System.Text.UTF8Encoding]::new($false))
    Write-Host "Regenerated $matrixRelativePath."
}
else {
    $committed = if (Test-Path -LiteralPath $matrixPath -PathType Leaf) { (Get-Content -LiteralPath $matrixPath -Raw).Replace("`r`n", "`n") } else { '' }
    if ($committed -ne $rendered) {
        Write-Error "$matrixRelativePath does not match $manifestRelativePath. Run ./scripts/Test-CompatibilityMatrix.ps1 -Update and commit the result." -ErrorAction Continue
        exit 1
    }
}

if ($VerifyReferences) {
    $checked = 0
    try {
        $checked = Test-References -Manifest $manifest -Errors $errors
    }
    catch {
        $errors.Add("References could not be verified: $($_.Exception.Message)")
    }

    if ($env:GITHUB_STEP_SUMMARY) {
        $summary = @('## Compatibility matrix references', '')
        if ($errors.Count -eq 0) {
            $summary += "All $checked referenced tags and evidence files exist, and every Reference Application release is recorded."
        }
        else {
            $summary += @('| Finding |', '| --- |') + @($errors | ForEach-Object { "| $($_.Replace('|', '\|')) |" })
        }
        $summary | Add-Content -LiteralPath $env:GITHUB_STEP_SUMMARY -Encoding utf8
    }

    if ($errors.Count -gt 0) {
        $errors | ForEach-Object { Write-Error $_ -ErrorAction Continue }
        exit 1
    }

    Write-Host "Verified $checked referenced tags and evidence files; every Reference Application release is recorded."
}

Write-Host 'Compatibility manifest is valid and the rendered matrix is current.'
