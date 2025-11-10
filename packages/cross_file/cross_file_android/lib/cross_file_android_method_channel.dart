import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'cross_file_android_platform_interface.dart';

/// An implementation of [CrossFileAndroidPlatform] that uses method channels.
class MethodChannelCrossFileAndroid extends CrossFileAndroidPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('cross_file_android');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
