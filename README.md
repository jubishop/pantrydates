# Pantry Dates

A simple iOS app to track pantry items and their expiration dates.

## Features

- **Track Items**: Add pantry items with names and expiration dates
- **Sort by Date**: Items are sorted with the oldest expiration dates first
- **Flag Items**: Swipe right on any item to flag it for attention
- **Filter**: Toggle the flag filter in the toolbar to show only flagged items
- **Edit**: Tap any item to edit its name, date, or flagged status
- **Delete**: Swipe left to delete items, or use the trash button in the detail view
- **Notifications**: Set optional reminder dates for items and receive local notifications when the date arrives

## Technical Details

- Built with SwiftUI
- Uses [GRDB.swift](https://github.com/groue/GRDB.swift) for SQLite database storage
- Database migrations for schema versioning
- Background task scheduling for notification delivery (checks every 12 hours minimum)
- Local notifications via UserNotifications framework

## Requirements

- iOS 17.0+
- Xcode 15.0+
