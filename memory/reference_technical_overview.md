# Technical Overview

Pantry Dates is a SwiftUI iOS 26.2+ app backed by GRDB/SQLite. The Xcode project
is `pantrydates/pantrydates.xcodeproj`; the app scheme and target are
`pantrydates`.

## Layout

- `pantrydates/pantrydates/Database/`: models, migrations, and database operations.
- `pantrydates/pantrydates/Views/`: SwiftUI screens.
- `pantrydates/pantrydates/Components/`: reusable SwiftUI components.
- `pantrydates/pantrydates/SymbolService.swift`: Foundation Models icon suggestions.
- `pantrydates/pantrydates/Assets.xcassets/FoodIcons/`: Lucide template SVG assets.

## Data Flow

`pantrydatesApp` creates `AppDatabase` and passes it to views. Views call
`AppDatabase` methods directly for CRUD operations. Current and finished lists
refresh through GRDB value observations.

Finishing a date inserts a `FinishedItem` and deletes the finished expiration
date or current item.

## Database

Migrations live in `pantrydates/pantrydates/Database/Database.swift` under
`migrator`. Add new migrations sequentially. In DEBUG builds,
`eraseDatabaseOnSchemaChange = true` resets the database when the schema changes.

Latest migration at memory creation: `v13`, which moved `expirationDate` from
`foodItem` into separate `expirationDate` rows.

## Icons

Each food item has a Lucide icon stored as `symbolName`, defaulting to `utensils`.
Icons are template-rendered SVGs in `Assets.xcassets/FoodIcons/`.

`FoodIcon` in `SymbolService.swift` lists available icons. Foundation Models
generates `IconSuggestion` values for automatic icon suggestions when creating
items or changing an item's name. If generation fails, preserve the existing icon.

## Local Data

- App database: Application Support under `Database/db.sqlite`.
- In-app export writes a temporary `pantrydates.sqlite`.
- Do not commit SQLite exports or copied app data.
