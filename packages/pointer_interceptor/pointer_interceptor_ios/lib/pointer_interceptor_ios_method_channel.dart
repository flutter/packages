import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'pointer_interceptor_ios_platform_interface.dart';

/// An implementation of [PointerInterceptorIosPlatform] that uses method channels.
class MethodChannelPointerInterceptorIos extends PointerInterceptorIosPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('pointer_interceptor_ios');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
