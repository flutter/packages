import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'cross_file_android_method_channel.dart';

abstract class CrossFileAndroidPlatform extends PlatformInterface {
  /// Constructs a CrossFileAndroidPlatform.
  CrossFileAndroidPlatform() : super(token: _token);

  static final Object _token = Object();

  static CrossFileAndroidPlatform _instance = MethodChannelCrossFileAndroid();

  /// The default instance of [CrossFileAndroidPlatform] to use.
  ///
  /// Defaults to [MethodChannelCrossFileAndroid].
  static CrossFileAndroidPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [CrossFileAndroidPlatform] when
  /// they register themselves.
  static set instance(CrossFileAndroidPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
