import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'file_selector_android_platform_interface.dart';

/// An implementation of [FileSelectorAndroidPlatform] that uses method channels.
class MethodChannelFileSelectorAndroid extends FileSelectorAndroidPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('file_selector_android');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
