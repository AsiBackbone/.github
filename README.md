# AsiBackbone organization profile

This repository publishes the public organization profile from `profile/README.md`.

## Open proposals, bounded authority

> **Proposal is open. Authority is bounded.**

Anyone may submit a proposal through [AsiBackbone Organization Discussions](https://github.com/orgs/AsiBackbone/discussions), including one drafted with AI assistance; the person who posts it is responsible for it. In this community process, human maintainers alone decide whether a proposal becomes organizational work and authorize any downstream action. See the [public proposal intake guidance](CONTRIBUTING.md#public-proposal-intake).

It also provides organization-default [conduct](CODE_OF_CONDUCT.md), [contribution](CONTRIBUTING.md), [support](SUPPORT.md), [security](SECURITY.md), issue-routing, and pull-request guidance for AsiBackbone repositories that do not define their own files. Repository-specific community files remain authoritative and override these defaults.

The [landing-page standard](LANDING-PAGE-STANDARD.md) defines the shared navigation, information architecture, visual tokens, accessibility requirements, and validation checklist for the organization profile, the organization landing page, and the Learning, AsiBackbone, .NET Core Application Template, and Reference Application documentation sites.

Changes to `main` use a squash-only pull-request flow with the deterministic `Validate organization profile` check. The recovery bypass remains restricted to pull requests so emergency repairs retain an auditable branch and merge record. The shared supporting-repository posture is documented in [`AsiBackbone/asibackbone.github.io`](https://github.com/AsiBackbone/asibackbone.github.io/blob/main/REPOSITORY-GOVERNANCE.md).

A scheduled `Validate published documentation sites` workflow checks the deployed Learning, AsiBackbone, .NET Core Application Template, and Reference Application sites for the standard's document-language, page-metadata, skip-link, homepage-layout, and published-output requirements. It reads the live sites, so it reports drift for the owning repository to fix rather than gating changes here. A scheduled `Validate strict DocFX builds` workflow likewise reads the four repositories' workflow files and reports any DocFX build that does not run with `--warningsAsErrors`.

The [ecosystem compatibility matrix](compatibility/README.md) is the organization's single source for which Learning, AsiBackbone, .NET Core Application Template, and Reference Application versions have been reviewed together, and on which .NET line. It is rendered from the versioned [`compatibility/ecosystem-compatibility.json`](compatibility/ecosystem-compatibility.json) manifest by `scripts/Test-CompatibilityMatrix.ps1`. The required `Validate organization profile` check rejects a malformed manifest, a matrix that no longer matches it, or a profile current-release statement that disagrees with it. A `Compatibility matrix validation` workflow checks every referenced tag and evidence file, and that every Reference Application release is recorded, on matrix pull requests and every week. Its release drift audit compares each project's current release in the matrix with the latest stable GitHub Release of the owning repository, and checks the release each published documentation site states, reporting deployment lag separately from real mismatches. Owning repositories link to the matrix rather than keeping their own copies.

The [security assurance and control-ownership map](assurance/README.md) records, for each important security and governance control across the ecosystem, its single owner, enforcement point, tests, operational dependency, failure behavior, host and operator responsibility, and residual risk, linking to each repository's canonical documentation rather than restating it. It is rendered from [`assurance/control-ownership.json`](assurance/control-ownership.json) by `scripts/Test-AssuranceMap.ps1`, pinned to the compatibility matrix's current reviewed combination, and checked by the required `Validate organization profile` check; an `Assurance map validation` workflow confirms every linked file still exists on map pull requests and every week. It is an ownership map, not a compliance matrix or certification claim.

The [Sigstore release-signing trust policy](assurance/SIGSTORE.md) defines which artifacts warrant signatures, release signer-identity and verification requirements, cross-repository ownership, and non-claims. It is release-supply-chain guidance, not a new organization signing workflow or a substitute for runtime governance signing.

The [documentation ownership map](documentation/README.md) names the canonical owner of each recurring cross-repository documentation topic, the content responsibilities of every documentation surface, and whether other repositories should link only, summarize with a canonical link, or keep a version-pinned snapshot. It includes a review rule for new documentation, which the organization [contribution guidance](CONTRIBUTING.md) and pull-request template link. It is rendered from [`documentation/ownership.json`](documentation/ownership.json) by `scripts/Test-DocumentationOwnership.ps1` and checked by the required `Validate organization profile` check. A weekly `Documentation ownership review` workflow confirms its links and scans each project's first-contact pages for current-version claims that disagree with the compatibility matrix.

The [documentation currency review](DOCUMENTATION-CURRENCY-REVIEW.md) records the dated inventory of this repository's documentation, its retained version references, and the coordination of the matching reviews in each project repository.

The [repository file baseline](REPOSITORY-FILE-BASELINE.md) lists the contributor, maintainer, and repository-control files each project repository is expected to carry, where they live, and why some exist in only some repositories.

GitHub Actions dependencies are maintained by Dependabot and reviewed by dependency-review, CodeQL, zizmor, actionlint, and OpenSSF Scorecard workflows using immutable action pins.

Organization-profile and community-guidance prose is licensed under CC BY 4.0. Validation scripts, workflows, and repository configuration are licensed under MIT. See [LICENSES.md](LICENSES.md), [LICENSE](LICENSE), and [LICENSE-CODE](LICENSE-CODE) for the complete boundary and trademark notice.
