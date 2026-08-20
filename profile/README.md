# AsiBackbone

Most applications don't need a governance layer. When you do need one — when you have to explain why an operation was permitted, under which policy, with what evidence — these are the patterns and the working implementations.

The organization maintains three related projects covering policy-as-code, auditable decision systems, capability-based authorization, host-owned execution boundaries, AI governance, and secure ASP.NET Core application architecture.

## Start Here

### [ASI Backbone Learning](https://github.com/AsiBackbone/Learning) — learn the architecture and patterns

An open, community-oriented learning resource for practical .NET architecture. Covers governed execution and decision-before-execution patterns, policy context and explicit decision outcomes, acknowledgment and audit-residue workflows, capability-scoped and host-owned execution, secure ASP.NET Core architecture, AI tool and agent governance, and architecture comparisons that include when these patterns are unnecessary.

Start here if you want to understand the reasoning before evaluating any implementation.

[Documentation](https://asibackbone.github.io/Learning/) · [Repository](https://github.com/AsiBackbone/Learning)

### [ASI Backbone](https://github.com/AsiBackbone/AsiBackbone) — add governed decision and execution boundaries

A .NET governance and policy-control framework for building auditable, policy-governed decision pipelines: policy evaluation and policy-as-code, AI and application governance, auditable decision records, acknowledgment workflows, capability-based authorization, host-owned execution boundaries, and ASP.NET Core integration.

[Documentation](https://asibackbone.github.io/AsiBackbone/) · [Repository](https://github.com/AsiBackbone/AsiBackbone)

### [.NET Core Application Template](https://github.com/AsiBackbone/NetCoreApplicationTemplate) — start with a secure ASP.NET Core reference architecture

A secure-by-default ASP.NET Core enterprise application template for building maintainable, production-ready .NET applications: authentication and authorization, Serilog structured logging, security headers, rate limiting, EF Core with SQL Server and SQLite, reverse proxy support, and Problem Details error handling.

[Documentation](https://asibackbone.github.io/NetCoreApplicationTemplate/) · [Repository](https://github.com/AsiBackbone/NetCoreApplicationTemplate)

## Design Philosophy

We favor architectures where consequential operations are explicit, constrained, reviewable, and auditable.

We also document when these patterns are unnecessary. See [When ASP.NET Core Authorization Is Enough](https://asibackbone.github.io/Learning/architecture/when-aspnet-core-authorization-is-enough.html) and [When a Simple Application Service Is Enough](https://asibackbone.github.io/Learning/architecture/when-a-simple-application-service-is-enough.html).

Our projects focus on practical .NET engineering rather than claiming regulatory certification or automatic compliance.

## Technologies

.NET · C# · ASP.NET Core · EF Core · Serilog · GitHub Actions

## License

Documentation and educational material are licensed under CC BY 4.0. Source code and executable samples are licensed under the MIT License. See each repository for component-specific terms.
