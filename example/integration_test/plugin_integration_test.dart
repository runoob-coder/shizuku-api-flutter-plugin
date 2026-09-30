import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shizuku_api_plugin/shizuku_api.dart';

/// Smoke test for the real plugin on a device.
///
/// Run with `flutter test integration_test` on a connected Android device.
/// It only asserts that the plugin methods resolve (instead of throwing a
/// `MissingPluginException` / `PlatformException`), so it passes whether or not
/// Shizuku is installed — it is not a functional assertion of shell execution.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('plugin methods resolve on a real device', (
    WidgetTester tester,
  ) async {
    final api = ShizukuApi();

    await expectLater(api.pingBinder(), completes);
    await expectLater(api.checkPermission(), completes);
  });
}
