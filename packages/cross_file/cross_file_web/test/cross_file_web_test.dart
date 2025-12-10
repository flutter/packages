import 'package:flutter_test/flutter_test.dart';
import 'package:cross_file_web/cross_file_web.dart';
import 'package:cross_file_web/cross_file_web_platform_interface.dart';
import 'package:cross_file_web/cross_file_web_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockCrossFileWebPlatform
    with MockPlatformInterfaceMixin
    implements CrossFileWebPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final CrossFileWebPlatform initialPlatform = CrossFileWebPlatform.instance;

  test('$MethodChannelCrossFileWeb is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelCrossFileWeb>());
  });

  test('getPlatformVersion', () async {
    CrossFileWeb crossFileWebPlugin = CrossFileWeb();
    MockCrossFileWebPlatform fakePlatform = MockCrossFileWebPlatform();
    CrossFileWebPlatform.instance = fakePlatform;

    expect(await crossFileWebPlugin.getPlatformVersion(), '42');
  });
}
