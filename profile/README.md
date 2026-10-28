# AsiBackbone

Most applications don't need a governance layer. When you do need one — when you have to explain why an operation was permitted, under which policy, with what evidence — these are the patterns and the working implementations.

The organization maintains three related projects covering policy-as-code, auditable decision systems, capability-based authorization, host-owned execution boundaries, AI governance, and secure ASP.NET Core application architecture, plus a reference application that combines them. The [organization site](https://asibackbone.github.io/) gives an overview of all four, the [ecosystem compatibility matrix](https://github.com/AsiBackbone/.github/blob/main/compatibility/README.md) records which of their versions have been reviewed together, and the [security assurance map](https://github.com/AsiBackbone/.github/blob/main/assurance/README.md) records who owns each security control and what it does not claim.

## Learn, Ask, and Contribute

- **Start learning:** [AsiBackbone Learning](https://asibackbone.github.io/Learning/) is the first stop for tutorials, labs, and architecture comparisons.
- **Ask a question:** use organization [Q&A](https://github.com/orgs/AsiBackbone/discussions/categories/q-a) for project-specific and cross-project help. Name the affected repository and version.
- **Propose or debate an idea:** use [Ideas](https://github.com/orgs/AsiBackbone/discussions/categories/ideas) for proposals or [Architecture & Integration](https://github.com/orgs/AsiBackbone/discussions/categories/architecture-integration) for design and integration discussion.
- **Contribute:** choose the repository affected and follow its guidance: [Learning](https://github.com/AsiBackbone/Learning/blob/main/CONTRIBUTING.md), [AsiBackbone](https://github.com/AsiBackbone/AsiBackbone/blob/main/CONTRIBUTING.md), or [.NET Core Application Template](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/main/CONTRIBUTING.md).
- **Report a sensitive security concern:** do not post vulnerability details publicly. Follow the affected repository's private reporting policy: [Learning](https://github.com/AsiBackbone/Learning/security/policy), [AsiBackbone](https://github.com/AsiBackbone/AsiBackbone/security/policy), or [.NET Core Application Template](https://github.com/AsiBackbone/NetCoreApplicationTemplate/security/policy).

## Start Here

### [AsiBackbone Learning](https://github.com/AsiBackbone/Learning) — learn the patterns

An open, community-oriented learning resource for practical .NET architecture. Covers governed execution and decision-before-execution patterns, policy context and explicit decision outcomes, acknowledgment and audit-residue workflows, capability-scoped and host-owned execution, secure ASP.NET Core architecture, AI tool and agent governance, and architecture comparisons that include when these patterns are unnecessary.

Start here if you want to understand the reasoning before evaluating any implementation.

[Documentation](https://asibackbone.github.io/Learning/) · [Repository](https://github.com/AsiBackbone/Learning) · [Archive (DOI 10.5281/zenodo.21938556)](https://doi.org/10.5281/zenodo.21938556)

### [AsiBackbone](https://github.com/AsiBackbone/AsiBackbone) — add governed decisions

A .NET governance and policy-control framework for building auditable, policy-governed decision pipelines: policy evaluation and policy-as-code, AI and application governance, auditable decision records, acknowledgment workflows, capability-based authorization, host-owned execution boundaries, and ASP.NET Core integration.

[Documentation](https://asibackbone.github.io/AsiBackbone/) · [Repository](https://github.com/AsiBackbone/AsiBackbone) · [Archive (DOI 10.5281/zenodo.20546032)](https://doi.org/10.5281/zenodo.20546032)

### [.NET Core Application Template](https://github.com/AsiBackbone/NetCoreApplicationTemplate) — start a secure application

A reusable, production-oriented ASP.NET Core baseline with secure defaults for building maintainable .NET applications: authentication and authorization, Serilog structured logging, security headers, rate limiting, EF Core with SQL Server and SQLite, reverse proxy support, and Problem Details error handling. It is not a finished, penetration-tested, or certified application; each generated application still requires application-specific configuration, threat analysis, deployment controls, testing, and security review.

[Documentation](https://asibackbone.github.io/NetCoreApplicationTemplate/) · [Repository](https://github.com/AsiBackbone/NetCoreApplicationTemplate) · [Archive (DOI 10.5281/zenodo.20373042)](https://doi.org/10.5281/zenodo.20373042)

### [AsiBackbone Reference Application](https://github.com/AsiBackbone/ReferenceApplication) — follow the integration

An ASP.NET Core host generated from the .NET Core Application Template, with AsiBackbone integration in progress, a step-by-step walkthrough of the procedure, and a generated API reference. It is an example, not a product; its planned sample governance rules illustrate patterns and are not recommendations for any specific domain.

[Documentation](https://asibackbone.github.io/ReferenceApplication/) · [Repository](https://github.com/AsiBackbone/ReferenceApplication)

## Design Philosophy

We favor architectures where consequential operations are explicit, constrained, reviewable, and auditable.

We also document when these patterns are unnecessary. See [When ASP.NET Core Authorization Is Enough](https://asibackbone.github.io/Learning/architecture/when-aspnet-core-authorization-is-enough.html) and [When a Simple Application Service Is Enough](https://asibackbone.github.io/Learning/architecture/when-a-simple-application-service-is-enough.html).

Our projects focus on practical .NET engineering rather than claiming regulatory certification or automatic compliance.

## Technologies

.NET · C# · ASP.NET Core · EF Core · Serilog · GitHub Actions

## License

This organization-profile prose is licensed under CC BY 4.0. Repository automation and configuration are licensed under MIT. These copyright licenses do not grant trademark rights or permission to imply endorsement. See the repository's [licensing boundary](https://github.com/AsiBackbone/.github/blob/main/LICENSES.md), [CC BY 4.0 text](https://github.com/AsiBackbone/.github/blob/main/LICENSE), and [MIT text](https://github.com/AsiBackbone/.github/blob/main/LICENSE-CODE).
