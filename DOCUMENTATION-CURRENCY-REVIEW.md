# Documentation Currency Review

**Review date:** 2026-11-18\
**Tracking issue:** [AsiBackbone/.github#58](https://github.com/AsiBackbone/.github/issues/58)\
**Reviewed source:** `main` at `a593d75`, against the [ecosystem compatibility matrix](compatibility/README.md) (updated 2026-11-15), the [documentation ownership map](documentation/README.md), and the [Landing-Page Standard](LANDING-PAGE-STANDARD.md) 3.1.0.

This record covers every documentation surface in this repository and coordinates the matching reviews in the project repositories. This repository has no `docs/` tree, so the review covers the profile, the root guidance files, the compatibility, assurance, and documentation registers, and the issue and pull-request templates.

## Reference points

Published, non-draft, non-prerelease releases, each confirmed as a tag in its owning repository and as the current release on its live documentation homepage on 2026-11-18:

| Project | Release | Live homepage statement |
| --- | --- | --- |
| AsiBackbone Learning | [v1.6.0](https://github.com/AsiBackbone/Learning/releases/tag/v1.6.0) | "Published Learning archive: 1.6.0" |
| AsiBackbone | [v7.5.4](https://github.com/AsiBackbone/AsiBackbone/releases/tag/v7.5.4) | "The current release is 7.5.4." |
| .NET Core Application Template | [v2.11.10](https://github.com/AsiBackbone/NetCoreApplicationTemplate/releases/tag/v2.11.10) | At a glance: "Current release 2.11.10" |
| AsiBackbone Reference Application | [v1.0.2](https://github.com/AsiBackbone/ReferenceApplication/releases/tag/v1.0.2) | At a glance: "Release line Stable 1.0.2" |

The profile, the compatibility manifest, and the assurance baseline agreed with these releases before this change. This review corrects no release number.

## Inventory and classification

| Surface | Files | Classification | Version references |
| --- | --- | --- | --- |
| Organization profile | `profile/README.md` | Current routing and positioning | Each project's current release and support line; now checked against the manifest by the required check |
| Repository guide | `README.md` | Current maintainer guidance | None |
| Compatibility register | `compatibility/ecosystem-compatibility.json`, `compatibility/README.md` | Owner of current release discovery and reviewed combinations; historical rows are pinned | Current, reviewed, and historical releases with tag-pinned evidence |
| Assurance register | `assurance/control-ownership.json`, `assurance/README.md` | Pinned to the current reviewed integration combination | Baseline releases, enforced against the matrix by `scripts/Test-AssuranceMap.ps1` |
| Release-signing and runner policy | `assurance/SIGSTORE.md`, `assurance/RUNNER-HARDENING.md` | Current policy with per-repository status | Releases that introduced signing, as feature-introduction records |
| Documentation ownership register | `documentation/ownership.json`, `documentation/README.md` | Current routing | Illustrative examples only |
| Standards and baselines | `LANDING-PAGE-STANDARD.md`, `REPOSITORY-FILE-BASELINE.md`, `EDITORCONFIG-BASELINE.md` | Current guidance with dated baseline reviews | The standard's own version history; dated reviews stay historical |
| Community health defaults | `CODE_OF_CONDUCT.md`, `CONTRIBUTING.md`, `SUPPORT.md`, `SECURITY.md`, `.github/PULL_REQUEST_TEMPLATE.md`, `.github/ISSUE_TEMPLATE/config.yml` | Current organization defaults | The Contributor Covenant version only |
| Licensing | `LICENSE`, `LICENSE-CODE`, `LICENSES.md` | Current boundary | None |
| Validation and automation | `scripts/`, `.github/workflows/`, `eng/repository-controls/` | Current implementation | Action pins only (immutable digests) |

## Findings

1. **No release drift detection.** `scripts/Test-CompatibilityMatrix.ps1 -VerifyReferences` confirmed that every referenced tag exists, so a superseded but existing tag stayed accepted after a newer release. *Resolved:* `-AuditReleases` compares each support line's current release with the owning repository's latest stable GitHub Release, under a documented selection policy, and reads the four published homepages for their current-release markers. It reports deployment lag, HTTP failures, missing markers, and version mismatches as separate findings with the source, observed value, expected release, and URL. The weekly `Compatibility matrix validation` workflow runs it with bounded retries.
2. **Profile claims were unchecked.** `profile/README.md` states each project's current release by hand, and only the weekly online scan compared those statements with the matrix. *Resolved:* the required `Validate organization profile` check now fails, offline, when a profile current-release or support-line statement disagrees with `supportLines`.
3. **Landing-page standard scope in the README.** `README.md` described the standard as covering the Learning, AsiBackbone, and .NET Core Application Template sites, omitting the Reference Application added in standard 2.0.0. *Corrected.*
4. **Landing-page standard change history.** The change history skipped versions 2.1.0 and 3.0.0, which pull requests #37 and #38 introduced. *Corrected* by adding both rows. The requirements did not change, so the standard keeps version 3.1.0.
5. **Learning and historical pins.** The audit reads only support lines, never combinations. Learning's AsiBackbone 7.0.0 and NCAT 2.11.2 review baseline and the historical integration rows record what was reviewed and are left unchanged; self-tests assert that the audit never reports or edits them.
6. **Deeper guidance.** No guide in this repository presents a release or major line as current outside the profile and the generated registers. The retained references below each carry a compatibility, evidence, or historical purpose.

## Retained version references

| Reference | Purpose |
| --- | --- |
| Profile current releases and support lines | Central first-contact release discovery, now validated against the matrix |
| Matrix current, reviewed, and historical releases | The organization's authoritative compatibility record |
| Assurance-map baselines | Version-pinned control evidence, enforced against the matrix's current reviewed combination |
| Releases named in `assurance/SIGSTORE.md` | The releases that introduced signing in each repository |
| Landing-page standard versions and dated baseline reviews | Standard version history and historical review records |
| Contributor Covenant 2.1 | The adopted text's exact version |

## Published counterparts

On 2026-11-18 the live homepages of all four project sites stated the current releases above, matching their `docs/index.md` sources on `main`, so there was no deployment drift. Search-engine snippets and caches were not used as evidence of what the sites serve.

## Organization coordination

Each project repository reviews its own documentation tree under its own issue; this repository cannot change their files.

| Repository | Issue | Status observed on 2026-11-18 |
| --- | --- | --- |
| AsiBackbone | [AsiBackbone/AsiBackbone#945](https://github.com/AsiBackbone/AsiBackbone/issues/945) | Not reviewed here |
| .NET Core Application Template | [AsiBackbone/NetCoreApplicationTemplate#718](https://github.com/AsiBackbone/NetCoreApplicationTemplate/issues/718) | Not reviewed here |
| Reference Application | [AsiBackbone/ReferenceApplication#153](https://github.com/AsiBackbone/ReferenceApplication/issues/153) | Not reviewed here |
| Learning | [AsiBackbone/Learning#507](https://github.com/AsiBackbone/Learning/issues/507) | Changes merged to `main` in Learning pull request #508 |
| Organization landing site | [AsiBackbone/asibackbone.github.io#45](https://github.com/AsiBackbone/asibackbone.github.io/issues/45) | A commit referencing this issue adds the generated current-release summary |

## Follow-up for owning repositories

- **Reference Application description (standard 3.1.0).** The Related Projects card for the Reference Application on the Learning, AsiBackbone, NCAT, and Reference Application homepages describes it as "An NCAT-generated ASP.NET Core host…" without the required "stable integration example, not a product" phrase. Each owning repository should update its card; their READMEs already use the phrase.
- **"Specimens" wording in Learning.** The Learning homepage asks readers to treat the working repositories "as specimens". The standard retired "integration specimen" for the Reference Application; Learning should confirm whether this general wording is intended.
- **Marker stability.** The release drift audit reads one current-release statement from each homepage. A repository that rewords that statement should update the marker definition in `scripts/Test-CompatibilityMatrix.ps1` in the same change, or the audit will report a missing marker.

## Controls

- The required `Validate organization profile` check runs the manifest, rendering, and profile current-release checks offline, and the validator self-tests, which cover a newer stable release, pre-release-only and draft changes, an unavailable API or site, a missing marker, deployment lag, a version mismatch, and intentional historical pins.
- The `Compatibility matrix validation` workflow runs `./scripts/Test-CompatibilityMatrix.ps1 -VerifyReferences -AuditReleases` on matrix and profile pull requests, every week, and on demand, and writes its findings to the job summary.
- The release drift audit is documented, including how to resolve each finding, in [Release drift audit](compatibility/README.md#release-drift-audit).
