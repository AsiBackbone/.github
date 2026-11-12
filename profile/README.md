# AsiBackbone

**Open-source .NET architecture for accountable decision flow, secure application foundations, and governed execution.**

> **Why was this outcome permitted, under which policy, with what evidence?**

AsiBackbone is an open-source .NET organization focused on making consequential software operations explicit, constrained, reviewable, and auditable.

The ecosystem now consists of four public-facing projects with distinct responsibilities:

- **[AsiBackbone Learning](https://github.com/AsiBackbone/Learning)** teaches the architecture and the reasoning behind it.
- **[AsiBackbone](https://github.com/AsiBackbone/AsiBackbone)** provides the production package family for policy-governed decision flow.
- **[.NET Core Application Template](https://github.com/AsiBackbone/NetCoreApplicationTemplate)** provides a secure-by-default ASP.NET Core application baseline.
- **[AsiBackbone Reference Application](https://github.com/AsiBackbone/ReferenceApplication)** demonstrates how the template and governance framework fit together in a real host.

The organization also maintains the **[organization documentation site](https://asibackbone.github.io/)** and shared organization governance, compatibility, licensing, and assurance material in **[AsiBackbone/.github](https://github.com/AsiBackbone/.github)**.

## Start Here

| Goal | Project | What it provides |
| --- | --- | --- |
| Learn the patterns | **[AsiBackbone Learning](https://asibackbone.github.io/Learning/)** | Tutorials, labs, runnable samples, architecture comparisons, AI/tool-call governance patterns, and guidance on when simpler designs are enough. |
| Add governed decisions | **[AsiBackbone](https://asibackbone.github.io/AsiBackbone/)** | Policy evaluation, decision receipts, acknowledgments, capability grants, durable evidence, signing/verification seams, ASP.NET Core integration, analyzers, templates, and host-owned execution boundaries. |
| Start a secure application | **[.NET Core Application Template](https://asibackbone.github.io/NetCoreApplicationTemplate/)** | A production-oriented .NET 10 ASP.NET Core baseline distributed as a `dotnet new` template, with secure defaults, observability, data-access patterns, health checks, and CI validation. |
| See the integration end to end | **[Reference Application](https://asibackbone.github.io/ReferenceApplication/)** | A stable ASP.NET Core reference host showing AsiBackbone integrated into an NCAT-generated application, including persisted governance evidence, operational exploration, failure paths, and measurable overhead. |

## Current Project State

### [AsiBackbone](https://github.com/AsiBackbone/AsiBackbone)

The stable package family is **7.x**, with **7.5.3** as the current release.

AsiBackbone is a governance framework for **Accountable Systems Infrastructure**. It evaluates policy before host-owned execution, returns structured governance decisions, records decision evidence, supports acknowledgment workflows and scoped capability grants, and provides integration surfaces for persistence, signing, verification, telemetry, and ASP.NET Core.

It is intentionally **not** an authentication system, authorization replacement, immutable ledger, compliance certification service, or intelligence engine. The host application continues to own identity, business authorization, persistence choices, execution, deployment controls, monitoring, and operational response.

[Documentation](https://asibackbone.github.io/AsiBackbone/) · [Repository](https://github.com/AsiBackbone/AsiBackbone) · [NuGet](https://www.nuget.org/packages/AsiBackbone.Core) · [Archive (DOI 10.5281/zenodo.20546032)](https://doi.org/10.5281/zenodo.20546032)

### [AsiBackbone Learning](https://github.com/AsiBackbone/Learning)

Learning is the **canonical educational layer** for the organization.

It teaches decision-before-execution, explicit policy outcomes, acknowledgment and scoped authority, durable audit evidence, secure ASP.NET Core design, AI tool and agent governance, background-work boundaries, distributed authorization concerns, and cross-project architectural tradeoffs.

The material is designed to remain useful **without requiring the AsiBackbone packages**.

[Documentation](https://asibackbone.github.io/Learning/) · [Repository](https://github.com/AsiBackbone/Learning) · [Archive (DOI 10.5281/zenodo.21938556)](https://doi.org/10.5281/zenodo.21938556)

### [.NET Core Application Template](https://github.com/AsiBackbone/NetCoreApplicationTemplate)

NCAT is a reusable, production-oriented **ASP.NET Core baseline for .NET 10**, distributed as a `dotnet new` template.

The current **2.x** line is feature-complete and actively maintained for security fixes, dependency servicing, and documentation corrections. The generated scaffold includes closed-by-default routed endpoints, explicit anonymous access, structured logging, security headers, rate limiting, centralized Problem Details handling, EF Core patterns, health checks, telemetry, reverse-proxy validation, and release/CI controls.

Current release: **2.11.9**.

NCAT is a baseline, not a finished or certified application. Applications generated from it still require application-specific identity configuration, threat analysis, deployment controls, testing, and security review.

[Documentation](https://asibackbone.github.io/NetCoreApplicationTemplate/) · [Repository](https://github.com/AsiBackbone/NetCoreApplicationTemplate) · [NuGet](https://www.nuget.org/packages/NetCoreApplicationTemplate) · [Archive (DOI 10.5281/zenodo.20373042)](https://doi.org/10.5281/zenodo.20373042)

### [AsiBackbone Reference Application](https://github.com/AsiBackbone/ReferenceApplication)

The Reference Application is the organization's **stable integration example**, not a product.

It begins from an NCAT-generated ASP.NET Core host and integrates AsiBackbone step by step. The completed walkthrough covers package integration, service registration, governance rules, governed endpoints, persisted and verified evidence, operational observation, Development-only governance tooling, and governance-overhead benchmarks.

Stable release: **1.0.1**.

The project makes the organization-wide boundary concrete: **AsiBackbone decides before execution; the host owns the operation and its side effects.**

[Documentation](https://asibackbone.github.io/ReferenceApplication/) · [Repository](https://github.com/AsiBackbone/ReferenceApplication)

## The Architectural Boundary

A typical governed operation looks like this:

```text
Request or proposed operation
        |
        v
Host builds safe policy context
        |
        v
Policy and constraints are evaluated
        |
        v
Structured governance decision
        |
        +---- Denied / Deferred / Escalated / Acknowledgment required
        |             |
        |             +--> Host does not execute
        |
        +---- Allowed
                      |
                      v
             Decision evidence recorded
                      |
                      v
              Host-owned execution
```

The important distinction is that **governance does not perform the business operation**. It determines whether the host may proceed and preserves evidence explaining that decision.

## Organization Contracts

The projects are maintained as one ecosystem, but each repository owns a different contract.

- **Learning** owns architecture education, tutorials, terminology explanations, comparisons, and tradeoffs.
- **AsiBackbone** owns package APIs, runtime semantics, integration boundaries, security posture, compatibility, and release behavior.
- **NetCoreApplicationTemplate** owns the secure ASP.NET Core scaffold and the behavior generated from its template package.
- **ReferenceApplication** owns the concrete integration example and its walkthrough.
- **`.github`** owns shared organization governance, compatibility, assurance, contribution, licensing, and community material.
- **`asibackbone.github.io`** owns the organization landing page, organization-wide documentation search, and cross-project navigation.

See the [organization site](https://asibackbone.github.io/), [ecosystem compatibility matrix](https://github.com/AsiBackbone/.github/blob/main/compatibility/README.md), and [security assurance map](https://github.com/AsiBackbone/.github/blob/main/assurance/README.md) for the cross-project view.

## Learn, Ask, and Contribute

- **Start learning:** [AsiBackbone Learning](https://asibackbone.github.io/Learning/)
- **Search across the organization:** [Organization documentation search](https://asibackbone.github.io/search/)
- **Ask a question:** [Organization Q&A](https://github.com/orgs/AsiBackbone/discussions/categories/q-a)
- **Propose an idea:** [Ideas](https://github.com/orgs/AsiBackbone/discussions/categories/ideas)
- **Discuss architecture or integration:** [Architecture & Integration](https://github.com/orgs/AsiBackbone/discussions/categories/architecture-integration)
- **Report a concrete issue:** use the affected project's issue tracker.
- **Report a sensitive security concern:** use the affected repository's private vulnerability-reporting path rather than a public issue.

When asking for help, include the affected repository and version whenever possible.

## Design Philosophy

We favor systems where consequential operations are:

- evaluated **before** execution;
- constrained by explicit policy;
- represented by structured outcomes rather than implicit control flow;
- attributable to the policy and evidence that produced the outcome;
- executed only by the host that owns the real-world side effect; and
- observable without pretending that logs, signatures, or governance metadata provide guarantees they do not actually provide.

We also document when these patterns are unnecessary. Ordinary ASP.NET Core authorization, application services, and conventional logging are often the better design when they already provide the required boundary and evidence.

See:

- [When ASP.NET Core Authorization Is Enough](https://asibackbone.github.io/Learning/architecture/when-aspnet-core-authorization-is-enough.html)
- [When a Simple Application Service Is Enough](https://asibackbone.github.io/Learning/architecture/when-a-simple-application-service-is-enough.html)

## Security and Assurance

The organization treats security claims as bounded claims.

Repositories use automated build, test, documentation, dependency, and security validation appropriate to their role, and the primary projects publish explicit security policies and assurance boundaries.

AsiBackbone does **not** claim automatic compliance, regulatory certification, legal non-repudiation, tamper-proof storage, or security merely because a governance decision or receipt exists.

Start with the organization **[Security Assurance Map](https://github.com/AsiBackbone/.github/blob/main/assurance/README.md)**, then follow the affected repository's `SECURITY.md`.

## Support AsiBackbone

AsiBackbone is independently developed and maintained as an open-source organization. Sponsorship helps support documentation, learning resources, project maintenance, infrastructure, and continued development.

[Support AsiBackbone on Patreon](https://www.patreon.com/AsiBackbone)

Sponsorship is voluntary and does not provide roadmap priority, governance authority, or preferential technical support.

## Technologies

.NET 10 · C# · ASP.NET Core · EF Core · Serilog · OpenTelemetry · GitHub Actions · DocFX

## License

This organization-profile prose is licensed under **CC BY 4.0**. Repository automation and configuration are licensed under **MIT**.

These copyright licenses do not grant trademark rights or permission to imply endorsement. See the `.github` repository's [licensing boundary](https://github.com/AsiBackbone/.github/blob/main/LICENSES.md), [CC BY 4.0 text](https://github.com/AsiBackbone/.github/blob/main/LICENSE), and [MIT text](https://github.com/AsiBackbone/.github/blob/main/LICENSE-CODE).
