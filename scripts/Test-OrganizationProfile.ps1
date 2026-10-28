[CmdletBinding()]
param(
    [string]$RepositoryRoot = (Split-Path -Parent $PSScriptRoot)
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$profilePath = Join-Path $RepositoryRoot 'profile/README.md'
if (-not (Test-Path -LiteralPath $profilePath -PathType Leaf)) {
    Write-Error 'profile/README.md is required.'
    exit 1
}

$profile = Get-Content -LiteralPath $profilePath -Raw
$requiredContent = [ordered]@{
    '# AsiBackbone' = 'organization heading'
    'https://github.com/AsiBackbone/Learning' = 'Learning repository link'
    'https://asibackbone.github.io/Learning/' = 'Learning documentation link'
    'https://github.com/AsiBackbone/AsiBackbone' = 'AsiBackbone repository link'
    'https://asibackbone.github.io/AsiBackbone/' = 'AsiBackbone documentation link'
    'https://github.com/AsiBackbone/NetCoreApplicationTemplate' = 'NetCoreApplicationTemplate repository link'
    'https://asibackbone.github.io/NetCoreApplicationTemplate/' = 'NetCoreApplicationTemplate documentation link'
    'https://github.com/AsiBackbone/ReferenceApplication' = 'ReferenceApplication repository link'
    'https://asibackbone.github.io/ReferenceApplication/' = 'ReferenceApplication documentation link'
    '## Learn, Ask, and Contribute' = 'community-routing section'
    'https://github.com/orgs/AsiBackbone/discussions/categories/q-a' = 'organization Q&A route'
    'https://github.com/orgs/AsiBackbone/discussions/categories/ideas' = 'organization Ideas route'
    'https://github.com/orgs/AsiBackbone/discussions/categories/architecture-integration' = 'organization architecture route'
    'https://github.com/AsiBackbone/Learning/blob/main/CONTRIBUTING.md' = 'Learning contribution route'
    'https://github.com/AsiBackbone/AsiBackbone/blob/main/CONTRIBUTING.md' = 'AsiBackbone contribution route'
    'https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/main/CONTRIBUTING.md' = 'template contribution route'
    'https://github.com/AsiBackbone/Learning/security/policy' = 'Learning security route'
    'https://github.com/AsiBackbone/AsiBackbone/security/policy' = 'AsiBackbone security route'
    'https://github.com/AsiBackbone/NetCoreApplicationTemplate/security/policy' = 'template security route'
    '## License' = 'license section'
    'https://github.com/AsiBackbone/.github/blob/main/LICENSES.md' = 'licensing boundary link'
    'https://github.com/AsiBackbone/.github/blob/main/compatibility/README.md' = 'ecosystem compatibility matrix link'
    'https://github.com/AsiBackbone/.github/blob/main/assurance/README.md' = 'security assurance map link'
}

# Canonical project order (LANDING-PAGE-STANDARD.md, Related Projects contract): Learn → Framework → Template → Reference.
$profileProjectHeadings = @(
    '### [AsiBackbone Learning](https://github.com/AsiBackbone/Learning) — learn the patterns'
    '### [AsiBackbone](https://github.com/AsiBackbone/AsiBackbone) — add governed decisions'
    '### [.NET Core Application Template](https://github.com/AsiBackbone/NetCoreApplicationTemplate) — start a secure application'
    '### [AsiBackbone Reference Application](https://github.com/AsiBackbone/ReferenceApplication) — follow the integration'
)
$standardProjectRows = @(
    '| AsiBackbone Learning | Learn the patterns |'
    '| AsiBackbone | Add governed decisions |'
    '| .NET Core Application Template | Start a secure application |'
    '| AsiBackbone Reference Application | Follow the integration |'
)

function Test-CanonicalOrder {
    param(
        [string]$Content,
        [string[]]$Markers,
        [string]$Source,
        [AllowEmptyCollection()][System.Collections.Generic.List[string]]$Failures
    )

    $previous = -1
    foreach ($marker in $Markers) {
        $index = $Content.IndexOf($marker, [StringComparison]::Ordinal)
        if ($index -lt 0) {
            continue
        }

        if ($index -lt $previous) {
            $Failures.Add("$Source lists the projects out of canonical order (Learn → Framework → Template → Reference): '$marker' appears too early.")
            return
        }

        $previous = $index
    }
}

$failures = [System.Collections.Generic.List[string]]::new()
foreach ($entry in $requiredContent.GetEnumerator()) {
    if (-not $profile.Contains($entry.Key, [StringComparison]::Ordinal)) {
        $failures.Add("profile/README.md is missing its $($entry.Value).")
    }
}

foreach ($requiredText in @(
    'https://asibackbone.github.io/'
    $profileProjectHeadings
    '## Design Philosophy'
    'We favor architectures where consequential operations are explicit, constrained, reviewable, and auditable.'
    'https://doi.org/10.5281/zenodo.21938556'
    'https://doi.org/10.5281/zenodo.20546032'
    'https://doi.org/10.5281/zenodo.20373042'
)) {
    if (-not $profile.Contains($requiredText, [StringComparison]::Ordinal)) {
        $failures.Add("profile/README.md is missing landing-page standard content: $requiredText")
    }
}

foreach ($requiredText in @(
    'A reusable, production-oriented ASP.NET Core baseline with secure defaults'
    'It is not a finished, penetration-tested, or certified application'
    'each generated application still requires application-specific configuration, threat analysis, deployment controls, testing, and security review.'
)) {
    if (-not $profile.Contains($requiredText, [StringComparison]::Ordinal)) {
        $failures.Add("profile/README.md is missing the NCAT product-boundary statement: $requiredText")
    }
}

if ($profile -match '(?i)production-ready|enterprise application template') {
    $failures.Add('profile/README.md overstates the NCAT boundary; use production-oriented baseline terminology.')
}

Test-CanonicalOrder -Content $profile -Markers $profileProjectHeadings -Source 'profile/README.md' -Failures $failures

if ($profile -match 'ASI Backbone') {
    $failures.Add('profile/README.md uses the legacy "ASI Backbone" spelling; use the canonical project names from LANDING-PAGE-STANDARD.md.')
}

$standardPath = Join-Path $RepositoryRoot 'LANDING-PAGE-STANDARD.md'
if (Test-Path -LiteralPath $standardPath -PathType Leaf) {
    $standard = Get-Content -LiteralPath $standardPath -Raw
    if ($standard -notmatch '(?m)^\*\*Version:\*\* \d+\.\d+\.\d+\s*$') {
        $failures.Add('LANDING-PAGE-STANDARD.md must declare a semantic **Version:** line.')
    }

    $standardContent = @(
        'https://github.com/AsiBackbone'
        'https://asibackbone.github.io/'
        'https://asibackbone.github.io/Learning/'
        'https://asibackbone.github.io/AsiBackbone/'
        'https://asibackbone.github.io/NetCoreApplicationTemplate/'
        'https://asibackbone.github.io/ReferenceApplication/'
        'https://github.com/AsiBackbone/ReferenceApplication'
        '## Required and optional sections'
        '## 1. Ecosystem navigation contract'
        '## 2. Hero contract'
        '## 3. Start Here contract'
        '## 4. Product-fit contract'
        '## 5. Related Projects contract'
        '## 6. Design Philosophy contract'
        '## 7. Visual tokens and components'
        '## 8. Footer contract'
        '## 9. Accessibility and quality requirements'
        '## 10. Drift prevention'
        '## Validation checklist'
        '## Rollout'
        'We favor architectures where consequential operations are explicit, constrained, reviewable, and auditable.'
        'https://github.com/AsiBackbone/.github/issues/16'
        'https://github.com/AsiBackbone/.github/issues/17'
        'https://github.com/AsiBackbone/.github/issues/18'
        'https://github.com/AsiBackbone/.github/issues/21'
        '### Page metadata'
        '### Published output'
        '<html lang="en">'
        '`"_lang": "en"`'
        '`_disableToc: true`'
        'It is rendered in the page''s template markup, before the `header`'
        'remove it before uploading the GitHub Pages artifact'
        'scripts/Test-PublishedSites.ps1'
        '.github/workflows/published-sites-validation.yml'
        'https://github.com/AsiBackbone/.github/issues/20'
        '### Strict DocFX builds'
        'scripts/Validate-DocFxStrictBuild.ps1'
        'scripts/Test-DocFxStrictBuilds.ps1'
        '.github/workflows/docfx-strict-builds-validation.yml'
        'https://github.com/AsiBackbone/ReferenceApplication/issues/7'
        '**Canonical order:**'
        'aria-current="page"'
        '## Baseline review: Reference'
        $standardProjectRows
    )
    foreach ($requiredText in $standardContent) {
        if (-not $standard.Contains($requiredText, [StringComparison]::Ordinal)) {
            $failures.Add("LANDING-PAGE-STANDARD.md is missing required content: $requiredText")
        }
    }

    Test-CanonicalOrder -Content $standard -Markers $standardProjectRows -Source 'LANDING-PAGE-STANDARD.md (Related Projects)' -Failures $failures

    foreach ($surface in @('Organization profile', 'Organization landing page', 'Learning', 'Framework', 'Template', 'Reference')) {
        if ($standard -notmatch "(?m)^\| $([regex]::Escape($surface)) \| <https://") {
            $failures.Add("LANDING-PAGE-STANDARD.md is missing the '$surface' public surface.")
        }
    }

    # The strict-build table in the standard and the conformance script must name the same workflows.
    $strictScriptPath = Join-Path $RepositoryRoot 'scripts/Test-DocFxStrictBuilds.ps1'
    $strictScript = if (Test-Path -LiteralPath $strictScriptPath -PathType Leaf) { Get-Content -LiteralPath $strictScriptPath -Raw } else { '' }
    foreach ($site in @('Learning', 'Framework', 'Template', 'Reference')) {
        $row = [regex]::Match($standard, "(?m)^\| $site \| \[``AsiBackbone/[^``]+``\]\([^)]+\) \| (?<workflows>``[^|]+``) \|\s*$")
        if (-not $row.Success) {
            $failures.Add("LANDING-PAGE-STANDARD.md is missing the '$site' row of the strict DocFX builds table.")
            continue
        }

        $workflows = @([regex]::Matches($row.Groups['workflows'].Value, '`(?<name>[^`]+)`') | ForEach-Object { "'$($_.Groups['name'].Value)'" })
        $expected = "RequiredWorkflows = @($($workflows -join ', '))"
        $definition = [regex]::Match($strictScript, "(?s)\b$site = \[pscustomobject\]@\{.*?RequiredWorkflows = @\([^)]*\)")
        if (-not $definition.Success -or -not $definition.Value.EndsWith($expected, [StringComparison]::Ordinal)) {
            $failures.Add("scripts/Test-DocFxStrictBuilds.ps1 must define $site with $expected to match LANDING-PAGE-STANDARD.md.")
        }
    }

    foreach ($label in @('Organization', 'Learning', 'Community', 'Framework', 'Template', 'Reference', 'GitHub')) {
        if ($standard -notmatch "(?m)^\| $label \| ") {
            $failures.Add("LANDING-PAGE-STANDARD.md is missing the '$label' ecosystem navigation destination.")
        }
    }
}

if ($profile -match '(?i)(password|token|secret)\s*[:=]\s*\S+') {
    $failures.Add('profile/README.md appears to contain credential-like content.')
}

$readmePath = Join-Path $RepositoryRoot 'README.md'
if (Test-Path -LiteralPath $readmePath -PathType Leaf) {
    $readme = Get-Content -LiteralPath $readmePath -Raw
    foreach ($requiredText in @('[conduct](CODE_OF_CONDUCT.md)', '[contribution](CONTRIBUTING.md)', '[support](SUPPORT.md)', '[security](SECURITY.md)', 'Repository-specific community files remain authoritative', '[ecosystem compatibility matrix](compatibility/README.md)', '[security assurance and control-ownership map](assurance/README.md)', '[documentation ownership map](documentation/README.md)')) {
        if (-not $readme.Contains($requiredText, [StringComparison]::Ordinal)) {
            $failures.Add("README.md is missing required community-health content: $requiredText")
        }
    }
}

$requiredFiles = @(
    'LICENSE'
    'LICENSE-CODE'
    'LICENSES.md'
    'LANDING-PAGE-STANDARD.md'
    '.editorconfig'
    '.gitattributes'
    '.gitignore'
    'CODE_OF_CONDUCT.md'
    'CONTRIBUTING.md'
    'SUPPORT.md'
    'SECURITY.md'
    '.github/PULL_REQUEST_TEMPLATE.md'
    '.github/ISSUE_TEMPLATE/config.yml'
    '.github/dependabot.yml'
    '.github/workflows/dependency-review.yml'
    '.github/workflows/codeql.yml'
    '.github/workflows/workflow-security.yml'
    '.github/workflows/openssf-scorecard.yml'
    '.github/workflows/profile-validation.yml'
    '.github/workflows/published-sites-validation.yml'
    '.github/workflows/docfx-strict-builds-validation.yml'
    'scripts/Test-PublishedSites.ps1'
    'scripts/Test-DocFxStrictBuilds.ps1'
    '.github/workflows/compatibility-matrix-validation.yml'
    'scripts/Test-CompatibilityMatrix.ps1'
    'compatibility/ecosystem-compatibility.json'
    'compatibility/README.md'
    '.github/workflows/assurance-map-validation.yml'
    'scripts/Test-AssuranceMap.ps1'
    'assurance/control-ownership.json'
    'assurance/README.md'
    '.github/workflows/documentation-ownership-review.yml'
    'scripts/Test-DocumentationOwnership.ps1'
    'documentation/ownership.json'
    'documentation/README.md'
)
foreach ($relativePath in $requiredFiles) {
    if (-not (Test-Path -LiteralPath (Join-Path $RepositoryRoot $relativePath) -PathType Leaf)) {
        $failures.Add("Required repository file is missing: $relativePath")
    }
}

$communityContracts = [ordered]@{
    'CODE_OF_CONDUCT.md' = @(
        '## Our Standards'
        '## Reporting'
        'Do not publish sensitive personal information'
        'Contributor Covenant, version 2.1'
    )
    'CONTRIBUTING.md' = @(
        '## Documentation Ownership'
        'https://github.com/AsiBackbone/.github/blob/main/documentation/README.md#review-rule-for-new-documentation'
        'Repository-specific contribution, support, security, governance, and validation files are authoritative'
        'https://github.com/orgs/AsiBackbone/discussions/categories/q-a'
        'https://github.com/orgs/AsiBackbone/discussions/categories/ideas'
        'Do not open a public issue or discussion containing passwords, tokens, personal information, exploit details, or other sensitive material.'
    )
    'SUPPORT.md' = @(
        'https://github.com/orgs/AsiBackbone/discussions'
        'https://github.com/orgs/AsiBackbone/discussions/categories/q-a'
        'https://github.com/orgs/AsiBackbone/discussions/categories/ideas'
        'https://github.com/orgs/AsiBackbone/discussions/categories/architecture-integration'
        'Do not disclose passwords, tokens, personal data, exploit details, or other sensitive material'
    )
    'SECURITY.md' = @(
        'Do not disclose exploit details, secrets, personal data, or other sensitive material in a public issue, pull request, or Discussion.'
        'https://github.com/AsiBackbone/AsiBackbone/security/advisories/new'
        'https://github.com/AsiBackbone/Learning/security/advisories/new'
        'https://github.com/AsiBackbone/NetCoreApplicationTemplate/security/advisories/new'
        'https://github.com/AsiBackbone/.github/security/advisories/new'
        'https://github.com/AsiBackbone/asibackbone.github.io/security/advisories/new'
        'Repository-specific `SECURITY.md` files remain authoritative'
        '## Repository Control Posture'
        'CodeQL analyzes every pull request and every push to `main`'
        'active `Main branch security baseline` ruleset'
        'Fuzzing is not used because the repository has no fuzzable'
        'An approving human review is not mandatory while the organization has one'
    )
    '.github/PULL_REQUEST_TEMPLATE.md' = @(
        'https://github.com/AsiBackbone/.github/blob/main/documentation/README.md'
        '## Summary'
        '## Scope and Boundaries'
        '## Validation'
        'I did not include credentials, tokens, personal data, or sensitive vulnerability details.'
    )
    '.github/ISSUE_TEMPLATE/config.yml' = @(
        'blank_issues_enabled: true'
        'https://github.com/orgs/AsiBackbone/discussions/categories/q-a'
        'https://github.com/orgs/AsiBackbone/discussions/categories/ideas'
        'https://github.com/orgs/AsiBackbone/discussions/categories/architecture-integration'
        'https://github.com/AsiBackbone/.github/security/advisories/new'
        'Do not disclose secrets or exploit details publicly.'
    )
    '.github/dependabot.yml' = @(
        'package-ecosystem: "github-actions"'
        'interval: "weekly"'
        'day: "friday"'
        'timezone: "America/Chicago"'
        'github-actions:'
    )
    '.github/workflows/dependency-review.yml' = @(
        'name: Dependency Review'
        'fail-on-severity: moderate'
    )
    '.github/workflows/codeql.yml' = @(
        'name: CodeQL Analysis'
        'pull_request:'
        'push:'
        'languages: actions'
    )
    '.github/workflows/workflow-security.yml' = @(
        'name: GitHub Actions security analysis'
        'advanced-security: true'
        'docker://rhysd/actionlint@sha256:b1934ee5f1c509618f2508e6eb47ee0d3520686341fec936f3b79331f9315667'
    )
    '.github/workflows/profile-validation.yml' = @(
        'pull_request:'
        './scripts/Test-OrganizationProfile.ps1'
        './scripts/Test-PublishedSites.ps1 -SelfTest'
        './scripts/Test-DocFxStrictBuilds.ps1 -SelfTest'
        './scripts/Test-CompatibilityMatrix.ps1'
        './scripts/Test-CompatibilityMatrix.ps1 -SelfTest'
        './scripts/Test-AssuranceMap.ps1'
        './scripts/Test-AssuranceMap.ps1 -SelfTest'
        './scripts/Test-DocumentationOwnership.ps1'
        './scripts/Test-DocumentationOwnership.ps1 -SelfTest'
    )
    '.github/workflows/documentation-ownership-review.yml' = @(
        'name: Documentation ownership review'
        'pull_request:'
        'schedule:'
        'workflow_dispatch:'
        'contents: read'
        'persist-credentials: false'
        'GITHUB_TOKEN: ${{ github.token }}'
        './scripts/Test-DocumentationOwnership.ps1 -VerifyReferences -ScanVersionClaims'
    )
    'scripts/Test-DocumentationOwnership.ps1' = @(
        "Repository = 'AsiBackbone/Learning'"
        "Repository = 'AsiBackbone/AsiBackbone'"
        "Repository = 'AsiBackbone/NetCoreApplicationTemplate'"
        "Repository = 'AsiBackbone/ReferenceApplication'"
        '## Review rule for new documentation'
        '## Current-version claim review'
        'does not move or delete content'
    )
    '.github/workflows/assurance-map-validation.yml' = @(
        'name: Assurance map validation'
        'pull_request:'
        'schedule:'
        'workflow_dispatch:'
        'contents: read'
        'persist-credentials: false'
        'GITHUB_TOKEN: ${{ github.token }}'
        './scripts/Test-AssuranceMap.ps1 -VerifyReferences'
    )
    'scripts/Test-AssuranceMap.ps1' = @(
        "asiBackbone = 'AsiBackbone/AsiBackbone'"
        "netCoreApplicationTemplate = 'AsiBackbone/NetCoreApplicationTemplate'"
        "referenceApplication = 'AsiBackbone/ReferenceApplication'"
        'compatibility/ecosystem-compatibility.json'
        'not a compliance matrix or a certification claim'
        '## Review cadence'
        'record an evidenceGap'
    )
    '.github/workflows/compatibility-matrix-validation.yml' = @(
        'name: Compatibility matrix validation'
        'pull_request:'
        'schedule:'
        'workflow_dispatch:'
        'contents: read'
        'persist-credentials: false'
        'GITHUB_TOKEN: ${{ github.token }}'
        './scripts/Test-CompatibilityMatrix.ps1 -VerifyReferences'
    )
    'scripts/Test-CompatibilityMatrix.ps1' = @(
        "Repository = 'AsiBackbone/Learning'"
        "Repository = 'AsiBackbone/AsiBackbone'"
        "Repository = 'AsiBackbone/NetCoreApplicationTemplate'"
        "Repository = 'AsiBackbone/ReferenceApplication'"
        'not known to be broken'
        'not a certification'
        'not a package dependency'
    )
    '.github/workflows/docfx-strict-builds-validation.yml' = @(
        'name: Strict DocFX builds validation'
        'schedule:'
        'workflow_dispatch:'
        'contents: read'
        'persist-credentials: false'
        'GITHUB_TOKEN: ${{ github.token }}'
        './scripts/Test-DocFxStrictBuilds.ps1'
    )
    'scripts/Test-DocFxStrictBuilds.ps1' = @(
        "Repository = 'AsiBackbone/Learning'"
        "Repository = 'AsiBackbone/AsiBackbone'"
        "Repository = 'AsiBackbone/NetCoreApplicationTemplate'"
        "Repository = 'AsiBackbone/ReferenceApplication'"
        '--warningsAsErrors'
    )
    '.github/workflows/published-sites-validation.yml' = @(
        'name: Published documentation sites validation'
        'schedule:'
        'workflow_dispatch:'
        'contents: read'
        'persist-credentials: false'
        './scripts/Test-PublishedSites.ps1'
    )
    'scripts/Test-PublishedSites.ps1' = @(
        'https://asibackbone.github.io/Learning/'
        'https://asibackbone.github.io/AsiBackbone/'
        'https://asibackbone.github.io/NetCoreApplicationTemplate/'
        'https://asibackbone.github.io/ReferenceApplication/'
        'manifest.json'
        'application/ld\+json'
        'skip-link'
        'docfx:tocrel'
    )
    '.github/workflows/openssf-scorecard.yml' = @(
        'name: OpenSSF Scorecard supply-chain security'
        'publish_results: true'
    )
}

# Required actions are checked by name and commit-SHA form, not by a specific SHA, so Dependabot
# version updates satisfy the contract. The workflow loop below still rejects unpinned references.
$requiredPinnedActions = [ordered]@{
    '.github/workflows/dependency-review.yml' = @(
        'actions/dependency-review-action'
    )
    '.github/workflows/codeql.yml' = @(
        'github/codeql-action/init'
        'github/codeql-action/analyze'
    )
    '.github/workflows/workflow-security.yml' = @(
        'zizmorcore/zizmor-action'
    )
    '.github/workflows/openssf-scorecard.yml' = @(
        'ossf/scorecard-action'
        'github/codeql-action/upload-sarif'
    )
}

foreach ($contract in $communityContracts.GetEnumerator()) {
    $communityPath = Join-Path $RepositoryRoot $contract.Key
    if (-not (Test-Path -LiteralPath $communityPath -PathType Leaf)) {
        continue
    }

    $communityContent = Get-Content -LiteralPath $communityPath -Raw
    foreach ($requiredText in $contract.Value) {
        if (-not $communityContent.Contains($requiredText, [StringComparison]::Ordinal)) {
            $failures.Add("$($contract.Key) is missing required content: $requiredText")
        }
    }
}

foreach ($contract in $requiredPinnedActions.GetEnumerator()) {
    $workflowPath = Join-Path $RepositoryRoot $contract.Key
    if (-not (Test-Path -LiteralPath $workflowPath -PathType Leaf)) {
        continue
    }

    $workflowContent = Get-Content -LiteralPath $workflowPath -Raw
    foreach ($requiredAction in $contract.Value) {
        $pinnedUsePattern = '(?m)^\s*(?:-\s+)?uses:\s*' + [regex]::Escape($requiredAction) + '@[0-9a-f]{40}(?:\s|$)'
        if ($workflowContent -notmatch $pinnedUsePattern) {
            $failures.Add("$($contract.Key) must use $requiredAction pinned to a full commit SHA.")
        }
    }
}

foreach ($workflowFile in Get-ChildItem -LiteralPath (Join-Path $RepositoryRoot '.github/workflows') -File -Filter '*.yml') {
    $workflowContent = Get-Content -LiteralPath $workflowFile.FullName -Raw
    foreach ($use in [regex]::Matches($workflowContent, '(?m)^\s*uses:\s*(?<action>\S+)')) {
        $action = $use.Groups['action'].Value
        if ($action -notmatch '@(?:[0-9a-f]{40}|sha256:[0-9a-f]{64})$') {
            $failures.Add("$($workflowFile.Name) contains an action that is not pinned to an immutable digest: $action")
        }
    }
}

$licensePath = Join-Path $RepositoryRoot 'LICENSE'
if ((Test-Path -LiteralPath $licensePath) -and -not (Get-Content -LiteralPath $licensePath -Raw).StartsWith('Attribution 4.0 International', [StringComparison]::Ordinal)) {
    $failures.Add('LICENSE must contain the complete CC BY 4.0 text.')
}

$codeLicensePath = Join-Path $RepositoryRoot 'LICENSE-CODE'
if ((Test-Path -LiteralPath $codeLicensePath) -and -not (Get-Content -LiteralPath $codeLicensePath -Raw).StartsWith('MIT License', [StringComparison]::Ordinal)) {
    $failures.Add('LICENSE-CODE must contain the complete MIT License text.')
}

$licenseScopePath = Join-Path $RepositoryRoot 'LICENSES.md'
if (Test-Path -LiteralPath $licenseScopePath) {
    $licenseScope = Get-Content -LiteralPath $licenseScopePath -Raw
    foreach ($requiredText in @('CC BY 4.0 content', 'root community health Markdown files', 'LANDING-PAGE-STANDARD.md', 'MIT-licensed source', '.github/ISSUE_TEMPLATE/config.yml', 'Brand, assets, and third-party boundaries', 'Contributions')) {
        if (-not $licenseScope.Contains($requiredText, [StringComparison]::Ordinal)) {
            $failures.Add("LICENSES.md is missing its '$requiredText' boundary.")
        }
    }
}

$editorConfigPath = Join-Path $RepositoryRoot '.editorconfig'
if ((Test-Path -LiteralPath $editorConfigPath) -and -not (Get-Content -LiteralPath $editorConfigPath -Raw).Contains('root = true', [StringComparison]::Ordinal)) {
    $failures.Add('.editorconfig must declare itself as the top-level configuration.')
}

$gitAttributesPath = Join-Path $RepositoryRoot '.gitattributes'
if ((Test-Path -LiteralPath $gitAttributesPath) -and -not (Get-Content -LiteralPath $gitAttributesPath -Raw).Contains('* text=auto eol=lf', [StringComparison]::Ordinal)) {
    $failures.Add('.gitattributes must normalize text files to LF.')
}

$gitIgnorePath = Join-Path $RepositoryRoot '.gitignore'
if ((Test-Path -LiteralPath $gitIgnorePath) -and -not (Get-Content -LiteralPath $gitIgnorePath -Raw).Contains('.vs/', [StringComparison]::Ordinal)) {
    $failures.Add('.gitignore must exclude Visual Studio workspace state.')
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    exit 1
}

Write-Host 'Organization-profile content contract passed.'
