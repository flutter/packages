import 'package:flutter_test/flutter_test.dart';
import 'package:cross_file_darwin/cross_file_darwin.dart';
import 'package:cross_file_darwin/cross_file_darwin_platform_interface.dart';
import 'package:cross_file_darwin/cross_file_darwin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockCrossFileDarwinPlatform
    with MockPlatformInterfaceMixin
    implements CrossFileDarwinPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final CrossFileDarwinPlatform initialPlatform = CrossFileDarwinPlatform.instance;

  test('$MethodChannelCrossFileDarwin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelCrossFileDarwin>());
  });

  test('getPlatformVersion', () async {
    CrossFileDarwin crossFileDarwinPlugin = CrossFileDarwin();
    MockCrossFileDarwinPlatform fakePlatform = MockCrossFileDarwinPlatform();
    CrossFileDarwinPlatform.instance = fakePlatform;

    expect(await crossFileDarwinPlugin.getPlatformVersion(), '42');
  });
}
