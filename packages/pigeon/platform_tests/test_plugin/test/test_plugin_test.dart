import 'package:flutter_test/flutter_test.dart';
import 'package:test_plugin/test_plugin.dart';
import 'package:test_plugin/test_plugin_platform_interface.dart';
import 'package:test_plugin/test_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockTestPluginPlatform
    with MockPlatformInterfaceMixin
    implements TestPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final TestPluginPlatform initialPlatform = TestPluginPlatform.instance;

  test('$MethodChannelTestPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelTestPlugin>());
  });

  test('getPlatformVersion', () async {
    TestPlugin testPlugin = TestPlugin();
    MockTestPluginPlatform fakePlatform = MockTestPluginPlatform();
    TestPluginPlatform.instance = fakePlatform;

    expect(await testPlugin.getPlatformVersion(), '42');
  });
}
