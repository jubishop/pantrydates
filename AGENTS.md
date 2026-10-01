# AGENTS.md

## Project

Pantry Dates is a SwiftUI iOS 26.2+ app backed by GRDB/SQLite.

Open/build `pantrydates/pantrydates.xcodeproj`. The app target and scheme are both
`pantrydates`.

App Store identifiers:
- Bundle ID: `com.artisanalsoftware.pantrydates`
- App Store app ID: `6758566877`

## App Store Connect

Detailed release memory lives in `memory/reference-app-store-release.md`.

The local App Store Connect API env vars live in `~/.env`; the private key is
under `~/.appstoreconnect/private_keys/`. Do not print or commit the `.p8`
contents.

## Database

Migrations live in `pantrydates/pantrydates/Database/Database.swift` under
`migrator`. Add migrations sequentially. In DEBUG builds,
`eraseDatabaseOnSchemaChange = true` resets the database on schema changes.

Current latest migration: `v13`, which moved expiration dates from `foodItem` into
separate `expirationDate` rows.

For new persisted fields, add the model property, add a migration, then update the
relevant add/edit/display views.

## Local Data

- App database: Application Support under `Database/db.sqlite`.
- In-app export writes a temporary `pantrydates.sqlite`.
- Do not commit SQLite exports or copied app data.

## Code Style

- Keep lines under 100 characters.
- Put each SwiftUI view in its own file under `Views/`.
- Put reusable UI in `Components/`.
- Put shared structs/classes/enums in their own files.
- After Swift edits, run `swift-format -i` on the modified Swift files.

Use `fatalError()` for impossible states and invariant violations. Do not force
unwrap optionals with `!`; use `guard let`, `if let`, or `??`. Do not use optional
`.map` just to unwrap.

## Project foundation

Keep durable project guidance in [memory](memory/README.md), and designs,
decisions, and research in [docs](docs/README.md). Follow the
[local task workflow](docs/task-tracking.md) for td setup and commands.

Before non-trivial work or writing memory, search the relevant knowledge.
Use `bin/knowledge search "term"` for known terms and
`bin/knowledge query "question" --no-rerank` for broader questions.
Read focused results with `bin/knowledge get <path> -l 80`.
Use direct reads or `rg` for known paths or after a successful lookup with no
matches. Markdown source files are authoritative. Update existing pages when possible.
If configured QMD fails, report it to the user immediately and attempt repair.
If repair fails, pause knowledge-dependent work until the user approves a
fallback; never silently bypass broken QMD with `rg` or direct reads. Follow
the [search failure policy](docs/development-workflow.md#search-failures).

Follow the engineering policies linked below:

- Prefer fewer dependencies; justify additions by their concrete benefits
  under the [dependency policy](docs/development-workflow.md#third-party-dependencies).
- Cover regression fixes and functional changes with automated tests. Use
  [red-green TDD](docs/development-workflow.md#test-driven-development)
  when practical; explain exceptions. Test observable behavior through public
  interfaces, with fakes at external-system boundaries.
- Keep [test cost proportional](docs/development-workflow.md#test-cost-and-coverage)
  while preserving coverage, independence, and useful complete journeys.
- Keep [files cohesive](docs/development-workflow.md#file-organization);
  approximately 1,000 lines is a review threshold for source, tests, and styles.
- Keep [Markdown pages focused](docs/development-workflow.md#markdown-pages)
  on one topic or reader task, without numeric size limits.
- Isolate [validation inputs and output](docs/development-workflow.md#validation-checkout-isolation)
  to the active checkout.
- Declare supported [runtime and toolchain versions](docs/development-workflow.md#runtime-and-toolchain-versions)
  and keep development, CI, and deployment compatible.

Run `bin/setup` after cloning. Choose checks for the changed files: use
`bin/check --documents-only` for Markdown edits and `bin/check` for foundation
checks only. Keep application tools out of both modes; run relevant application
checks explicitly for code edits.
Run `bin/check --full` locally after setup, test/build infrastructure changes,
or when focused checks leave material uncertainty. Require successful full
validation before merge or release. An enforced full CI gate can supply that
result for ordinary code changes; otherwise run the full check locally before
delivery. Do not run checks for discussion or read-only work. Batch edits
before checking; reuse passing results while relevant inputs are unchanged.
See [the workflow](docs/development-workflow.md#checks-and-project-extensions).
Nonfunctional changes may be pushed without deployment or a package release;
follow the [deployment policy](docs/development-workflow.md#deployment-decisions).
Use `bin/doctor` to inspect local setup and `bin/qmd-index` to refresh search
after uncommitted knowledge edits when current search results are needed.
Hooks refresh search after Git events.
