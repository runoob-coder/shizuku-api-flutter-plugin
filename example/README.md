# shizuku_api_example

A runnable demo of the [`shizuku_api_plugin`](https://pub.dev/packages/shizuku_api_plugin) Flutter
plugin, demonstrating the recommended flow:

**check service → check permission → request permission → run command**.

## Requirements

- A physical Android device (the Shizuku binder is not available on emulators without extra setup).
- The [Shizuku](https://shizuku.rikka.app/) app installed and running on the device.
- `minSdk` 24 or higher (already set in `android/app/build.gradle.kts`).

## Run

```bash
cd example
flutter run
```

On first launch the demo shows the Shizuku service and permission status as "Unknown". Tap the
refresh icon (or "Check status") to query the live state, then:

1. If the service is **Not running**, start Shizuku on the device first.
2. Tap **Request permission** and accept the dialog.
3. Tap a quick-command chip or type your own command and tap **Run**.

The output area keeps the last command output in a monospace, scrollable, selectable view (tap and
hold to copy). Output from a failed command is highlighted in red.

## Localization

The demo ships English (`lib/l10n/app_en.arb`) and Simplified Chinese (`lib/l10n/app_zh.arb`)
messages. It follows the device locale by default; the drop-down at the top of the page can override
it with **English**, **简体中文**, or **Follow system**. The override lives in memory (it is not
persisted), and unsupported device locales fall back to English.

Generated Dart localizations live in `lib/l10n/app_localizations*.dart`. They are produced by
`flutter gen-l10n` (also run automatically by `flutter pub get` / `flutter run`). To add a language,
add `app_<locale>.arb` next to the existing ARB files and re-run `flutter gen-l10n`.

## Tests

```bash
# Widget tests (no device needed, uses a fake plugin).
flutter test

# Integration smoke test (requires a connected device).
flutter test integration_test
```
