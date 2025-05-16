import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'camera_linux_method_channel.dart';

abstract class CameraLinuxPlatform extends PlatformInterface {
  /// Constructs a CameraLinuxPlatform.
  CameraLinuxPlatform() : super(token: _token);

  static final Object _token = Object();

  static CameraLinuxPlatform _instance = MethodChannelCameraLinux();

  /// The default instance of [CameraLinuxPlatform] to use.
  ///
  /// Defaults to [MethodChannelCameraLinux].
  static CameraLinuxPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [CameraLinuxPlatform] when
  /// they register themselves.
  static set instance(CameraLinuxPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
