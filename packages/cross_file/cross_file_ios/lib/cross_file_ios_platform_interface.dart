import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'cross_file_ios_method_channel.dart';

abstract class CrossFileIosPlatform extends PlatformInterface {
  /// Constructs a CrossFileIosPlatform.
  CrossFileIosPlatform() : super(token: _token);

  static final Object _token = Object();

  static CrossFileIosPlatform _instance = MethodChannelCrossFileIos();

  /// The default instance of [CrossFileIosPlatform] to use.
  ///
  /// Defaults to [MethodChannelCrossFileIos].
  static CrossFileIosPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [CrossFileIosPlatform] when
  /// they register themselves.
  static set instance(CrossFileIosPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
