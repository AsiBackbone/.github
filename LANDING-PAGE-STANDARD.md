# AsiBackbone Landing-Page Standard

**Version:** 1.2.0
**Status:** Active
**Contract issue:** [AsiBackbone/.github#15](https://github.com/AsiBackbone/.github/issues/15)

This standard defines the shared landing-page experience for the AsiBackbone organization. It sets a family resemblance and a common information architecture. It does not require identical pages, identical markup, or a shared runtime dependency.

Each project remains the technical source of truth for its own APIs, runtime behavior, educational content, and template behavior. A landing page routes readers to that canonical material; it does not restate it.

## Versioning

The standard uses semantic versioning:

- **Major:** a required section, destination, or label is added, removed, or renamed.
- **Minor:** a new optional section, token, or validation check is added.
- **Patch:** wording, examples, or references change without changing a requirement.

Implementations should record which version they were last reviewed against, for example in the pull request that applies the standard.

### Change history

| Version | Issue | Change |
| --- | --- | --- |
| 1.0.0 | [AsiBackbone/.github#15](https://github.com/AsiBackbone/.github/issues/15) | Initial standard. |
| 1.1.0 | [AsiBackbone/.github#21](https://github.com/AsiBackbone/.github/issues/21) | Adds document-language, page-metadata, published-output, full-width DocFX homepage, and template-rendered skip-link requirements, and the scheduled published-site check. |
| 1.2.0 | [AsiBackbone/.github#20](https://github.com/AsiBackbone/.github/issues/20) | Requires every DocFX build in pull-request, release, and publication workflows to fail on warnings, and adds per-repository and scheduled strict-build checks. |

## Public surfaces

| Surface | URL | Platform | Repository |
| --- | --- | --- | --- |
| Organization profile | <https://github.com/AsiBackbone> | GitHub-rendered Markdown | [`AsiBackbone/.github`](https://github.com/AsiBackbone/.github) (`profile/README.md`) |
| Organization landing page | <https://asibackbone.github.io/> | Static HTML on GitHub Pages | [`AsiBackbone/asibackbone.github.io`](https://github.com/AsiBackbone/asibackbone.github.io) |
| Learning | <https://asibackbone.github.io/Learning/> | DocFX `modern` template with custom template overrides | [`AsiBackbone/Learning`](https://github.com/AsiBackbone/Learning) |
| Framework | <https://asibackbone.github.io/AsiBackbone/> | DocFX `modern` template | [`AsiBackbone/AsiBackbone`](https://github.com/AsiBackbone/AsiBackbone) |
| Template | <https://asibackbone.github.io/NetCoreApplicationTemplate/> | DocFX `modern` template | [`AsiBackbone/NetCoreApplicationTemplate`](https://github.com/AsiBackbone/NetCoreApplicationTemplate) |

## Baselines

- **Semantic baseline:** the organization landing page and organization profile. Their problem-first positioning, Start Here routing, ecosystem cards, simpler-alternative guidance, and practical architectural voice define the shared content model.
- **DocFX visual baseline:** Learning. Its homepage hero, calls to action, entry-point cards, learning-path cards, skip link, reduced-motion handling, and light/dark support (`docs/index.md` and `docs/templates/` in the Learning repository) are the reference implementation for DocFX sites. Framework and Template should reuse that vocabulary rather than invent another.
- **Product-fit baseline:** AsiBackbone's [Adoption and Target Use Cases](https://asibackbone.github.io/AsiBackbone/articles/use-cases.html), with its "Good product fit" and "Poor product fit" sections, and Learning's [When ASP.NET Core Authorization Is Enough](https://asibackbone.github.io/Learning/architecture/when-aspnet-core-authorization-is-enough.html) and [When a Simple Application Service Is Enough](https://asibackbone.github.io/Learning/architecture/when-a-simple-application-service-is-enough.html). These pages are referenced, not recreated.

## Required and optional sections

A product landing page (Learning, Framework, Template) contains the required sections in this order. The organization landing page and profile follow the same order where their platform allows it; their substitutions are listed in [Surface adaptations](#surface-adaptations).

| Order | Section | Requirement |
| --- | --- | --- |
| — | Ecosystem navigation | Required |
| 1 | Hero | Required |
| 2 | Start Here | Required |
| 3 | Product fit | Required |
| — | Project-specific sections | Optional |
| 4 | Related Projects | Required |
| 5 | Design Philosophy | Required |
| — | Footer | Required |

Project-specific sections may appear between Product fit and Related Projects. Examples of permitted optional sections:

- Learning: core model flow, learning paths, how Learning works, recently added, scope and limitations;
- Framework: current stable package family, product documentation map;
- Template: At a Glance, generated application reference, deployment and operations, release and compatibility.

Optional sections must not displace the required sections from the first screenful of the page on desktop: the hero and the start of Start Here should be visible without scrolling at a 1280×800 viewport.

DocFX homepages disable the table-of-contents sidebar and the affix (`_disableToc: true` and `_disableAffix: true` in the homepage front matter) so the hero and Start Here use the full content width. Article pages keep their sidebar.

## 1. Ecosystem navigation contract

Every surface exposes the same six destinations with the same labels:

| Label | Destination | Notes |
| --- | --- | --- |
| Organization | `https://asibackbone.github.io/` | May be the brand link on the organization landing page itself. |
| Learning | `https://asibackbone.github.io/Learning/` | |
| Community | `https://asibackbone.github.io/#community` | The organization landing page may use the in-page anchor `#community`. |
| Framework | `https://asibackbone.github.io/AsiBackbone/` | |
| Template | `https://asibackbone.github.io/NetCoreApplicationTemplate/` | |
| GitHub | `https://github.com/AsiBackbone` | The organization, not a single repository. |

Requirements:

- Labels are exactly those listed. Longer descriptive text may accompany a label (for example a DocFX dropdown item "Framework documentation"), but the short label is the visible name wherever space is constrained.
- The current site is identified with `aria-current="page"` or the platform's equivalent active state where the platform permits it.
- The ecosystem navigation is a labelled navigation landmark (for example `aria-label="AsiBackbone sites"`) on HTML surfaces.
- Navigation remains reachable on mobile. It may collapse into a disclosure control, but it must not be removed with `display: none` without an accessible alternative.
- **DocFX adaptation:** add a top-level `AsiBackbone` (or `Resources`) entry in `toc.yml` whose items use the six labels above, plus a link to the site's own repository. The repository link is in addition to, not a replacement for, `GitHub`.
- **Profile adaptation:** GitHub profile Markdown cannot host a navigation landmark. The profile satisfies this contract by linking Organization, Learning, Framework, and Template in its body. Its "Learn, Ask, and Contribute" routes to organization Discussions stand in for Community, and the profile is itself the GitHub destination.

## 2. Hero contract

The hero contains, in order:

1. **Heading:** the site name as the page `h1`, or a short problem-first positioning statement when the site name is already in the header.
2. **Positioning statement:** one short line describing what the project is.
3. **Why it exists:** one sentence naming the problem.
4. **When to use it:** one sentence naming the situation in which a reader should choose it.
5. **Actions:** one primary action and one or two secondary actions.

Requirements:

- The primary action is the task most first-time readers need (for example Get Started). Secondary actions route to orientation (for example Find Your Path) or evaluation (for example Is this a fit?).
- Actions are links styled as buttons, not `<button>` elements, because they navigate.
- No more than three actions.
- The hero does not repeat the Product-fit section; the "when to use it" sentence links to it if more detail is needed.
- The hero may include one principle statement (for example Learning's "A proposed action should become a governed decision before it becomes real-world execution.").

## 3. Start Here contract

- Three to six task-oriented routes, presented immediately after the hero.
- Each route has a short label written from the reader's point of view (for example "Install and generate an application", "I have a problem to solve") and a one-sentence description.
- Each route links to one canonical page. Routes do not summarize that page's content.
- Routes use the card component on HTML and DocFX surfaces. The profile uses a bulleted list or headed subsections.
- Longer task tables (such as Framework's "Choose a task") may remain as an optional section after Start Here; the six most common rows become the Start Here cards.

## 4. Product-fit contract

- A short section headed "Is this a fit?" (or equivalent) with two parts: when the project is appropriate, and when a simpler alternative is preferable.
- Each part is at most three bullets or two short paragraphs.
- The section links to the canonical fit guidance instead of duplicating it:
  - Learning: the "when it is enough" architecture pages listed in [Baselines](#baselines), and the statement that Learning does not require installing the package;
  - Framework: [Adoption and Target Use Cases](https://asibackbone.github.io/AsiBackbone/articles/use-cases.html);
  - Template: the template's own guidance on when plain `dotnet new webapp` or `dotnet new webapi` is sufficient. If that page does not yet exist, creating it is part of the Template rollout issue.
- The organization landing page and profile satisfy this contract through the Design Philosophy section's links to simpler-alternative guidance.

## 5. Related Projects contract

The three-project ecosystem uses the same names, roles, and destinations everywhere:

| Canonical name | Role label | Documentation | Repository | Archive |
| --- | --- | --- | --- | --- |
| AsiBackbone Learning | Learn the patterns | `https://asibackbone.github.io/Learning/` | `https://github.com/AsiBackbone/Learning` | `https://doi.org/10.5281/zenodo.21938556` |
| AsiBackbone | Add governed decisions | `https://asibackbone.github.io/AsiBackbone/` | `https://github.com/AsiBackbone/AsiBackbone` | `https://doi.org/10.5281/zenodo.20546032` |
| .NET Core Application Template | Start a secure application | `https://asibackbone.github.io/NetCoreApplicationTemplate/` | `https://github.com/AsiBackbone/NetCoreApplicationTemplate` | `https://doi.org/10.5281/zenodo.20373042` |

Requirements:

- Use the canonical names in headings and cards. "ASI Backbone" (with a space) is a legacy spelling.
- Site names use the canonical names too: the browser title suffix (DocFX `_appTitle`), the navbar brand (DocFX `_appName`), and `og:site_name` must not use the legacy spelling.
- Each project card contains, in order: role label, project name as a heading linked to its documentation, a one- or two-sentence description, and links labelled `Documentation`, `Repository`, and `Archive (DOI)`.
- On a product site, the card for the current project is either omitted or marked as the current site; it is never presented as an external destination.
- Cards are `article` elements (or Markdown subsections on the profile) with a heading, so they are discoverable by heading navigation.
- Descriptions are owned by each project. The organization surfaces use the descriptions from the projects' own README or homepage, shortened if needed, rather than inventing new claims.

## 6. Design Philosophy contract

Every surface includes this shared statement verbatim:

> We favor architectures where consequential operations are explicit, constrained, reviewable, and auditable.

It is followed by:

- a statement that the organization also documents when these patterns are unnecessary, linking to at least one simpler-alternative page; and
- a non-claim that the projects focus on practical .NET engineering and do not claim regulatory certification or automatic compliance.

Project-specific boundaries are preserved, not merged. For example, AsiBackbone's [Project Boundaries and Non-Claims](https://asibackbone.github.io/AsiBackbone/articles/project-boundaries.html) and Learning's scope-and-limitations disclosure remain canonical; the Design Philosophy callout links to them where relevant.

## 7. Visual tokens and components

The tokens below are a shared vocabulary. Each repository defines them locally. On DocFX sites they map to Bootstrap 5 variables provided by the `modern` template so that its light/dark switch keeps working.

### Typography

| Role | Value |
| --- | --- |
| Font stack | System UI stack: `system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif` (DocFX: template default) |
| Body size | `1rem`–`1.0625rem`, line height `1.5`–`1.6` |
| Hero heading | `clamp(1.9rem, 4.5vw, 2.8rem)`, line height `1.2` |
| Hero summary | `clamp(1.1rem, 2.5vw, 1.4rem)`, line height `1.55` |
| Section heading (`h2`) | `1.5rem` |
| Kicker and role labels | `0.75rem`–`0.875rem`, weight 600–700 |

### Layout and spacing

| Token | Value |
| --- | --- |
| Content width | `68rem` maximum on the organization landing page; DocFX sites use the template container |
| Prose width | `44rem`–`54rem` maximum for hero and intro paragraphs |
| Side gutter | `1rem` minimum |
| Card gap | `1rem`–`1.25rem` |
| Card padding | `1rem`–`1.5rem` |
| Section spacing | `2rem`–`2.5rem` above each `h2` |

### Color roles

| Role | Landing page variable | DocFX / Bootstrap variable | Light | Dark |
| --- | --- | --- | --- | --- |
| Page background | `--bg` | `--bs-body-bg` | `#f7f8fa` | `#0f1419` |
| Surface (cards) | `--surface` | `--bs-body-bg` or `--bs-tertiary-bg` | `#ffffff` | `#161c23` |
| Text | `--text` | `--bs-body-color` | `#1b1f24` | `#e6edf3` |
| Muted text | `--muted` | `--bs-secondary-color` | `#57606a` | `#9aa6b2` |
| Border | `--border` | `--bs-border-color` | `#d8dee4` | `#2d3640` |
| Accent / link | `--accent` | `--bs-link-color`, `--bs-primary` | `#0b5cad` | `#6cb6ff` |
| Accent soft (role label background) | `--accent-soft` | `rgba(var(--bs-primary-rgb), 0.12)` | `#e7f0fa` | `#15283b` |
| Focus ring | `--focus` | `--bs-focus-ring-color` | `#0b5cad` | `#6cb6ff` |

The hex values are those of the organization landing page. DocFX sites use the template's own values for the mapped variables; they are not required to override Bootstrap colors, only to use the mapped roles instead of hard-coded colors.

### Borders, radii, and elevation

| Token | Value |
| --- | --- |
| Border | `1px solid` border role |
| Card radius | `0.625rem`–`0.75rem` (10–12px) |
| Hero panel radius | `1rem` |
| Pill radius (role labels) | `999px` |
| Elevation | None at rest; hover/focus may add `0 0.3rem 0.9rem rgba(var(--bs-primary-rgb), 0.12)` |

### Components

| Component | Reference implementation | Required behavior |
| --- | --- | --- |
| Hero panel | Learning `.home-hero`, `.home-kicker`, `.home-summary`, `.home-actions` | Contains the hero contract; actions wrap and become full width below the small breakpoint. |
| Button | Bootstrap `.btn-primary` and `.btn-outline-primary` on DocFX; landing page may use styled links | Minimum target size 44×44 CSS pixels; visible focus. |
| Route card | Learning `.entry-point`; landing page `.route` | Whole card is one link or contains one heading link; label plus one-sentence description. |
| Project card | Landing page `.project` with `.role` | Follows the Related Projects contract. |
| Philosophy callout | Landing page `.principles` | Bordered surface panel containing the Design Philosophy contract. |
| Disclosure | Learning `.home-details` | Used for secondary scope and limitation detail only; never for required sections. |

Repositories copy and adapt these components. They do not load CSS or JavaScript from another repository's published site.

### Light and dark behavior

- The organization landing page follows `prefers-color-scheme`.
- DocFX sites use the `modern` template's theme switch (`data-bs-theme`). Custom CSS uses Bootstrap variables so both themes work without separate overrides.
- Gradients and tinted backgrounds are derived from the accent role with transparency so they adapt to the active theme.
- The GitHub profile inherits GitHub's theme and adds no images that are unreadable in either theme.

### Responsive breakpoints

| Name | Width | Behavior |
| --- | --- | --- |
| Small | below `36rem` (576px) | Single-column cards; hero actions full width; navigation collapses into a disclosure control. |
| Medium | `36rem`–`62rem` (576–992px) | Two-column card grids. |
| Large | `62rem` (992px) and above | Up to three-column card grids. |

Card grids may instead use `repeat(auto-fit, minmax(min(100%, 18rem), 1fr))`, which satisfies the same behavior without explicit breakpoints. No layout may cause horizontal page scrolling at a 320px viewport.

## 8. Footer contract

Every HTML and DocFX surface footer contains:

- organization affiliation: "Part of [AsiBackbone](https://asibackbone.github.io/)";
- the source route: a link to the site's own repository;
- the community route: a link to organization [Discussions](https://github.com/orgs/AsiBackbone/discussions) or the landing page's `#community` section; and
- project-appropriate license or archive links: the repository license, and the Zenodo DOI where the project has one.

The footer may also include the non-affiliation notice ("not affiliated with the Artificial Superintelligence Alliance"), a feed link, and a "Made with DocFX" credit. On DocFX sites the footer is set through `_appFooter` in `docfx.json`. The profile satisfies this contract with its License section.

## 9. Accessibility and quality requirements

- **Landmarks:** one `header`, one `main` with an `id` targeted by a skip link, labelled `nav` landmarks, and one `footer`.
- **Document language:** the root element declares the page language, `<html lang="en">`. On DocFX sites set `"_lang": "en"` in `globalMetadata`.
- **Skip link:** the first focusable element moves focus to main content and is visible when focused. It is rendered in the page's template markup, before the `header`, and targets the `main` element's `id`, so it works when JavaScript does not run. A script may enhance it but must not be the only thing that creates it.
- **Headings:** exactly one `h1`; required sections are `h2`; cards inside a section are `h3`. No heading levels are skipped.
- **Keyboard:** every action, card, disclosure, and navigation item is reachable and operable by keyboard in a logical order.
- **Focus:** focus is always visible, using at least a 2px outline or ring in the focus role with offset, in both themes.
- **Contrast:** text meets WCAG 2.2 AA (4.5:1 for normal text, 3:1 for large text and for focus indicators and component boundaries that convey state) in both themes.
- **Link text:** link text is meaningful out of context, or an `aria-label` supplies the full destination name (as Learning's learning-path cards do).
- **Reduced motion:** transitions and hover transforms are disabled under `prefers-reduced-motion: reduce`.
- **Mobile layout:** content reflows to a single column at 320px width without loss of content or functionality.
- **No hidden content for symmetry:** required content is not hidden, truncated, or moved behind a disclosure to make cards or columns equal height. Unequal cards are acceptable.
- **Decorative images:** decorative images use empty `alt`; meaningful images have descriptive alternatives.

### Page metadata

Every HTML and DocFX surface publishes the following. Values are owned by each project and set in its own configuration (on DocFX sites, `globalMetadata` in `docs/docfx.json` and the homepage front matter); they are not copied from another project.

- **Homepage title:** `<page title> | <site name>`, where the page title is a short positioning phrase that does not repeat the site name, and the whole title is at most 80 characters. On DocFX sites, set `title` in the homepage front matter and the site name in `_appTitle`.
- **Description:** a homepage meta description of at most 160 characters (DocFX: `description` in the homepage front matter). Every page has a meta description.
- **Canonical URL:** an absolute `<link rel="canonical">` on every page. Index pages use the directory form, so the homepage canonical is the site root (for example `https://asibackbone.github.io/AsiBackbone/`).
- **Social preview:** `og:url`, `og:title`, `og:description`, `og:image`, `og:image:alt`, and a `twitter:card`. The image is an absolute URL to an image published by the same site.
- **Structured data:** one JSON-LD `@graph` containing a `WebSite` node whose `url` is the site root, a `WebPage` node whose `url` is the canonical URL, and an `Organization` publisher named `AsiBackbone` with `url` `https://github.com/AsiBackbone`.

Learning's `docs/templates/` is the reference implementation. Framework and Template implement the same output with a layout override and shared `site-metadata.common.js` extension in their own `docs/templates/` folders, which also cover generated API reference pages.

### Published output

- Internal build artifacts are not deployed. DocFX writes `manifest.json` to the build output; remove it before uploading the GitHub Pages artifact unless a consumer is documented in this standard.
- Layout overrides of the DocFX `modern` template name the DocFX version they are based on, and a repository check fails when the pinned DocFX version moves without re-aligning the override.

## 10. Drift prevention

Drift is controlled by a small set of automated checks owned by each repository and a periodic visual review.

### Automated checks

| Check | Surface | Where it runs |
| --- | --- | --- |
| Profile contains all ecosystem destinations, community routes, canonical project names, Design Philosophy statement, and license links | Profile | `scripts/Test-OrganizationProfile.ps1` in this repository |
| This standard names all five surfaces, all ten contracts, the rollout issues, the page-metadata and published-output requirements, and the validation checklist | Standard | `scripts/Test-OrganizationProfile.ps1` in this repository |
| Landing page contains required community and project routes, structured data, and sitemap entries | Organization landing page | `scripts/Test-LandingSite.ps1` in `asibackbone.github.io` |
| Homepage source contains the six navigation destinations, the required section headings, and the Design Philosophy statement | Learning, Framework, Template | A repository-owned script or test added by each rollout issue |
| Homepage front matter, `docfx.json`, and the layout override declare the document language, page metadata, full-width homepage, and template-rendered skip link; the built homepage contains them | Framework, Template | `scripts/Validate-LandingPage.ps1` in each repository |
| Published homepages declare `lang="en"`, a concise non-duplicated title, the canonical URL, a social image, and JSON-LD; render the skip link without JavaScript; omit the sidebar; and do not serve `manifest.json` | Learning, Framework, Template | `scripts/Test-PublishedSites.ps1` in this repository, weekly and on demand through `.github/workflows/published-sites-validation.yml` |
| Every DocFX build in a pull-request, release, or publication workflow runs with `--warningsAsErrors` | Learning, Framework, Template | Each repository's workflows (see [Strict DocFX builds](#strict-docfx-builds)) |
| No workflow DocFX build drops `--warningsAsErrors`, and each required workflow still builds DocFX | Framework, Template | `scripts/Validate-DocFxStrictBuild.ps1` in each repository, on every pull request |
| The same rule holds across all three DocFX sites, including newly added workflows | Learning, Framework, Template | `scripts/Test-DocFxStrictBuilds.ps1` in this repository, weekly and on demand through `.github/workflows/docfx-strict-builds-validation.yml` |
| Internal and external links resolve | All HTML and DocFX surfaces | Each repository's link checker (for example lychee) |

Automated checks assert the presence of destinations, headings, metadata, and served markup. They do not assert visual appearance, contrast, or focus behavior.

The published-site check reads the deployed sites, so it runs on a schedule rather than as a required pull-request check; its self-test runs with the organization profile validation. A finding names the repository that owns the fix.

### Strict DocFX builds

A DocFX warning, such as a broken cross-reference, an unresolved link, or an invalid metadata source, means the published site differs from what the source describes. Every DocFX build that validates a pull request, validates a release, or publishes a site therefore runs with `--warningsAsErrors`, so a warning fails the workflow instead of publishing.

The following workflows must build DocFX strictly. Adding a DocFX build to another workflow is allowed only if that build is strict too; removing a workflow from this table is a change to this standard.

| Site | Repository | Workflows that must build DocFX with `--warningsAsErrors` |
| --- | --- | --- |
| Learning | [`AsiBackbone/Learning`](https://github.com/AsiBackbone/Learning) | `docs-validation.yml`, `publish-docs.yml`, `publish-release-evidence.yml` |
| Framework | [`AsiBackbone/AsiBackbone`](https://github.com/AsiBackbone/AsiBackbone) | `ci.yml`, `publish-docs.yml`, `publish-packages.yml`, `publish-quality-reports.yml`, `release-validation.yml` |
| Template | [`AsiBackbone/NetCoreApplicationTemplate`](https://github.com/AsiBackbone/NetCoreApplicationTemplate) | `link-validation.yml`, `publish-docs.yml` |

Contributor documentation that shows how to build a site locally uses the same strict command, for example `dotnet tool run docfx -- docs/docfx.json --warningsAsErrors`. Local preview commands may add `--serve`. Dated release records keep the commands that were actually run.

### Periodic visual review

Visual consistency, contrast in practice, focus visibility, and mobile layout require a human review. Perform the [validation checklist](#validation-checklist) for every surface:

- when a rollout issue is completed;
- when this standard changes major or minor version; and
- at least once per quarter.

Record the review in an issue or pull request in the affected repository, noting the standard version reviewed against.

## Validation checklist

Use this checklist for each surface. Mark not applicable items explicitly.

- [ ] **Desktop:** at 1280×800, the hero and the start of Start Here are visible without scrolling; layout matches the section order.
- [ ] **Mobile:** at 375×812 and 320px width, content is single-column, actions are full width, there is no horizontal scrolling, and ecosystem navigation is reachable.
- [ ] **Light theme:** text, links, borders, and focus rings meet contrast requirements.
- [ ] **Dark theme (where supported):** the same checks pass after switching theme or emulating `prefers-color-scheme: dark`.
- [ ] **Keyboard focus:** tab from the top of the page; the skip link appears first, every interactive element receives visible focus, and the order follows the visual order.
- [ ] **Reduced motion:** with reduced motion emulated, cards and links do not animate.
- [ ] **Headings and landmarks:** one `h1`, required sections as `h2`, labelled navigation landmarks, one `main`.
- [ ] **Document language and metadata:** the page declares `lang="en"`; the title, description, canonical URL, social preview, and structured data meet [Page metadata](#page-metadata).
- [ ] **Without JavaScript:** with scripts disabled, the skip link is present, moves focus to main content, and the homepage content is readable at full width.
- [ ] **Internal links:** every relative link in the homepage source resolves in the build output.
- [ ] **External links:** all six ecosystem destinations and the three project documentation, repository, and archive links resolve.
- [ ] **DocFX build output (DocFX sites):** `docfx build` with `--warningsAsErrors` completes with no warnings, and `_site/index.html` contains the hero, Start Here, Product fit, Related Projects, and Design Philosophy sections.
- [ ] **Published Pages rendering:** after deployment, the published URL renders the same content as the local build, with styles and theme switching working.

## Surface adaptations

| Contract | Organization profile | Organization landing page |
| --- | --- | --- |
| Ecosystem navigation | Destinations linked in the body; Discussions routes stand in for Community | Header `nav` with Learning, Community, Framework, Template, GitHub; brand link is Organization |
| Hero | Opening paragraphs | Hero section |
| Start Here | "Learn, Ask, and Contribute" routes and "Start Here" project sections | "Learn, ask, and contribute" route cards and "Start here" project cards |
| Product fit | Design Philosophy links to simpler-alternative pages | Design Philosophy links to simpler-alternative pages |
| Related Projects | "Start Here" project subsections | "Start here" project cards |
| Design Philosophy | Required | Required |
| Footer | License section | Footer |

On the two organization surfaces, the Start Here project list doubles as the Related Projects section; repeating it would duplicate content.

## Rollout

Rollout order:

1. **Standard and organization profile** — this standard, issue [AsiBackbone/.github#15](https://github.com/AsiBackbone/.github/issues/15).
2. **Learning** — confirm and close remaining gaps against the DocFX visual baseline: [AsiBackbone/.github#16](https://github.com/AsiBackbone/.github/issues/16).
3. **AsiBackbone** — adopt the Learning component vocabulary on the framework homepage: [AsiBackbone/.github#17](https://github.com/AsiBackbone/.github/issues/17).
4. **NetCoreApplicationTemplate** — adopt the same vocabulary on the template homepage: [AsiBackbone/.github#18](https://github.com/AsiBackbone/.github/issues/18).
5. **Organization landing page** — apply the review findings below in `asibackbone.github.io`.
6. **Cross-site metadata and accessibility drift** — close the remaining DocFX output drift in Framework and Template and add the published-site check: [AsiBackbone/.github#21](https://github.com/AsiBackbone/.github/issues/21).
7. **Strict DocFX builds** — make every Framework and Template DocFX build fail on warnings, guard the rule in each repository and across the organization: [AsiBackbone/.github#20](https://github.com/AsiBackbone/.github/issues/20).

Learning goes first because it already implements most of the DocFX contract; its components then become the copy source for steps 3 and 4.

## Baseline review: organization surfaces

Reviewed against version 1.0.0 of this standard.

### Organization profile (`profile/README.md`)

- Hero, Start Here, Related Projects, Design Philosophy, and License sections satisfy the contract.
- **Adjusted:** project headings used the legacy "ASI Backbone" spelling and role phrases that differed from the landing page. They now use the canonical names and role labels from the Related Projects contract.
- **Adjusted:** the profile did not link the organization landing page. It now does, so every ecosystem destination is reachable from the profile.

### Organization landing page (`asibackbone.github.io`)

The landing page satisfies the hero, Start Here, Related Projects, Design Philosophy, and color-token contracts. Remaining mismatches, to be fixed in that repository:

- The header navigation is hidden with `display: none` below `36rem` and has no mobile alternative (Ecosystem navigation contract; Accessibility: mobile layout).
- The footer does not link the landing page's own repository, organization Discussions, or license files (Footer contract).
- The header navigation does not mark the current site with `aria-current` (Ecosystem navigation contract).

## Non-goals

- Rewriting detailed project documentation into marketing copy.
- Making every homepage pixel-identical.
- Duplicating canonical product-fit or architecture guidance on multiple sites.
- Introducing analytics, a new JavaScript framework, or a shared deployment service.
- Changing project APIs, package behavior, release metadata, or documentation ownership boundaries.
