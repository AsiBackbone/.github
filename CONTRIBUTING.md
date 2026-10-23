# Contributing to AsiBackbone Projects

Thank you for contributing to an AsiBackbone project.

## Start with the Affected Repository

Repository-specific contribution, support, security, governance, and validation files are authoritative and override these organization defaults. Before opening an issue or pull request, read the affected repository's `CONTRIBUTING.md`, `SUPPORT.md`, `SECURITY.md`, issue templates, and pull-request template when present.

The three primary projects have tailored guidance:

- [AsiBackbone Learning](https://github.com/AsiBackbone/Learning/blob/main/CONTRIBUTING.md) for tutorials, labs, samples, and educational material;
- [AsiBackbone](https://github.com/AsiBackbone/AsiBackbone/blob/main/CONTRIBUTING.md) for the governance framework, packages, APIs, and runtime behavior; and
- [.NET Core Application Template](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/main/CONTRIBUTING.md) for the template source, generated scaffold, packaging, and documentation.

## Choose the Right Starting Point

- Use the affected repository's issue tracker for a reproducible defect or clearly scoped change.
- Use [organization Q&A](https://github.com/orgs/AsiBackbone/discussions/categories/q-a) for project-specific and cross-project questions or support. Name the affected repository and version.
- Use [Ideas](https://github.com/orgs/AsiBackbone/discussions/categories/ideas) or [Architecture & Integration](https://github.com/orgs/AsiBackbone/discussions/categories/architecture-integration) before investing in an open-ended proposal.

Do not open a public issue or discussion containing passwords, tokens, personal information, exploit details, or other sensitive material. Follow [the security reporting guidance](SECURITY.md) instead.

## Documentation Ownership

Several repositories document overlapping concepts. The [documentation ownership map](https://github.com/AsiBackbone/.github/blob/main/documentation/README.md) names the canonical owner of each recurring cross-repository topic and how other repositories should reference it: link only, a short summary with a canonical link, or a version-pinned snapshot.

Before adding or expanding documentation, apply its [review rule](https://github.com/AsiBackbone/.github/blob/main/documentation/README.md#review-rule-for-new-documentation): if the content states behavior, an option, an API, a version, or a support boundary that another repository owns, link to that owner instead of restating it. State another project's current version only through the [compatibility matrix](https://github.com/AsiBackbone/.github/blob/main/compatibility/README.md), or tie it to a named release as a pinned snapshot. Keep existing useful summaries, linked to their canonical detail.

## Pull Requests

Keep pull requests focused. Explain:

- the problem and affected repository;
- what changed and what deliberately did not change;
- how the change was validated; and
- any compatibility, security, documentation, or licensing consequences.

Run the checks required by the affected repository and include the results. Passing automation is evidence, not a substitute for reviewing the final diff and project boundaries.

## Contribution Licensing

Contributions are accepted under the license or licensing boundary documented by the affected repository. You must have the right to submit the material under those terms. Do not add third-party code, prose, media, or data without recording the applicable source and license where the repository requires it.

Participation is subject to the [AsiBackbone Code of Conduct](CODE_OF_CONDUCT.md).
