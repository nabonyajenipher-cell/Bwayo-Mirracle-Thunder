# BWAYO MIRACLE THUNDER

Flutter phone-service workflow app. Owner & Founder: **BWAYO EMMANUEL**.

## Included
- Miracle Box service dashboard
- Device information form
- USB connection guidance and read-only ADB commands
- Manual diagnostics and backup checklists
- Firmware preparation checklist and safety warnings
- Service report preview and copy action

## Run
Install Flutter (Dart SDK >= 3.3), then run:

```sh
flutter pub get
flutter run
```

For Android: `flutter build apk --release`.

## Important limitations
This starter is a workflow UI, not a physical Miracle Box replacement. Native USB discovery, vendor driver integration, automated hardware diagnostics, firmware downloads/verification and flashing are not implemented. Do not use it for lock/FRP bypass or IMEI changes.

## Android APK
The GitHub Actions workflow generates the Android scaffold, builds a release APK and uploads it as the `bwayo-miracle-thunder-release-apk` artifact. A successful workflow run is required before an APK is available.
