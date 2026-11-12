# BWAYO MIRACLE THUNDER

Flutter phone-service workflow app. Owner & Founder: **BWAYO EMMANUEL**.

## Included
- Miracle Box service dashboard
- Device information form
- USB connection guidance and read-only ADB commands
- USB OTG scan for compatible USB-serial accessories in the firmware assistant
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
This starter is a workflow UI, not a physical Miracle Box replacement. USB OTG scanning currently lists compatible USB-serial accessories only; it does not detect every phone or bootloader interface. Direct phone-to-phone firmware flashing, vendor flashing protocols/drivers, firmware downloads/verification and partition writing are not implemented. Android apps cannot generically flash another phone over OTG without model-specific bootloader support and signed vendor firmware. Do not use it for lock/FRP bypass or IMEI changes.

## Android APK
The GitHub Actions workflow generates the Android scaffold, builds a release APK and uploads it as the `bwayo-miracle-thunder-release-apk` artifact. A successful workflow run is required before an APK is available.
