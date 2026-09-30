import 'package:flutter_test/flutter_test.dart';
import 'package:shizuku_api_plugin/shizuku_api.dart';
import 'package:shizuku_api_plugin/shizuku_api_method_channel.dart';
import 'package:shizuku_api_plugin/shizuku_api_platform_interface.dart';

class MockShizukuApiPlatform extends ShizukuApiPlatform {
  @override
  Future<bool?> requestPermission() async => true;

  @override
  Future<bool?> pingBinder() async => true;

  @override
  Future<bool?> checkPermission() async => true;

  @override
  Future<String?> runCommand(String command) async => 'output: $command';
}

void main() {
  test('$MethodChannelShizukuApi is the default instance', () {
    expect(
      ShizukuApiPlatform.instance,
      isInstanceOf<MethodChannelShizukuApi>(),
    );
  });

  group('ShizukuApi', () {
    late ShizukuApi api;
    late MockShizukuApiPlatform mockPlatform;

    setUp(() {
      mockPlatform = MockShizukuApiPlatform();
      ShizukuApiPlatform.instance = mockPlatform;
      api = ShizukuApi();
    });

    tearDown(() {
      ShizukuApiPlatform.instance = MethodChannelShizukuApi();
    });

    test('requestPermission delegates to the platform', () async {
      expect(await api.requestPermission(), isTrue);
    });

    test('pingBinder delegates to the platform', () async {
      expect(await api.pingBinder(), isTrue);
    });

    test('checkPermission delegates to the platform', () async {
      expect(await api.checkPermission(), isTrue);
    });

    test('runCommand delegates to the platform', () async {
      expect(await api.runCommand('id'), 'output: id');
    });
  });
}
