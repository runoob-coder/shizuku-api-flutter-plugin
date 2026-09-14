# Shizuku API Flutter 插件

<div align="center">
   <img src="https://raw.githubusercontent.com/runoob-coder/shizuku-api-flutter-plugin/main/logo.png" width="100" style="width: 100px;" alt="Shizuku API Flutter Plugin">
</div>

一个用于对接 [Shizuku API](https://github.com/RikkaApps/Shizuku-API) 的 Flutter 插件，让你的应用可以以系统权限或
`ADB` 权限执行 `shell` 命令。

[![Pub Version](https://img.shields.io/pub/v/shizuku_api_plugin.svg)][pub]
[![API Reference](https://img.shields.io/badge/API-Reference-0175C2.svg)](https://pub.dev/documentation/shizuku_api_plugin/latest/)
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/runoob-coder/shizuku-api-flutter-plugin)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![CI](https://img.shields.io/github/actions/workflow/status/runoob-coder/shizuku-api-flutter-plugin/build_apk.yml?label=CI)](https://github.com/runoob-coder/shizuku-api-flutter-plugin/actions/workflows/build_apk.yml)
[![GitHub stars](https://img.shields.io/github/stars/runoob-coder/shizuku-api-flutter-plugin.svg?style=social)][GitHub]

[English](README.md) | 简体中文

## 📦 安装

在你的项目中添加依赖：

```bash
flutter pub add shizuku_api_plugin
```

## 📋 环境要求

* 需要 Flutter `>=3.44.0` 与 Dart SDK `^3.12.0`。
* 目标设备上必须已安装并运行 [Shizuku](https://shizuku.rikka.app/) 应用。

## ⚙️ 配置

### 🔧 app/build.gradle

确保最低 SDK 版本（`minSdk`）设置为 `24` 或更高。

### 📄 AndroidManifest.xml

在 `<application>` 标签内添加 Shizuku 的 provider 声明：

```xml

<application>
    <provider android:name="rikka.shizuku.ShizukuProvider"
        android:authorities="${applicationId}.shizuku" android:multiprocess="false"
        android:enabled="true" android:exported="true"
        android:permission="android.permission.INTERACT_ACROSS_USERS_FULL" />
</application>
```

## 🚀 使用方法

下面每个代码片段都是完整的 `async` 函数，实际项目中从你的 Widget 或 Service 里调用即可。

### 1. 🔍 检查 Shizuku 服务

在执行任何插件命令之前，先确认 Shizuku 服务正在运行：

```dart
import 'package:shizuku_api_plugin/shizuku_api.dart';

Future<void> main() async {
  final shizukuApiPlugin = ShizukuApi();

  // 检查 Shizuku binder 服务是否处于活跃状态
  final isBinderRunning = await shizukuApiPlugin.pingBinder() ?? false;
  print(isBinderRunning);
}
```

### 2. ✅ 检查权限

检查你的应用是否已被授予 Shizuku 权限：

```dart
import 'package:shizuku_api_plugin/shizuku_api.dart';

Future<void> main() async {
  final shizukuApiPlugin = ShizukuApi();

  // 已授权返回 true；被拒绝或尚未申请返回 false
  final hasPermission = await shizukuApiPlugin.checkPermission();
  print(hasPermission);
}
```

### 3. 🔑 申请权限

通过 Shizuku 的系统弹窗向用户申请权限：

```dart
import 'package:shizuku_api_plugin/shizuku_api.dart';

Future<void> main() async {
  final shizukuApiPlugin = ShizukuApi();

  // 触发 Shizuku 权限弹窗
  // 授予返回 true，拒绝返回 false
  final permissionGranted = await shizukuApiPlugin.requestPermission();
  print(permissionGranted);
}
```

### 4. ⌨️ 执行命令

执行 ADB shell 命令：

* **注意：** 在 root 环境（`su`）下执行尚未经过测试。
* 支持标准的 ADB shell 命令。

```dart
import 'package:shizuku_api_plugin/shizuku_api.dart';

Future<void> main() async {
  final shizukuApiPlugin = ShizukuApi();
  const command = 'pm uninstall --user 0 com.android.chrome';

  // 命令执行成功且系统应用被卸载则返回执行结果，否则返回 failure
  final output = await shizukuApiPlugin.runCommand(command);
  print(output);
}
```

## 📖 API 一览

`ShizukuApi` 对外暴露的方法（全部返回 `Future`，需要 `await`）：

| 方法                           | 返回值               | 说明                        |
|------------------------------|-------------------|---------------------------|
| `pingBinder()`               | `Future<bool?>`   | Shizuku binder 服务是否处于活跃状态 |
| `checkPermission()`          | `Future<bool?>`   | 是否已获得 Shizuku 权限          |
| `requestPermission()`        | `Future<bool?>`   | 弹出授权对话框并返回用户选择结果          |
| `runCommand(String command)` | `Future<String?>` | 以 shell（ADB）身份执行命令并返回输出结果 |

> 建议的调用顺序：`pingBinder()` → `checkPermission()` → （未授权时）`requestPermission()` →
`runCommand()`。

## 💡 完整示例

可运行的示例工程见 [`example/`](https://github.com/runoob-coder/shizuku-api-flutter-plugin/example)
目录，其中演示了「检查服务 → 检查权限 → 申请权限 → 执行命令」的完整流程。

## ❓ 常见问题

* **命令执行失败 / 无输出**：确认 Shizuku 应用已启动并处于运行状态，且已授予本应用权限。
* **权限申请无弹窗**：请先确认 `pingBinder()` 返回 `true`，Shizuku 未运行时无法弹出授权对话框。
* **未捕获的 `PlatformException`**：请在调用处使用 `try/catch` 捕获，并做降级处理。

更多问题请参考 [Shizuku 文档](https://shizuku.rikka.app/zh-hans/guide/setup/#常见问题)。

## 💛 支持

如果 `shizuku_api_plugin` 帮助了你，请考虑支持它，只需几秒即可帮助更多 Flutter 开发者发现此库。

- ⭐ [GitHub 上点星][GitHub]
- 👍 [pub.dev 上点赞][pub]

## ☕️ 请我喝咖啡

<a href="https://ko-fi.com/noob_coder" target="_blank">
  <img src="https://storage.ko-fi.com/cdn/kofi6.png" alt="Buy Me a Coffee at ko-fi.com" />
</a>

[pub]: https://pub.dev/packages/shizuku_api_plugin
[API Reference]: https://pub.dev/documentation/shizuku_api_plugin/latest/
[GitHub]: https://github.com/runoob-coder/shizuku-api-flutter-plugin