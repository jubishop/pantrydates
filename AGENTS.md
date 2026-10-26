# AGENTS.md

<!-- project-starter:begin -->
Project Starter manages this block; add project rules after it. Project rules
take precedence over this block and the foundation pages wherever they differ.

- Keep durable guidance and non-derivable context in [memory](memory/README.md),
  and designs, decisions, and research in [docs](docs/README.md). Before
  non-trivial work or writing memory, search with `bin/knowledge search "term"`
  or `bin/knowledge query "question" --no-rerank`, then read results with
  `bin/knowledge get <path> -l 80`. Markdown sources are authoritative.
- If configured QMD fails, tell the user immediately and attempt repair. If
  repair fails, pause knowledge-dependent work until the user approves a
  fallback; never silently substitute `rg` or direct reads. See
  [search failures](docs/foundation/knowledge-search.md#search-failures).
- Follow the [engineering policy](docs/foundation/engineering-policy.md):
  fewer dependencies, red-green tests for behavior changes, flaky tests fixed
  or filed as an issue right away, cohesive files and pages, checkout-isolated
  validation, and the latest stable toolchains.
- Deliver by [kind of change](docs/foundation/engineering-policy.md#kinds-of-change):
  commit text, such as Markdown and AI skill prose, directly on the default
  branch without checks; commit development code, such as tests, CI, and
  tooling, directly after its checks pass; and deliver production code through
  a pull request after its checks.
- Run [checks](docs/foundation/engineering-policy.md#checks) by change: the
  relevant checks while editing, and `bin/check --full` before merging or
  releasing production code unless an enforced CI gate runs it. Reuse passing
  results.
- Keep accepted decisions separate from proposals, preserve unrelated changes,
  and keep generated caches out of Git. Keep secrets out of public
  repositories only; a private one may commit them.
- Run `bin/setup` after cloning, `bin/doctor` to diagnose setup, and
  `bin/qmd-index` after uncommitted knowledge edits. Managed files listed in
  `.project-starter.json` change only through Project Starter or a recorded
  override with its reason.
<!-- project-starter:end -->

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
