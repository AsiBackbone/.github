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
    '## Learn, Ask, and Contribute' = 'community-routing section'
    'https://github.com/orgs/AsiBackbone/discussions/categories/q-a' = 'organization Q&A route'
    'https://github.com/orgs/AsiBackbone/discussions/categories/ideas' = 'organization Ideas route'
    'https://github.com/orgs/AsiBackbone/discussions/categories/architecture-integration' = 'organization architecture route'
    'https://github.com/AsiBackbone/Learning/discussions' = 'Learning Discussions route'
    'https://github.com/AsiBackbone/AsiBackbone/discussions' = 'AsiBackbone Discussions route'
    'https://github.com/AsiBackbone/NetCoreApplicationTemplate/discussions' = 'template Discussions route'
    'https://github.com/AsiBackbone/Learning/blob/main/CONTRIBUTING.md' = 'Learning contribution route'
    'https://github.com/AsiBackbone/AsiBackbone/blob/main/CONTRIBUTING.md' = 'AsiBackbone contribution route'
    'https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/main/CONTRIBUTING.md' = 'template contribution route'
    'https://github.com/AsiBackbone/Learning/security/policy' = 'Learning security route'
    'https://github.com/AsiBackbone/AsiBackbone/security/policy' = 'AsiBackbone security route'
    'https://github.com/AsiBackbone/NetCoreApplicationTemplate/security/policy' = 'template security route'
    '## License' = 'license section'
    'https://github.com/AsiBackbone/.github/blob/main/LICENSES.md' = 'licensing boundary link'
}

$failures = [System.Collections.Generic.List[string]]::new()
foreach ($entry in $requiredContent.GetEnumerator()) {
    if (-not $profile.Contains($entry.Key, [StringComparison]::Ordinal)) {
        $failures.Add("profile/README.md is missing its $($entry.Value).")
    }
}

if ($profile -match '(?i)(password|token|secret)\s*[:=]\s*\S+') {
    $failures.Add('profile/README.md appears to contain credential-like content.')
}

$readmePath = Join-Path $RepositoryRoot 'README.md'
if (Test-Path -LiteralPath $readmePath -PathType Leaf) {
    $readme = Get-Content -LiteralPath $readmePath -Raw
    foreach ($requiredText in @('[conduct](CODE_OF_CONDUCT.md)', '[contribution](CONTRIBUTING.md)', '[support](SUPPORT.md)', '[security](SECURITY.md)', 'Repository-specific community files remain authoritative')) {
        if (-not $readme.Contains($requiredText, [StringComparison]::Ordinal)) {
            $failures.Add("README.md is missing required community-health content: $requiredText")
        }
    }
}

$requiredFiles = @(
    'LICENSE'
    'LICENSE-CODE'
    'LICENSES.md'
    '.editorconfig'
    '.gitattributes'
    '.gitignore'
    'CODE_OF_CONDUCT.md'
    'CONTRIBUTING.md'
    'SUPPORT.md'
    'SECURITY.md'
    '.github/PULL_REQUEST_TEMPLATE.md'
    '.github/ISSUE_TEMPLATE/config.yml'
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
        'Repository-specific contribution, support, security, governance, and validation files are authoritative'
        'https://github.com/orgs/AsiBackbone/discussions/categories/q-a'
        'https://github.com/orgs/AsiBackbone/discussions/categories/ideas'
        'Do not open a public issue or discussion containing passwords, tokens, personal information, exploit details, or other sensitive material.'
    )
    'SUPPORT.md' = @(
        'https://github.com/AsiBackbone/Learning/discussions'
        'https://github.com/AsiBackbone/AsiBackbone/discussions'
        'https://github.com/AsiBackbone/NetCoreApplicationTemplate/discussions'
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
    )
    '.github/PULL_REQUEST_TEMPLATE.md' = @(
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
    foreach ($requiredText in @('CC BY 4.0 content', 'root community health Markdown files', 'MIT-licensed source', '.github/ISSUE_TEMPLATE/config.yml', 'Brand, assets, and third-party boundaries', 'Contributions')) {
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
