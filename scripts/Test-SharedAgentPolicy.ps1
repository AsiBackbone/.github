[CmdletBinding()]
param(
    [string]$RepositoryRoot = (Split-Path -Parent $PSScriptRoot),

    [ValidateSet('AsiBackbone', 'Learning', 'NetCoreApplicationTemplate', 'ReferenceApplication', 'asibackbone.github.io')]
    [string[]]$Repository = @('AsiBackbone', 'Learning', 'NetCoreApplicationTemplate', 'ReferenceApplication', 'asibackbone.github.io'),

    # Compare against sibling checkouts under this folder instead of each repository's published main branch.
    [string]$LocalRoot,

    [ValidateRange(1, 5)]
    [int]$MaximumAttempts = 3,

    [switch]$SelfTest
)

# Checks that every organization repository's root AGENTS.md carries the shared
# "Organization discussion proposals" section exactly as this repository's AGENTS.md
# defines it. This repository's copy is canonical; the other copies are compared to it
# after normalizing line endings and trailing whitespace. Repositories publish their
# own AGENTS.md, so this is a scheduled drift check rather than a pull-request gate.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$sectionHeading = '## Organization discussion proposals'

function Get-PolicySection {
    param([AllowNull()][string]$Markdown)

    if ([string]::IsNullOrEmpty($Markdown)) {
        return $null
    }

    $lines = $Markdown.Replace("`r`n", "`n").Split("`n") | ForEach-Object { $_.TrimEnd() }
    $start = [Array]::IndexOf([string[]]$lines, $sectionHeading)
    if ($start -lt 0) {
        return $null
    }

    $end = $lines.Count
    for ($index = $start + 1; $index -lt $lines.Count; $index++) {
        if ($lines[$index].StartsWith('## ', [StringComparison]::Ordinal)) {
            $end = $index
            break
        }
    }

    return (($lines[$start..($end - 1)]) -join "`n").Trim()
}

function Compare-PolicySection {
    param(
        [Parameter(Mandatory = $true)][string]$Canonical,
        [AllowNull()][string]$Candidate,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][System.Collections.Generic.List[string]]$Errors
    )

    if ($null -eq $Candidate) {
        $Errors.Add("AGENTS.md has no '$sectionHeading' section.")
        return
    }

    if ($Candidate -ceq $Canonical) {
        return
    }

    $expected = $Canonical.Split("`n")
    $actual = $Candidate.Split("`n")
    $count = [Math]::Max($expected.Count, $actual.Count)
    for ($index = 0; $index -lt $count; $index++) {
        $expectedLine = if ($index -lt $expected.Count) { $expected[$index] } else { '<end of section>' }
        $actualLine = if ($index -lt $actual.Count) { $actual[$index] } else { '<end of section>' }
        if ($expectedLine -cne $actualLine) {
            $Errors.Add("AGENTS.md '$sectionHeading' differs from the canonical section at line $($index + 1) of the section. Expected: '$expectedLine'. Found: '$actualLine'.")
            return
        }
    }
}

function Invoke-AgentsRequest {
    param([Parameter(Mandatory = $true)][string]$Uri)

    for ($attempt = 1; $attempt -le $MaximumAttempts; $attempt++) {
        try {
            $response = Invoke-WebRequest -Uri $Uri -MaximumRedirection 5 -TimeoutSec 30 -SkipHttpErrorCheck -UserAgent 'AsiBackbone-shared-agent-policy-validation'
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

function Get-RepositoryAgents {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][System.Collections.Generic.List[string]]$Errors
    )

    if ($LocalRoot) {
        $path = Join-Path (Join-Path $LocalRoot $Name) 'AGENTS.md'
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            $Errors.Add("$path was not found.")
            return $null
        }

        return Get-Content -LiteralPath $path -Raw
    }

    $uri = "https://raw.githubusercontent.com/AsiBackbone/$Name/main/AGENTS.md"
    try {
        $response = Invoke-AgentsRequest -Uri $uri
    }
    catch {
        $Errors.Add("$uri could not be fetched: $($_.Exception.Message)")
        return $null
    }

    if ([int]$response.StatusCode -ne 200) {
        $Errors.Add("$uri returned HTTP $([int]$response.StatusCode).")
        return $null
    }

    return [string]$response.Content
}

function Invoke-SelfTest {
    $canonicalMarkdown = @(
        '# Agent instructions'
        ''
        '## Purpose'
        ''
        'Repository-specific purpose.'
        ''
        $sectionHeading
        ''
        'Anyone may submit proposals.'
        'Maintainers decide.'
        ''
        '## Validation'
        ''
        'Repository-specific validation.'
    ) -join "`n"
    $canonical = Get-PolicySection $canonicalMarkdown

    $cases = @(
        @{ Name = 'identical section'; Markdown = $canonicalMarkdown; Pass = $true }
        @{ Name = 'CRLF line endings and trailing whitespace'; Markdown = $canonicalMarkdown.Replace("`n", "  `r`n"); Pass = $true }
        @{ Name = 'different surrounding sections'; Markdown = $canonicalMarkdown.Replace('Repository-specific purpose.', 'Another purpose.').Replace('Repository-specific validation.', 'Other checks.'); Pass = $true }
        @{ Name = 'section at end of file'; Markdown = ($canonicalMarkdown -split "`n## Validation")[0]; Pass = $true }
        @{ Name = 'missing section'; Markdown = $canonicalMarkdown.Replace($sectionHeading, '## Discussion proposals'); Pass = $false }
        @{ Name = 'empty file'; Markdown = ''; Pass = $false }
        @{ Name = 'changed wording'; Markdown = $canonicalMarkdown.Replace('Maintainers decide.', 'Agents decide.'); Pass = $false }
        @{ Name = 'added line'; Markdown = $canonicalMarkdown.Replace('Maintainers decide.', "Maintainers decide.`nAgents may also decide."); Pass = $false }
        @{ Name = 'removed line'; Markdown = $canonicalMarkdown.Replace("Maintainers decide.`n", ''); Pass = $false }
        @{ Name = 'changed case'; Markdown = $canonicalMarkdown.Replace('Maintainers decide.', 'maintainers decide.'); Pass = $false }
    )

    $failures = [System.Collections.Generic.List[string]]::new()
    if ($null -eq $canonical) {
        $failures.Add('Self-test fixture has no canonical section.')
    }

    foreach ($case in $cases) {
        $caseErrors = [System.Collections.Generic.List[string]]::new()
        Compare-PolicySection -Canonical $canonical -Candidate (Get-PolicySection $case.Markdown) -Errors $caseErrors
        if (($caseErrors.Count -eq 0) -ne $case.Pass) {
            $expected = if ($case.Pass) { 'success' } else { 'failure' }
            $failures.Add("Self-test '$($case.Name)' expected $expected but got $($caseErrors.Count) error(s): $($caseErrors -join ' ')")
        }
    }

    if ($failures.Count -gt 0) {
        $failures | ForEach-Object { Write-Error $_ -ErrorAction Continue }
        exit 1
    }

    Write-Host "Shared agent policy validator self-test passed ($($cases.Count) cases)."
}

if ($MyInvocation.InvocationName -eq '.') {
    return
}

if ($SelfTest) {
    Invoke-SelfTest
    exit 0
}

$canonicalPath = Join-Path $RepositoryRoot 'AGENTS.md'
if (-not (Test-Path -LiteralPath $canonicalPath -PathType Leaf)) {
    Write-Error "$canonicalPath is required."
    exit 1
}

$canonical = Get-PolicySection (Get-Content -LiteralPath $canonicalPath -Raw)
if ($null -eq $canonical) {
    Write-Error "The canonical AGENTS.md has no '$sectionHeading' section."
    exit 1
}

$source = if ($LocalRoot) { "local checkouts under $LocalRoot" } else { 'each repository''s main branch' }
$failedRepositories = 0
$summary = [System.Collections.Generic.List[string]]::new()
$summary.Add('| Repository | Result |')
$summary.Add('| --- | --- |')

foreach ($name in $Repository) {
    $repositoryErrors = [System.Collections.Generic.List[string]]::new()
    $markdown = Get-RepositoryAgents -Name $name -Errors $repositoryErrors
    if ($repositoryErrors.Count -eq 0) {
        Compare-PolicySection -Canonical $canonical -Candidate (Get-PolicySection $markdown) -Errors $repositoryErrors
    }

    if ($repositoryErrors.Count -eq 0) {
        Write-Host "AsiBackbone/$name AGENTS.md matches the canonical '$sectionHeading' section."
        $summary.Add("| [AsiBackbone/$name](https://github.com/AsiBackbone/$name/blob/main/AGENTS.md) | Matches |")
        continue
    }

    $failedRepositories++
    $summary.Add("| [AsiBackbone/$name](https://github.com/AsiBackbone/$name/blob/main/AGENTS.md) | Drift; copy the section from this repository's AGENTS.md |")
    foreach ($repositoryError in $repositoryErrors) {
        Write-Error "AsiBackbone/${name}: $repositoryError" -ErrorAction Continue
        $summary.Add("|  | $($repositoryError.Replace('|', '\|')) |")
    }
}

if ($env:GITHUB_STEP_SUMMARY) {
    @('## Shared agent policy', '', "Compared with $source.", '') + $summary | Add-Content -LiteralPath $env:GITHUB_STEP_SUMMARY -Encoding utf8
}

if ($failedRepositories -gt 0) {
    exit 1
}

Write-Host "All $($Repository.Count) repositories match the canonical '$sectionHeading' section."
