# AsiBackbone

Most applications don't need a governance layer. When you do need one — when you have to explain why an operation was permitted, under which policy, with what evidence — these are the patterns and the working implementations.

The organization maintains three related projects covering policy-as-code, auditable decision systems, capability-based authorization, host-owned execution boundaries, AI governance, and secure ASP.NET Core application architecture.

## Learn, Ask, and Contribute

- **Start learning:** [AsiBackbone Learning](https://asibackbone.github.io/Learning/) is the first stop for tutorials, labs, and architecture comparisons.
- **Ask a cross-project question:** use organization [Q&A](https://github.com/orgs/AsiBackbone/discussions/categories/q-a) when a question spans repositories or concerns AsiBackbone as a whole.
- **Propose or debate an idea:** use [Ideas](https://github.com/orgs/AsiBackbone/discussions/categories/ideas) for proposals or [Architecture & Integration](https://github.com/orgs/AsiBackbone/discussions/categories/architecture-integration) for cross-project design discussion.
- **Get project-specific help:** use the affected repository's Discussions so support stays with its implementation: [Learning](https://github.com/AsiBackbone/Learning/discussions), [AsiBackbone](https://github.com/AsiBackbone/AsiBackbone/discussions), or [.NET Core Application Template](https://github.com/AsiBackbone/NetCoreApplicationTemplate/discussions).
- **Contribute:** choose the repository affected and follow its guidance: [Learning](https://github.com/AsiBackbone/Learning/blob/main/CONTRIBUTING.md), [AsiBackbone](https://github.com/AsiBackbone/AsiBackbone/blob/main/CONTRIBUTING.md), or [.NET Core Application Template](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/main/CONTRIBUTING.md).
- **Report a sensitive security concern:** do not post vulnerability details publicly. Follow the affected repository's private reporting policy: [Learning](https://github.com/AsiBackbone/Learning/security/policy), [AsiBackbone](https://github.com/AsiBackbone/AsiBackbone/security/policy), or [.NET Core Application Template](https://github.com/AsiBackbone/NetCoreApplicationTemplate/security/policy).

## Start Here

### [ASI Backbone Learning](https://github.com/AsiBackbone/Learning) — learn the architecture and patterns

An open, community-oriented learning resource for practical .NET architecture. Covers governed execution and decision-before-execution patterns, policy context and explicit decision outcomes, acknowledgment and audit-residue workflows, capability-scoped and host-owned execution, secure ASP.NET Core architecture, AI tool and agent governance, and architecture comparisons that include when these patterns are unnecessary.

Start here if you want to understand the reasoning before evaluating any implementation.

[Documentation](https://asibackbone.github.io/Learning/) · [Repository](https://github.com/AsiBackbone/Learning) · [Archive (DOI 10.5281/zenodo.21938556)](https://doi.org/10.5281/zenodo.21938556)

### [ASI Backbone](https://github.com/AsiBackbone/AsiBackbone) — add governed decision and execution boundaries

A .NET governance and policy-control framework for building auditable, policy-governed decision pipelines: policy evaluation and policy-as-code, AI and application governance, auditable decision records, acknowledgment workflows, capability-based authorization, host-owned execution boundaries, and ASP.NET Core integration.

[Documentation](https://asibackbone.github.io/AsiBackbone/) · [Repository](https://github.com/AsiBackbone/AsiBackbone) · [Archive (DOI 10.5281/zenodo.20546032)](https://doi.org/10.5281/zenodo.20546032)

### [.NET Core Application Template](https://github.com/AsiBackbone/NetCoreApplicationTemplate) — start with a secure ASP.NET Core reference architecture

A secure-by-default ASP.NET Core enterprise application template for building maintainable, production-ready .NET applications: authentication and authorization, Serilog structured logging, security headers, rate limiting, EF Core with SQL Server and SQLite, reverse proxy support, and Problem Details error handling.

[Documentation](https://asibackbone.github.io/NetCoreApplicationTemplate/) · [Repository](https://github.com/AsiBackbone/NetCoreApplicationTemplate) · [Archive (DOI 10.5281/zenodo.20373042)](https://doi.org/10.5281/zenodo.20373042)

## Design Philosophy

We favor architectures where consequential operations are explicit, constrained, reviewable, and auditable.

We also document when these patterns are unnecessary. See [When ASP.NET Core Authorization Is Enough](https://asibackbone.github.io/Learning/architecture/when-aspnet-core-authorization-is-enough.html) and [When a Simple Application Service Is Enough](https://asibackbone.github.io/Learning/architecture/when-a-simple-application-service-is-enough.html).

Our projects focus on practical .NET engineering rather than claiming regulatory certification or automatic compliance.

## Technologies

.NET · C# · ASP.NET Core · EF Core · Serilog · GitHub Actions

## License

This organization-profile prose is licensed under CC BY 4.0. Repository automation and configuration are licensed under MIT. These copyright licenses do not grant trademark rights or permission to imply endorsement. See the repository's [licensing boundary](https://github.com/AsiBackbone/.github/blob/main/LICENSES.md), [CC BY 4.0 text](https://github.com/AsiBackbone/.github/blob/main/LICENSE), and [MIT text](https://github.com/AsiBackbone/.github/blob/main/LICENSE-CODE).
