import 'package:flutter_test/flutter_test.dart';
import 'package:file_selector_android/file_selector_android.dart';
import 'package:file_selector_android/file_selector_android_platform_interface.dart';
import 'package:file_selector_android/file_selector_android_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFileSelectorAndroidPlatform
    with MockPlatformInterfaceMixin
    implements FileSelectorAndroidPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FileSelectorAndroidPlatform initialPlatform = FileSelectorAndroidPlatform.instance;

  test('$MethodChannelFileSelectorAndroid is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFileSelectorAndroid>());
  });

  test('getPlatformVersion', () async {
    FileSelectorAndroid fileSelectorAndroidPlugin = FileSelectorAndroid();
    MockFileSelectorAndroidPlatform fakePlatform = MockFileSelectorAndroidPlatform();
    FileSelectorAndroidPlatform.instance = fakePlatform;

    expect(await fileSelectorAndroidPlugin.getPlatformVersion(), '42');
  });
}
