# BWAYO MIRACLE THUNDER

Flutter phone-service workflow app. Owner & Founder: **BWAYO EMMANUEL**.

## Included
- Miracle Box service dashboard
- Device information form
- USB connection guidance and read-only ADB commands
- USB OTG scan for compatible USB-serial accessories in the firmware assistant
- Local firmware file selection and SHA-256 calculation / comparison against an official manufacturer checksum before a readiness check can pass
- Manual diagnostics and backup checklists
- Firmware preparation checklist and safety warnings
- Samsung Galaxy A07 SM-A075F/DS device profile, with a guard against entering firmware builds for the different SM-A075M family
- Direct in-app links to Samsung's official Smart Switch PC page and emergency recovery instructions for supported Galaxy software recovery
- Service report preview and copy action

## Run
Install Flutter (Dart SDK >= 3.3), then run:

```sh
flutter pub get
flutter run
```

For Android: `flutter build apk --release`.

## Important limitations
This starter is a workflow UI, not a physical Miracle Box replacement. USB OTG scanning currently lists compatible USB-serial accessories only; it does not detect every phone or bootloader interface. The Samsung Galaxy A07 SM-A075F/DS profile is a model-specific preparation and firmware-family check only. It links to Samsung's official PC-based Smart Switch and emergency recovery documentation, but does not implement direct phone-to-phone flashing, Samsung Download Mode communication, Odin/Heimdall integration, vendor flashing protocols/drivers, automatic firmware downloads/authenticity verification or partition writing. The firmware checker requires a valid 64-character SHA-256 checksum for its readiness check and compares it with the selected file. A match verifies integrity against the supplied checksum only; it does not establish firmware authenticity or model compatibility. Obtain the checksum from the official manufacturer source. Android apps cannot generically flash another phone over OTG without model-specific bootloader support and signed vendor firmware. Do not use it for lock/FRP bypass or IMEI changes.

## Android APK
The GitHub Actions workflow generates the Android scaffold, builds a release APK and uploads it as the `bwayo-miracle-thunder-release-apk` artifact. A successful workflow run is required before an APK is available.
