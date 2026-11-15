[CmdletBinding()]
param(
    # Repository whose .editorconfig is the reference copy of the shared rules.
    [string]$ReferenceRepository = 'AsiBackbone/NetCoreApplicationTemplate',

    # Repositories whose shared section must match the reference copy. ReferenceApplication is included because its
    # .editorconfig is generated from the NetCoreApplicationTemplate scaffold.
    [string[]]$Repositories = @(
        'AsiBackbone/AsiBackbone',
        'AsiBackbone/Learning',
        'AsiBackbone/ReferenceApplication'
    ),

    [string]$Branch = 'main',

    [ValidateRange(1, 5)]
    [int]$MaximumAttempts = 3,

    [switch]$SelfTest
)

# Checks that every AsiBackbone .NET repository carries the shared EditorConfig rules unchanged (AsiBackbone/.github#49).
# Each .editorconfig has a shared section followed by a banner such as "# Learning-specific extensions"; everything above
# that banner is compared with the reference repository's shared section. Repository-specific extensions below the banner
# are not compared. See EDITORCONFIG-BASELINE.md. The check reads public files only and never writes to any repository.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Header lines a repository may add to, or omit from, its shared section without changing any rule.
$allowedHeaderLines = @(
    '# This file is also the starting baseline emitted into generated applications.'
)

$extensionBannerPattern = '^# \S.*-specific extensions\s*$'
$bannerRulePattern = '^#{8,}\s*$'

function Get-SharedSection {
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string]$Text,
        [Parameter(Mandatory)][string]$Source
    )

    $lines = $Text.Replace("`r`n", "`n").Split("`n")
    $bannerIndex = -1
    for ($index = 0; $index -lt $lines.Length; $index++) {
        if ($lines[$index] -match $extensionBannerPattern) {
            $bannerIndex = $index
            break
        }
    }

    if ($bannerIndex -lt 0) {
        throw "$Source has no '# <Repository>-specific extensions' banner separating the shared rules from local extensions."
    }

    $end = $bannerIndex
    # Drop the "########" rule line that opens the banner, and any blank lines before it.
    while ($end -gt 0 -and ($lines[$end - 1] -match $bannerRulePattern -or [string]::IsNullOrWhiteSpace($lines[$end - 1]))) {
        $end--
    }

    return @($lines[0..($end - 1)] | Where-Object { $allowedHeaderLines -notcontains $_.TrimEnd() } | ForEach-Object { $_.TrimEnd() })
}

function Compare-SharedSection {
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string[]]$Reference,
        [Parameter(Mandatory)][AllowEmptyString()][string[]]$Candidate,
        [Parameter(Mandatory)][string]$Source
    )

    $count = [Math]::Max($Reference.Length, $Candidate.Length)
    for ($index = 0; $index -lt $count; $index++) {
        $expected = if ($index -lt $Reference.Length) { $Reference[$index] } else { '<end of shared section>' }
        $actual = if ($index -lt $Candidate.Length) { $Candidate[$index] } else { '<end of shared section>' }
        if ($expected -cne $actual) {
            return "$Source differs from the reference shared section at shared line $($index + 1): expected '$expected', found '$actual'."
        }
    }

    return $null
}

function Get-RemoteEditorConfig {
    param([Parameter(Mandatory)][string]$Repository)

    $uri = "https://raw.githubusercontent.com/$Repository/$Branch/.editorconfig"
    for ($attempt = 1; $attempt -le $MaximumAttempts; $attempt++) {
        try {
            return (Invoke-WebRequest -Uri $uri -TimeoutSec 30 -UseBasicParsing).Content
        }
        catch {
            if ($attempt -eq $MaximumAttempts) {
                throw "Could not read $uri after $MaximumAttempts attempt(s): $($_.Exception.Message)"
            }

            Start-Sleep -Seconds (2 * $attempt)
        }
    }
}

if ($SelfTest) {
    $failures = [System.Collections.Generic.List[string]]::new()
    $shared = "# AsiBackbone shared .NET formatting and analyzer baseline.`nroot = true`n`n[*.cs]`nindent_size = 4`n"
    $reference = "$shared`n########################################`n# NetCoreApplicationTemplate-specific extensions`n########################################`n# None.`n"
    $referenceSection = Get-SharedSection -Text $reference -Source 'reference'

    $cases = @(
        [pscustomobject]@{ Name = 'identical shared section with local extensions passes'; Text = "$shared`n########################################`n# Learning-specific extensions`n########################################`n[samples/**/*.cs]`ndotnet_diagnostic.ca1050.severity = none`n"; Pass = $true }
        [pscustomobject]@{ Name = 'CRLF line endings are equivalent'; Text = ("$shared`n# AsiBackbone-specific extensions`n").Replace("`n", "`r`n"); Pass = $true }
        [pscustomobject]@{ Name = 'documented header line is allowed'; Text = $shared.Replace("root = true", "# This file is also the starting baseline emitted into generated applications.`nroot = true") + "`n# Learning-specific extensions`n"; Pass = $true }
        [pscustomobject]@{ Name = 'changed shared rule fails'; Text = $shared.Replace('indent_size = 4', 'indent_size = 2') + "`n# Learning-specific extensions`n"; Pass = $false }
        [pscustomobject]@{ Name = 'extra shared rule fails'; Text = "$shared" + "dotnet_style_readonly_field = true:suggestion`n`n# Learning-specific extensions`n"; Pass = $false }
        [pscustomobject]@{ Name = 'missing extensions banner fails'; Text = $shared; Pass = $false }
    )

    foreach ($case in $cases) {
        $passed = $false
        try {
            $candidate = Get-SharedSection -Text $case.Text -Source $case.Name
            $passed = $null -eq (Compare-SharedSection -Reference $referenceSection -Candidate $candidate -Source $case.Name)
        }
        catch {
            $passed = $false
        }

        if ($passed -ne $case.Pass) {
            $failures.Add("Self-test case '$($case.Name)' expected pass=$($case.Pass) but got pass=$passed.")
        }
    }

    if ($failures.Count -gt 0) {
        $failures | ForEach-Object { Write-Error $_ -ErrorAction Continue }
        exit 1
    }

    Write-Output 'EditorConfig baseline validator self-test passed.'
    exit 0
}

$failures = [System.Collections.Generic.List[string]]::new()
$referenceSection = Get-SharedSection -Text (Get-RemoteEditorConfig -Repository $ReferenceRepository) -Source "$ReferenceRepository/.editorconfig"
Write-Output "Reference: $ReferenceRepository ($($referenceSection.Length) shared lines)."

foreach ($repository in $Repositories) {
    try {
        $candidate = Get-SharedSection -Text (Get-RemoteEditorConfig -Repository $repository) -Source "$repository/.editorconfig"
        $difference = Compare-SharedSection -Reference $referenceSection -Candidate $candidate -Source "$repository/.editorconfig"
        if ($difference) {
            $failures.Add($difference)
        }
        else {
            Write-Output "Matches: $repository"
        }
    }
    catch {
        $failures.Add($_.Exception.Message)
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ -ErrorAction Continue }
    exit 1
}

Write-Output "EditorConfig shared rules match $ReferenceRepository in $($Repositories.Count) repositories."
