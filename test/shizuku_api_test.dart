import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shizuku_api_plugin/shizuku_api_method_channel.dart';
import 'package:shizuku_api_plugin/shizuku_api_platform_interface.dart';

class MockShizukuApiPlatform
    with MockPlatformInterfaceMixin
    implements ShizukuApiPlatform {
  @override
  Future<bool?> checkPermission() {
    // TODO: implement checkPermission
    throw UnimplementedError();
  }

  @override
  Future<bool?> pingBinder() {
    // TODO: implement pingBinder
    throw UnimplementedError();
  }

  @override
  Future<bool?> requestPermission() {
    // TODO: implement requestPermission
    throw UnimplementedError();
  }

  @override
  Future<String?> runCommand(String command) {
    // TODO: implement runCommand
    throw UnimplementedError();
  }
}

void main() {
  final ShizukuApiPlatform initialPlatform = ShizukuApiPlatform.instance;

  test('$MethodChannelShizukuApi is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelShizukuApi>());
  });
}
