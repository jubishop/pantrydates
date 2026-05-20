# AGENTS.md

This file provides guidance to coding agents when working with this repository.

## Build Commands

This is an Xcode project. Open `pantrydates/pantrydates.xcodeproj` in Xcode to build and run.

## Architecture

SwiftUI iOS 26.2+ app using GRDB.swift for SQLite persistence.

**Folder structure:**
- `Views/` - All SwiftUI views
- `Components/` - Reusable UI components
- `Database/` - Database and model files
- Root - Services and app entry point

**Key files:**
- `Database/FoodItem.swift` - Current-item model and joined expiration-date info
- `Database/ExpirationDate.swift` - Separate expiration dates for each current item
- `Database/FinishedItem.swift` - Finished-item history model
- `Database/Database.swift` - Migrations and database operations
- `Views/ContentView.swift` - Tab root for current and finished items
- `Views/CurrentItemsView.swift` - Current item list, filtering, swipe actions, export
- `Views/FinishedItemsView.swift` - Finished item history and re-add flow
- `Views/ItemDetailView.swift` - Edit view for individual items
- `Views/AddItemView.swift` - Sheet for creating new items
- `Components/SymbolPicker.swift` - Icon picker UI component
- `Views/FoodIconView.swift` - Renders Lucide icons from asset catalog
- `Components/ItemFormFields.swift` - Shared form fields for add/edit views
- `SymbolService.swift` - Apple Intelligence integration for Lucide icon suggestions

**Data flow:**
- `pantrydatesApp` creates `AppDatabase` and passes it to views
- Views call `AppDatabase` methods directly for CRUD operations
- Current and finished lists refresh through GRDB value observations
- Finishing a date inserts a `FinishedItem` and deletes the date or current item

## Database Migrations

Migrations are in `Database.swift` under the `migrator` property. Add new
migrations sequentially (v14, v15, etc.). In DEBUG builds,
`eraseDatabaseOnSchemaChange = true` automatically resets the database when the
schema changes.

**Current migrations:**
- v1: Create `pantryItem` table with `id`, `name`, `expirationDate`
- v2: Add `flagged` boolean
- v3: Add legacy `notificationDate`
- v4: Add legacy `notificationSent`
- v5: Add `notes` text field
- v6: Rename table from `pantryItem` to `foodItem`
- v7: Add `refrigerated` boolean
- v8: Add `symbolName` text field (defaults to `fork.knife`)
- v9: Migrate all symbolName values to `utensils` (Lucide icon migration)
- v10: Drop legacy notification columns
- v11: Create `finishedItem` table with `id`, `name`, `finishedDate`
- v12: Add finished-item metadata fields
- v13: Move `expirationDate` from `foodItem` into separate `expirationDate` rows

## Adding New Fields

1. Add property to `FoodItem` struct with a default value
2. Add migration in `Database.swift` to alter the table
3. Update views to display/edit the new field

## Icon System

Each food item has a Lucide icon for visual identification, suggested by Apple Intelligence.

**How it works:**
- `symbolName` (text) - Lucide icon name for the item, defaults to `utensils`
- Icons are stored in `Assets.xcassets/FoodIcons/` as template-rendered SVGs
- `FoodIcon` enum in `SymbolService.swift` lists all available icons
- Uses the Foundation Models framework with `@Generable` for structured output
- Icons are auto-generated when creating new items or changing an item's name
- User can manually select via icon picker or regenerate via "Suggest Icon" button

**Key types:**
- `FoodIcon` - All available Lucide icon names
- `IconSuggestion` - Foundation Models structured output for one icon
- `FoodIconView` - SwiftUI view that renders icons from the asset catalog

**Fallback behavior:**
- If AI generation fails, the existing icon is preserved

## Local Data

- The app database lives in Application Support under `Database/db.sqlite`
- In-app export writes a temporary `pantrydates.sqlite`
- The Claude `pull-db` command copies device data into local `app_support/`
- Do not commit SQLite database exports or copied device data

## Error Handling

Use `fatalError()` for scenarios that should never logically happen. If the code
reaches a state that violates invariants or represents a programming error, fail
loudly rather than silently.

Never force unwrap optionals using `!`. Use `guard let`, `if let`, or
nil-coalescing (`??`) instead. If a value truly must exist, use
`guard let value = optional else { fatalError("reason") }` to fail explicitly.

Do not use `.map` on optionals to unwrap them. `.map` should only transform
collection elements. For optionals, use `guard let`, `if let`, or `??`.

## Code Style

All lines must stay under 100 characters, including comments.

Every SwiftUI view should be in its own file in `Views/`, named after the view.
Reusable UI components go in `Components/`.

Any struct, class, or enum used by multiple files should be in its own file.
Otherwise, it is acceptable to keep it in the same file as its sole consumer.

After making any code changes, always run `swift-format -i` on the modified files.
