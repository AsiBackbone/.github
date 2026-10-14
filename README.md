# AsiBackbone organization profile

This repository publishes the public organization profile from `profile/README.md`.

It also provides organization-default [conduct](CODE_OF_CONDUCT.md), [contribution](CONTRIBUTING.md), [support](SUPPORT.md), [security](SECURITY.md), issue-routing, and pull-request guidance for AsiBackbone repositories that do not define their own files. Repository-specific community files remain authoritative and override these defaults.

The [landing-page standard](LANDING-PAGE-STANDARD.md) defines the shared navigation, information architecture, visual tokens, accessibility requirements, and validation checklist for the organization profile, the organization landing page, and the Learning, AsiBackbone, and .NET Core Application Template documentation sites.

Changes to `main` use a squash-only pull-request flow with the deterministic `Validate organization profile` check. The recovery bypass remains restricted to pull requests so emergency repairs retain an auditable branch and merge record. The shared supporting-repository posture is documented in [`AsiBackbone/asibackbone.github.io`](https://github.com/AsiBackbone/asibackbone.github.io/blob/main/REPOSITORY-GOVERNANCE.md).

A scheduled `Validate published documentation sites` workflow checks the deployed Learning, AsiBackbone, and .NET Core Application Template sites for the standard's document-language, page-metadata, skip-link, homepage-layout, and published-output requirements. It reads the live sites, so it reports drift for the owning repository to fix rather than gating changes here.

GitHub Actions dependencies are maintained by Dependabot and reviewed by dependency-review, CodeQL, zizmor, actionlint, and OpenSSF Scorecard workflows using immutable action pins.

Organization-profile and community-guidance prose is licensed under CC BY 4.0. Validation scripts, workflows, and repository configuration are licensed under MIT. See [LICENSES.md](LICENSES.md), [LICENSE](LICENSE), and [LICENSE-CODE](LICENSE-CODE) for the complete boundary and trademark notice.
