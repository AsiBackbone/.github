# AsiBackbone Security Reporting

Thank you for reporting security concerns responsibly.

## Report Privately

Do not disclose exploit details, secrets, personal data, or other sensitive material in a public issue, pull request, or Discussion.

Report the concern privately to the repository that owns the affected component:

| Affected area | Private reporting route |
| --- | --- |
| AsiBackbone packages, APIs, or runtime | [Report to AsiBackbone](https://github.com/AsiBackbone/AsiBackbone/security/advisories/new) |
| Learning documentation, samples, or publishing automation | [Report to Learning](https://github.com/AsiBackbone/Learning/security/advisories/new) |
| .NET Core Application Template or generated scaffold | [Report to NetCoreApplicationTemplate](https://github.com/AsiBackbone/NetCoreApplicationTemplate/security/advisories/new) |
| Organization profile or default community files | [Report to the `.github` repository](https://github.com/AsiBackbone/.github/security/advisories/new) |
| Organization landing page | [Report to the landing repository](https://github.com/AsiBackbone/asibackbone.github.io/security/advisories/new) |

For another AsiBackbone repository, use its Security tab when private vulnerability reporting is available. If no private route is available, use the [`.github` private reporting route](https://github.com/AsiBackbone/.github/security/advisories/new) and identify the affected repository. Repository-specific `SECURITY.md` files remain authoritative and override this default policy.

## What to Include

Provide, when practical:

- the affected repository, version, commit, page, or workflow;
- a concise description of the suspected vulnerability;
- reproduction steps or a minimal proof of concept;
- the practical impact and required preconditions;
- known mitigations or workarounds; and
- whether the information has been disclosed elsewhere.

Do not include real credentials or unnecessary personal or production data. Use clearly fictional or redacted values in reproductions.

## What to Expect

The maintainer will assess the report, clarify scope when needed, and coordinate remediation and disclosure when a vulnerability is confirmed. This is a community-maintained open-source organization and does not promise a formal response SLA or fixed remediation timeline.

Reports that are usage questions, general hardening suggestions, compliance requests, or defects without a security impact may be redirected to the appropriate public support or issue channel.

These projects do not provide end-to-end production security, legal assurance, regulatory certification, or automatic compliance. Consuming applications remain responsible for their own authentication, authorization, deployment, infrastructure, data protection, monitoring, and incident-response controls.

## Repository Control Posture

This repository publishes organization-profile content, default community files,
GitHub Actions workflows, the ecosystem compatibility manifest and matrix,
deterministic PowerShell validation scripts, and PowerShell checks that read the
public AsiBackbone documentation sites and the public workflow files, release
tags, and files of the ecosystem repositories with read-only repository
permissions. It does not ship a service, library, parser, or other runtime that
accepts untrusted application input.

- CodeQL analyzes every pull request and every push to `main` for vulnerabilities
  in GitHub Actions workflows. Zizmor and actionlint provide complementary
  workflow-specific analysis.
- The active `Main branch security baseline` ruleset requires pull requests,
  resolved review conversations, linear history, and three status checks that
  run on every pull request to `main`: `Validate organization profile`,
  `Analyze GitHub Actions with CodeQL`, and `Dependency review`. It also requires
  CodeQL code-scanning results, blocking security alerts of medium severity or
  higher and alerts at error or warning level, and it blocks deletion and force
  pushes to `main`. Its desired state is versioned in
  [`eng/repository-controls/main-branch-ruleset.json`](eng/repository-controls/main-branch-ruleset.json).
- Path-filtered and scheduled checks are intentionally not required, because a
  required check that does not run would block unrelated pull requests. Zizmor
  and actionlint run on pull requests that change workflows or Dependabot
  configuration, the compatibility matrix and assurance map reference checks run
  on pull requests that change them and weekly, and OpenSSF Scorecard runs on its
  weekly schedule.
- Fuzzing is not used because the repository has no fuzzable runtime or untrusted
  input-processing surface. Reconsider this decision if executable application,
  parsing, or request-handling code is added.
- An approving human review is not mandatory while the organization has one
  active maintainer. A pull-request-only owner bypass preserves recovery from a
  broken profile or required check without enabling direct pushes to `main`.
  Reconsider required approvals and Code Owner review when an independent active
  maintainer is available.

These proportionate exceptions explain the OpenSSF Scorecard fuzzing,
branch-protection, and code-review findings; they are reviewed controls rather
than evidence that those protections were overlooked.
