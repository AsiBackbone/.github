# AsiBackbone Documentation Ownership Map

<!-- Generated from ownership.json by scripts/Test-DocumentationOwnership.ps1 -Update. Do not edit by hand. -->

The ecosystem has several legitimate documentation surfaces, and the same concepts appear on more than one of them. Repetition helps people find things; duplicated technical truth drifts when versions, APIs, support boundaries, or terminology change. This map names one canonical owner for each recurring cross-repository topic and says how every other surface should reference it.

> **Boundary:** This map routes ownership; it does not move or delete content. Existing useful summaries stay, linked to their canonical detail. Each repository's own documentation-ownership or contribution guide stays authoritative for how that repository classifies its own pages. The machine-readable source is [`ownership.json`](ownership.json).

## Surfaces

| Surface | Content kind | Owns | Repository guide |
| --- | --- | --- | --- |
| [AsiBackbone Learning](https://asibackbone.github.io/Learning/) | Reusable education | Framework-neutral architecture education: tutorials, labs, runnable teaching samples, comparisons, tradeoff analysis, and educational terminology. Implementation-dependent pages are reviewed against a pinned AsiBackbone or NCAT release; Learning never defines product behavior. | [Learning `CONTRIBUTING.md`](https://github.com/AsiBackbone/Learning/blob/main/CONTRIBUTING.md) |
| [AsiBackbone](https://asibackbone.github.io/AsiBackbone/) | Implementation and runtime contract | Package, API, runtime, and integration-boundary truth: installation, public API behavior, runtime semantics, security and cryptographic posture, exact terminology-to-API mappings, release notes, upgrade guides, and consumer verification. | [AsiBackbone `docs/articles/documentation-ownership.md`](https://github.com/AsiBackbone/AsiBackbone/blob/main/docs/articles/documentation-ownership.md) |
| [.NET Core Application Template](https://asibackbone.github.io/NetCoreApplicationTemplate/) | Implementation and runtime contract | Template and generated-application truth: template options, generated configuration, middleware order, runtime contracts, the public surface, ADRs, deployment guidance, and release history. | [NetCoreApplicationTemplate `docs/articles/documentation-ownership.md`](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/main/docs/articles/documentation-ownership.md) |
| [AsiBackbone Reference Application](https://asibackbone.github.io/ReferenceApplication/) | Integration evidence | The ordered NCAT-to-AsiBackbone integration walkthrough, its host-specific API reference, and measured integration evidence such as benchmarks, recorded per release. | [ReferenceApplication `docs/walkthrough/index.md`](https://github.com/AsiBackbone/ReferenceApplication/blob/main/docs/walkthrough/index.md) |
| [Organization profile and landing pages](https://asibackbone.github.io/) | Routing and positioning | Ecosystem positioning and navigation, the landing-page standard, organization community defaults, and the cross-repository registers: the compatibility matrix, the security assurance map, and this ownership map. | [.github `LANDING-PAGE-STANDARD.md`](https://github.com/AsiBackbone/.github/blob/main/LANDING-PAGE-STANDARD.md) |

Reusable education explains ideas that stay useful without any one package. Implementation and runtime contracts state what a released package or template actually does. Integration evidence records what one host did with specific versions. Routing surfaces position the projects and send readers to the owner.

## Reuse patterns

| Pattern | Rule |
| --- | --- |
| Link only | Do not restate the contract. Link to the canonical source. |
| Summary + link | A short orientation summary for first-contact context, with a link to the canonical detail. Keep it short enough that it cannot become a second contract. |
| Pinned snapshot | A statement tied to a named release or tag, for historical or reproducible evidence. Say which release it describes, and do not update it as current guidance when the owner moves on. |

## Current guidance and pinned evidence

| Currency | Meaning |
| --- | --- |
| Current | Mutable current guidance. The owner keeps it up to date; other repositories link to it rather than copying it. |
| Pinned | Version-pinned historical evidence. Each entry describes a released state and does not change afterwards. |

## Ownership

| Topic | Owner | Currency | Canonical source | Learning | AsiBackbone | NCAT | Reference Application | Organization |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| [Product fit and choosing a project](#product-fit) | Organization | Current | [.github `LANDING-PAGE-STANDARD.md`](https://github.com/AsiBackbone/.github/blob/main/LANDING-PAGE-STANDARD.md)<br>[.github `profile/README.md`](https://github.com/AsiBackbone/.github/blob/main/profile/README.md) | Summary + link | Summary + link | Summary + link | Summary + link | **Owner** |
| [AsiBackbone API and runtime behavior](#asibackbone-api-runtime) | AsiBackbone | Current | [AsiBackbone `docs/index.md`](https://github.com/AsiBackbone/AsiBackbone/blob/main/docs/index.md)<br>[AsiBackbone `docs/api-reference.md`](https://github.com/AsiBackbone/AsiBackbone/blob/main/docs/api-reference.md) | Pinned snapshot | **Owner** | Link only | Pinned snapshot | Link only |
| [NCAT template options and runtime contracts](#ncat-template-contracts) | NCAT | Current | [NetCoreApplicationTemplate `docs/articles/public-surface-v1.md`](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/main/docs/articles/public-surface-v1.md)<br>[NetCoreApplicationTemplate `docs/articles/template-option-matrix.md`](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/main/docs/articles/template-option-matrix.md) | Pinned snapshot | Link only | **Owner** | Pinned snapshot | Link only |
| [Reference Application integration sequence and measured evidence](#reference-integration) | Reference Application | Current | [ReferenceApplication `docs/walkthrough/index.md`](https://github.com/AsiBackbone/ReferenceApplication/blob/main/docs/walkthrough/index.md)<br>[ReferenceApplication `docs/walkthrough/08-benchmarks.md`](https://github.com/AsiBackbone/ReferenceApplication/blob/main/docs/walkthrough/08-benchmarks.md) | Summary + link | Summary + link | Summary + link | **Owner** | Summary + link |
| [Framework-neutral tutorials, comparisons, and architecture explanations](#architecture-education) | Learning | Current | [Learning `docs/index.md`](https://github.com/AsiBackbone/Learning/blob/main/docs/index.md)<br>[Learning `docs/architecture/index.md`](https://github.com/AsiBackbone/Learning/blob/main/docs/architecture/index.md) | **Owner** | Summary + link | Summary + link | Link only | Summary + link |
| [Educational terminology and glossary](#educational-terminology) | Learning | Current | [Learning `docs/architecture/glossary.md`](https://github.com/AsiBackbone/Learning/blob/main/docs/architecture/glossary.md)<br>[Learning `docs/architecture/terminology-and-established-concepts.md`](https://github.com/AsiBackbone/Learning/blob/main/docs/architecture/terminology-and-established-concepts.md) | **Owner** | Summary + link | Link only | Link only | Link only |
| [Compatibility and version matrix](#compatibility-matrix) | Organization | Current | [.github `compatibility/README.md`](https://github.com/AsiBackbone/.github/blob/main/compatibility/README.md) | Pinned snapshot | Summary + link | Summary + link | Pinned snapshot | **Owner** |
| [Security control ownership](#security-control-ownership) | Organization | Current | [.github `assurance/README.md`](https://github.com/AsiBackbone/.github/blob/main/assurance/README.md) | Link only | Link only | Link only | Link only | **Owner** |
| [AsiBackbone release history and migration guidance](#asibackbone-releases) | AsiBackbone | Pinned | [AsiBackbone `CHANGELOG.md`](https://github.com/AsiBackbone/AsiBackbone/blob/main/CHANGELOG.md)<br>[AsiBackbone `docs/articles/api-compatibility-and-semver.md`](https://github.com/AsiBackbone/AsiBackbone/blob/main/docs/articles/api-compatibility-and-semver.md) | Pinned snapshot | **Owner** | Link only | Pinned snapshot | Link only |
| [NCAT release history and support lifecycle](#ncat-releases) | NCAT | Pinned | [NetCoreApplicationTemplate `CHANGELOG.md`](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/main/CHANGELOG.md)<br>[NetCoreApplicationTemplate `.github/SUPPORT.md`](https://github.com/AsiBackbone/NetCoreApplicationTemplate/blob/main/.github/SUPPORT.md) | Pinned snapshot | Link only | **Owner** | Pinned snapshot | Link only |
| [Reference Application release history](#reference-releases) | Reference Application | Pinned | [ReferenceApplication `CHANGELOG.md`](https://github.com/AsiBackbone/ReferenceApplication/blob/main/CHANGELOG.md) | Link only | Link only | Link only | **Owner** | Pinned snapshot |
| [Learning release history and citation](#learning-releases) | Learning | Pinned | [Learning `CHANGELOG.md`](https://github.com/AsiBackbone/Learning/blob/main/CHANGELOG.md)<br>[Learning `README.md`](https://github.com/AsiBackbone/Learning/blob/main/README.md) | **Owner** | Link only | Link only | Link only | Pinned snapshot |
| [Organization positioning and navigation](#organization-navigation) | Organization | Current | [.github `LANDING-PAGE-STANDARD.md`](https://github.com/AsiBackbone/.github/blob/main/LANDING-PAGE-STANDARD.md)<br>[.github `profile/README.md`](https://github.com/AsiBackbone/.github/blob/main/profile/README.md) | Summary + link | Summary + link | Summary + link | Summary + link | **Owner** |

## Topic notes

<a id="product-fit"></a>

### Product fit and choosing a project

The organization owns the cross-project choice and the shared structure of fit sections. Each project's own fit section stays canonical for its own adoption criteria.

- **AsiBackbone Learning** (Summary + link): Keeps its own fit guidance under the landing-page standard's product-fit contract and links the organization overview for choosing between projects.
- **AsiBackbone** (Summary + link): Keeps its own fit guidance under the product-fit contract, including when simpler designs are enough.
- **.NET Core Application Template** (Summary + link): Keeps its own "Is the template a fit?" section under the product-fit contract.
- **AsiBackbone Reference Application** (Summary + link): States that it is an example host, not a product, and links the organization overview.

<a id="asibackbone-api-runtime"></a>

### AsiBackbone API and runtime behavior

AsiBackbone's own documentation-ownership page classifies its articles; this row only routes other repositories to it.

- **AsiBackbone Learning** (Pinned snapshot): Implementation-dependent pages name the reviewed AsiBackbone release and pin source links to its tag.
- **.NET Core Application Template** (Link only): Documents only the host-owned integration seams and links AsiBackbone for package behavior.
- **AsiBackbone Reference Application** (Pinned snapshot): Each release records the exact package version it integrates.
- **Organization profile and landing pages** (Link only): Routes to the AsiBackbone documentation.

<a id="ncat-template-contracts"></a>

### NCAT template options and runtime contracts

Generated applications are not modified by later NCAT releases, so a derived host's baseline is always a pinned snapshot.

- **AsiBackbone Learning** (Pinned snapshot): Pages that cite NCAT behavior name the reviewed NCAT release and pin links to its tag.
- **AsiBackbone** (Link only): Its NCAT host-validation guide is a procedure that links NCAT for generated behavior.
- **AsiBackbone Reference Application** (Pinned snapshot): Records its NCAT baseline as an ncat-v<version> tag; NCAT's documentation stays authoritative for baseline behavior.
- **Organization profile and landing pages** (Link only): Routes to the NCAT documentation.

<a id="reference-integration"></a>

### Reference Application integration sequence and measured evidence

The walkthrough is current guidance. Measured results, such as benchmarks, belong to the release that produced them and are cited by release tag.

- **AsiBackbone Learning** (Summary + link): May describe the integration path in teaching terms and link the walkthrough for the concrete steps.
- **AsiBackbone** (Summary + link): May point adopters to the walkthrough as a worked example.
- **.NET Core Application Template** (Summary + link): Lists the Reference Application as a related project.
- **Organization profile and landing pages** (Summary + link): Describes it in the profile and landing pages and links the walkthrough.

<a id="architecture-education"></a>

### Framework-neutral tutorials, comparisons, and architecture explanations

If a page teaches an idea that stays useful without the AsiBackbone packages, it belongs in Learning.

- **AsiBackbone** (Summary + link): Keeps short product-boundary or transition pages that route to Learning for the broader explanation.
- **.NET Core Application Template** (Summary + link): Links Learning for general rationale, alternatives, and tradeoffs from its implementation articles.
- **AsiBackbone Reference Application** (Link only): Links Learning for concepts instead of teaching them.
- **Organization profile and landing pages** (Summary + link): Introduces Learning as the first stop for the patterns.

<a id="educational-terminology"></a>

### Educational terminology and glossary

Definitions live in Learning; type and namespace mappings live in AsiBackbone.

- **AsiBackbone** (Summary + link): Owns only the exact mapping from terms to API types, in its API glossary and terminology map, and links Learning for definitions.
- **.NET Core Application Template** (Link only): Uses the terms without redefining them.
- **AsiBackbone Reference Application** (Link only): Uses the terms without redefining them.
- **Organization profile and landing pages** (Link only): Uses the terms without redefining them.

<a id="compatibility-matrix"></a>

### Compatibility and version matrix

Statements about another project's current version belong in the matrix. The current-version claim review below checks first-contact pages for stale copies.

- **AsiBackbone Learning** (Pinned snapshot): May state the release a page was reviewed against; links the matrix for current combinations.
- **AsiBackbone** (Summary + link): States its own supported line and target framework, and links the matrix for cross-project combinations.
- **.NET Core Application Template** (Summary + link): States its own supported line and target framework, and links the matrix for cross-project combinations.
- **AsiBackbone Reference Application** (Pinned snapshot): Each release records its exact NCAT and AsiBackbone pins; the matrix records which combination it qualifies.

<a id="security-control-ownership"></a>

### Security control ownership

The map records who owns each control and links each repository's documentation; it does not restate the technical contract.

- **AsiBackbone Learning** (Link only): Teaches security architecture without assigning ownership of the organization's controls.
- **AsiBackbone** (Link only): Its security and cryptographic documentation stays canonical for each control's contract; it links the map for cross-repository ownership.
- **.NET Core Application Template** (Link only): Its security documentation stays canonical for each control's contract; it links the map for cross-repository ownership.
- **AsiBackbone Reference Application** (Link only): Documents its own host controls and links the map for cross-repository ownership.

<a id="asibackbone-releases"></a>

### AsiBackbone release history and migration guidance

Release notes are historical once published. Upgrade guides are current for the version span they cover.

- **AsiBackbone Learning** (Pinned snapshot): Records which AsiBackbone release a Learning release reviewed.
- **.NET Core Application Template** (Link only): Does not restate AsiBackbone release notes.
- **AsiBackbone Reference Application** (Pinned snapshot): Records each package update in its own changelog, naming the versions.
- **Organization profile and landing pages** (Link only): Links release pages from the compatibility matrix.

<a id="ncat-releases"></a>

### NCAT release history and support lifecycle

Release notes are historical once published. The support policy is current guidance owned by NCAT.

- **AsiBackbone Learning** (Pinned snapshot): Records which NCAT release a Learning page was reviewed against.
- **AsiBackbone** (Link only): Does not restate NCAT release notes.
- **AsiBackbone Reference Application** (Pinned snapshot): Records each NCAT baseline refresh, naming the versions.
- **Organization profile and landing pages** (Link only): Links release pages from the compatibility matrix.

<a id="reference-releases"></a>

### Reference Application release history

Each release is a pre-release snapshot of the walkthrough's progress.

- **AsiBackbone Learning** (Link only): Links the Reference Application instead of restating its releases.
- **AsiBackbone** (Link only): Links the Reference Application instead of restating its releases.
- **.NET Core Application Template** (Link only): Links the Reference Application instead of restating its releases.
- **Organization profile and landing pages** (Pinned snapshot): The compatibility matrix records each release's qualified combination with tag-pinned evidence.

<a id="learning-releases"></a>

### Learning release history and citation

Learning releases are archival and citation snapshots; they do not establish runtime compatibility or package support lines.

- **AsiBackbone** (Link only): Links Learning instead of restating its releases.
- **.NET Core Application Template** (Link only): Links Learning instead of restating its releases.
- **AsiBackbone Reference Application** (Link only): Links Learning instead of restating its releases.
- **Organization profile and landing pages** (Pinned snapshot): The compatibility matrix records each Learning release's reviewed baseline.

<a id="organization-navigation"></a>

### Organization positioning and navigation

Each project owns its own description. As the landing-page standard requires, the organization surfaces reuse those descriptions, shortened if needed, rather than inventing new claims.

- **AsiBackbone Learning** (Summary + link): Carries the shared ecosystem navigation and related-project section defined by the landing-page standard.
- **AsiBackbone** (Summary + link): Carries the shared ecosystem navigation and related-project section defined by the landing-page standard.
- **.NET Core Application Template** (Summary + link): Carries the shared ecosystem navigation and related-project section defined by the landing-page standard.
- **AsiBackbone Reference Application** (Summary + link): Carries the shared ecosystem navigation and related-project section defined by the landing-page standard.

## Review rule for new documentation

Before adding or expanding documentation, answer:

1. Does it state behavior, an option, an API, a version, or a support boundary? If this repository is not the topic's owner above, link to the owner, or add at most a short summary with a canonical link.
2. Does it state another project's current version or compatibility? Link the [compatibility matrix](../compatibility/README.md) instead, or tie the statement to a named release as a pinned snapshot, for example "reviewed against AsiBackbone 7.0.0".
3. Is it a historical or reproducible record? Pin it to a release tag, say so, and do not update it as current guidance.
4. Does it teach an idea that stays useful without the AsiBackbone packages? It belongs in Learning.
5. Is there an existing summary? Keep it if it helps readers, and make sure it links its canonical source rather than removing it for symmetry.

## Current-version claim review

The weekly `Documentation ownership review` workflow runs `scripts/Test-DocumentationOwnership.ps1 -ScanVersionClaims`. It reads each surface's first-contact pages on `main` and reports a sentence or clause that:

- names another project with a version, such as "AsiBackbone 7.1.0";
- asserts that it is current, using words such as current, latest, newest, newer, or now;
- does not mark itself as a pinned snapshot, with words such as reviewed, pinned, baseline, snapshot, or historical; and
- disagrees with the current release in the compatibility matrix.

Claims about a surface's own project are not checked, because that surface owns them. Changelogs and release notes are not scanned, because they are pinned history. Resolve a finding in the owning repository by linking the compatibility matrix or rewording the statement as a pinned snapshot.

| Surface | Scanned pages |
| --- | --- |
| AsiBackbone Learning | `README.md`, `docs/index.md` |
| AsiBackbone | `README.md`, `docs/index.md` |
| .NET Core Application Template | `README.md`, `PACKAGE-README.md`, `docs/index.md` |
| AsiBackbone Reference Application | `README.md`, `docs/index.md` |
| Organization profile and landing pages | `profile/README.md`, `README.md` |

## Updating the map

1. Edit [`ownership.json`](ownership.json). Give each topic exactly one owner and canonical source, and say how every other surface references it.
2. Run `./scripts/Test-DocumentationOwnership.ps1 -Update` to regenerate this page, then `./scripts/Test-DocumentationOwnership.ps1 -VerifyReferences -ScanVersionClaims` to confirm every link resolves and see current-version findings.
3. Open a pull request. The `Validate organization profile` check fails when the manifest is malformed, a required topic or reuse entry is missing, a surface owns nothing, or this page does not match the manifest.
