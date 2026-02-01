# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

This is an Xcode project. Open `pantrydates/pantrydates.xcodeproj` in Xcode to build and run.

## Architecture

SwiftUI iOS 26+ app using GRDB.swift for SQLite persistence.

**Key files:**
- `FoodItem.swift` - Model conforming to GRDB's `FetchableRecord` and `MutablePersistableRecord`
- `Database.swift` - `AppDatabase` struct containing migrations and all database operations
- `ContentView.swift` - Main list view with filtering and swipe actions
- `ItemDetailView.swift` - Edit view for individual items
- `AddItemView.swift` - Sheet for creating new items
- `NotificationManager.swift` - Background task scheduling and local notification delivery
- `SymbolService.swift` - Apple Intelligence integration for SF Symbol suggestions

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

## Symbol System

Each food item has an SF Symbol for visual identification, suggested by Apple Intelligence.

**How it works:**
- `symbolName` (text) - SF Symbol name for the item, defaults to `fork.knife`
- Uses the Foundation Models framework with `@Generable` for structured output
- Symbols are auto-generated when creating new items or changing an item's name
- User can manually regenerate via "Suggest Symbol" button in ItemDetailView

**Fallback behavior:**
- If AI generation fails, the existing symbol is preserved

## Error Handling

Use `fatalError()` for scenarios that should never logically happen. If the code reaches a state that violates invariants or represents a programming error, fail loudly rather than silently. This makes bugs immediately visible during development instead of causing subtle issues later.

Never force unwrap optionals using `!`. Use `guard let`, `if let`, or nil-coalescing (`??`) instead. If a value truly must exist, use `guard let value = optional else { fatalError("reason") }` to fail explicitly with context.
