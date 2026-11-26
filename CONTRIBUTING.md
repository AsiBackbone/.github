# Contributing to AsiBackbone Projects

Thank you for contributing to an AsiBackbone project.

## Start with the Affected Repository

Repository-specific contribution, support, security, governance, and validation files are authoritative and override these organization defaults. Before opening an issue or pull request, read the affected repository's `CONTRIBUTING.md`, `SUPPORT.md`, `SECURITY.md`, issue templates, and pull-request template when present.

The four primary projects have tailored guidance:

- [AsiBackbone Learning](https://github.com/AsiBackbone/Learning/blob/main/CONTRIBUTING.md) for tutorials, labs, samples, and educational material;
- [AsiBackbone](https://github.com/AsiBackbone/AsiBackbone/blob/main/CONTRIBUTING.md) for the governance framework, packages, APIs, and runtime behavior;
- [.NET Core Application Template](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/main/CONTRIBUTING.md) for the template source, generated scaffold, packaging, and documentation; and
- [AsiBackbone Reference Application](https://github.com/AsiBackbone/ReferenceApplication/blob/main/CONTRIBUTING.md) for the integration host, its configuration and container files, and the integration walkthrough.

## Contribution and Pull Request Policy

AsiBackbone projects use a controlled-contribution model to preserve architectural consistency, security boundaries, and sustainable maintainer review capacity. Public source code remains available under each repository's applicable license; pull request permissions govern contributions to the official repository, not independent forks or use of the licensed work.

- **Start with a proposal.** Open an issue for a reproducible defect or a focused improvement. For larger features or architectural changes, use [organization Discussions](https://github.com/orgs/AsiBackbone/discussions) before undertaking substantial implementation. Follow the repository's security policy for vulnerabilities; do not disclose sensitive details publicly.
- **Explain the change.** Include the problem, intended outcome, affected components, relevant compatibility and security considerations, and a proposed validation approach. A concise proposal is sufficient for minor documentation defects.
- **Maintainer review comes first.** Maintainers evaluate scope, project direction, technical risk, compatibility, testing requirements, and available review capacity. Acknowledgment of an issue or proposal does not constitute approval to implement or a commitment to review within a specific timeframe.
- **Contribution is by agreement.** When a proposal is accepted, maintainers may invite implementation through an appropriate mechanism, such as a patch, a focused pull request where permitted, or time-limited collaborator access. Acceptance of a proposal does not automatically confer repository write access.
- **Integration remains controlled.** Contributions are subject to the affected repository's existing testing, review, licensing, and governance requirements. Maintainers retain final integration and release authority.

Some repositories restrict pull request creation to authorized collaborators. These restrictions do not prevent independent forks or modifications permitted by the applicable license. Unsolicited changes developed without prior agreement may not be reviewed or accepted. Public issues and discussions remain the preferred starting point for outside participation.

## Public Proposal Intake

Humans and agents may propose ideas through [AsiBackbone Organization Discussions](https://github.com/orgs/AsiBackbone/discussions). Search existing Discussions and the affected repository's issues before starting one. If the idea is already entered, add relevant context there instead of creating a duplicate.

Use [Ideas](https://github.com/orgs/AsiBackbone/discussions/categories/ideas) for feature, process, documentation, or outreach proposals. Use [Architecture & Integration](https://github.com/orgs/AsiBackbone/discussions/categories/architecture-integration) for cross-project design, tradeoff, compatibility, or integration decisions. Name the affected repositories and versions, and include the problem or goal, evidence or prior work, alternatives and tradeoffs, risks, and the decision requested.

Every AI-assisted proposal must begin with this notice:

> **AI-assisted proposal — unreviewed:** This discussion was prepared with AI
> assistance and remains a proposal until a maintainer records a decision.

A Discussion invites public review; it is not approval, authorization to implement, or a commitment that the proposal will be incorporated. Maintainers may accept, defer, decline, combine, or adapt proposals at their discretion. Only a maintainer records an organization decision and opens or authorizes a concrete issue or other governed work item. Any downstream issue must link back to the accepted Discussion, and implementation remains subject to the affected repository's contribution and validation rules.

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
