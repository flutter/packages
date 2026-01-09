import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'cross_file_darwin_platform_interface.dart';

/// An implementation of [CrossFileDarwinPlatform] that uses method channels.
class MethodChannelCrossFileDarwin extends CrossFileDarwinPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('cross_file_darwin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
