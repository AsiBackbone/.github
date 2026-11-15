# AsiBackbone Repository File Baseline

**Last reviewed:** 2026-11-15 ([AsiBackbone/.github#50](https://github.com/AsiBackbone/.github/issues/50))

This baseline lists the contributor, maintainer, and repository-control files that each AsiBackbone project repository
is expected to carry, and records why some files exist in only some repositories. It complements the
[landing-page standard](LANDING-PAGE-STANDARD.md) and the [documentation ownership map](documentation/README.md).

## Location

Community and maintainer files live at the **repository root**. Only GitHub configuration lives under `.github/`:
`CODEOWNERS`, the pull-request template, issue templates, `dependabot.yml`, workflows, and tool-specific agent
instructions such as `copilot-instructions.md`. GitHub recognizes community health files in the root, `docs/`, or
`.github/`; the root is chosen so that links and validation scripts are the same in every repository.

## Organization defaults

GitHub applies the files in this repository to any AsiBackbone repository that does not have its own:
`CODE_OF_CONDUCT.md`, `CONTRIBUTING.md`, `SECURITY.md`, `SUPPORT.md`, `.github/FUNDING.yml`, the pull-request
template, and the issue-template configuration. A repository needs its own copy only when it has something
repository-specific to add. `GOVERNANCE.md` and `MAINTAINERS.md` have no organization default.

## Baseline

Legend: **Required**: every project repository must have it. **Conditional**: required when the condition holds.
**Optional**: the repository decides. **Inherited**: the organization default applies.

| File | Rule | Learning | AsiBackbone | NetCoreApplicationTemplate | ReferenceApplication |
| --- | --- | --- | --- | --- | --- |
| `README.md` | Required | ✓ | ✓ | ✓ | ✓ |
| `LICENSE.txt` | Required | ✓ CC BY 4.0 | ✓ MIT | ✓ MIT | ✓ MIT |
| `LICENSING.md` | Conditional: more than one license | ✓ | n/a | n/a | n/a |
| `ASSETS-LICENSES.md` | Conditional: distributes third-party assets or notices | n/a | n/a | ✓ | ✓ |
| `CHANGELOG.md` | Required | ✓ | ✓ | ✓ | ✓ |
| `CONTRIBUTING.md` | Required | ✓ | ✓ | ✓ | ✓ |
| `SECURITY.md` | Required | ✓ | ✓ | ✓ | ✓ |
| `SUPPORT.md` | Optional; otherwise inherited | ✓ | ✓ | ✓ | Inherited |
| `CODE_OF_CONDUCT.md` | Optional; otherwise inherited | ✓ | ✓ | ✓ | Inherited |
| `GOVERNANCE.md`, `MAINTAINERS.md` | Required, except for the example host (see below) | ✓ | ✓ | ✓ | Not required (see below) |
| `COMMUNITY_STANDARDS.md` | Optional | — | — | ✓ | — |
| Release procedure | Conditional: the repository publishes releases. `RELEASE.md` or a linked policy document | `RELEASE.md` | `docs/articles/release-cadence-and-readiness.md` | `RELEASE.md` | `docs/stable-release-policy-v1.md` |
| `ROADMAP.md` | Optional | ✓ | — | — | — |
| `ADOPTERS.md` | Optional; suited to a reusable package | — | ✓ | — | — |
| `CITATION.cff`, `.zenodo.json` | Conditional: the repository is archived with a DOI | ✓ | ✓ | ✓ | Not yet archived |
| AI-agent instructions | Optional (see below) | `.github/copilot-instructions.md` | — | `AGENTS.md` | — |
| `.github/CODEOWNERS` | Required | ✓ | ✓ | ✓ | Missing: [ReferenceApplication#145](https://github.com/AsiBackbone/ReferenceApplication/issues/145) |
| `.github/dependabot.yml` | Required | ✓ | ✓ | ✓ | ✓ |
| Issue templates | Required (organization chooser is the fallback) | ✓ | ✓ | ✓ | ✓ |
| Pull-request template | Optional; otherwise inherited | ✓ | ✓ | ✓ | Inherited |
| `lychee.toml` with link validation | Required for repositories that publish documentation | ✓ | ✓ | ✓ | Missing: [ReferenceApplication#145](https://github.com/AsiBackbone/ReferenceApplication/issues/145) |

NetCoreApplicationTemplate's community files move from `.github/` to the root in
[NetCoreApplicationTemplate#707](https://github.com/AsiBackbone/NetCoreApplicationTemplate/issues/707); the table
shows the location this baseline requires.

## Decisions

**ReferenceApplication governance, maintainer, and citation files.** ReferenceApplication is the stable integration
example, not a product. It has the same single maintainer as the rest of the organization, and its
[Stable Release Policy v1](https://github.com/AsiBackbone/ReferenceApplication/blob/main/docs/stable-release-policy-v1.md)
already defines its release and compatibility decisions, so separate `GOVERNANCE.md` and `MAINTAINERS.md` files are not
required. It has no DOI yet; add `CITATION.cff` and `.zenodo.json` when its first archive is published, at the same
time as the `Archive (DOI)` link that the landing-page standard requires.

**Release procedure.** A repository that publishes releases must document its release procedure, but the document
does not have to be called `RELEASE.md`. AsiBackbone and ReferenceApplication already publish theirs as documentation
pages, which are linked above.

**AI-agent instructions.** Agent instruction files are optional. When a repository adds one, the tool-neutral
`AGENTS.md` at the repository root is preferred. A tool-specific file, such as `.github/copilot-instructions.md`, may
sit alongside it. Instructions must not contradict `CONTRIBUTING.md`, which stays authoritative for people and agents
alike.

## Open gaps

Every current omission is either marked intentional above or tracked:

- ReferenceApplication `CODEOWNERS` and link validation: [ReferenceApplication#145](https://github.com/AsiBackbone/ReferenceApplication/issues/145).
- Learning's Code of Conduct text and reporting route: [Learning#493](https://github.com/AsiBackbone/Learning/issues/493).
