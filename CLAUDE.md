# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

This is an Xcode project. Open `pantrydates/pantrydates.xcodeproj` in Xcode to build and run.

## Architecture

SwiftUI iOS app using GRDB.swift for SQLite persistence.

**Key files:**
- `PantryItem.swift` - Model conforming to GRDB's `FetchableRecord` and `MutablePersistableRecord`
- `Database.swift` - `AppDatabase` struct containing migrations and all database operations
- `ContentView.swift` - Main list view with filtering and swipe actions
- `ItemDetailView.swift` - Edit view for individual items
- `AddItemView.swift` - Sheet for creating new items

**Data flow:**
- `pantrydatesApp` creates `AppDatabase` and passes it to views
- Views call `AppDatabase` methods directly for CRUD operations
- List refreshes via explicit `loadItems()` calls after mutations

## Database Migrations

Migrations are in `Database.swift` under the `migrator` property. Add new migrations sequentially (v3, v4, etc.). In DEBUG builds, `eraseDatabaseOnSchemaChange = true` automatically resets the database when schema changes.

## Adding New Fields

1. Add property to `PantryItem` struct with a default value
2. Add migration in `Database.swift` to alter the table
3. Update views to display/edit the new field
