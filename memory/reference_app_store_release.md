# App Store Release

## Identifiers

- App name in App Store Connect: `pantrydates`
- Bundle ID: `com.artisanalsoftware.pantrydates`
- App Store app ID: `6758566877`
- SKU: `com.artisanalsoftware.pantrydates`
- Version observed during release audit: `1.0`
- Support URL: `https://github.com/jubishop/pantrydates/issues`
- Privacy Policy URL: `https://github.com/jubishop/pantrydates/blob/main/PRIVACY.md`

## App Store Connect API

The App Store Connect API key is stored outside the repo:

- Env file: `~/.config/pantrydates/appstore-connect.env`
- Private key: `~/.appstoreconnect/private_keys/AuthKey_A9CMX47R79.p8`
- Key ID: `A9CMX47R79`
- Issuer ID: `9e67e4e3-0208-4437-a158-b218c77edea5`

The env file exports `ASC_KEY_ID`, `ASC_ISSUER_ID`, and `ASC_KEY_PATH`. Do not
print or commit the `.p8` contents.

Read-only API verification succeeded with:

```sh
GET /v1/apps?filter[bundleId]=com.artisanalsoftware.pantrydates
```

Apple returned app ID `6758566877`, name `pantrydates`, and the expected bundle ID.

## Release Audit

Local release readiness checks completed successfully:

- Release build with code signing disabled.
- Archive to `/tmp/pantrydates-release-audit.xcarchive`.
- App Store Connect export to `/tmp/pantrydates-export/pantrydates.ipa`.
- App icon is a 1024x1024 PNG with RGB and no alpha.
- `Info.plist` has `ITSAppUsesNonExemptEncryption=false`.

Signing available locally:

- Archive signed with Apple Development and an iOS Team provisioning profile.
- Export re-signed with Apple Distribution for Justin Bishop.
- Export used the App Store profile for `com.artisanalsoftware.pantrydates`.

## Screenshots

Generated release screenshots live in `/tmp/pantrydates-appstore-screenshots/`.

- `iphone-6.5.png`: 1284x2778 PNG for the 6.5-inch iPhone slot.
- `ipad-13.png`: 2064x2752 PNG for the 13-inch iPad slot.

Both screenshots were created from seeded simulator data. They currently report
alpha channels; strip alpha before final App Store upload if Apple rejects them.

## App Store Connect Requirements Seen

Required items App Store Connect reported during release prep:

- 13-inch iPad screenshot.
- 6.5-inch iPhone screenshot.
- Privacy Policy URL in App Privacy.
- Content Rights Information in App Information.
- Required age-rating questions.
- Primary category.
- Free price tier.

The version page also showed missing description, keywords, and support URL.
