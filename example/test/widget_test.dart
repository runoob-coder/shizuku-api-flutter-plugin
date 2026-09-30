import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

void main() {
  testWidgets('renders the demo shell', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(api: FakeShizukuApi()));
    await tester.pumpAndSettle();

    expect(find.text('Shizuku API Demo'), findsOneWidget);
    expect(find.text('Run command'), findsOneWidget);
    expect(find.text('Run'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('auto-refreshes status on start', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(api: FakeShizukuApi()));
    await tester.pumpAndSettle();

    expect(find.text('Running'), findsOneWidget);
    expect(find.text('Granted'), findsOneWidget);
  });

  testWidgets('runs a command and shows its output', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(api: FakeShizukuApi()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'pm list packages');
    final runButton = find.text('Run');
    await tester.ensureVisible(runButton);
    await tester.pumpAndSettle();
    await tester.tap(runButton);
    await tester.pumpAndSettle();

    final output = tester.widget<SelectableText>(find.byType(SelectableText));
    expect(output.data, 'output for pm list packages');
  });
}
