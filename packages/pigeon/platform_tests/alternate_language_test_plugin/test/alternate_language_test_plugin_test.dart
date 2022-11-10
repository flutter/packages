import 'package:flutter_test/flutter_test.dart';
import 'package:alternate_language_test_plugin/alternate_language_test_plugin.dart';
import 'package:alternate_language_test_plugin/alternate_language_test_plugin_platform_interface.dart';
import 'package:alternate_language_test_plugin/alternate_language_test_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAlternateLanguageTestPluginPlatform
    with MockPlatformInterfaceMixin
    implements AlternateLanguageTestPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final AlternateLanguageTestPluginPlatform initialPlatform = AlternateLanguageTestPluginPlatform.instance;

  test('$MethodChannelAlternateLanguageTestPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAlternateLanguageTestPlugin>());
  });

  test('getPlatformVersion', () async {
    AlternateLanguageTestPlugin alternateLanguageTestPlugin = AlternateLanguageTestPlugin();
    MockAlternateLanguageTestPluginPlatform fakePlatform = MockAlternateLanguageTestPluginPlatform();
    AlternateLanguageTestPluginPlatform.instance = fakePlatform;

    expect(await alternateLanguageTestPlugin.getPlatformVersion(), '42');
  });
}
