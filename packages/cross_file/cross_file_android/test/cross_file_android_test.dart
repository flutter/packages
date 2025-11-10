import 'package:flutter_test/flutter_test.dart';
import 'package:cross_file_android/cross_file_android.dart';
import 'package:cross_file_android/cross_file_android_platform_interface.dart';
import 'package:cross_file_android/cross_file_android_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockCrossFileAndroidPlatform
    with MockPlatformInterfaceMixin
    implements CrossFileAndroidPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final CrossFileAndroidPlatform initialPlatform = CrossFileAndroidPlatform.instance;

  test('$MethodChannelCrossFileAndroid is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelCrossFileAndroid>());
  });

  test('getPlatformVersion', () async {
    CrossFileAndroid crossFileAndroidPlugin = CrossFileAndroid();
    MockCrossFileAndroidPlatform fakePlatform = MockCrossFileAndroidPlatform();
    CrossFileAndroidPlatform.instance = fakePlatform;

    expect(await crossFileAndroidPlugin.getPlatformVersion(), '42');
  });
}
