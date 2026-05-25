# AGENTS.md

## Project

Pantry Dates is a SwiftUI iOS 26.2+ app backed by GRDB/SQLite.

Open/build `pantrydates/pantrydates.xcodeproj`. The app target and scheme are both
`pantrydates`.

App Store identifiers:
- Bundle ID: `com.artisanalsoftware.pantrydates`
- App Store app ID: `6758566877`

## Project Memory

Project-specific memory lives in `memory/`.
Use `memory/MEMORY.md` as the canonical index of saved memories, with one linked
Markdown file per memory in `memory/`.
When asked to save, recall, or update a memory, read and write those files directly.
Check memory before guessing about prior project-specific decisions or release details.

## App Store Connect

Detailed release memory lives in `memory/reference_app_store_release.md`.

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
