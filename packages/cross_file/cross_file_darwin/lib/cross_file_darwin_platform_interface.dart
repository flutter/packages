import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'cross_file_darwin_method_channel.dart';

abstract class CrossFileDarwinPlatform extends PlatformInterface {
  /// Constructs a CrossFileDarwinPlatform.
  CrossFileDarwinPlatform() : super(token: _token);

  static final Object _token = Object();

  static CrossFileDarwinPlatform _instance = MethodChannelCrossFileDarwin();

  /// The default instance of [CrossFileDarwinPlatform] to use.
  ///
  /// Defaults to [MethodChannelCrossFileDarwin].
  static CrossFileDarwinPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [CrossFileDarwinPlatform] when
  /// they register themselves.
  static set instance(CrossFileDarwinPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
