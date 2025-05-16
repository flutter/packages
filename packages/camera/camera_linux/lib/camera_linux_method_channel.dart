import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'camera_linux_platform_interface.dart';

/// An implementation of [CameraLinuxPlatform] that uses method channels.
class MethodChannelCameraLinux extends CameraLinuxPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('camera_linux');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
