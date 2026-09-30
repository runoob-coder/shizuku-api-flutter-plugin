import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shizuku_api_plugin/shizuku_api_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('shizuku_api');
  final platform = MethodChannelShizukuApi();
  final calls = <MethodCall>[];

  Future<Object?> handleMethodCall(MethodCall methodCall) async {
    calls.add(methodCall);
    switch (methodCall.method) {
      case 'pingBinder':
        return true;
      case 'checkPermission':
        return false;
      case 'requestPermission':
        return true;
      case 'runCommand':
        return 'output';
      default:
        return null;
    }
  }

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, handleMethodCall);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('requestPermission invokes the channel with a request code', () async {
    expect(await platform.requestPermission(), isTrue);
    expect(calls.single.method, 'requestPermission');
    expect(calls.single.arguments, <String, dynamic>{'requestCode': 123});
  });

  test('pingBinder returns the channel result', () async {
    expect(await platform.pingBinder(), isTrue);
    expect(calls.single.method, 'pingBinder');
    expect(calls.single.arguments, isNull);
  });

  test('checkPermission returns the channel result', () async {
    expect(await platform.checkPermission(), isFalse);
    expect(calls.single.method, 'checkPermission');
    expect(calls.single.arguments, isNull);
  });

  test('runCommand passes the command and returns the output', () async {
    expect(await platform.runCommand('wm size'), 'output');
    expect(calls.single.method, 'runCommand');
    expect(calls.single.arguments, <String, dynamic>{'command': 'wm size'});
  });
}
