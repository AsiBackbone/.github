# AsiBackbone Security Assurance and Control-Ownership Map

<!-- Generated from control-ownership.json by scripts/Test-AssuranceMap.ps1 -Update. Do not edit by hand. -->

This map records, for each important security and governance control in the AsiBackbone ecosystem, who owns it, where it is enforced, how it is tested, what it depends on, how it fails, what the deploying host still owns, and what it does not claim. It maps responsibility; the technical contracts stay in the linked repository documentation, which is authoritative.

> **Boundary:** This is an assurance and ownership map, not a compliance matrix or a certification claim. A linked test shows that a behavior is exercised, not that a deployment is secure. Where evidence is missing, the map says so rather than assuming it.

Reviewed 2026-10-23 against [.NET Core Application Template 2.11.5](https://github.com/AsiBackbone/NetCoreApplicationTemplate/releases/tag/v2.11.5), [AsiBackbone 7.5.0](https://github.com/AsiBackbone/AsiBackbone/releases/tag/v7.5.0), and [Reference Application 0.1.0-alpha.11](https://github.com/AsiBackbone/ReferenceApplication/releases/tag/v0.1.0-alpha.11), the current integration-reviewed combination in the [ecosystem compatibility matrix](../compatibility/README.md). Product links are pinned to those release tags. Repository-host links point to each repository's `main` branch, because those settings are not versioned with releases. Learning is educational material and owns no runtime control, so it has no rows. The machine-readable source is [`control-ownership.json`](control-ownership.json).

## Owners

| Owner | Responsibility |
| --- | --- |
| AsiBackbone | The AsiBackbone package family. Owns governance primitives and their fail-closed defaults. |
| .NET Core Application Template | The template and the baseline it generates. Owns host defaults that a generated application inherits. |
| Reference Application | The example host. Owns controls it adds while integrating AsiBackbone; it is an example, not a product. |
| Organization (.github) | This repository. Owns organization defaults, standards, and this map. |
| Deploying host and operator | Whoever builds and runs an application. Owns controls no library or template can supply. |

## Failure modes

| Mode | Meaning |
| --- | --- |
| Fails closed | A failed or missing check blocks the operation, the request, or startup. |
| Defers | Work is kept and retried or held for review instead of being lost or blocking the business operation. |
| Warns | Unsafe postures are reported, and some invalid settings stop startup, but common deployment gaps only warn. |
| Host-defined | The component reports the result; the host decides what it blocks. |
| Fails open | A failed check lets the operation continue. Recorded so the choice stays visible. |

## Summary

| Control | Scope | Owner | Failure mode | Evidence |
| --- | --- | --- | --- | --- |
| [Authenticated-by-default routed endpoints](#authenticated-by-default) | Authentication and endpoint authorization | .NET Core Application Template | Fails closed | 2 linked |
| [Governance policy evaluation](#policy-evaluation) | Policy evaluation and decision before execution | AsiBackbone | Fails closed | 2 linked |
| [Decision before execution at the HTTP edge](#decision-before-execution) | Policy evaluation and decision before execution | AsiBackbone | Fails closed | 3 linked |
| [Acknowledgment challenge before continuation](#acknowledgment-handshake) | Acknowledgment and handshake | AsiBackbone | Fails closed | 2 linked |
| [Signed capability grants and replay protection](#capability-grants) | Capability grants and replay protection | AsiBackbone | Fails closed | 4 linked |
| [Decision evidence persistence](#decision-evidence-persistence) | Decision and evidence persistence | AsiBackbone | Host-defined | 2 linked |
| [Application mutation audit manifest digest](#mutation-manifest-digest) | Decision and evidence persistence | .NET Core Application Template | Host-defined | 2 linked |
| [Governance outbox delivery](#governance-outbox) | Outbox and reconciliation | AsiBackbone | Defers | 2 linked |
| [Audit completion outbox and reconciliation](#audit-completion-reconciliation) | Outbox and reconciliation | .NET Core Application Template | Defers | 3 linked |
| [Signature verification policy](#signature-verification) | Signing and verification | AsiBackbone | Fails closed | 3 linked |
| [Audit-integrity hash chain](#audit-integrity-chain) | Signing and verification | AsiBackbone | Host-defined | 2 linked |
| [Production signing-key custody](#key-custody) | Key custody | Deploying host and operator | Host-defined | 2 linked, gap recorded |
| [ASP.NET Core Data Protection key ring](#data-protection) | Data Protection | .NET Core Application Template | Warns | 1 linked |
| [Reverse-proxy and TLS trust](#proxy-tls-trust) | Proxy and TLS trust | .NET Core Application Template | Fails closed | 3 linked |
| [Request rate limiting](#rate-limiting) | Rate limiting | .NET Core Application Template | Fails closed | 1 linked |
| [Health and readiness endpoints](#health-readiness) | Health and readiness exposure | .NET Core Application Template | Warns | 2 linked |
| [Database migrations and provider support](#migrations-providers) | Database migrations and provider support | .NET Core Application Template | Warns | 2 linked |
| [Development-only plain-HTTP cookie override](#development-insecure-cookie) | Development-only feature isolation | .NET Core Application Template | Fails closed | 1 linked |
| [Local-development signing kept out of production](#development-local-signing) | Development-only feature isolation | AsiBackbone | Fails closed | 2 linked |
| [Reference Application demo identity](#development-demo-identity) | Development-only feature isolation | Reference Application | Fails closed | 1 linked |
| [NCAT release provenance and SBOM evidence](#ncat-release-evidence) | Release, provenance, and SBOM evidence | .NET Core Application Template | Fails closed | 2 linked |
| [AsiBackbone package provenance and SBOM evidence](#asibackbone-release-evidence) | Release, provenance, and SBOM evidence | AsiBackbone | Fails closed | 2 linked |
| [NCAT repository rulesets and security scanning](#ncat-repository-controls) | Repository-host rulesets and security scanning | .NET Core Application Template | Fails closed | 2 linked |
| [AsiBackbone repository rulesets and security scanning](#asibackbone-repository-controls) | Repository-host rulesets and security scanning | AsiBackbone | Fails closed | 1 linked, gap recorded |
| [Reference Application repository rulesets](#reference-repository-controls) | Repository-host rulesets and security scanning | Reference Application | Fails closed | 1 linked, gap recorded |
| [Organization repository rulesets and security scanning](#organization-repository-controls) | Repository-host rulesets and security scanning | Organization (.github) | Fails closed | 2 linked, gap recorded |

## Controls

### Authentication and endpoint authorization

<a id="authenticated-by-default"></a>

#### Authenticated-by-default routed endpoints

A routed endpoint without authorization metadata requires an authenticated user; public access needs explicit anonymous metadata.

- **Owner:** .NET Core Application Template
- **Enforcement point:** Authenticated-user fallback authorization policy — [NetCoreApplicationTemplate `src/ProjectTemplate.Web/Authentication/Extensions/AuthorizationServiceExtensions.cs`](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/v2.11.5/src/ProjectTemplate.Web/Authentication/Extensions/AuthorizationServiceExtensions.cs)
- **Tests and evidence:** [NetCoreApplicationTemplate `tests/ProjectTemplate.Web.Tests/FallbackAuthorizationPolicyTests.cs`](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/v2.11.5/tests/ProjectTemplate.Web.Tests/FallbackAuthorizationPolicyTests.cs), [NetCoreApplicationTemplate `tests/ProjectTemplate.Web.Tests/AuthorizationPolicyTests.cs`](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/v2.11.5/tests/ProjectTemplate.Web.Tests/AuthorizationPolicyTests.cs)
- **Operational dependency:** A configured sign-in provider or host-owned identity flow. The default scaffold has none, so protected routes stay unavailable until one is added.
- **Failure behavior:** Fails closed. Unannotated routed endpoints reject anonymous users. The --authProvider none scaffold and RequireAuthenticatedUserByDefault=false are explicit opt-outs that make unannotated endpoints public.
- **Host and operator responsibility:** Configure the identity provider, review and test every anonymous exception, and authorize access to business resources and operations.
- **Residual risk and non-claims:** Requires an authenticated identity; it does not decide whether that identity may act on a specific resource. Named role and permission policies apply only where an endpoint declares them.
- **Canonical documentation:** [NetCoreApplicationTemplate `docs/articles/authorization.md`](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/v2.11.5/docs/articles/authorization.md), [NetCoreApplicationTemplate `docs/articles/authentication.md`](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/v2.11.5/docs/articles/authentication.md)

### Policy evaluation and decision before execution

<a id="policy-evaluation"></a>

#### Governance policy evaluation

A governance decision reflects every registered constraint, and a denial from any constraint wins.

- **Owner:** AsiBackbone
- **Enforcement point:** Default governance policy evaluator — [AsiBackbone `src/AsiBackbone.Core/Evaluation/DefaultGovernancePolicyEvaluator.cs`](https://github.com/AsiBackbone/AsiBackbone/blob/v7.5.0/src/AsiBackbone.Core/Evaluation/DefaultGovernancePolicyEvaluator.cs)
- **Tests and evidence:** [AsiBackbone `tests/AsiBackbone.Core.Tests/Evaluation/DefaultAsiBackbonePolicyEvaluatorTests.cs`](https://github.com/AsiBackbone/AsiBackbone/blob/v7.5.0/tests/AsiBackbone.Core.Tests/Evaluation/DefaultAsiBackbonePolicyEvaluatorTests.cs), [AsiBackbone `tests/AsiBackbone.Core.Tests/Evaluation/DefaultAsiBackbonePolicyEvaluatorCriticalExceptionTests.cs`](https://github.com/AsiBackbone/AsiBackbone/blob/v7.5.0/tests/AsiBackbone.Core.Tests/Evaluation/DefaultAsiBackbonePolicyEvaluatorCriticalExceptionTests.cs)
- **Operational dependency:** Host-registered constraints, threat contributors, and decision policy.
- **Failure behavior:** Fails closed. An empty constraint set denies by default (DenyWhenNoConstraints), and constraint and threat-contributor exceptions become denials by default. Both defaults can be switched off; the permissive empty-policy path then only logs a warning.
- **Host and operator responsibility:** Register constraints that express the real policy, and keep the fail-closed defaults unless a documented lower-risk exception applies.
- **Residual risk and non-claims:** A decision is only as complete as the registered constraints. Endpoint policy markers do not select or derive constraints; every registered constraint runs on every governed endpoint.
- **Canonical documentation:** [AsiBackbone `docs/articles/policy-evaluator-pipeline.md`](https://github.com/AsiBackbone/AsiBackbone/blob/v7.5.0/docs/articles/policy-evaluator-pipeline.md)

<a id="decision-before-execution"></a>

#### Decision before execution at the HTTP edge

A governed endpoint executes only after an allowing decision; denied, unverified, or misconfigured requests do not reach the endpoint.

- **Owner:** AsiBackbone
- **Enforcement point:** Endpoint governance middleware, registered after routing and authentication — [AsiBackbone `src/AsiBackbone.AspNetCore/Endpoints/EndpointGovernanceMiddleware.cs`](https://github.com/AsiBackbone/AsiBackbone/blob/v7.5.0/src/AsiBackbone.AspNetCore/Endpoints/EndpointGovernanceMiddleware.cs)
- **Tests and evidence:** [AsiBackbone `tests/AsiBackbone.AspNetCore.Tests/Endpoints/AsiBackboneEndpointGovernanceTests.cs`](https://github.com/AsiBackbone/AsiBackbone/blob/v7.5.0/tests/AsiBackbone.AspNetCore.Tests/Endpoints/AsiBackboneEndpointGovernanceTests.cs), [AsiBackbone `tests/AsiBackbone.AspNetCore.Tests/Endpoints/AsiBackboneEndpointGovernanceOrderingTests.cs`](https://github.com/AsiBackbone/AsiBackbone/blob/v7.5.0/tests/AsiBackbone.AspNetCore.Tests/Endpoints/AsiBackboneEndpointGovernanceOrderingTests.cs), [ReferenceApplication `tests/ReferenceApplication.Web.Tests/GovernanceEnforcementTests.cs`](https://github.com/AsiBackbone/ReferenceApplication/blob/v0.1.0-alpha.11/tests/ReferenceApplication.Web.Tests/GovernanceEnforcementTests.cs)
- **Operational dependency:** Correct middleware order and a registered policy evaluator.
- **Failure behavior:** Fails closed. The middleware blocks the endpoint with a safe HTTP result when policy, capability, or configuration checks fail. Invalid endpoint-governance options fail at startup through options validation.
- **Host and operator responsibility:** Gate every non-HTTP path yourself (background jobs, message consumers, internal services, CLI tools), place side effects below the decision check, and treat a missing decision or failed evaluation as a denial on consequential paths.
- **Residual risk and non-claims:** Protects only the HTTP endpoints where the middleware is registered. AsiBackbone does not execute operations and cannot make a host honor a decision.
- **Canonical documentation:** [AsiBackbone `docs/articles/aspnetcore-endpoint-governance.md`](https://github.com/AsiBackbone/AsiBackbone/blob/v7.5.0/docs/articles/aspnetcore-endpoint-governance.md), [AsiBackbone `docs/articles/host-owned-execution-enforcement.md`](https://github.com/AsiBackbone/AsiBackbone/blob/v7.5.0/docs/articles/host-owned-execution-enforcement.md)

### Acknowledgment and handshake

<a id="acknowledgment-handshake"></a>

#### Acknowledgment challenge before continuation

An acknowledgment-required decision answers with a challenge and does not execute until an acknowledged retry is evaluated again.

- **Owner:** AsiBackbone
- **Enforcement point:** Acknowledgment challenge service — [AsiBackbone `src/AsiBackbone.AspNetCore/Acknowledgments/DefaultAcknowledgmentChallengeService.cs`](https://github.com/AsiBackbone/AsiBackbone/blob/v7.5.0/src/AsiBackbone.AspNetCore/Acknowledgments/DefaultAcknowledgmentChallengeService.cs)
- **Tests and evidence:** [AsiBackbone `tests/AsiBackbone.AspNetCore.Tests/Acknowledgments/AsiBackboneAcknowledgmentChallengeServiceTests.cs`](https://github.com/AsiBackbone/AsiBackbone/blob/v7.5.0/tests/AsiBackbone.AspNetCore.Tests/Acknowledgments/AsiBackboneAcknowledgmentChallengeServiceTests.cs), [AsiBackbone `tests/AsiBackbone.Core.Tests/Acknowledgments/AcknowledgmentResponseTests.cs`](https://github.com/AsiBackbone/AsiBackbone/blob/v7.5.0/tests/AsiBackbone.Core.Tests/Acknowledgments/AcknowledgmentResponseTests.cs)
- **Operational dependency:** Host storage for acknowledgment requests and responses, linked to decision and lifecycle evidence.
- **Failure behavior:** Fails closed. The challenged request does not execute. A valid capability grant never upgrades an acknowledgment-required decision, so a grant cannot bypass the challenge.
- **Host and operator responsibility:** Authenticate and authorize the acknowledging actor, present the acknowledgment accessibly, define when acknowledgment is required, choose storage and retention, and decide freshness rules before execution.
- **Residual risk and non-claims:** Records an acknowledgment checkpoint. It is not legal protection, non-repudiation, compliance certification, or production tamper-evidence, and an acknowledgment record is not an execution credential.
- **Canonical documentation:** [AsiBackbone `docs/articles/dynamic-liability-handshake.md`](https://github.com/AsiBackbone/AsiBackbone/blob/v7.5.0/docs/articles/dynamic-liability-handshake.md)

### Capability grants and replay protection

<a id="capability-grants"></a>

#### Signed capability grants and replay protection

A signed capability grant authorizes one bound request for one subject, operation, scope, and policy, and cannot be replayed beyond its use limit.

- **Owner:** AsiBackbone
- **Enforcement point:** Capability grant validator with a capability-grant use store — [AsiBackbone `src/AsiBackbone.Core/CapabilityGrants/CapabilityGrantValidator.cs`](https://github.com/AsiBackbone/AsiBackbone/blob/v7.5.0/src/AsiBackbone.Core/CapabilityGrants/CapabilityGrantValidator.cs)
- **Tests and evidence:** [AsiBackbone `tests/AsiBackbone.Core.Tests/CapabilityGrants/CapabilityGrantValidatorTests.cs`](https://github.com/AsiBackbone/AsiBackbone/blob/v7.5.0/tests/AsiBackbone.Core.Tests/CapabilityGrants/CapabilityGrantValidatorTests.cs), [AsiBackbone `tests/AsiBackbone.AspNetCore.Tests/CapabilityGrants/SignedCapabilityGrantEndpointValidatorTests.cs`](https://github.com/AsiBackbone/AsiBackbone/blob/v7.5.0/tests/AsiBackbone.AspNetCore.Tests/CapabilityGrants/SignedCapabilityGrantEndpointValidatorTests.cs), [AsiBackbone `tests/AsiBackbone.EntityFrameworkCore.Tests/CapabilityGrants/EfCoreCapabilityGrantUseStoreTests.cs`](https://github.com/AsiBackbone/AsiBackbone/blob/v7.5.0/tests/AsiBackbone.EntityFrameworkCore.Tests/CapabilityGrants/EfCoreCapabilityGrantUseStoreTests.cs), [ReferenceApplication `tests/ReferenceApplication.Web.Tests/CapabilityTokenEndpointTests.cs`](https://github.com/AsiBackbone/ReferenceApplication/blob/v0.1.0-alpha.11/tests/ReferenceApplication.Web.Tests/CapabilityTokenEndpointTests.cs)
- **Operational dependency:** A verification service, a request binding provider, and a durable use store shared by every replica, with expired records purged on a schedule.
- **Failure behavior:** Fails closed. The signed endpoint validator denies every result other than Valid, including results the core validator would defer or escalate. A missing verification service, use store, or binding provider denies, as does one that throws. Grants are single-use by default.
- **Host and operator responsibility:** Own key material and the verification service, the use store and its migration and purge, issuer and audience expectations, clock skew, and what a request binding covers.
- **Residual risk and non-claims:** Signed grants are opt-in; the default claim-backed validator has no replay semantics. Replay protection is only as wide as the use store: the in-memory store is process-local, so behind a load balancer a single-use grant can be accepted once per replica.
- **Canonical documentation:** [AsiBackbone `docs/articles/signed-capability-grants.md`](https://github.com/AsiBackbone/AsiBackbone/blob/v7.5.0/docs/articles/signed-capability-grants.md), [AsiBackbone `docs/articles/capability-grant-hardening.md`](https://github.com/AsiBackbone/AsiBackbone/blob/v7.5.0/docs/articles/capability-grant-hardening.md), [ReferenceApplication `docs/walkthrough/signed-capability-tokens.md`](https://github.com/AsiBackbone/ReferenceApplication/blob/v0.1.0-alpha.11/docs/walkthrough/signed-capability-tokens.md)

### Decision and evidence persistence

<a id="decision-evidence-persistence"></a>

#### Decision evidence persistence

Governance decision receipts are persisted to the host database before the governed operation executes.

- **Owner:** AsiBackbone
- **Enforcement point:** EF Core audit ledger store on a host-owned DbContext — [AsiBackbone `src/AsiBackbone.EntityFrameworkCore/Audit/EfCoreAuditLedgerStore.cs`](https://github.com/AsiBackbone/AsiBackbone/blob/v7.5.0/src/AsiBackbone.EntityFrameworkCore/Audit/EfCoreAuditLedgerStore.cs)
- **Tests and evidence:** [AsiBackbone `tests/AsiBackbone.EntityFrameworkCore.Tests/EfCoreAuditLedgerStoreTests.cs`](https://github.com/AsiBackbone/AsiBackbone/blob/v7.5.0/tests/AsiBackbone.EntityFrameworkCore.Tests/EfCoreAuditLedgerStoreTests.cs), [ReferenceApplication `tests/ReferenceApplication.Web.Tests/LedgerDecisionReceiptSinkTests.cs`](https://github.com/AsiBackbone/ReferenceApplication/blob/v0.1.0-alpha.11/tests/ReferenceApplication.Web.Tests/LedgerDecisionReceiptSinkTests.cs)
- **Operational dependency:** A host-owned DbContext, database provider, and applied migrations that include the AsiBackbone tables.
- **Failure behavior:** Host-defined. Whether a failed append blocks execution is decided by the host's decision receipt sink. In the Reference Application a failed append throws, so the governed operation fails closed, and governed operations fail closed until the migration is applied.
- **Host and operator responsibility:** Own the DbContext, connection, migrations, transactions, retention, and backups, and make the receipt sink fail closed on consequential paths.
- **Residual risk and non-claims:** Ledger rows are not immutable or tamper-evident by themselves. Tamper-evidence needs signing or hash-chain verification plus protected storage and retention controls.
- **Canonical documentation:** [AsiBackbone `docs/articles/ef-core-host-ownership-and-migrations.md`](https://github.com/AsiBackbone/AsiBackbone/blob/v7.5.0/docs/articles/ef-core-host-ownership-and-migrations.md), [ReferenceApplication `docs/walkthrough/06-persist-and-verify-audit.md`](https://github.com/AsiBackbone/ReferenceApplication/blob/v0.1.0-alpha.11/docs/walkthrough/06-persist-and-verify-audit.md)

<a id="mutation-manifest-digest"></a>

#### Application mutation audit manifest digest

A retained audit batch can be checked against the receipt issued when the mutation was saved.

- **Owner:** .NET Core Application Template
- **Enforcement point:** Canonical mutation manifest verifier with a fixed-time digest comparison — [NetCoreApplicationTemplate `src/ProjectTemplate.Infrastructure/Data/Auditing/ApplicationMutationManifestVerifier.cs`](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/v2.11.5/src/ProjectTemplate.Infrastructure/Data/Auditing/ApplicationMutationManifestVerifier.cs)
- **Tests and evidence:** [NetCoreApplicationTemplate `tests/ProjectTemplate.Web.Tests/ApplicationMutationManifestTests.cs`](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/v2.11.5/tests/ProjectTemplate.Web.Tests/ApplicationMutationManifestTests.cs), [NetCoreApplicationTemplate `tests/ProjectTemplate.Web.Tests/AuditCompletionContractVectorTests.cs`](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/v2.11.5/tests/ProjectTemplate.Web.Tests/AuditCompletionContractVectorTests.cs)
- **Operational dependency:** Retained audit batches and their receipts.
- **Failure behavior:** Host-defined. Verification succeeds only when the retained batch still matches the receipt's manifest and record count. The caller decides what a mismatch blocks.
- **Host and operator responsibility:** Retain batches and receipts, run verification where it matters, and supply transaction strategy, access controls, retention, immutable storage, and signing or timestamping where required.
- **Residual risk and non-claims:** The default digest is an unkeyed SHA-256 hash, so it detects change but not a rewrite by someone who can also replace the stored digest. A match does not prove an atomic commit, immutable storage, retention compliance, an authenticated actor or upstream decision, or a complete archive transfer.
- **Canonical documentation:** [NetCoreApplicationTemplate `docs/articles/audit-accountability-integration.md`](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/v2.11.5/docs/articles/audit-accountability-integration.md)

### Outbox and reconciliation

<a id="governance-outbox"></a>

#### Governance outbox delivery

Governance emissions are saved locally before downstream delivery, and delivery failures are preserved as outbox state.

- **Owner:** AsiBackbone
- **Enforcement point:** Provider-neutral governance outbox drain — [AsiBackbone `src/AsiBackbone.Core/Outbox/GovernanceOutboxDrain.cs`](https://github.com/AsiBackbone/AsiBackbone/blob/v7.5.0/src/AsiBackbone.Core/Outbox/GovernanceOutboxDrain.cs)
- **Tests and evidence:** [AsiBackbone `tests/AsiBackbone.Core.Tests/Outbox/GovernanceOutboxDrainClaimSafetyTests.cs`](https://github.com/AsiBackbone/AsiBackbone/blob/v7.5.0/tests/AsiBackbone.Core.Tests/Outbox/GovernanceOutboxDrainClaimSafetyTests.cs), [AsiBackbone `tests/AsiBackbone.EntityFrameworkCore.Tests/EfCoreGovernanceOutboxSemanticsTests.cs`](https://github.com/AsiBackbone/AsiBackbone/blob/v7.5.0/tests/AsiBackbone.EntityFrameworkCore.Tests/EfCoreGovernanceOutboxSemanticsTests.cs)
- **Operational dependency:** A durable outbox store, a drain worker, and an emission provider.
- **Failure behavior:** Defers. Provider failures become retryable, deferred, failed, or dead-lettered outbox state; the local record is kept for review and retry.
- **Host and operator responsibility:** Own worker topology, claim and lease behavior, provider idempotency, migrations, duplicate reconciliation, retention, and monitoring.
- **Residual risk and non-claims:** Not a distributed queue, an append-only event stream, or an immutable ledger. Delivery is at-least-once and best-effort; exactly-once delivery is not claimed.
- **Canonical documentation:** [AsiBackbone `docs/articles/governance-outbox-delivery-semantics.md`](https://github.com/AsiBackbone/AsiBackbone/blob/v7.5.0/docs/articles/governance-outbox-delivery-semantics.md), [AsiBackbone `docs/articles/durable-audit-outbox-persistence.md`](https://github.com/AsiBackbone/AsiBackbone/blob/v7.5.0/docs/articles/durable-audit-outbox-persistence.md)

<a id="audit-completion-reconciliation"></a>

#### Audit completion outbox and reconciliation

A committed mutation's audit completion is handed off durably, and missing, altered, or stalled evidence is detected afterwards.

- **Owner:** .NET Core Application Template
- **Enforcement point:** Optional audit completion outbox, with a scheduled reconciler — [NetCoreApplicationTemplate `src/ProjectTemplate.Infrastructure/Data/Auditing/ApplicationAuditCompletionOutbox.cs`](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/v2.11.5/src/ProjectTemplate.Infrastructure/Data/Auditing/ApplicationAuditCompletionOutbox.cs)
- **Tests and evidence:** [NetCoreApplicationTemplate `tests/ProjectTemplate.Web.Tests/ApplicationAuditCompletionOutboxTests.cs`](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/v2.11.5/tests/ProjectTemplate.Web.Tests/ApplicationAuditCompletionOutboxTests.cs), [NetCoreApplicationTemplate `tests/ProjectTemplate.Web.Tests/ApplicationAuditReconciliationTests.cs`](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/v2.11.5/tests/ProjectTemplate.Web.Tests/ApplicationAuditReconciliationTests.cs), [NetCoreApplicationTemplate `tests/ProjectTemplate.Web.Tests/ApplicationAuditIntegrityHealthCheckTests.cs`](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/v2.11.5/tests/ProjectTemplate.Web.Tests/ApplicationAuditIntegrityHealthCheckTests.cs)
- **Operational dependency:** The outbox and reconciliation features enabled, the application database, and an optional external publisher.
- **Failure behavior:** Defers. With no publisher, ready entries are deferred rather than failing the business mutation. Retryable failures back off and dead-letter after MaxRetryAttempts. Reconciliation findings surface through the audit-integrity health check, which is kept out of readiness.
- **Host and operator responsibility:** Make publishers idempotent on the idempotency key, and review and remediate reconciliation findings.
- **Residual risk and non-claims:** A durable local handoff, not a distributed queue; exactly-once delivery is not promised. Reconciliation detects problems after the transaction; it does not replace transactional persistence.
- **Canonical documentation:** [NetCoreApplicationTemplate `docs/articles/audit-completion-outbox.md`](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/v2.11.5/docs/articles/audit-completion-outbox.md), [NetCoreApplicationTemplate `docs/articles/audit-reconciliation.md`](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/v2.11.5/docs/articles/audit-reconciliation.md)

### Signing and verification

<a id="signature-verification"></a>

#### Signature verification policy

Only a valid signature from a trusted key and signing context is accepted.

- **Owner:** AsiBackbone
- **Enforcement point:** Verification policy evaluator — [AsiBackbone `src/AsiBackbone.Core/Signing/VerificationPolicyEvaluator.cs`](https://github.com/AsiBackbone/AsiBackbone/blob/v7.5.0/src/AsiBackbone.Core/Signing/VerificationPolicyEvaluator.cs)
- **Tests and evidence:** [AsiBackbone `tests/AsiBackbone.Core.Tests/Signing/VerificationPolicySafetyTests.cs`](https://github.com/AsiBackbone/AsiBackbone/blob/v7.5.0/tests/AsiBackbone.Core.Tests/Signing/VerificationPolicySafetyTests.cs), [AsiBackbone `tests/AsiBackbone.Core.Tests/Signing/VerificationPolicyHandlingTests.cs`](https://github.com/AsiBackbone/AsiBackbone/blob/v7.5.0/tests/AsiBackbone.Core.Tests/Signing/VerificationPolicyHandlingTests.cs), [AsiBackbone `tests/AsiBackbone.Signing.ManagedKey.Tests/PublicKeySignatureVerificationServiceTests.cs`](https://github.com/AsiBackbone/AsiBackbone/blob/v7.5.0/tests/AsiBackbone.Signing.ManagedKey.Tests/PublicKeySignatureVerificationServiceTests.cs)
- **Operational dependency:** A verification provider, key lookup, and trust pins for keys and signing context.
- **Failure behavior:** Fails closed. Only Valid allows by default. Hash mismatches, untrusted keys, and untrusted signing contexts deny; an unknown key version escalates and an unavailable provider defers.
- **Host and operator responsibility:** Provide the signing and verification infrastructure, configure key and context pins, and map deferred or escalated results to execution decisions.
- **Residual risk and non-claims:** A valid signature shows the payload matches what the key signed. It does not prove legal non-repudiation, immutable storage, or that the signer was authorized to act.
- **Canonical documentation:** [AsiBackbone `docs/articles/verification-policy-and-result-handling.md`](https://github.com/AsiBackbone/AsiBackbone/blob/v7.5.0/docs/articles/verification-policy-and-result-handling.md), [AsiBackbone `docs/articles/cryptographic-security-posture.md`](https://github.com/AsiBackbone/AsiBackbone/blob/v7.5.0/docs/articles/cryptographic-security-posture.md)

<a id="audit-integrity-chain"></a>

#### Audit-integrity hash chain

Changed, missing, reordered, or forked audit records are detected when the chain is verified.

- **Owner:** AsiBackbone
- **Enforcement point:** Audit integrity verifier — [AsiBackbone `src/AsiBackbone.Core/Integrity/AuditIntegrityVerifier.cs`](https://github.com/AsiBackbone/AsiBackbone/blob/v7.5.0/src/AsiBackbone.Core/Integrity/AuditIntegrityVerifier.cs)
- **Tests and evidence:** [AsiBackbone `tests/AsiBackbone.Core.Tests/Integrity/AuditIntegrityVerifierTests.cs`](https://github.com/AsiBackbone/AsiBackbone/blob/v7.5.0/tests/AsiBackbone.Core.Tests/Integrity/AuditIntegrityVerifierTests.cs), [AsiBackbone `tests/AsiBackbone.Core.Tests/Integrity/AuditIntegritySequencePrecedenceTests.cs`](https://github.com/AsiBackbone/AsiBackbone/blob/v7.5.0/tests/AsiBackbone.Core.Tests/Integrity/AuditIntegritySequencePrecedenceTests.cs)
- **Operational dependency:** Retained chain metadata stored next to the audit records, and a process that runs verification.
- **Failure behavior:** Host-defined. Verification reports categorized failures such as a previous-link hash mismatch. The host decides what a failure blocks and how it is escalated.
- **Host and operator responsibility:** Persist link metadata, run verification on a schedule or before reliance, and protect chain tips, for example in immutable storage.
- **Residual risk and non-claims:** A local hash chain detects change only when verified against retained metadata. It is not tamper-evident without protected storage, external anchoring, and retention controls, and it is not a blockchain or transparency log.
- **Canonical documentation:** [AsiBackbone `docs/articles/audit-integrity-chain-model.md`](https://github.com/AsiBackbone/AsiBackbone/blob/v7.5.0/docs/articles/audit-integrity-chain-model.md)

### Key custody

<a id="key-custody"></a>

#### Production signing-key custody

Production private keys stay in a host-controlled key-management system and never pass through AsiBackbone.

- **Owner:** Deploying host and operator
- **Enforcement point:** Host-owned managed-key signing client behind the AsiBackbone managed-key adapter — [AsiBackbone `src/AsiBackbone.Signing.ManagedKey/IManagedKeySigningClient.cs`](https://github.com/AsiBackbone/AsiBackbone/blob/v7.5.0/src/AsiBackbone.Signing.ManagedKey/IManagedKeySigningClient.cs)
- **Tests and evidence:** [AsiBackbone `tests/AsiBackbone.Signing.ManagedKey.Tests/ManagedKeySigningServiceTests.cs`](https://github.com/AsiBackbone/AsiBackbone/blob/v7.5.0/tests/AsiBackbone.Signing.ManagedKey.Tests/ManagedKeySigningServiceTests.cs), [ReferenceApplication `tests/ReferenceApplication.Web.Tests/CapabilityTokenConfigurationTests.cs`](https://github.com/AsiBackbone/ReferenceApplication/blob/v0.1.0-alpha.11/tests/ReferenceApplication.Web.Tests/CapabilityTokenConfigurationTests.cs)
- **Evidence gap:** Custody evidence is deployment-specific. These tests cover the adapter boundary and the Reference Application's startup key checks, not any production key-management system.
- **Operational dependency:** A cloud KMS, HSM, or organization signing service reachable from the host.
- **Failure behavior:** Host-defined. An unavailable signing provider maps to a deferral or retry for lower-risk work and should fail closed for high-risk execution. The Reference Application fails startup when its signing key does not match a trusted, unrevoked verification key.
- **Host and operator responsibility:** Choose and operate the key-management system, control access to keys, rotate and revoke key versions, and distribute public verification keys.
- **Residual risk and non-claims:** AsiBackbone is not a key-management system: it ships no first-party cloud KMS or HSM provider, automatic rotation, or emergency revocation. The Reference Application's configured PEM key is a sample, not production custody.
- **Canonical documentation:** [AsiBackbone `docs/articles/managed-key-signing-provider.md`](https://github.com/AsiBackbone/AsiBackbone/blob/v7.5.0/docs/articles/managed-key-signing-provider.md), [AsiBackbone `docs/articles/production-managed-key-integration.md`](https://github.com/AsiBackbone/AsiBackbone/blob/v7.5.0/docs/articles/production-managed-key-integration.md), [AsiBackbone `docs/articles/key-rotation-and-retired-key-verification.md`](https://github.com/AsiBackbone/AsiBackbone/blob/v7.5.0/docs/articles/key-rotation-and-retired-key-verification.md)

### Data Protection

<a id="data-protection"></a>

#### ASP.NET Core Data Protection key ring

Every replica protects and unprotects cookies and antiforgery tokens with the same persisted key ring.

- **Owner:** .NET Core Application Template
- **Enforcement point:** Data Protection registration and startup posture checks — [NetCoreApplicationTemplate `src/ProjectTemplate.Web/Extensions/DataProtectionServiceExtensions.cs`](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/v2.11.5/src/ProjectTemplate.Web/Extensions/DataProtectionServiceExtensions.cs)
- **Tests and evidence:** [NetCoreApplicationTemplate `tests/ProjectTemplate.Web.Tests/DataProtectionServiceExtensionsTests.cs`](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/v2.11.5/tests/ProjectTemplate.Web.Tests/DataProtectionServiceExtensionsTests.cs)
- **Operational dependency:** Durable, access-restricted key-ring storage shared by every replica, and an optional key-encryption certificate.
- **Failure behavior:** Warns. Startup fails when the key-encryption certificate is missing, has no private key, or a password is set without a certificate path. Outside Development, warnings 1003 (relative key-ring path) and 1004 (unencrypted key ring) flag common deployment problems without stopping startup.
- **Host and operator responsibility:** Provide durable shared storage, use one ApplicationName per application, encrypt the key ring, and keep retired certificates available until their keys age out.
- **Residual risk and non-claims:** Without a key-encryption certificate or storage-level encryption, key-ring files are stored unencrypted by the application.
- **Canonical documentation:** [NetCoreApplicationTemplate `docs/articles/deployment.md`](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/v2.11.5/docs/articles/deployment.md), [NetCoreApplicationTemplate `docs/articles/authentication-hardening.md`](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/v2.11.5/docs/articles/authentication-hardening.md)

### Proxy and TLS trust

<a id="proxy-tls-trust"></a>

#### Reverse-proxy and TLS trust

Client address and scheme come only from forwarded headers sent by an explicitly trusted proxy or network.

- **Owner:** .NET Core Application Template
- **Enforcement point:** Forwarded-headers configuration with a startup trust check — [NetCoreApplicationTemplate `src/ProjectTemplate.Web/Diagnostics/ForwardedHeadersTrustDiagnosticsHostedService.cs`](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/v2.11.5/src/ProjectTemplate.Web/Diagnostics/ForwardedHeadersTrustDiagnosticsHostedService.cs)
- **Tests and evidence:** [NetCoreApplicationTemplate `tests/ProjectTemplate.Web.Tests/ForwardedHeadersTests.cs`](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/v2.11.5/tests/ProjectTemplate.Web.Tests/ForwardedHeadersTests.cs), [NetCoreApplicationTemplate `tests/ProjectTemplate.Web.Tests/ForwardedHeadersTrustDiagnosticsTests.cs`](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/v2.11.5/tests/ProjectTemplate.Web.Tests/ForwardedHeadersTrustDiagnosticsTests.cs), [NetCoreApplicationTemplate `tests/ProjectTemplate.Web.Tests/HstsTests.cs`](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/v2.11.5/tests/ProjectTemplate.Web.Tests/HstsTests.cs)
- **Operational dependency:** The deployment's proxy, ingress, or load balancer topology, and TLS termination.
- **Failure behavior:** Fails closed. Outside Development, startup fails when forwarded client-IP processing and rate limiting are active without a KnownProxies or KnownNetworks entry. Raw X-Forwarded-For values are never trusted directly.
- **Host and operator responsibility:** Terminate TLS and manage certificates, configure the narrowest trusted proxy addresses or networks (replace the sample Kubernetes range), and set AllowedHosts if X-Forwarded-Host is enabled.
- **Residual risk and non-claims:** An over-broad trusted network lets clients spoof their address. The template cannot know the deployment's proxy topology.
- **Canonical documentation:** [NetCoreApplicationTemplate `docs/articles/forwarded-headers.md`](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/v2.11.5/docs/articles/forwarded-headers.md), [NetCoreApplicationTemplate `docs/articles/deployment.md`](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/v2.11.5/docs/articles/deployment.md)

### Rate limiting

<a id="rate-limiting"></a>

#### Request rate limiting

Clients are rate limited per resolved address, and unresolved clients remain limited.

- **Owner:** .NET Core Application Template
- **Enforcement point:** Fixed-window and concurrency rate limiters — [NetCoreApplicationTemplate `src/ProjectTemplate.Web/Extensions/RateLimitingServiceExtensions.cs`](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/v2.11.5/src/ProjectTemplate.Web/Extensions/RateLimitingServiceExtensions.cs)
- **Tests and evidence:** [NetCoreApplicationTemplate `tests/ProjectTemplate.Web.Tests/RateLimitingTests.cs`](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/v2.11.5/tests/ProjectTemplate.Web.Tests/RateLimitingTests.cs)
- **Operational dependency:** Correct proxy trust, so the client address is the real client rather than the ingress.
- **Failure behavior:** Fails closed. By default, clients without a resolved address share one fallback partition and stay rate limited, with warning 6002 when that path is used. Rejections are inexpensive 429 responses.
- **Host and operator responsibility:** Tune limits for real traffic, and provide edge or distributed rate limiting and denial-of-service protection where needed.
- **Residual risk and non-claims:** The limiter keeps its counters in each application instance's memory, so limits apply per replica rather than across a scaled deployment. It is not denial-of-service protection.
- **Canonical documentation:** [NetCoreApplicationTemplate `docs/articles/rate-limiting.md`](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/v2.11.5/docs/articles/rate-limiting.md)

### Health and readiness exposure

<a id="health-readiness"></a>

#### Health and readiness endpoints

Probes report liveness and readiness without login state and without exposing sensitive diagnostics.

- **Owner:** .NET Core Application Template
- **Enforcement point:** Anonymous health, readiness, liveness, and audit-integrity endpoints — [NetCoreApplicationTemplate `src/ProjectTemplate.Web/Extensions/HealthCheckExtensions.cs`](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/v2.11.5/src/ProjectTemplate.Web/Extensions/HealthCheckExtensions.cs)
- **Tests and evidence:** [NetCoreApplicationTemplate `tests/ProjectTemplate.Web.Tests/HealthCheckTests.cs`](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/v2.11.5/tests/ProjectTemplate.Web.Tests/HealthCheckTests.cs), [NetCoreApplicationTemplate `tests/ProjectTemplate.Web.Tests/ApplicationDatabaseHealthCheckTests.cs`](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/v2.11.5/tests/ProjectTemplate.Web.Tests/ApplicationDatabaseHealthCheckTests.cs)
- **Operational dependency:** The application database for readiness when data access is enabled.
- **Failure behavior:** Warns. Readiness fails when the database is unreachable, liveness has no dependency checks, and audit integrity is kept out of readiness. In Production, a startup warning names the anonymously mapped health routes.
- **Host and operator responsibility:** Restrict health endpoint reachability at the deployment boundary, and register any further dependency checks that define readiness for the service.
- **Residual risk and non-claims:** Anonymous mapping does not mean the endpoints should be reachable from the Internet. Responses must not carry secrets, configuration, or exception details.
- **Canonical documentation:** [NetCoreApplicationTemplate `docs/articles/health-checks.md`](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/v2.11.5/docs/articles/health-checks.md), [NetCoreApplicationTemplate `docs/articles/runtime-readiness.md`](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/v2.11.5/docs/articles/runtime-readiness.md)

### Database migrations and provider support

<a id="migrations-providers"></a>

#### Database migrations and provider support

Schema changes are applied as an explicit, reviewed deployment step, never automatically at startup.

- **Owner:** .NET Core Application Template
- **Enforcement point:** Data-access startup diagnostic and explicit migration commands — [NetCoreApplicationTemplate `src/ProjectTemplate.Web/Services/DataAccessStartupLogger.cs`](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/v2.11.5/src/ProjectTemplate.Web/Services/DataAccessStartupLogger.cs)
- **Tests and evidence:** [NetCoreApplicationTemplate `tests/ProjectTemplate.Web.Tests/EfCoreMigrationCoverageTests.cs`](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/v2.11.5/tests/ProjectTemplate.Web.Tests/EfCoreMigrationCoverageTests.cs), [NetCoreApplicationTemplate `tests/ProjectTemplate.Web.Tests/DataAccessStartupLoggerTests.cs`](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/v2.11.5/tests/ProjectTemplate.Web.Tests/DataAccessStartupLoggerTests.cs)
- **Operational dependency:** A supported provider (SQLite or SQL Server) and a deployment step that applies migrations.
- **Failure behavior:** Warns. The application never migrates at startup. A SQL Server scaffold ships without migration history and logs a warning with the command to create one.
- **Host and operator responsibility:** Generate, review, and apply provider-specific migrations, including the AsiBackbone tables, and back up the database before schema changes.
- **Residual risk and non-claims:** Providers other than SQLite and SQL Server are not supported. Generated migrations are not reviewed by the template; their correctness for the selected provider is the host's to check.
- **Canonical documentation:** [NetCoreApplicationTemplate `docs/articles/data-access.md`](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/v2.11.5/docs/articles/data-access.md), [AsiBackbone `docs/articles/ef-core-host-ownership-and-migrations.md`](https://github.com/AsiBackbone/AsiBackbone/blob/v7.5.0/docs/articles/ef-core-host-ownership-and-migrations.md)

### Development-only feature isolation

<a id="development-insecure-cookie"></a>

#### Development-only plain-HTTP cookie override

Authentication cookies are sent over HTTP only in Development.

- **Owner:** .NET Core Application Template
- **Enforcement point:** Authentication options validation at startup — [NetCoreApplicationTemplate `src/ProjectTemplate.Web/Authentication/Options/ApplicationAuthenticationOptionsValidator.cs`](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/v2.11.5/src/ProjectTemplate.Web/Authentication/Options/ApplicationAuthenticationOptionsValidator.cs)
- **Tests and evidence:** [NetCoreApplicationTemplate `tests/ProjectTemplate.Web.Tests/AuthenticationCookieSecurePolicyTests.cs`](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/v2.11.5/tests/ProjectTemplate.Web.Tests/AuthenticationCookieSecurePolicyTests.cs)
- **Operational dependency:** An accurate hosting environment name.
- **Failure behavior:** Fails closed. Startup validation rejects AllowInsecureHttp=true in every environment other than Development.
- **Host and operator responsibility:** Keep the override in Development-only configuration sources, and make sure deployed environments never run as Development.
- **Residual risk and non-claims:** The guard trusts the environment name; a deployment that runs as Development disables it.
- **Canonical documentation:** [NetCoreApplicationTemplate `docs/articles/authentication-hardening.md`](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/v2.11.5/docs/articles/authentication-hardening.md)

<a id="development-local-signing"></a>

#### Local-development signing kept out of production

The local-development signing provider is not registered in a production environment.

- **Owner:** AsiBackbone
- **Enforcement point:** Registration-time production guard, backed by analyzers ASIB002 and ASIB003 — [AsiBackbone `src/AsiBackbone.Signing.LocalDevelopment/LocalDevelopmentSigningBuilderExtensions.cs`](https://github.com/AsiBackbone/AsiBackbone/blob/v7.5.0/src/AsiBackbone.Signing.LocalDevelopment/LocalDevelopmentSigningBuilderExtensions.cs)
- **Tests and evidence:** [AsiBackbone `tests/AsiBackbone.Signing.LocalDevelopment.Tests/LocalDevelopmentSigningProductionGuardTests.cs`](https://github.com/AsiBackbone/AsiBackbone/blob/v7.5.0/tests/AsiBackbone.Signing.LocalDevelopment.Tests/LocalDevelopmentSigningProductionGuardTests.cs), [AsiBackbone `tests/AsiBackbone.Analyzers.Tests/LocalDevelopmentSigningProductionAnalyzerTests.cs`](https://github.com/AsiBackbone/AsiBackbone/blob/v7.5.0/tests/AsiBackbone.Analyzers.Tests/LocalDevelopmentSigningProductionAnalyzerTests.cs)
- **Operational dependency:** An accurate hosting environment name, and analyzers enabled in the build.
- **Failure behavior:** Fails closed. Registering the provider in a production environment throws unless AllowInProduction is set. The analyzers warn at build time by default.
- **Host and operator responsibility:** Elevate ASIB002 and ASIB003 to errors in production CI, and never set AllowInProduction.
- **Residual risk and non-claims:** The provider generates a new key in each process by default; its signatures are not production evidence.
- **Canonical documentation:** [AsiBackbone `docs/articles/roslyn-analyzers.md`](https://github.com/AsiBackbone/AsiBackbone/blob/v7.5.0/docs/articles/roslyn-analyzers.md), [AsiBackbone `docs/articles/signing-provider-package-boundary.md`](https://github.com/AsiBackbone/AsiBackbone/blob/v7.5.0/docs/articles/signing-provider-package-boundary.md)

<a id="development-demo-identity"></a>

#### Reference Application demo identity

The demonstration sign-in and its fixed claims exist only in Development.

- **Owner:** Reference Application
- **Enforcement point:** Environment-gated service and endpoint registration — [ReferenceApplication `src/ReferenceApplication.Web/Authentication/Extensions/DemoIdentityServiceExtensions.cs`](https://github.com/AsiBackbone/ReferenceApplication/blob/v0.1.0-alpha.11/src/ReferenceApplication.Web/Authentication/Extensions/DemoIdentityServiceExtensions.cs)
- **Tests and evidence:** [ReferenceApplication `tests/ReferenceApplication.Web.Tests/DemoIdentityTests.cs`](https://github.com/AsiBackbone/ReferenceApplication/blob/v0.1.0-alpha.11/tests/ReferenceApplication.Web.Tests/DemoIdentityTests.cs)
- **Operational dependency:** An accurate hosting environment name.
- **Failure behavior:** Fails closed. Outside the Development environment neither the service nor the sign-in endpoint is registered, even when the switch is set. A startup warning is written whenever the control is active.
- **Host and operator responsibility:** Do not carry the demonstration identity into a derived application.
- **Residual risk and non-claims:** A demonstration aid, not an identity provider; its fixed claims prove nothing about a real user.
- **Canonical documentation:** [ReferenceApplication `docs/walkthrough/development-demo-identity.md`](https://github.com/AsiBackbone/ReferenceApplication/blob/v0.1.0-alpha.11/docs/walkthrough/development-demo-identity.md)

### Release, provenance, and SBOM evidence

<a id="ncat-release-evidence"></a>

#### NCAT release provenance and SBOM evidence

Each tagged release publishes a durable, hashed evidence set for the exact NuGet package and container image.

- **Owner:** .NET Core Application Template
- **Enforcement point:** Tag-driven publish workflows that generate evidence before publication — [NetCoreApplicationTemplate `.github/workflows/publish-template-package.yml`](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/v2.11.5/.github/workflows/publish-template-package.yml)
- **Tests and evidence:** [NetCoreApplicationTemplate `scripts/Test-ReleaseEvidence.ps1`](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/v2.11.5/scripts/Test-ReleaseEvidence.ps1), [NetCoreApplicationTemplate `scripts/Assert-GitHubReleaseAssets.ps1`](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/v2.11.5/scripts/Assert-GitHubReleaseAssets.ps1)
- **Operational dependency:** GitHub Actions OIDC, artifact attestations, keyless image signing, and the protected publishing environment.
- **Failure behavior:** Fails closed. The publish workflow fails when the GitHub release is missing a required evidence asset.
- **Host and operator responsibility:** Verify the evidence manifest hashes, SBOMs, provenance attestations, and image signature before relying on a release.
- **Residual risk and non-claims:** NuGet author signing is deferred (ADR-0005). SBOMs and provenance describe how an artifact was built; they do not show it is free of vulnerabilities.
- **Canonical documentation:** [NetCoreApplicationTemplate `docs/articles/container-publish.md`](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/v2.11.5/docs/articles/container-publish.md), [NetCoreApplicationTemplate `docs/adr/0005-defer-nuget-package-signing.md`](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/v2.11.5/docs/adr/0005-defer-nuget-package-signing.md)

<a id="asibackbone-release-evidence"></a>

#### AsiBackbone package provenance and SBOM evidence

Each stable release attaches attested packages, SBOMs, release notes, and a checksum manifest to the GitHub release.

- **Owner:** AsiBackbone
- **Enforcement point:** Package publish workflow — [AsiBackbone `.github/workflows/publish-packages.yml`](https://github.com/AsiBackbone/AsiBackbone/blob/v7.5.0/.github/workflows/publish-packages.yml)
- **Tests and evidence:** [AsiBackbone `scripts/Test-ReleaseEvidence.ps1`](https://github.com/AsiBackbone/AsiBackbone/blob/v7.5.0/scripts/Test-ReleaseEvidence.ps1), [AsiBackbone `scripts/Assert-GitHubReleaseAssets.ps1`](https://github.com/AsiBackbone/AsiBackbone/blob/v7.5.0/scripts/Assert-GitHubReleaseAssets.ps1)
- **Operational dependency:** GitHub Actions artifact attestations where the workflow event supports them.
- **Failure behavior:** Fails closed. The release workflow verifies every required release asset and package attestation.
- **Host and operator responsibility:** Verify package hashes, SBOMs, and attestations before adopting a release.
- **Residual risk and non-claims:** NuGet package signing is deferred for the 7.x line under a time-bounded decision record. SBOMs and provenance do not make the packages a compliance product.
- **Canonical documentation:** [AsiBackbone `docs/articles/supply-chain-provenance.md`](https://github.com/AsiBackbone/AsiBackbone/blob/v7.5.0/docs/articles/supply-chain-provenance.md), [AsiBackbone `docs/articles/nuget-package-signing-decision.md`](https://github.com/AsiBackbone/AsiBackbone/blob/v7.5.0/docs/articles/nuget-package-signing-decision.md)

### Repository-host rulesets and security scanning

<a id="ncat-repository-controls"></a>

#### NCAT repository rulesets and security scanning

Changes reach main only through pull requests that pass the required checks and code-scanning thresholds.

- **Owner:** .NET Core Application Template
- **Enforcement point:** Main branch ruleset, recorded as a desired-state manifest — [NetCoreApplicationTemplate `eng/repository-controls/main-branch-ruleset.json`](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/main/eng/repository-controls/main-branch-ruleset.json)
- **Tests and evidence:** [NetCoreApplicationTemplate `scripts/Test-RepositorySecurityControls.ps1`](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/main/scripts/Test-RepositorySecurityControls.ps1), [NetCoreApplicationTemplate `.github/workflows/repository-controls-audit.yml`](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/main/.github/workflows/repository-controls-audit.yml)
- **Operational dependency:** GitHub-hosted settings, which live outside git.
- **Failure behavior:** Fails closed. The read-only drift audit exits nonzero on required drift and reports administrator-only controls as Unavailable rather than compliant.
- **Host and operator responsibility:** Run the audit with an administrator login before each stable release, and change the manifest and live setting together.
- **Residual risk and non-claims:** The audit detects drift; it never changes settings. Settings it cannot read are unverified, not compliant.
- **Canonical documentation:** [NetCoreApplicationTemplate `docs/articles/repository-security-profile.md`](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/main/docs/articles/repository-security-profile.md)

<a id="asibackbone-repository-controls"></a>

#### AsiBackbone repository rulesets and security scanning

Changes reach main only through pull requests that pass release-blocking CI.

- **Owner:** AsiBackbone
- **Enforcement point:** Main branch ruleset, recorded as a desired-state manifest — [AsiBackbone `eng/repository-controls/main-branch-ruleset.json`](https://github.com/AsiBackbone/AsiBackbone/blob/main/eng/repository-controls/main-branch-ruleset.json)
- **Tests and evidence:** [AsiBackbone `scripts/Manage-RepositorySecurityControls.ps1`](https://github.com/AsiBackbone/AsiBackbone/blob/main/scripts/Manage-RepositorySecurityControls.ps1)
- **Evidence gap:** No scheduled workflow compares the live ruleset with the manifest; that depends on a maintainer running the script with administrator access.
- **Operational dependency:** GitHub-hosted settings, which live outside git.
- **Failure behavior:** Fails closed. The ruleset blocks merges that skip required checks. Emergency bypass is limited to one maintainer and to pull requests.
- **Host and operator responsibility:** Apply manifest changes deliberately; the script changes GitHub settings only when run with -Apply.
- **Residual risk and non-claims:** The manifest records intent; without a scheduled comparison, drift between it and the live ruleset is not detected automatically.
- **Canonical documentation:** [AsiBackbone `docs/articles/repository-host-security-controls.md`](https://github.com/AsiBackbone/AsiBackbone/blob/main/docs/articles/repository-host-security-controls.md)

<a id="reference-repository-controls"></a>

#### Reference Application repository rulesets

Changes reach main only through pull requests that pass every CI job, and reach ncat-baseline only through pull requests.

- **Owner:** Reference Application
- **Enforcement point:** Main and ncat-baseline branch rulesets, recorded as desired-state manifests — [ReferenceApplication `eng/repository-controls/main-branch-ruleset.json`](https://github.com/AsiBackbone/ReferenceApplication/blob/main/eng/repository-controls/main-branch-ruleset.json)
- **Tests and evidence:** [ReferenceApplication `tests/ReferenceApplication.Web.Tests/RepositoryControlsTests.cs`](https://github.com/AsiBackbone/ReferenceApplication/blob/main/tests/ReferenceApplication.Web.Tests/RepositoryControlsTests.cs)
- **Evidence gap:** The tests check the committed manifests against the CI workflows; nothing compares them with the live rulesets.
- **Operational dependency:** GitHub-hosted settings, which live outside git.
- **Failure behavior:** Fails closed. The rulesets block merges that skip a required CI job, and the tests fail when the manifest stops requiring a CI job.
- **Host and operator responsibility:** Change the manifest and live rulesets together.
- **Residual risk and non-claims:** The manifests record intent; live drift is not detected automatically.
- **Canonical documentation:** [ReferenceApplication `eng/repository-controls/README.md`](https://github.com/AsiBackbone/ReferenceApplication/blob/main/eng/repository-controls/README.md)

<a id="organization-repository-controls"></a>

#### Organization repository rulesets and security scanning

Changes to organization defaults, standards, and this map reach main only through pull requests that pass the required checks and CodeQL thresholds.

- **Owner:** Organization (.github)
- **Enforcement point:** Main branch security baseline ruleset, recorded as a desired-state manifest — [.github `eng/repository-controls/main-branch-ruleset.json`](https://github.com/AsiBackbone/.github/blob/main/eng/repository-controls/main-branch-ruleset.json)
- **Tests and evidence:** [.github `scripts/Test-OrganizationProfile.ps1`](https://github.com/AsiBackbone/.github/blob/main/scripts/Test-OrganizationProfile.ps1), [.github `.github/workflows/profile-validation.yml`](https://github.com/AsiBackbone/.github/blob/main/.github/workflows/profile-validation.yml)
- **Evidence gap:** No drift audit compares the ruleset manifest with the live ruleset.
- **Operational dependency:** GitHub-hosted settings, which live outside git.
- **Failure behavior:** Fails closed. The ruleset requires three status checks and CodeQL code-scanning results on every pull request. Path-filtered and scheduled checks are deliberately not required.
- **Host and operator responsibility:** Change the manifest and live ruleset together.
- **Residual risk and non-claims:** The manifest records intent; live drift is not detected automatically.
- **Canonical documentation:** [.github `SECURITY.md`](https://github.com/AsiBackbone/.github/blob/main/SECURITY.md)

## Review cadence

Review this map, and update the `reviewed` date, whenever:

- the current integration-reviewed combination in the compatibility matrix changes. The `Validate organization profile` check fails until the map's baselines match it, so a new Reference Application release forces a review;
- AsiBackbone or the .NET Core Application Template publishes a major release;
- an architecture change adds, removes, or moves the enforcement point of a mapped control, or changes its failure behavior; or
- a security incident or review finding shows a row is wrong or incomplete.

The weekly `Assurance map validation` workflow checks that every linked file still exists at its resolved ref, so a moved or deleted enforcement point, test, or document surfaces as a finding.

## Updating the map

1. Edit [`control-ownership.json`](control-ownership.json). Give each control exactly one owner and enforcement point, link tests and canonical documentation by repository and path, and record an `evidenceGap` wherever evidence is missing or partial.
2. Run `./scripts/Test-AssuranceMap.ps1 -Update` to regenerate this page, then `./scripts/Test-AssuranceMap.ps1 -VerifyReferences` to confirm every link resolves.
3. Open a pull request. The `Validate organization profile` check fails when the manifest is malformed, a scope is uncovered, the baselines do not match the compatibility matrix, or this page does not match the manifest.
