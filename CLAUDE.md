# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

This is an Xcode project. Open `pantrydates/pantrydates.xcodeproj` in Xcode to build and run.

## Architecture

SwiftUI iOS 26+ app using GRDB.swift for SQLite persistence.

**Folder structure:**
- `Views/` - All SwiftUI views
- `Components/` - Reusable UI components
- `Database/` - Database and model files
- Root - Services and app entry point

**Key files:**
- `Database/FoodItem.swift` - Model conforming to GRDB's `FetchableRecord` and `MutablePersistableRecord`
- `Database/Database.swift` - `AppDatabase` struct containing migrations and all database operations
- `Views/ContentView.swift` - Main list view with filtering and swipe actions
- `Views/ItemDetailView.swift` - Edit view for individual items
- `Views/AddItemView.swift` - Sheet for creating new items
- `Views/SymbolPickerSection.swift` - Icon picker UI component
- `Views/FoodIconView.swift` - Renders Lucide icons from asset catalog
- `Components/ItemFormFields.swift` - Shared form fields for add/edit views
- `NotificationManager.swift` - Background task scheduling and local notification delivery
- `SymbolService.swift` - Apple Intelligence integration for Lucide icon suggestions

**Data flow:**
- `pantrydatesApp` creates `AppDatabase` and passes it to views
- Views call `AppDatabase` methods directly for CRUD operations
- List refreshes via explicit `loadItems()` calls after mutations

## Database Migrations

Migrations are in `Database.swift` under the `migrator` property. Add new migrations sequentially (v5, v6, etc.). In DEBUG builds, `eraseDatabaseOnSchemaChange = true` automatically resets the database when schema changes.

**Current migrations:**
- v1: Create `pantryItem` table with `id`, `name`, `expirationDate`
- v2: Add `flagged` boolean
- v3: Add `notificationDate` (optional datetime)
- v4: Add `notificationSent` boolean
- v5: Add `notes` text field
- v6: Rename table from `pantryItem` to `foodItem`
- v7: Add `refrigerated` boolean
- v8: Add `symbolName` text field (defaults to `fork.knife`)
- v9: Migrate all symbolName values to `utensils` (Lucide icon migration)

## Adding New Fields

1. Add property to `FoodItem` struct with a default value
2. Add migration in `Database.swift` to alter the table
3. Update views to display/edit the new field

## Notification System

Each pantry item can have an optional `notificationDate` for reminders. The system uses iOS Background Tasks to check and deliver notifications.

**How it works:**
- `notificationDate` (optional) - When set, triggers a local notification on or after this date
- `notificationSent` (boolean) - Tracks whether the notification has been delivered to prevent duplicates
- Changing `notificationDate` in `ItemDetailView` automatically resets `notificationSent` to false

**Background task flow:**
1. `NotificationManager.registerBackgroundTask()` registers the task identifier on app init
2. `NotificationManager.scheduleBackgroundTask()` schedules the next check when app enters background (minimum 12-hour interval)
3. When the task runs, `processNotifications()` queries for items where `notificationDate <= now` and `notificationSent == false`
4. For each match, it sends a local notification and marks `notificationSent = true`

**Required Info.plist keys:**
- `BGTaskSchedulerPermittedIdentifiers` - Contains `com.pantrydates.notificationCheck`
- `UIBackgroundModes` - Contains `fetch`

The Info.plist is at the project root level (not inside the pantrydates source folder) to avoid conflicts with Xcode's file synchronization.

## Icon System

Each food item has a Lucide icon for visual identification, suggested by Apple Intelligence.

**How it works:**
- `symbolName` (text) - Lucide icon name for the item, defaults to `utensils`
- Icons are stored in `Assets.xcassets/FoodIcons/` as template-rendered SVGs (56 icons)
- `FoodIcon` enum in `SymbolService.swift` lists all available icons
- `FoodCategory` enum maps food categories to icon names for AI suggestions
- Uses the Foundation Models framework with `@Generable` for structured output
- Icons are auto-generated when creating new items or changing an item's name
- User can manually select via icon picker or regenerate via "Suggest Icon" button

**Key types:**
- `FoodIcon` - All available Lucide icon names (rawValue = asset name like "ice-cream-cone")
- `FoodCategory` - AI classification categories mapped to icon names
- `FoodIconView` - SwiftUI view that renders icons from the asset catalog

**Fallback behavior:**
- If AI generation fails, the existing icon is preserved

## Error Handling

Use `fatalError()` for scenarios that should never logically happen. If the code reaches a state that violates invariants or represents a programming error, fail loudly rather than silently. This makes bugs immediately visible during development instead of causing subtle issues later.

Never force unwrap optionals using `!`. Use `guard let`, `if let`, or nil-coalescing (`??`) instead. If a value truly must exist, use `guard let value = optional else { fatalError("reason") }` to fail explicitly with context.

## Code Style

All lines must stay under 100 characters, including comments.

Every SwiftUI view should be in its own file in `Views/`, named after the view (e.g., `Views/FoodIconView.swift`). Reusable UI components go in `Components/`.

Any struct, class, or enum used by multiple files should be in its own file. Otherwise, it's acceptable to keep it in the same file as its sole consumer.

After making any code changes, always run `swift-format -i` on the modified files.
