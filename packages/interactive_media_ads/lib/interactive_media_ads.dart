
import 'interactive_media_ads_platform_interface.dart';

class InteractiveMediaAds {
  Future<String?> getPlatformVersion() {
    return InteractiveMediaAdsPlatform.instance.getPlatformVersion();
  }
}
