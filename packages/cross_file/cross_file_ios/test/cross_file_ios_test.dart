import 'package:flutter_test/flutter_test.dart';
import 'package:cross_file_ios/cross_file_ios.dart';
import 'package:cross_file_ios/cross_file_ios_platform_interface.dart';
import 'package:cross_file_ios/cross_file_ios_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockCrossFileIosPlatform
    with MockPlatformInterfaceMixin
    implements CrossFileIosPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final CrossFileIosPlatform initialPlatform = CrossFileIosPlatform.instance;

  test('$MethodChannelCrossFileIos is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelCrossFileIos>());
  });

  test('getPlatformVersion', () async {
    CrossFileIos crossFileIosPlugin = CrossFileIos();
    MockCrossFileIosPlatform fakePlatform = MockCrossFileIosPlatform();
    CrossFileIosPlatform.instance = fakePlatform;

    expect(await crossFileIosPlugin.getPlatformVersion(), '42');
  });
}
