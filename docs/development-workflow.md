---
status: current
---

# Development workflow

This page records this project's own commands and integrations. Shared rules
are in the [foundation pages](foundation/README.md).

## Setup

```sh
bin/setup
bin/doctor
bin/check --full
```

Setup needs Git and Python 3.9 or later, and checks also need ShellCheck.
QMD and direnv are optional; setup reports skipped features. Install td and
run `td init` as described in [task tracking](foundation/task-tracking.md).
Create `.envrc` only when the project needs environment settings, and review
it before running `direnv allow`; search does not need it.

## Checks

Follow the [check schedule](foundation/engineering-policy.md#checks).
`bin/check-application` runs the Python tests in `tests/`, then builds the
existing pantrydates scheme for a generic iOS Simulator with code signing
disabled. Derived data and Swift package checkouts stay under `.cache/xcode/`
in the active checkout. There is no existing test target; a successful build
does not establish behavioral coverage. Keep the existing iOS deployment
target and package resolution.

GitHub validation is defined in [the workflow](../.github/workflows/check.yml).
Require successful full CI for the delivered revision, except for the
confirmed capacity exception below. A local pass does not establish a remote
result.

If GitHub CI is blocked solely by confirmed Actions quota exhaustion or
GitHub rate limiting, run `bin/check --full` and all equivalent required
checks locally on the exact revision being delivered. Once they pass,
continue the normal review, merge, and cleanup process without waiting for
hosted CI. Record the blocker, tested revision, commands, and results; report
CI as unavailable, not passed. Actual test failures, unknown failures, and
checks that cannot be validated locally remain blockers. Do not bypass
enforced branch protections, required approvals, or deployment gates.

## Runtime and toolchain versions

Application validation requires macOS and Xcode 26.3 or later, matching the
README; `bin/check-application` stops before any check on an older Xcode. The
app targets iOS 26.2 or later, set by `IPHONEOS_DEPLOYMENT_TARGET` in the
Xcode project. CI installs the latest stable Python and selects the newest
stable Xcode on its `macos-latest` runner. Follow the
[version policy](foundation/engineering-policy.md#runtime-and-toolchain-versions).

## Deployment

Pushes do not deploy or release. App Store releases are manual; see the
[App Store release notes](../memory/reference-app-store-release.md).
Nonfunctional changes need no release. Follow the
[deployment policy](foundation/engineering-policy.md#deployment-decisions).

## Project Starter

`.project-starter.json` records the installed Project Starter release and the
hashes of its managed files. Update them with Project Starter's `bin/sync`,
and record any intentional local change as an override with its reason.
