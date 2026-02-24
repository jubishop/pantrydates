Pull the pantrydates SQLite database from the connected iPhone.

## Steps

1. Remove any existing `./app_support` directory to ensure a fresh copy.

2. Copy the database from the device:

```
xcrun devicectl device copy from \
  --device "iPhone" \
  --domain-type appDataContainer \
  --domain-identifier com.artisanalsoftware.pantrydates \
  --source "Library/Application Support" \
  --destination "./app_support"
```

If the copy fails because no device is connected, tell the user to connect their iPhone.

3. Confirm the database exists at `./app_support/Database/db.sqlite` and report success.
