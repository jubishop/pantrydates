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

## App Store Connect State

The following App Store Connect fields were set through the API during release
prep:

- App name: `Pantry Dates`
- Subtitle: `Track pantry expirations`
- Primary category: `FOOD_AND_DRINK`
- Content rights: `DOES_NOT_USE_THIRD_PARTY_CONTENT`
- Age rating: `FOUR_PLUS`
- Version description, keywords, and support URL for the `en-US` localization.
- Privacy policy URL for the `en-US` App Info localization.
- Free app price schedule with base territory `USA`.

Verification after the API writes showed:

- 6.5-inch iPhone screenshot set `APP_IPHONE_65`, 1 screenshot, state
  `COMPLETE`.
- 13-inch iPad screenshot set `APP_IPAD_PRO_3GEN_129`, 1 screenshot, state
  `COMPLETE`.
- Price schedule readable at `/v1/apps/6758566877/appPriceSchedule`, with free
  current prices.

## Screenshots

Generated release screenshots live in `/tmp/pantrydates-appstore-screenshots/`.
The RGB/no-alpha copies uploaded to App Store Connect were staged under
`/tmp/pantrydates-deliver/screenshots/en-US/`.

- `iphone-6.5.png`: 1284x2778 PNG for the 6.5-inch iPhone slot.
- `ipad-13.png`: 2064x2752 PNG for the 13-inch iPad slot.

## Remaining Manual Step

App Privacy data-usage details could not be written with the App Store Connect
API key. Fastlane's App Privacy action uses private App Store Connect web APIs
that are not available through the official API key path.

For this app, select that the app does not collect data. The repo privacy policy
is already public at `https://github.com/jubishop/pantrydates/blob/main/PRIVACY.md`.

## Original App Store Connect Requirements Seen

Required items App Store Connect reported during release prep:

- 13-inch iPad screenshot.
- 6.5-inch iPhone screenshot.
- Privacy Policy URL in App Privacy.
- Content Rights Information in App Information.
- Required age-rating questions.
- Primary category.
- Free price tier.

The version page also showed missing description, keywords, and support URL.
