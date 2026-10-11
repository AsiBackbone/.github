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

$requiredFiles = @('LICENSE', 'LICENSE-CODE', 'LICENSES.md', '.editorconfig', '.gitattributes', '.gitignore')
foreach ($relativePath in $requiredFiles) {
    if (-not (Test-Path -LiteralPath (Join-Path $RepositoryRoot $relativePath) -PathType Leaf)) {
        $failures.Add("Required repository file is missing: $relativePath")
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
    foreach ($requiredText in @('CC BY 4.0 content', 'MIT-licensed source', 'Brand, assets, and third-party boundaries', 'Contributions')) {
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
