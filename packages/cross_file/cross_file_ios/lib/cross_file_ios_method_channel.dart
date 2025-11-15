import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'cross_file_ios_platform_interface.dart';

/// An implementation of [CrossFileIosPlatform] that uses method channels.
class MethodChannelCrossFileIos extends CrossFileIosPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('cross_file_ios');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
