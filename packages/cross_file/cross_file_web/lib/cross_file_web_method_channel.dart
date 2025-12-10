import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'cross_file_web_platform_interface.dart';

/// An implementation of [CrossFileWebPlatform] that uses method channels.
class MethodChannelCrossFileWeb extends CrossFileWebPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('cross_file_web');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
