
import 'alternate_language_test_plugin_platform_interface.dart';

class AlternateLanguageTestPlugin {
  Future<String?> getPlatformVersion() {
    return AlternateLanguageTestPluginPlatform.instance.getPlatformVersion();
  }
}
