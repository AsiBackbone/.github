[CmdletBinding()]
param(
    [ValidateSet('Learning', 'Framework', 'Template', 'Reference')]
    [string[]]$Site = @('Learning', 'Framework', 'Template', 'Reference'),

    [string]$Ref = 'main',

    [ValidateRange(1, 5)]
    [int]$MaximumAttempts = 3,

    [switch]$SelfTest
)

# Checks that every DocFX build in the Learning, AsiBackbone, .NET Core Application Template, and Reference Application
# workflows fails on warnings, and that each repository's required pull-request, release, and publication workflows
# still build DocFX (LANDING-PAGE-STANDARD.md, Strict DocFX builds; AsiBackbone/.github#20). It reads public workflow
# files only.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$siteDefinitions = [ordered]@{
    Learning = [pscustomobject]@{
        Repository = 'AsiBackbone/Learning'
        RequiredWorkflows = @('docs-validation.yml', 'publish-docs.yml', 'publish-release-evidence.yml')
    }
    Framework = [pscustomobject]@{
        Repository = 'AsiBackbone/AsiBackbone'
        RequiredWorkflows = @('ci.yml', 'publish-docs.yml', 'publish-packages.yml', 'publish-quality-reports.yml', 'release-validation.yml')
    }
    Template = [pscustomobject]@{
        Repository = 'AsiBackbone/NetCoreApplicationTemplate'
        RequiredWorkflows = @('link-validation.yml', 'publish-docs.yml')
    }
    Reference = [pscustomobject]@{
        Repository = 'AsiBackbone/ReferenceApplication'
        RequiredWorkflows = @('publish-docs.yml')
    }
}

function Get-DocFxBuildCommands {
    param([AllowEmptyString()][string]$Content)

    # Join shell (\) and PowerShell (`) line continuations so a flag on a continuation line is seen.
    $logicalLines = [System.Collections.Generic.List[string]]::new()
    $pending = ''
    foreach ($line in ($Content -split "`r?`n")) {
        if ($line -match '^\s*#') {
            continue
        }

        if ($line -match '(\\|`)\s*$') {
            $pending += ($line -replace '(\\|`)\s*$', ' ')
            continue
        }

        $logicalLines.Add($pending + $line)
        $pending = ''
    }

    if ($pending) {
        $logicalLines.Add($pending)
    }

    foreach ($logicalLine in $logicalLines) {
        if ($logicalLine -match '(?i)\bdocfx(?:\s+--)?(?:\s+build)?\s+\S*docfx\.json\b') {
            [regex]::Replace($logicalLine.Trim(), '^-?\s*run:\s*', '')
        }
    }
}

function Test-StrictDocFxCommand {
    param([string]$Command)

    return $Command -match '(?<!\S)--warningsAsErrors(?![\w-])' -and
        $Command -notmatch '(?i)(?<!\S)--warningsAsErrors(?:\s+|=)false\b'
}

function Test-RepositoryWorkflows {
    param(
        [Parameter(Mandatory = $true)][System.Collections.IDictionary]$Workflows,
        [Parameter(Mandatory = $true)][string[]]$RequiredWorkflows,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][System.Collections.Generic.List[string]]$Errors
    )

    foreach ($required in $RequiredWorkflows) {
        if (-not $Workflows.Contains($required)) {
            $Errors.Add("Required DocFX workflow is missing: .github/workflows/$required")
        }
    }

    $buildCount = 0
    foreach ($name in $Workflows.Keys) {
        $commands = @(Get-DocFxBuildCommands ([string]$Workflows[$name]))
        $buildCount += $commands.Count
        foreach ($command in $commands) {
            if (-not (Test-StrictDocFxCommand $command)) {
                $Errors.Add(".github/workflows/$name builds DocFX without --warningsAsErrors: $command")
            }
        }

        if ($RequiredWorkflows -contains $name -and $commands.Count -eq 0) {
            $Errors.Add(".github/workflows/$name must build DocFX with --warningsAsErrors, but no DocFX build was found.")
        }
    }

    return $buildCount
}

function Invoke-GitHubRequest {
    param([string]$Uri, [switch]$Raw)

    $headers = @{
        'User-Agent' = 'AsiBackbone-docfx-strict-build-validation'
        'X-GitHub-Api-Version' = '2022-11-28'
    }
    if (-not $Raw) {
        $headers['Accept'] = 'application/vnd.github+json'
    }
    if ($env:GITHUB_TOKEN) {
        $headers['Authorization'] = "Bearer $env:GITHUB_TOKEN"
    }

    for ($attempt = 1; $attempt -le $MaximumAttempts; $attempt++) {
        try {
            if ($Raw) {
                return [string](Invoke-WebRequest -Uri $Uri -Headers $headers -TimeoutSec 30).Content
            }

            return Invoke-RestMethod -Uri $Uri -Headers $headers -TimeoutSec 30
        }
        catch {
            if ($attempt -eq $MaximumAttempts) {
                throw
            }

            Start-Sleep -Seconds (5 * $attempt)
        }
    }
}

function Get-RepositoryWorkflows {
    param([string]$Repository)

    $workflows = [ordered]@{}
    $listing = Invoke-GitHubRequest -Uri "https://api.github.com/repos/$Repository/contents/.github/workflows?ref=$Ref"
    foreach ($entry in @($listing | Where-Object { $_.type -eq 'file' -and $_.name -match '\.ya?ml$' } | Sort-Object name)) {
        $workflows[$entry.name] = Invoke-GitHubRequest -Uri $entry.download_url -Raw
    }

    return $workflows
}

function Invoke-SelfTest {
    $strict = "      - name: Build DocFX site`n        run: dotnet tool run docfx -- docs/docfx.json --warningsAsErrors"
    $nonStrict = $strict.Replace(' --warningsAsErrors', '')

    $cases = @(
        @{ Name = 'strict required workflow'; Workflows = [ordered]@{ 'ci.yml' = $strict }; Required = @('ci.yml'); Pass = $true }
        @{ Name = 'flag removed'; Workflows = [ordered]@{ 'ci.yml' = $nonStrict }; Required = @('ci.yml'); Pass = $false }
        @{ Name = 'flag explicitly disabled'; Workflows = [ordered]@{ 'ci.yml' = $strict.Replace('--warningsAsErrors', '--warningsAsErrors false') }; Required = @('ci.yml'); Pass = $false }
        @{ Name = 'new workflow without the flag'; Workflows = [ordered]@{ 'ci.yml' = $strict; 'preview.yml' = $nonStrict }; Required = @('ci.yml'); Pass = $false }
        @{ Name = 'required workflow deleted'; Workflows = [ordered]@{ 'ci.yml' = $strict }; Required = @('ci.yml', 'publish-docs.yml'); Pass = $false }
        @{ Name = 'required workflow stops building DocFX'; Workflows = [ordered]@{ 'ci.yml' = "        run: dotnet test" }; Required = @('ci.yml'); Pass = $false }
        @{ Name = 'flag on a continuation line'; Workflows = [ordered]@{ 'ci.yml' = "        run: |`n          dotnet tool run docfx docs/docfx.json \`n            --warningsAsErrors" }; Required = @('ci.yml'); Pass = $true }
        @{ Name = 'path filters and comments are not builds'; Workflows = [ordered]@{ 'ci.yml' = "    paths:`n      - 'docs/docfx.json'`n      # dotnet tool run docfx docs/docfx.json`n$strict"; 'lint.yml' = "    paths:`n      - 'docs/docfx.json'" }; Required = @('ci.yml'); Pass = $true }
    )

    $failures = [System.Collections.Generic.List[string]]::new()
    foreach ($case in $cases) {
        $caseErrors = [System.Collections.Generic.List[string]]::new()
        $null = Test-RepositoryWorkflows -Workflows $case.Workflows -RequiredWorkflows $case.Required -Errors $caseErrors
        if (($caseErrors.Count -eq 0) -ne $case.Pass) {
            $expected = if ($case.Pass) { 'success' } else { 'failure' }
            $failures.Add("Self-test '$($case.Name)' expected $expected but got $($caseErrors.Count) error(s): $($caseErrors -join ' ')")
        }
    }

    if ($failures.Count -gt 0) {
        $failures | ForEach-Object { Write-Error $_ -ErrorAction Continue }
        exit 1
    }

    Write-Host 'Strict DocFX build conformance self-test passed.'
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
$summary.Add('| Site | Repository | Result |')
$summary.Add('| --- | --- | --- |')

foreach ($name in $Site) {
    $definition = $siteDefinitions[$name]
    $siteErrors = [System.Collections.Generic.List[string]]::new()
    $buildCount = 0

    try {
        $workflows = Get-RepositoryWorkflows -Repository $definition.Repository
        $buildCount = Test-RepositoryWorkflows -Workflows $workflows -RequiredWorkflows $definition.RequiredWorkflows -Errors $siteErrors
    }
    catch {
        $siteErrors.Add("Workflows could not be read: $($_.Exception.Message)")
    }

    $repositoryLink = "[$($definition.Repository)](https://github.com/$($definition.Repository)/tree/$Ref/.github/workflows)"
    if ($siteErrors.Count -eq 0) {
        Write-Host "$name ($($definition.Repository)): all $buildCount DocFX workflow build(s) fail on warnings."
        $summary.Add("| $name | $repositoryLink | Passed: $buildCount strict build(s) |")
        continue
    }

    $failedSites++
    $summary.Add("| $name | $repositoryLink | $($siteErrors.Count) finding(s) |")
    foreach ($siteError in $siteErrors) {
        Write-Error "${name}: $siteError" -ErrorAction Continue
        $summary.Add("|  |  | $($siteError.Replace('|', '\|')) |")
    }
}

if ($env:GITHUB_STEP_SUMMARY) {
    @('## Strict DocFX builds', '') + $summary | Add-Content -LiteralPath $env:GITHUB_STEP_SUMMARY -Encoding utf8
}

if ($failedSites -gt 0) {
    exit 1
}

Write-Host 'All DocFX workflow builds fail on warnings.'
