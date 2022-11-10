import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'alternate_language_test_plugin_method_channel.dart';

abstract class AlternateLanguageTestPluginPlatform extends PlatformInterface {
  /// Constructs a AlternateLanguageTestPluginPlatform.
  AlternateLanguageTestPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static AlternateLanguageTestPluginPlatform _instance = MethodChannelAlternateLanguageTestPlugin();

  /// The default instance of [AlternateLanguageTestPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelAlternateLanguageTestPlugin].
  static AlternateLanguageTestPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AlternateLanguageTestPluginPlatform] when
  /// they register themselves.
  static set instance(AlternateLanguageTestPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
