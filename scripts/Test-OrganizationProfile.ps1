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
    '## License' = 'license section'
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

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    exit 1
}

Write-Host 'Organization-profile content contract passed.'
