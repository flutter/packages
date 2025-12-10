import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'cross_file_web_method_channel.dart';

abstract class CrossFileWebPlatform extends PlatformInterface {
  /// Constructs a CrossFileWebPlatform.
  CrossFileWebPlatform() : super(token: _token);

  static final Object _token = Object();

  static CrossFileWebPlatform _instance = MethodChannelCrossFileWeb();

  /// The default instance of [CrossFileWebPlatform] to use.
  ///
  /// Defaults to [MethodChannelCrossFileWeb].
  static CrossFileWebPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [CrossFileWebPlatform] when
  /// they register themselves.
  static set instance(CrossFileWebPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
