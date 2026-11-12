import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shizuku_api_plugin/shizuku_api.dart';

import 'package:shizuku_api_example/main.dart';

/// A fake plugin that never touches the platform channel, so the demo can be
/// exercised in a pure widget test.
class FakeShizukuApi extends ShizukuApi {
  @override
  Future<bool?> pingBinder() async => true;

  @override
  Future<bool?> checkPermission() async => true;

  @override
  Future<bool?> requestPermission() async => true;

  @override
  Future<String?> runCommand(String command) async => 'output for $command';
}

/// Pumps the demo with a deterministic device locale; the host machine's
/// locale must not leak into the assertions.
Future<void> pumpDemo(
  WidgetTester tester, {
  Locale systemLocale = const Locale('en', 'US'),
}) async {
  // WidgetsApp resolves locales from the platform's locale *list*, not from
  // the single locale getter, so both test values must be overridden.
  tester.platformDispatcher.localeTestValue = systemLocale;
  tester.platformDispatcher.localesTestValue = <Locale>[systemLocale];
  addTearDown(() {
    tester.platformDispatcher.clearLocaleTestValue();
    tester.platformDispatcher.clearLocalesTestValue();
  });
  await tester.pumpWidget(MyApp(api: FakeShizukuApi()));
  await tester.pumpAndSettle();
}

Future<void> selectLanguage(WidgetTester tester, String label) async {
  await tester.tap(find.byKey(const ValueKey('language-dropdown')));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders the demo shell', (WidgetTester tester) async {
    await pumpDemo(tester);

    expect(find.text('Shizuku API Demo'), findsOneWidget);
    expect(find.text('Run command'), findsOneWidget);
    expect(find.text('Run'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('auto-refreshes status on start', (WidgetTester tester) async {
    await pumpDemo(tester);

    expect(find.text('Running'), findsOneWidget);
    expect(find.text('Granted'), findsOneWidget);
  });

  testWidgets('runs a command and shows its output', (
    WidgetTester tester,
  ) async {
    await pumpDemo(tester);

    await tester.enterText(find.byType(TextField), 'pm list packages');
    final runButton = find.text('Run');
    await tester.ensureVisible(runButton);
    await tester.pumpAndSettle();
    await tester.tap(runButton);
    await tester.pumpAndSettle();

    final output = tester.widget<SelectableText>(find.byType(SelectableText));
    expect(output.data, 'output for pm list packages');
  });

  testWidgets('follows the device locale by default', (
    WidgetTester tester,
  ) async {
    await pumpDemo(tester);

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.locale, isNull);
    expect(app.supportedLocales, [const Locale('en'), const Locale('zh')]);
    expect(find.text('Follow system'), findsOneWidget);
  });

  testWidgets('uses a Chinese device locale', (WidgetTester tester) async {
    await pumpDemo(tester, systemLocale: const Locale('zh', 'CN'));

    expect(find.text('Shizuku API 演示'), findsOneWidget);
    expect(find.text('执行命令'), findsOneWidget);
    expect(find.byKey(const ValueKey('language-dropdown')), findsOneWidget);
    expect(find.text('跟随系统'), findsOneWidget);
  });

  testWidgets('switches language from the drop-down and back', (
    WidgetTester tester,
  ) async {
    await pumpDemo(tester);

    await selectLanguage(tester, '简体中文');
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).locale,
      const Locale('zh'),
    );
    expect(find.text('Shizuku API 演示'), findsOneWidget);
    expect(find.text('执行命令'), findsOneWidget);
    expect(find.text('运行'), findsOneWidget);

    await selectLanguage(tester, 'English');
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).locale,
      const Locale('en'),
    );
    expect(find.text('Shizuku API Demo'), findsOneWidget);

    await selectLanguage(tester, 'Follow system');
    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).locale, isNull);
    expect(find.text('Shizuku API Demo'), findsOneWidget);
  });
}
