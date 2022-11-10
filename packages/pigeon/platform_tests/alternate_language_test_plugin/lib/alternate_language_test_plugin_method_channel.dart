import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'alternate_language_test_plugin_platform_interface.dart';

/// An implementation of [AlternateLanguageTestPluginPlatform] that uses method channels.
class MethodChannelAlternateLanguageTestPlugin extends AlternateLanguageTestPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('alternate_language_test_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
