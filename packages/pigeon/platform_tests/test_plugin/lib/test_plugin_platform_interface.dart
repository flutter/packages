import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'test_plugin_method_channel.dart';

abstract class TestPluginPlatform extends PlatformInterface {
  /// Constructs a TestPluginPlatform.
  TestPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static TestPluginPlatform _instance = MethodChannelTestPlugin();

  /// The default instance of [TestPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelTestPlugin].
  static TestPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [TestPluginPlatform] when
  /// they register themselves.
  static set instance(TestPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
