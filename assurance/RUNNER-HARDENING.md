# Release Runner-Hardening Policy

**Last reviewed:** 2026-11-15 ([AsiBackbone/.github#46](https://github.com/AsiBackbone/.github/issues/46))

This policy defines where AsiBackbone repositories run
[`step-security/harden-runner`](https://github.com/step-security/harden-runner) on GitHub-hosted runners. It is the
`release-runner-hardening` control in the [assurance map](README.md).

## Policy

Every **release job** starts with `step-security/harden-runner` as its first step, pinned to a full commit SHA, with
`egress-policy: audit`.

A job is a release job when it does any of the following:

1. **Builds a release artifact** that a later job signs, attests, or publishes, such as packages, container images,
   template packages, release evidence, or SBOMs.
2. **Signs or attests** release artifacts. In practice this means it holds `id-token: write` for Sigstore or
   artifact attestations.
3. **Publishes** to a package registry, container registry, or GitHub Release, using `packages: write` or
   `contents: write` on release assets.
4. **Uses a stored credential for an external publishing service**, for example the X API keys.

A job that calls a reusable workflow inherits that workflow's hardening and needs no step of its own.

Other jobs may use runner hardening but aren't required to: pull-request CI, scheduled scans, OpenSSF Scorecard,
documentation builds and GitHub Pages deployments, and workflows that only open pull requests.

```yaml
steps:
  - name: Harden runner
    uses: step-security/harden-runner@1d88384fd173af6ecb012dfd0264a306b711241a # v2.22.4
    with:
      egress-policy: audit
```

Use the same pinned SHA across the organization. Dependabot updates it like any other action.

## Why audit mode

In audit mode, harden-runner records every outbound network connection, process, and file change on the runner, and
StepSecurity's insights page shows them for each run. It does **not** block anything. These jobs reach several
services (NuGet.org, GitHub, Sigstore, container registries, and, for Learning, the X API), and a `block` policy that
misses one of them would stop a release. Start in audit mode, and move a job to `egress-policy: block` with an
explicit `allowed-endpoints` list only after its audit runs show a stable set of endpoints.

## What it does not do

- Audit mode detects and records unexpected egress. It doesn't prevent exfiltration of a signing token or
  credential, so it **fails open**.
- It doesn't replace the controls that already protect releases: SHA-pinned actions, minimal job permissions,
  protected publishing environments, Sigstore signing, and the verification that runs after publication.
- It applies only to GitHub-hosted runners. It says nothing about a maintainer's local machine.

## Adoption

As of the review date:

| Repository | Release jobs | Status |
| --- | --- | --- |
| NetCoreApplicationTemplate | `publish-template-package.yml` (`pack-template`, `publish-template`) and `publish-container.yml` (`build-scan`, `publish`). `publish-stable-release.yml` calls both. `publish-release.yml` (`update-readme`) only opens a pull request and is hardened voluntarily. | Compliant |
| AsiBackbone | `publish-packages.yml` (`pack-packages`, `publish-packages`, `publish-release-evidence`), `release-validation.yml` (`stable-release-validation`, `attest-artifacts`) | Not yet: [AsiBackbone/AsiBackbone#942](https://github.com/AsiBackbone/AsiBackbone/issues/942) |
| Learning | `publish-release-evidence.yml` (`validate-and-build-evidence`, `publish-evidence`), `publish-x.yml` (`publish`; `publish-docs.yml` calls it for its `publish-x` job) | Not yet: [AsiBackbone/Learning#501](https://github.com/AsiBackbone/Learning/issues/501) |
| ReferenceApplication | None. Releases attach no assets, and documentation deployment is optional. | Not applicable |
| `.github`, `asibackbone.github.io` | None | Not applicable |

Review this table when a repository adds a publishing workflow or job.
