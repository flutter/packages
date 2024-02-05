import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'interactive_media_ads_platform_interface.dart';

/// An implementation of [InteractiveMediaAdsPlatform] that uses method channels.
class MethodChannelInteractiveMediaAds extends InteractiveMediaAdsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('interactive_media_ads');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
