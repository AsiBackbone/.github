# AsiBackbone Ecosystem Compatibility Matrix

<!-- Generated from ecosystem-compatibility.json by scripts/Test-CompatibilityMatrix.ps1 -Update. Do not edit by hand. -->

This matrix records which versions of [AsiBackbone Learning](https://github.com/AsiBackbone/Learning), [AsiBackbone](https://github.com/AsiBackbone/AsiBackbone), the [.NET Core Application Template](https://github.com/AsiBackbone/NetCoreApplicationTemplate) (NCAT), and the [AsiBackbone Reference Application](https://github.com/AsiBackbone/ReferenceApplication) have been reviewed together, and on which .NET line. It is the organization's single source for that information; owning repositories link here rather than keeping their own copies.

The machine-readable source is [`ecosystem-compatibility.json`](ecosystem-compatibility.json). This page is generated from it and checked against it on every pull request. Last updated: 2026-10-23.

> **Boundary:** The matrix records reviewed compatibility evidence. A combination that is not listed is untested, not known to be broken. A listed combination is not a certification, a compliance statement, or a security guarantee; each consuming application remains responsible for its own configuration, threat analysis, deployment controls, testing, and security review.

## Status definitions

| Status | Meaning |
| --- | --- |
| Reviewed together | Built, tested, or reviewed together, with the evidence linked in the row. This is the strongest status the matrix records. |
| Independently supported | Each component is on a supported line, but the combination has not been integration-reviewed. It is likely to work and is not known to be broken. |
| Historical | Was reviewed together and has since been superseded. Kept for reproducibility; not a current recommendation. |
| Incompatible | Known not to work together, with the reason in the notes. |

## Current integration

Each Reference Application release qualifies exactly one NCAT and AsiBackbone combination. The Reference Application is an example host generated from NCAT; its releases are pre-releases and do not declare a stable public contract.

| Status | NCAT | AsiBackbone | Reference Application | .NET | Reviewed | Evidence | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Reviewed together | [2.11.5](https://github.com/AsiBackbone/NetCoreApplicationTemplate/releases/tag/v2.11.5) | [7.5.0](https://github.com/AsiBackbone/AsiBackbone/releases/tag/v7.5.0) | [0.1.0-alpha.11](https://github.com/AsiBackbone/ReferenceApplication/releases/tag/v0.1.0-alpha.11) | `net10.0` (SDK 10.0.400) | 2026-10-22 | [ReferenceApplication@v0.1.0-alpha.11 CHANGELOG.md](https://github.com/AsiBackbone/ReferenceApplication/blob/v0.1.0-alpha.11/CHANGELOG.md)<br>[ReferenceApplication@v0.1.0-alpha.11 Directory.Packages.props](https://github.com/AsiBackbone/ReferenceApplication/blob/v0.1.0-alpha.11/Directory.Packages.props) | Current integration-reviewed combination: the NCAT 2.11.5 scaffold with the AsiBackbone 7.5.0 packages, built and tested by this Reference Application pre-release. |

## Learning review baselines

Learning is educational material, not a package dependency. These rows record which implementation versions a Learning release was reviewed against; they do not make a Learning release a runtime requirement or recommend the reviewed package version over a newer release.

| Status | Learning | Reviewed against AsiBackbone | Reviewed against NCAT | .NET | Reviewed | Evidence | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Reviewed together | [1.3.0](https://github.com/AsiBackbone/Learning/releases/tag/v1.3.0) | [7.0.0](https://github.com/AsiBackbone/AsiBackbone/releases/tag/v7.0.0) | — | `net10.0` (SDK 10.0.400) | 2026-10-10 | [Learning@v1.3.0 docs/getting-started/asibackbone-7-api-boundary.md](https://github.com/AsiBackbone/Learning/blob/v1.3.0/docs/getting-started/asibackbone-7-api-boundary.md) | Current Learning documentation baseline. Its implementation-dependent pages were reviewed against AsiBackbone 7.0.0. Newer AsiBackbone 7.x releases exist; this row records what Learning reviewed, not a recommended package version. |

## Supported lines

Each product is supported independently on the line below. A combination of supported lines that has no row above is independently supported but not integration-reviewed.

| Product | Line | Current release | Target frameworks | Notes |
| --- | --- | --- | --- | --- |
| [AsiBackbone Learning](https://github.com/AsiBackbone/Learning) | 1.x | [1.3.0](https://github.com/AsiBackbone/Learning/releases/tag/v1.3.0) | `net10.0` | Educational material and runnable samples. Learning releases are archival and citation snapshots; they do not establish runtime compatibility or package support lines. |
| [AsiBackbone](https://github.com/AsiBackbone/AsiBackbone) | 7.x | [7.5.0](https://github.com/AsiBackbone/AsiBackbone/releases/tag/v7.5.0) | `net10.0`, `netstandard2.0` | Stable 7.x packages target net10.0 only and are not multi-targeted for .NET 8. AsiBackbone.Analyzers targets netstandard2.0 because it loads in the compiler. |
| [.NET Core Application Template](https://github.com/AsiBackbone/NetCoreApplicationTemplate) | 2.x | [2.11.5](https://github.com/AsiBackbone/NetCoreApplicationTemplate/releases/tag/v2.11.5) | `net10.0` | The 2.x line is feature-complete and maintained for security fixes, dependency servicing, and documentation corrections. Generated applications are not modified by later releases. |
| [AsiBackbone Reference Application](https://github.com/AsiBackbone/ReferenceApplication) | 0.1.0 pre-release | [0.1.0-alpha.11](https://github.com/AsiBackbone/ReferenceApplication/releases/tag/v0.1.0-alpha.11) | `net10.0` | An example host, not a product. Releases remain 0.x pre-releases and do not declare a stable public contract. |
| [.NET 10](https://dotnet.microsoft.com/platform/support/policy/dotnet-core) | LTS | SDK 10.0.400 | `net10.0` | Microsoft support ends 2028-11-14. |

## Historical combinations

These combinations were reviewed together and have since been superseded. They remain for reproducibility of earlier releases and are not current recommendations.

| Status | NCAT | AsiBackbone | Reference Application | .NET | Reviewed | Evidence | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Historical | [2.11.5](https://github.com/AsiBackbone/NetCoreApplicationTemplate/releases/tag/v2.11.5) | [7.2.1](https://github.com/AsiBackbone/AsiBackbone/releases/tag/v7.2.1) | [0.1.0-alpha.5](https://github.com/AsiBackbone/ReferenceApplication/releases/tag/v0.1.0-alpha.5), [0.1.0-alpha.6](https://github.com/AsiBackbone/ReferenceApplication/releases/tag/v0.1.0-alpha.6), [0.1.0-alpha.7](https://github.com/AsiBackbone/ReferenceApplication/releases/tag/v0.1.0-alpha.7), [0.1.0-alpha.8](https://github.com/AsiBackbone/ReferenceApplication/releases/tag/v0.1.0-alpha.8), [0.1.0-alpha.9](https://github.com/AsiBackbone/ReferenceApplication/releases/tag/v0.1.0-alpha.9), [0.1.0-alpha.10](https://github.com/AsiBackbone/ReferenceApplication/releases/tag/v0.1.0-alpha.10) | `net10.0` (SDK 10.0.400) | 2026-10-19 | [ReferenceApplication@v0.1.0-alpha.10 CHANGELOG.md](https://github.com/AsiBackbone/ReferenceApplication/blob/v0.1.0-alpha.10/CHANGELOG.md) | Governed endpoints, persisted and verified governance evidence, evidence query, hashing, and the evidence explorer on AsiBackbone 7.2.1. Superseded by 0.1.0-alpha.11. |
| Historical | [2.11.5](https://github.com/AsiBackbone/NetCoreApplicationTemplate/releases/tag/v2.11.5) | [7.2.0](https://github.com/AsiBackbone/AsiBackbone/releases/tag/v7.2.0) | [0.1.0-alpha.2](https://github.com/AsiBackbone/ReferenceApplication/releases/tag/v0.1.0-alpha.2), [0.1.0-alpha.3](https://github.com/AsiBackbone/ReferenceApplication/releases/tag/v0.1.0-alpha.3), [0.1.0-alpha.4](https://github.com/AsiBackbone/ReferenceApplication/releases/tag/v0.1.0-alpha.4) | `net10.0` (SDK 10.0.400) | 2026-10-18 | [ReferenceApplication@v0.1.0-alpha.4 CHANGELOG.md](https://github.com/AsiBackbone/ReferenceApplication/blob/v0.1.0-alpha.4/CHANGELOG.md) | Partial integration: packages added, services registered, and sample governance rules defined. Endpoints were not yet governed. |
| Historical | [2.11.5](https://github.com/AsiBackbone/NetCoreApplicationTemplate/releases/tag/v2.11.5) | — | [0.1.0-alpha.1](https://github.com/AsiBackbone/ReferenceApplication/releases/tag/v0.1.0-alpha.1) | `net10.0` (SDK 10.0.400) | 2026-10-18 | [ReferenceApplication@v0.1.0-alpha.1](https://github.com/AsiBackbone/ReferenceApplication/tree/v0.1.0-alpha.1) | NCAT 2.11.5 baseline only, with walkthrough Step 1 complete. No AsiBackbone packages were referenced. |

| Status | Learning | Reviewed against AsiBackbone | Reviewed against NCAT | .NET | Reviewed | Evidence | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Historical | [1.1.0](https://github.com/AsiBackbone/Learning/releases/tag/v1.1.0), [1.2.0](https://github.com/AsiBackbone/Learning/releases/tag/v1.2.0) | [7.0.0](https://github.com/AsiBackbone/AsiBackbone/releases/tag/v7.0.0) | — | `net10.0` (SDK 10.0.400) | 2026-10-03 | [Learning@v1.1.0 RELEASE-NOTES-1.1.0.md](https://github.com/AsiBackbone/Learning/blob/v1.1.0/RELEASE-NOTES-1.1.0.md)<br>[Learning@v1.2.0 RELEASE-NOTES-1.2.0.md](https://github.com/AsiBackbone/Learning/blob/v1.2.0/RELEASE-NOTES-1.2.0.md) | Earlier Learning snapshots aligned with the AsiBackbone 7.0.0 boundary. Superseded by Learning 1.3.0. |
| Historical | [1.0.0](https://github.com/AsiBackbone/Learning/releases/tag/v1.0.0) | [6.0.0](https://github.com/AsiBackbone/AsiBackbone/releases/tag/v6.0.0) | — | `net10.0` (SDK 10.0.400) | 2026-09-19 | [Learning@v1.0.0 RELEASE-NOTES-1.0.0.md](https://github.com/AsiBackbone/Learning/blob/v1.0.0/RELEASE-NOTES-1.0.0.md) | First Learning documentation baseline, the educational companion to AsiBackbone 6.0.0. Retained as immutable history. |

## Known incompatibilities

None recorded. Incompatible combinations appear in the tables above with the Incompatible status and the reason in their notes.

## Updating the matrix

1. Edit [`ecosystem-compatibility.json`](ecosystem-compatibility.json). Record a new Reference Application release in exactly one integration entry, mark the entry it supersedes `historical`, and link the release evidence by tag.
2. Run `./scripts/Test-CompatibilityMatrix.ps1 -Update` to regenerate this page, then `./scripts/Test-CompatibilityMatrix.ps1 -VerifyReferences` to confirm that every referenced tag and evidence file exists and that every Reference Application release is recorded.
3. Open a pull request. The `Validate organization profile` check fails when the manifest is malformed or this page does not match it, and the `Compatibility matrix validation` workflow repeats the reference check on the pull request and every week.
