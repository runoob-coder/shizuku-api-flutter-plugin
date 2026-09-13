# Shizuku API Flutter Plugin

<div align="center">
   <img src="https://raw.githubusercontent.com/runoob-coder/shizuku-api-flutter-plugin/master/logo.png" width="100" style="width: 100px;" alt="Shizuku API Flutter Plugin">
</div>

A Flutter plugin to interact with the [Shizuku API](https://github.com/RikkaApps/Shizuku-API),
allowing your
application to execute `shell` commands with system or `ADB` privileges.

[![Pub Version](https://img.shields.io/pub/v/shizuku-api-flutter-plugin.svg)](https://pub.dev/packages/shizuku-api-flutter-plugin)
[![API Reference](https://img.shields.io/badge/API-Reference-0175C2.svg)](https://pub.dev/documentation/shizuku-api-plugin/latest/)
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/runoob-coder/shizuku-api-flutter-plugin)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/runoob-coder/shizuku-api-flutter-plugin.svg?style=social)](https://github.com/runoob-coder/shizuku-api-flutter-plugin)

English | [中文](https://github.com/runoob-coder/shizuku-api-flutter-plugin/blob/master/README_CN.md)

## 📦 Installation

Add the dependency to your project:

```bash
flutter pub add shizuku_api_plugin
```

## 📋 Requirements

* Flutter `>=3.44.0` and Dart SDK `^3.12.0` are required.
* The [Shizuku](https://shizuku.rikka.app/) app must be installed and running on the target device.

## ⚙️ Configuration

### 🔧 app/build.gradle

Ensure that the minimum SDK version (`minSdk`) is set to `24` or higher.

### 📄 AndroidManifest.xml

Add the Shizuku provider definition inside the `<application>` tag:

```xml

<application>
    <provider android:name="rikka.shizuku.ShizukuProvider"
        android:authorities="${applicationId}.shizuku" android:multiprocess="false"
        android:enabled="true" android:exported="true"
        android:permission="android.permission.INTERACT_ACROSS_USERS_FULL" />
</application>
```

## 🚀 Usage

Each snippet below is a complete `async` function. In a real app, call it from your widget or
service.

### 1. 🔍 Verify Shizuku Service

Before executing any plugin commands, verify that the Shizuku service is running:

```dart
import 'package:shizuku_api_plugin/shizuku_api.dart';

Future<void> main() async {
  final shizukuApiPlugin = ShizukuApi();

  // Check if the Shizuku binder service is active
  final isBinderRunning = await shizukuApiPlugin.pingBinder() ?? false;
  print(isBinderRunning);
}
```

### 2. ✅ Check Permissions

Check if Shizuku permissions have been granted to your application:

```dart
import 'package:shizuku_api_plugin/shizuku_api.dart';

Future<void> main() async {
  final shizukuApiPlugin = ShizukuApi();

  // Returns true if permission is granted, false if denied or not requested yet
  final hasPermission = await shizukuApiPlugin.checkPermission();
  print(hasPermission);
}
```

### 3. 🔑 Request Permissions

Request permissions from the user via the Shizuku system dialog:

```dart
import 'package:shizuku_api_plugin/shizuku_api.dart';

Future<void> main() async {
  final shizukuApiPlugin = ShizukuApi();

  // Triggers the Shizuku permission dialog
  // Returns true if permission is granted, false if declined
  final permissionGranted = await shizukuApiPlugin.requestPermission();
  print(permissionGranted);
}
```

### 4. ⌨️ Run Commands

Execute ADB shell commands:

* **Note:** Execution within a root environment (`su`) is untested.
* Standard ADB shell commands are supported.

```dart
import 'package:shizuku_api_plugin/shizuku_api.dart';

Future<void> main() async {
  final shizukuApiPlugin = ShizukuApi();
  const command = 'pm uninstall --user 0 com.android.chrome';

  // Returns success if the command is executed and the system app is uninstalled
  final output = await shizukuApiPlugin.runCommand(command);
  print(output);
}
```

## 📖 API Reference

Methods exposed by `ShizukuApi` (all return a `Future`, so `await` is required):

| Method                       | Returns           | Description                                                |
|------------------------------|-------------------|------------------------------------------------------------|
| `pingBinder()`               | `Future<bool?>`   | Whether the Shizuku binder service is active               |
| `checkPermission()`          | `Future<bool?>`   | Whether Shizuku permission has been granted                |
| `requestPermission()`        | `Future<bool?>`   | Shows the Shizuku permission dialog and returns the result |
| `runCommand(String command)` | `Future<String?>` | Executes a command as shell (ADB) and returns its output   |

> Recommended order: `pingBinder()` → `checkPermission()` → `requestPermission()` (if not granted) →
`runCommand()`.

## 💡 Example

A runnable example project is available in the [
`example/`](https://github.com/runoob-coder/shizuku-api-flutter-plugin/example) directory,
demonstrating the full flow:
check service → check permission → request permission → run command.

## ❓ FAQ

* **Command fails / no output**: make sure the Shizuku app is started and running, and that your app
  has been granted permission.
* **No permission dialog**: verify that `pingBinder()` returns `true` first; the dialog cannot be
  shown when Shizuku is not running.
* **Uncaught `PlatformException`**: wrap the calls in `try/catch` and handle the failure gracefully.

For more questions, refer to the
[Shizuku documentation](https://shizuku.rikka.app/guide/setup/#faq).

## 💛 Support

If `shizuku_api_plugin` helps you build better UIs, please consider supporting it.  
It only takes a few seconds and helps other Flutter developers discover the library.

- ⭐ [Star on GitHub](https://github.com/runoob-coder/shizuku-api-flutter-plugin)
- 👍 [Like on pub.dev](https://pub.dev/packages/shizuku_api_plugin)

## ☕️ Buy Me a Coffee

<a href="https://ko-fi.com/noob_coder" target="_blank">
  <img src="https://storage.ko-fi.com/cdn/kofi6.png" alt="Buy Me a Coffee at ko-fi.com" />
</a>
