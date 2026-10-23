[CmdletBinding()]
param(
    [string]$RepositoryRoot = (Split-Path -Parent $PSScriptRoot),

    # Regenerates assurance/README.md from the manifest instead of checking it.
    [switch]$Update,

    # Also checks that every linked enforcement point, test, and document exists at its resolved ref on GitHub.
    # Requires network access; set GITHUB_TOKEN to raise the API rate limit.
    [switch]$VerifyReferences,

    [ValidateRange(1, 5)]
    [int]$MaximumAttempts = 3,

    [switch]$SelfTest
)

# Validates the security assurance and control-ownership map (assurance/control-ownership.json), renders the
# human-readable map (assurance/README.md) from it, and fails when the committed map differs from the rendering
# (AsiBackbone/.github#26). Product links resolve to the release tags of the current integration-reviewed combination
# in compatibility/ecosystem-compatibility.json; repository-host links resolve to main. The default mode is offline and
# deterministic. -VerifyReferences reads public GitHub files only and never writes to any repository.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$manifestRelativePath = 'assurance/control-ownership.json'
$mapRelativePath = 'assurance/README.md'
$compatibilityRelativePath = 'compatibility/ecosystem-compatibility.json'

# Product repositories whose links resolve to the reviewed baseline tag, keyed by their compatibility-matrix component.
$baselineRepositories = [ordered]@{
    asiBackbone = 'AsiBackbone/AsiBackbone'
    netCoreApplicationTemplate = 'AsiBackbone/NetCoreApplicationTemplate'
    referenceApplication = 'AsiBackbone/ReferenceApplication'
}
$organizationRepository = 'AsiBackbone/.github'
$knownRepositories = @($baselineRepositories.Values) + $organizationRepository

$owners = [ordered]@{
    asibackbone = [pscustomobject]@{ Label = 'AsiBackbone'; Meaning = 'The AsiBackbone package family. Owns governance primitives and their fail-closed defaults.' }
    ncat = [pscustomobject]@{ Label = '.NET Core Application Template'; Meaning = 'The template and the baseline it generates. Owns host defaults that a generated application inherits.' }
    'reference-application' = [pscustomobject]@{ Label = 'Reference Application'; Meaning = 'The example host. Owns controls it adds while integrating AsiBackbone; it is an example, not a product.' }
    organization = [pscustomobject]@{ Label = 'Organization (.github)'; Meaning = 'This repository. Owns organization defaults, standards, and this map.' }
    host = [pscustomobject]@{ Label = 'Deploying host and operator'; Meaning = 'Whoever builds and runs an application. Owns controls no library or template can supply.' }
}

# Canonical scope order follows AsiBackbone/.github#26.
$scopes = [ordered]@{
    'authentication-authorization' = 'Authentication and endpoint authorization'
    'policy-evaluation' = 'Policy evaluation and decision before execution'
    'acknowledgment' = 'Acknowledgment and handshake'
    'capability-grants' = 'Capability grants and replay protection'
    'evidence-persistence' = 'Decision and evidence persistence'
    'outbox-reconciliation' = 'Outbox and reconciliation'
    'signing-verification' = 'Signing and verification'
    'key-custody' = 'Key custody'
    'data-protection' = 'Data Protection'
    'proxy-tls' = 'Proxy and TLS trust'
    'rate-limiting' = 'Rate limiting'
    'health-readiness' = 'Health and readiness exposure'
    'migrations-providers' = 'Database migrations and provider support'
    'development-isolation' = 'Development-only feature isolation'
    'release-provenance' = 'Release, provenance, and SBOM evidence'
    'repository-host' = 'Repository-host rulesets and security scanning'
}

$failureModes = [ordered]@{
    'fail-closed' = [pscustomobject]@{ Label = 'Fails closed'; Meaning = 'A failed or missing check blocks the operation, the request, or startup.' }
    'defer' = [pscustomobject]@{ Label = 'Defers'; Meaning = 'Work is kept and retried or held for review instead of being lost or blocking the business operation.' }
    'warn' = [pscustomobject]@{ Label = 'Warns'; Meaning = 'Unsafe postures are reported, and some invalid settings stop startup, but common deployment gaps only warn.' }
    'host-defined' = [pscustomobject]@{ Label = 'Host-defined'; Meaning = 'The component reports the result; the host decides what it blocks.' }
    'fail-open' = [pscustomobject]@{ Label = 'Fails open'; Meaning = 'A failed check lets the operation continue. Recorded so the choice stays visible.' }
}

$idPattern = '^[a-z0-9][a-z0-9-]*$'
$semVerPattern = '^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(-[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*)?$'

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

function Test-IsoDate {
    param($Value)

    if ($Value -isnot [string] -or $Value -notmatch '^\d{4}-\d{2}-\d{2}$') {
        return $false
    }

    $parsed = [datetime]::MinValue
    return [datetime]::TryParseExact($Value, 'yyyy-MM-dd', [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::None, [ref]$parsed)
}

function Resolve-LinkRef {
    param([string]$Repository, [string]$Scope, $Baselines)

    if ($Repository -eq $organizationRepository -or $Scope -eq 'repository-host') {
        return 'main'
    }

    foreach ($entry in $baselineRepositories.GetEnumerator()) {
        if ($entry.Value -eq $Repository) {
            $version = Get-Value $Baselines $entry.Key
            if (Test-NonEmptyString $version) {
                return "v$version"
            }
        }
    }

    return $null
}

function Test-Link {
    param($Link, [string]$Scope, $Baselines, [string]$Source, [System.Collections.Generic.List[string]]$Errors)

    $repository = Get-Value $Link 'repository'
    $path = Get-Value $Link 'path'
    if ($knownRepositories -notcontains $repository) {
        $Errors.Add("$Source links to an unknown repository: '$repository'.")
        return
    }
    if (-not (Test-NonEmptyString $path) -or $path.StartsWith('/') -or $path -match '(^|/)\.\.(/|$)' -or $path -match '[\s?#]') {
        $Errors.Add("$Source must link to a repository-relative file path: '$path'.")
    }
    if ($null -eq (Resolve-LinkRef -Repository $repository -Scope $Scope -Baselines $Baselines)) {
        $Errors.Add("$Source links to $repository, which has no reviewed baseline to pin to.")
    }
}

function Get-CurrentIntegrations {
    param($Compatibility)

    foreach ($combination in @(Get-Items (Get-Value $Compatibility 'combinations'))) {
        if ((Get-Value $combination 'kind') -eq 'integration' -and (Get-Value $combination 'status') -eq 'reviewed') {
            $components = Get-Value $combination 'components'
            foreach ($release in @(Get-Items (Get-Value $components 'referenceApplication'))) {
                [pscustomobject]@{
                    netCoreApplicationTemplate = Get-Value $components 'netCoreApplicationTemplate'
                    asiBackbone = Get-Value $components 'asiBackbone'
                    referenceApplication = $release
                }
            }
        }
    }
}

function Test-Manifest {
    param($Manifest, $Compatibility, [System.Collections.Generic.List[string]]$Errors)

    if ($Manifest -isnot [System.Collections.IDictionary]) {
        $Errors.Add('The manifest must be a JSON object.')
        return
    }

    if ((Get-Value $Manifest 'schemaVersion') -ne 1) {
        $Errors.Add('schemaVersion must be 1.')
    }
    $reviewed = Get-Value $Manifest 'reviewed'
    if (-not (Test-IsoDate $reviewed)) {
        $Errors.Add("reviewed must be a yyyy-MM-dd date: '$reviewed'.")
    }

    $baselines = Get-Value $Manifest 'baselines'
    foreach ($component in $baselineRepositories.Keys) {
        $version = Get-Value $baselines $component
        if (-not (Test-NonEmptyString $version) -or $version -notmatch $semVerPattern) {
            $Errors.Add("baselines.$component must be a semantic version: '$version'.")
        }
    }

    $current = @(Get-CurrentIntegrations $Compatibility)
    if ($current.Count -eq 0) {
        $Errors.Add("$compatibilityRelativePath has no current integration-reviewed combination to review against.")
    }
    else {
        $matched = @($current | Where-Object {
                $_.netCoreApplicationTemplate -eq (Get-Value $baselines 'netCoreApplicationTemplate') -and
                $_.asiBackbone -eq (Get-Value $baselines 'asiBackbone') -and
                $_.referenceApplication -eq (Get-Value $baselines 'referenceApplication')
            })
        if ($matched.Count -eq 0) {
            $expected = ($current | ForEach-Object { "NCAT $($_.netCoreApplicationTemplate), AsiBackbone $($_.asiBackbone), Reference Application $($_.referenceApplication)" }) -join '; '
            $Errors.Add("baselines must match the current integration-reviewed combination in ${compatibilityRelativePath} ($expected). Review the map against it and update the baselines.")
        }
    }

    $controls = @(Get-Items (Get-Value $Manifest 'controls'))
    if ($controls.Count -eq 0) {
        $Errors.Add('controls must list at least one control.')
    }

    $ids = [System.Collections.Generic.HashSet[string]]::new()
    $coveredScopes = [System.Collections.Generic.HashSet[string]]::new()
    foreach ($control in $controls) {
        $id = Get-Value $control 'id'
        $source = "controls[$id]"
        if (-not (Test-NonEmptyString $id) -or $id -notmatch $idPattern) {
            $Errors.Add("Control id must be lowercase letters, digits, and hyphens: '$id'.")
        }
        elseif (-not $ids.Add($id)) {
            $Errors.Add("Control id '$id' is used more than once.")
        }

        $scope = Get-Value $control 'scope'
        if (-not $scopes.Contains([string]$scope)) {
            $Errors.Add("$source.scope must be one of $($scopes.Keys -join ', '): '$scope'.")
        }
        else {
            $null = $coveredScopes.Add($scope)
        }

        $owner = Get-Value $control 'owner'
        if (-not $owners.Contains([string]$owner)) {
            $Errors.Add("$source.owner must name exactly one of $($owners.Keys -join ', '): '$owner'.")
        }

        foreach ($field in @('title', 'invariant', 'operationalDependency', 'hostResponsibility', 'nonClaims')) {
            if (-not (Test-NonEmptyString (Get-Value $control $field))) {
                $Errors.Add("$source.$field is required.")
            }
        }

        $enforcement = Get-Value $control 'enforcement'
        if (-not (Test-NonEmptyString (Get-Value $enforcement 'description'))) {
            $Errors.Add("$source.enforcement.description is required.")
        }
        $enforcementLink = Get-Value $enforcement 'link'
        if ($null -eq $enforcementLink) {
            $Errors.Add("$source.enforcement.link is required; name the enforcement point.")
        }
        else {
            Test-Link -Link $enforcementLink -Scope $scope -Baselines $baselines -Source "$source.enforcement" -Errors $Errors
        }

        $evidence = Get-Value $control 'evidence'
        if ($null -ne $evidence -and $evidence -isnot [array]) {
            $Errors.Add("$source.evidence must be an array.")
            $evidence = @()
        }
        $evidenceItems = @(Get-Items $evidence)
        $gap = Get-Value $control 'evidenceGap'
        if ($null -ne $gap -and -not (Test-NonEmptyString $gap)) {
            $Errors.Add("$source.evidenceGap must be null or describe the missing evidence.")
        }
        if ($evidenceItems.Count -eq 0 -and -not (Test-NonEmptyString $gap)) {
            $Errors.Add("$source has no linked evidence; record an evidenceGap instead of leaving it implied.")
        }
        foreach ($item in $evidenceItems) {
            Test-Link -Link $item -Scope $scope -Baselines $baselines -Source "$source.evidence" -Errors $Errors
        }

        $documentation = @(Get-Items (Get-Value $control 'documentation'))
        if ($documentation.Count -eq 0) {
            $Errors.Add("$source must link to canonical repository documentation.")
        }
        foreach ($item in $documentation) {
            Test-Link -Link $item -Scope $scope -Baselines $baselines -Source "$source.documentation" -Errors $Errors
        }

        $failure = Get-Value $control 'failure'
        $mode = Get-Value $failure 'mode'
        if (-not $failureModes.Contains([string]$mode)) {
            $Errors.Add("$source.failure.mode must be one of $($failureModes.Keys -join ', '): '$mode'.")
        }
        if (-not (Test-NonEmptyString (Get-Value $failure 'detail'))) {
            $Errors.Add("$source.failure.detail is required.")
        }
    }

    foreach ($scope in $scopes.Keys) {
        if (-not $coveredScopes.Contains($scope)) {
            $Errors.Add("No control covers the '$scope' scope.")
        }
    }
}

function Get-LinkUrl {
    param($Link, [string]$Scope, $Baselines)

    $repository = $Link['repository']
    $ref = Resolve-LinkRef -Repository $repository -Scope $Scope -Baselines $Baselines
    return "https://github.com/$repository/blob/$ref/$($Link['path'])"
}

function Format-Link {
    param($Link, [string]$Scope, $Baselines)

    $repository = $Link['repository'] -replace '^AsiBackbone/', ''
    return "[$repository ``$($Link['path'])``]($(Get-LinkUrl -Link $Link -Scope $Scope -Baselines $Baselines))"
}

function Format-Text {
    param([string]$Value)

    return $Value.Replace('|', '\|').Replace("`r", '').Replace("`n", ' ')
}

function ConvertTo-AssuranceMarkdown {
    param($Manifest)

    $baselines = $Manifest['baselines']
    $controls = @($Manifest['controls'] | Sort-Object -Stable { @($scopes.Keys).IndexOf($_['scope']) })
    $lines = [System.Collections.Generic.List[string]]::new()

    $lines.Add('# AsiBackbone Security Assurance and Control-Ownership Map')
    $lines.Add('')
    $lines.Add('<!-- Generated from control-ownership.json by scripts/Test-AssuranceMap.ps1 -Update. Do not edit by hand. -->')
    $lines.Add('')
    $lines.Add('This map records, for each important security and governance control in the AsiBackbone ecosystem, who owns it, where it is enforced, how it is tested, what it depends on, how it fails, what the deploying host still owns, and what it does not claim. It maps responsibility; the technical contracts stay in the linked repository documentation, which is authoritative.')
    $lines.Add('')
    $lines.Add('> **Boundary:** This is an assurance and ownership map, not a compliance matrix or a certification claim. A linked test shows that a behavior is exercised, not that a deployment is secure. Where evidence is missing, the map says so rather than assuming it.')
    $lines.Add('')
    $lines.Add("Reviewed $($Manifest['reviewed']) against [.NET Core Application Template $($baselines['netCoreApplicationTemplate'])](https://github.com/AsiBackbone/NetCoreApplicationTemplate/releases/tag/v$($baselines['netCoreApplicationTemplate'])), [AsiBackbone $($baselines['asiBackbone'])](https://github.com/AsiBackbone/AsiBackbone/releases/tag/v$($baselines['asiBackbone'])), and [Reference Application $($baselines['referenceApplication'])](https://github.com/AsiBackbone/ReferenceApplication/releases/tag/v$($baselines['referenceApplication'])), the current integration-reviewed combination in the [ecosystem compatibility matrix](../compatibility/README.md). Product links are pinned to those release tags. Repository-host links point to each repository's ``main`` branch, because those settings are not versioned with releases. Learning is educational material and owns no runtime control, so it has no rows. The machine-readable source is [``control-ownership.json``](control-ownership.json).")
    $lines.Add('')

    $lines.Add('## Owners')
    $lines.Add('')
    $lines.Add('| Owner | Responsibility |')
    $lines.Add('| --- | --- |')
    foreach ($owner in $owners.GetEnumerator()) {
        $lines.Add("| $($owner.Value.Label) | $($owner.Value.Meaning) |")
    }
    $lines.Add('')

    $lines.Add('## Failure modes')
    $lines.Add('')
    $lines.Add('| Mode | Meaning |')
    $lines.Add('| --- | --- |')
    foreach ($mode in $failureModes.GetEnumerator()) {
        $lines.Add("| $($mode.Value.Label) | $($mode.Value.Meaning) |")
    }
    $lines.Add('')

    $lines.Add('## Summary')
    $lines.Add('')
    $lines.Add('| Control | Scope | Owner | Failure mode | Evidence |')
    $lines.Add('| --- | --- | --- | --- | --- |')
    foreach ($control in $controls) {
        $evidenceCount = @(Get-Items $control['evidence']).Count
        $evidenceText = if ($control['evidenceGap']) { "$evidenceCount linked, gap recorded" } else { "$evidenceCount linked" }
        $lines.Add("| [$(Format-Text $control['title'])](#$($control['id'])) | $($scopes[$control['scope']]) | $($owners[$control['owner']].Label) | $($failureModes[$control['failure']['mode']].Label) | $evidenceText |")
    }
    $lines.Add('')

    $lines.Add('## Controls')
    foreach ($scope in $scopes.GetEnumerator()) {
        $scoped = @($controls | Where-Object { $_['scope'] -eq $scope.Key })
        if ($scoped.Count -eq 0) {
            continue
        }

        $lines.Add('')
        $lines.Add("### $($scope.Value)")
        foreach ($control in $scoped) {
            $lines.Add('')
            $lines.Add("<a id=""$($control['id'])""></a>")
            $lines.Add('')
            $lines.Add("#### $(Format-Text $control['title'])")
            $lines.Add('')
            $lines.Add("$(Format-Text $control['invariant'])")
            $lines.Add('')
            $lines.Add("- **Owner:** $($owners[$control['owner']].Label)")
            $lines.Add("- **Enforcement point:** $(Format-Text $control['enforcement']['description']) — $(Format-Link -Link $control['enforcement']['link'] -Scope $scope.Key -Baselines $baselines)")
            $evidence = @(Get-Items $control['evidence'])
            if ($evidence.Count -gt 0) {
                $lines.Add("- **Tests and evidence:** $((@($evidence | ForEach-Object { Format-Link -Link $_ -Scope $scope.Key -Baselines $baselines })) -join ', ')")
            }
            if ($control['evidenceGap']) {
                $lines.Add("- **Evidence gap:** $(Format-Text $control['evidenceGap'])")
            }
            $lines.Add("- **Operational dependency:** $(Format-Text $control['operationalDependency'])")
            $lines.Add("- **Failure behavior:** $($failureModes[$control['failure']['mode']].Label). $(Format-Text $control['failure']['detail'])")
            $lines.Add("- **Host and operator responsibility:** $(Format-Text $control['hostResponsibility'])")
            $lines.Add("- **Residual risk and non-claims:** $(Format-Text $control['nonClaims'])")
            $lines.Add("- **Canonical documentation:** $((@(Get-Items $control['documentation'] | ForEach-Object { Format-Link -Link $_ -Scope $scope.Key -Baselines $baselines })) -join ', ')")
        }
    }
    $lines.Add('')

    $lines.Add('## Review cadence')
    $lines.Add('')
    $lines.Add('Review this map, and update the `reviewed` date, whenever:')
    $lines.Add('')
    $lines.Add('- the current integration-reviewed combination in the compatibility matrix changes. The `Validate organization profile` check fails until the map''s baselines match it, so a new Reference Application release forces a review;')
    $lines.Add('- AsiBackbone or the .NET Core Application Template publishes a major release;')
    $lines.Add('- an architecture change adds, removes, or moves the enforcement point of a mapped control, or changes its failure behavior; or')
    $lines.Add('- a security incident or review finding shows a row is wrong or incomplete.')
    $lines.Add('')
    $lines.Add('The weekly `Assurance map validation` workflow checks that every linked file still exists at its resolved ref, so a moved or deleted enforcement point, test, or document surfaces as a finding.')
    $lines.Add('')

    $lines.Add('## Updating the map')
    $lines.Add('')
    $lines.Add('1. Edit [`control-ownership.json`](control-ownership.json). Give each control exactly one owner and enforcement point, link tests and canonical documentation by repository and path, and record an `evidenceGap` wherever evidence is missing or partial.')
    $lines.Add('2. Run `./scripts/Test-AssuranceMap.ps1 -Update` to regenerate this page, then `./scripts/Test-AssuranceMap.ps1 -VerifyReferences` to confirm every link resolves.')
    $lines.Add('3. Open a pull request. The `Validate organization profile` check fails when the manifest is malformed, a scope is uncovered, the baselines do not match the compatibility matrix, or this page does not match the manifest.')

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
        'User-Agent' = 'AsiBackbone-assurance-map-validation'
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

function Test-GitHubFile {
    param([string]$Repository, [string]$Ref, [string]$Path)

    $escapedPath = (($Path -split '/') | ForEach-Object { [uri]::EscapeDataString($_) }) -join '/'
    return $null -ne (Invoke-GitHubRequest -Uri "https://api.github.com/repos/$Repository/contents/${escapedPath}?ref=$([uri]::EscapeDataString($Ref))")
}

function Test-References {
    param($Manifest, [System.Collections.Generic.List[string]]$Errors)

    $baselines = $Manifest['baselines']
    $files = [ordered]@{}
    foreach ($control in @($Manifest['controls'])) {
        $scope = $control['scope']
        $links = @($control['enforcement']['link']) + @(Get-Items $control['evidence']) + @(Get-Items $control['documentation'])
        foreach ($link in $links) {
            $ref = Resolve-LinkRef -Repository $link['repository'] -Scope $scope -Baselines $baselines
            $key = "$($link['repository'])@${ref}:$($link['path'])"
            if (-not $files.Contains($key)) {
                $files[$key] = [pscustomobject]@{ Repository = $link['repository']; Ref = $ref; Path = $link['path']; Source = "controls[$($control['id'])]" }
            }
        }
    }

    foreach ($file in $files.Values) {
        if (-not (Test-GitHubFile -Repository $file.Repository -Ref $file.Ref -Path $file.Path)) {
            $Errors.Add("$($file.Source) links to $($file.Path) at $($file.Repository) $($file.Ref), which does not exist.")
        }
    }

    return $files.Count
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
    $valid = [ordered]@{
        schemaVersion = 1
        reviewed = '2026-10-23'
        baselines = [ordered]@{ netCoreApplicationTemplate = '2.11.5'; asiBackbone = '7.5.0'; referenceApplication = '0.1.0-alpha.11' }
        controls = @(
            foreach ($scope in $scopes.Keys) {
                $repository = if ($scope -eq 'repository-host') { 'AsiBackbone/.github' } else { 'AsiBackbone/AsiBackbone' }
                [ordered]@{
                    id = "control-$scope"; scope = $scope; title = "Control for $scope"; invariant = 'Holds.'; owner = 'asibackbone'
                    enforcement = [ordered]@{ description = 'Enforced here.'; link = (& $link $repository 'src/Enforce.cs') }
                    evidence = @((& $link $repository 'tests/EnforceTests.cs'))
                    evidenceGap = $null
                    documentation = @((& $link $repository 'docs/control.md'))
                    operationalDependency = 'None.'; failure = [ordered]@{ mode = 'fail-closed'; detail = 'Blocks.' }
                    hostResponsibility = 'Configure it.'; nonClaims = 'Claims nothing more.'
                }
            }
        )
    }
    $compatibility = [ordered]@{
        combinations = @(
            [ordered]@{ kind = 'integration'; status = 'reviewed'; components = [ordered]@{ netCoreApplicationTemplate = '2.11.5'; asiBackbone = '7.5.0'; referenceApplication = @('0.1.0-alpha.11'); learning = @() } }
            [ordered]@{ kind = 'integration'; status = 'historical'; components = [ordered]@{ netCoreApplicationTemplate = '2.11.5'; asiBackbone = '7.2.1'; referenceApplication = @('0.1.0-alpha.10'); learning = @() } }
        )
    }

    $clone = { ($valid | ConvertTo-Json -Depth 20 | ConvertFrom-Json -AsHashtable -Depth 20) }
    $mutate = {
        param([scriptblock]$Change)
        $copy = & $clone
        & $Change $copy
        return $copy
    }
    $compatibilityCopy = { ($compatibility | ConvertTo-Json -Depth 20 | ConvertFrom-Json -AsHashtable -Depth 20) }

    $cases = @(
        @{ Name = 'valid manifest'; Manifest = (& $clone); Pass = $true }
        @{ Name = 'unknown owner'; Manifest = (& $mutate { param($m) $m['controls'][0]['owner'] = 'everyone' }); Pass = $false }
        @{ Name = 'missing enforcement point'; Manifest = (& $mutate { param($m) $m['controls'][0]['enforcement'].Remove('link') }); Pass = $false }
        @{ Name = 'missing evidence without a gap'; Manifest = (& $mutate { param($m) $m['controls'][0]['evidence'] = @() }); Pass = $false }
        @{ Name = 'missing evidence with a recorded gap'; Manifest = (& $mutate { param($m) $m['controls'][0]['evidence'] = @(); $m['controls'][0]['evidenceGap'] = 'No test exists yet.' }); Pass = $true }
        @{ Name = 'blank evidence gap'; Manifest = (& $mutate { param($m) $m['controls'][0]['evidenceGap'] = ' ' }); Pass = $false }
        @{ Name = 'unknown failure mode'; Manifest = (& $mutate { param($m) $m['controls'][0]['failure']['mode'] = 'mostly-safe' }); Pass = $false }
        @{ Name = 'missing non-claims'; Manifest = (& $mutate { param($m) $m['controls'][0]['nonClaims'] = '' }); Pass = $false }
        @{ Name = 'missing host responsibility'; Manifest = (& $mutate { param($m) $m['controls'][0]['hostResponsibility'] = $null }); Pass = $false }
        @{ Name = 'no canonical documentation'; Manifest = (& $mutate { param($m) $m['controls'][0]['documentation'] = @() }); Pass = $false }
        @{ Name = 'uncovered scope'; Manifest = (& $mutate { param($m) $m['controls'] = @($m['controls'] | Where-Object { $_['scope'] -ne 'key-custody' }) }); Pass = $false }
        @{ Name = 'duplicate id'; Manifest = (& $mutate { param($m) $m['controls'][1]['id'] = $m['controls'][0]['id'] }); Pass = $false }
        @{ Name = 'link outside the ecosystem'; Manifest = (& $mutate { param($m) $m['controls'][0]['evidence'][0]['repository'] = 'example/other' }); Pass = $false }
        @{ Name = 'link escaping the repository'; Manifest = (& $mutate { param($m) $m['controls'][0]['documentation'][0]['path'] = '../secret.md' }); Pass = $false }
        @{ Name = 'baseline behind the compatibility matrix'; Manifest = (& $mutate { param($m) $m['baselines']['asiBackbone'] = '7.2.1' }); Pass = $false }
        @{ Name = 'malformed baseline'; Manifest = (& $mutate { param($m) $m['baselines']['referenceApplication'] = 'alpha' }); Pass = $false }
    )

    $failures = [System.Collections.Generic.List[string]]::new()
    foreach ($case in $cases) {
        $caseErrors = [System.Collections.Generic.List[string]]::new()
        Test-Manifest -Manifest $case.Manifest -Compatibility (& $compatibilityCopy) -Errors $caseErrors
        if (($caseErrors.Count -eq 0) -ne $case.Pass) {
            $expected = if ($case.Pass) { 'success' } else { 'failure' }
            $failures.Add("Self-test '$($case.Name)' expected $expected but got $($caseErrors.Count) error(s): $($caseErrors -join ' ')")
        }
    }

    $noCurrent = & $compatibilityCopy
    $noCurrent['combinations'][0]['status'] = 'historical'
    $caseErrors = [System.Collections.Generic.List[string]]::new()
    Test-Manifest -Manifest (& $clone) -Compatibility $noCurrent -Errors $caseErrors
    if ($caseErrors.Count -eq 0) {
        $failures.Add("Self-test 'no current compatibility combination' expected failure but got success.")
    }

    $rendered = ConvertTo-AssuranceMarkdown (& $clone)
    if ($rendered -ne (ConvertTo-AssuranceMarkdown (& $clone))) {
        $failures.Add('Rendering is not deterministic.')
    }
    foreach ($expected in @(
        'not a compliance matrix or a certification claim'
        '## Review cadence'
        '<a id="control-key-custody"></a>'
        '[AsiBackbone `src/Enforce.cs`](https://github.com/AsiBackbone/AsiBackbone/blob/v7.5.0/src/Enforce.cs)'
        '[.github `src/Enforce.cs`](https://github.com/AsiBackbone/.github/blob/main/src/Enforce.cs)'
    )) {
        if (-not $rendered.Contains($expected, [StringComparison]::Ordinal)) {
            $failures.Add("Rendered map is missing: $expected")
        }
    }
    $gapped = & $mutate { param($m) $m['controls'][0]['evidenceGap'] = 'Only partly tested.' }
    if (-not (ConvertTo-AssuranceMarkdown $gapped).Contains('- **Evidence gap:** Only partly tested.', [StringComparison]::Ordinal)) {
        $failures.Add('An evidence gap is not rendered.')
    }

    # Drive the real request and lookup functions against an offline responder that answers like the GitHub REST API.
    $existing = @(
        'AsiBackbone/AsiBackbone@v7.5.0:src/Enforce.cs', 'AsiBackbone/AsiBackbone@v7.5.0:tests/EnforceTests.cs', 'AsiBackbone/AsiBackbone@v7.5.0:docs/control.md'
        'AsiBackbone/.github@main:src/Enforce.cs', 'AsiBackbone/.github@main:tests/EnforceTests.cs', 'AsiBackbone/.github@main:docs/control.md'
    )
    $referenceCases = @(
        @{ Name = 'GitHub API: all links resolve'; Manifest = (& $clone); Pass = $true }
        @{ Name = 'GitHub API: moved test file'; Manifest = (& $mutate { param($m) $m['controls'][0]['evidence'][0]['path'] = 'tests/Moved.cs' }); Pass = $false }
    )
    foreach ($case in $referenceCases) {
        $script:GitHubResponder = {
            param($Uri)
            if ($Uri -match '/repos/(?<repo>[^/]+/[^/]+)/contents/(?<path>[^?]+)\?ref=(?<ref>.+)$') {
                $key = "$($Matches.repo)@$([uri]::UnescapeDataString($Matches.ref)):$([uri]::UnescapeDataString($Matches.path))"
                if ($existing -contains $key) { return [pscustomobject]@{ StatusCode = 200; Content = '{}' } }
                return $null
            }
            throw "Unexpected request: $Uri"
        }.GetNewClosure()

        $caseErrors = [System.Collections.Generic.List[string]]::new()
        try {
            $null = Test-References -Manifest $case.Manifest -Errors $caseErrors
        }
        finally {
            $script:GitHubResponder = $null
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

    Write-Host 'Assurance map validator self-test passed.'
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
    $compatibility = Read-JsonFile -Path (Join-Path $RepositoryRoot $compatibilityRelativePath) -RelativePath $compatibilityRelativePath
}
catch {
    Write-Error "The assurance map could not be read: $($_.Exception.Message)" -ErrorAction Continue
    exit 1
}

Test-Manifest -Manifest $manifest -Compatibility $compatibility -Errors $errors
if ($errors.Count -gt 0) {
    $errors | ForEach-Object { Write-Error $_ -ErrorAction Continue }
    exit 1
}

$rendered = ConvertTo-AssuranceMarkdown $manifest
if ($Update) {
    [System.IO.File]::WriteAllText($mapPath, $rendered, [System.Text.UTF8Encoding]::new($false))
    Write-Host "Regenerated $mapRelativePath."
}
else {
    $committed = if (Test-Path -LiteralPath $mapPath -PathType Leaf) { (Get-Content -LiteralPath $mapPath -Raw).Replace("`r`n", "`n") } else { '' }
    if ($committed -ne $rendered) {
        Write-Error "$mapRelativePath does not match $manifestRelativePath. Run ./scripts/Test-AssuranceMap.ps1 -Update and commit the result." -ErrorAction Continue
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
        $summary = @('## Assurance map references', '')
        if ($errors.Count -eq 0) {
            $summary += "All $checked linked enforcement points, tests, and documents exist at their resolved refs."
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

    Write-Host "Verified $checked linked enforcement points, tests, and documents."
}

Write-Host 'Assurance map is valid and the rendered map is current.'
