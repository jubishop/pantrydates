# Pantry Dates

A simple iOS app to track pantry items and their expiration dates.

## Features

- **Track Items**: Add pantry and fridge items with names, notes, and dates
- **Multiple Dates**: Store more than one expiration date for the same item
- **Sort by Date**: Items are sorted with the oldest expiration dates first
- **Search and Filter**: Search items and toggle the flag filter from the toolbar
- **Flag Items**: Swipe right on any current item to flag it for attention
- **Finish Items**: Mark one expiration date as finished without losing item history
- **Finished History**: Review finished items, delete them, or re-add them
- **Icons**: Use Lucide food icons with Apple Intelligence suggestions
- **Export**: Share a local SQLite database export from the current-items toolbar

## Technical Details

- Built with SwiftUI
- Uses [GRDB.swift](https://github.com/groue/GRDB.swift) for SQLite database storage
- Database migrations for schema versioning
- Uses Foundation Models for structured icon suggestions
- Uses Lucide SVG icons stored in the asset catalog
- See `NOTICE` for third-party asset attribution

## Requirements

- iOS 26.2+
- Xcode 26.3+

## Support and Privacy

- Support: https://github.com/jubishop/pantrydates/issues
- Privacy Policy: https://github.com/jubishop/pantrydates/blob/main/PRIVACY.md

## Project maintenance

Run `bin/setup` to prepare local knowledge search and Git hooks. It requires
Git and Python 3.9 or later; QMD and direnv are optional. Install ShellCheck
for checks. Follow the [task workflow](docs/task-tracking.md) to initialize td.

Use `bin/check --documents-only` for Markdown changes, `bin/check` for
foundation static checks, and `bin/check --full` for foundation behavior tests
and the project checks listed in the [development workflow](docs/development-workflow.md).
Use `bin/doctor` to inspect setup. Keep application tools out of routine checks.

- [Memory](memory/README.md): durable project guidance and context.
- [Documents](docs/README.md): designs, decisions, research, and reference guides.
- [Git remotes](docs/git-remotes.md): existing hosts and fresh-clone push setup.
